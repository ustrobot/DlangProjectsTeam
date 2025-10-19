/**
 * Lesson 8: Retry Logic - Implementing robust retry mechanisms for HTTP requests
 *
 * This example demonstrates how to implement retry logic with exponential backoff,
 * jitter, and intelligent error handling for network requests.
 */

module lesson8.retry_logic;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.random;
import std.math;
import core.time;

/**
 * Retry configuration structure
 */
struct RetryConfig {
    int maxRetries = 3;
    Duration initialDelay = 1.seconds;
    Duration maxDelay = 30.seconds;
    float backoffMultiplier = 2.0f;
    bool useJitter = true;
    float jitterFactor = 0.1f;

    /**
     * Calculate delay for a given attempt number
     */
    Duration calculateDelay(int attempt) {
        if (attempt <= 0) return Duration.zero;

        // Exponential backoff: delay = initialDelay * (backoffMultiplier ^ (attempt - 1))
        double delaySeconds = initialDelay.total!"seconds" *
                             pow(backoffMultiplier, attempt - 1);

        // Cap at maxDelay
        delaySeconds = min(delaySeconds, maxDelay.total!"seconds");

        auto delay = dur!"seconds"(cast(long)delaySeconds);

        // Add jitter if enabled
        if (useJitter) {
            double jitterRange = delaySeconds * jitterFactor;
            double jitter = uniform(-jitterRange, jitterRange);
            delay += dur!"msecs"(cast(long)(jitter * 1000));
        }

        return max(delay, 100.msecs);  // Minimum 100ms delay
    }
}

/**
 * Result of a retry operation
 */
struct RetryResult(T) {
    bool success;
    T value;
    string errorMessage;
    int attempts;
    Duration totalDuration;

    static RetryResult!T ok(T val, int attempts, Duration duration) {
        return RetryResult!T(true, val, "", attempts, duration);
    }

    static RetryResult!T error(string err, int attempts, Duration duration) {
        return RetryResult!T(false, T.init, err, attempts, duration);
    }
}

/**
 * Check if an error is retryable
 */
bool isRetryableError(CurlCode code) {
    // CURLE_OK (0) is not an error, so not retryable
    // CURLE_COULDNT_RESOLVE_HOST (6) is typically not retryable (DNS issues)
    // Other errors are considered retryable for demo purposes
    if (code == 0) return false; // CURLE_OK
    if (code == 6) return false; // CURLE_COULDNT_RESOLVE_HOST
    return true; // Other errors are retryable
}

/**
 * Check if HTTP status code is retryable
 */
bool isRetryableHTTPStatus(int statusCode) {
    // Retry on server errors (5xx) and specific client errors
    return (statusCode >= 500 && statusCode < 600) ||  // Server errors
           statusCode == 429 ||  // Too Many Requests
           statusCode == 408 ||  // Request Timeout
           statusCode == 503;    // Service Unavailable
}

/**
 * HTTP request with retry logic
 */
RetryResult!string httpGetWithRetry(string url, RetryConfig config = RetryConfig.init) {
    import std.datetime.stopwatch;

    auto stopwatch = StopWatch(AutoStart.yes);

    for (int attempt = 1; attempt <= config.maxRetries + 1; attempt++) {
        try {
            auto http = HTTP(url);
              // 10 second timeout

            string response;
            int statusCode = 0;

            http.onReceive = (ubyte[] data) {
                response ~= cast(string)data;
                return data.length;
            };

            http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
                statusCode = statusLine.code;
            };

            http.perform();

            // Check if we got a successful response
            if (statusCode >= 200 && statusCode < 300) {
                stopwatch.stop();
                return RetryResult!string.ok(response, attempt, stopwatch.peek);
            }

            // Check if this is a retryable error
            if (isRetryableHTTPStatus(statusCode) && attempt <= config.maxRetries) {
                writefln("  Attempt %d failed with HTTP %d, retrying...", attempt, statusCode);
            } else {
                stopwatch.stop();
                return RetryResult!string.error(
                    format("HTTP %d: %s", statusCode, response), attempt, stopwatch.peek);
            }

        } catch (CurlException e) {
            // Check if this curl error is retryable
            if (isRetryableError(0) && attempt <= config.maxRetries) {
                writefln("  Attempt %d failed with curl error, retrying: %s", attempt, e.msg);
            } else {
                stopwatch.stop();
                return RetryResult!string.error(
                    format("Curl error: %s", e.msg), attempt, stopwatch.peek);
            }

        } catch (Exception e) {
            if (attempt <= config.maxRetries) {
                writefln("  Attempt %d failed with error, retrying: %s", attempt, e.msg);
            } else {
                stopwatch.stop();
                return RetryResult!string.error(
                    format("Error: %s", e.msg), attempt, stopwatch.peek);
            }
        }

        // Wait before retrying
        if (attempt <= config.maxRetries) {
            auto delay = config.calculateDelay(attempt);
            writefln("  Waiting %s before retry %d...", delay, attempt + 1);
            import core.thread;
            Thread.sleep(delay);
        }
    }

    stopwatch.stop();
    return RetryResult!string.error("Max retries exceeded", config.maxRetries + 1, stopwatch.peek);
}

/**
 * Demonstrate basic retry logic
 */
void demonstrateBasicRetry() {
    writeln("=== Basic Retry Logic ===");

    // Test with a reliable endpoint
    writefln("Testing with reliable endpoint:");
    string reliableUrl = "https://httpbin.org/get";
    auto result = httpGetWithRetry(reliableUrl);

    if (result.success) {
        writefln("✓ Success on attempt %d in %s", result.attempts, result.totalDuration);
        writefln("Response length: %d bytes", result.value.length);
    } else {
        writefln("✗ Failed after %d attempts: %s", result.attempts, result.errorMessage);
    }

    writeln();

    // Test with an endpoint that may fail
    writefln("Testing with potentially unreliable endpoint:");
    string unreliableUrl = "https://httpbin.org/status/503";  // Service Unavailable
    result = httpGetWithRetry(unreliableUrl);

    if (result.success) {
        writefln("✓ Success on attempt %d in %s", result.attempts, result.totalDuration);
    } else {
        writefln("✗ Failed after %d attempts: %s", result.attempts, result.errorMessage);
    }
}

/**
 * Demonstrate exponential backoff
 */
void demonstrateExponentialBackoff() {
    writeln("\n=== Exponential Backoff ===");

    RetryConfig config = RetryConfig();
    config.maxRetries = 5;
    config.initialDelay = 500.msecs;
    config.backoffMultiplier = 2.0f;
    config.useJitter = false;  // Disable jitter for predictable output

    writefln("Backoff delays for %d retries:", config.maxRetries);
    for (int attempt = 1; attempt <= config.maxRetries; attempt++) {
        auto delay = config.calculateDelay(attempt);
        writefln("  Attempt %d: %s", attempt, delay);
    }

    // Show the exponential growth
    writefln("\nExponential growth demonstration:");
    config.initialDelay = 1.seconds;
    for (int attempt = 1; attempt <= 6; attempt++) {
        auto delay = config.calculateDelay(attempt);
        double multiplier = pow(config.backoffMultiplier, attempt - 1);
        writefln("  Attempt %d: %s (multiplier: %.1f)",
                attempt, delay, multiplier);
    }
}

/**
 * Demonstrate jitter
 */
void demonstrateJitter() {
    writeln("\n=== Jitter in Retry Delays ===");

    RetryConfig config = RetryConfig();
    config.maxRetries = 3;
    config.initialDelay = 1.seconds;
    config.backoffMultiplier = 2.0f;
    config.useJitter = true;
    config.jitterFactor = 0.2f;  // 20% jitter

    writefln("Retry delays with jitter (multiple samples):");

    // Generate multiple samples to show jitter variation
    for (int sample = 1; sample <= 5; sample++) {
        writefln("Sample %d:", sample);
        for (int attempt = 1; attempt <= config.maxRetries; attempt++) {
            auto delay = config.calculateDelay(attempt);
            writefln("  Attempt %d: %s", attempt, delay);
        }
        writeln();
    }

    writefln("Jitter helps prevent thundering herd problems by randomizing delays.");
}

/**
 * Demonstrate different retry strategies
 */
void demonstrateRetryStrategies() {
    writeln("\n=== Different Retry Strategies ===");

    // Strategy 1: Aggressive retries for quick failures
    RetryConfig aggressive = RetryConfig();
    aggressive.maxRetries = 5;
    aggressive.initialDelay = 100.msecs;
    aggressive.backoffMultiplier = 1.5f;

    // Strategy 2: Conservative retries for expensive operations
    RetryConfig conservative = RetryConfig();
    conservative.maxRetries = 3;
    conservative.initialDelay = 2.seconds;
    conservative.maxDelay = 10.seconds;
    conservative.backoffMultiplier = 2.0f;

    // Strategy 3: Fast retries with jitter
    RetryConfig fastJitter = RetryConfig();
    fastJitter.maxRetries = 4;
    fastJitter.initialDelay = 500.msecs;
    fastJitter.backoffMultiplier = 1.8f;
    fastJitter.useJitter = true;
    fastJitter.jitterFactor = 0.3f;

    RetryConfig[] strategies = [aggressive, conservative, fastJitter];
    string[] names = ["Aggressive", "Conservative", "Fast with Jitter"];

    foreach (i, config; strategies) {
        writefln("%s strategy delays:", names[i]);
        for (int attempt = 1; attempt <= config.maxRetries; attempt++) {
            auto delay = config.calculateDelay(attempt);
            writefln("  Attempt %d: %s", attempt, delay);
        }
        writeln();
    }
}

/**
 * Demonstrate rate limit handling
 */
void demonstrateRateLimitHandling() {
    writeln("\n=== Rate Limit Handling (429 Errors) ===");

    // Test with an endpoint that returns 429 (if available)
    // For demo purposes, we'll simulate this with httpbin's status endpoint

    string rateLimitUrl = "https://httpbin.org/status/429";

    RetryConfig rateLimitConfig = RetryConfig();
    rateLimitConfig.maxRetries = 3;
    rateLimitConfig.initialDelay = 2.seconds;  // Longer delay for rate limits
    rateLimitConfig.backoffMultiplier = 2.0f;

    writefln("Testing rate limit handling with 429 responses:");
    auto result = httpGetWithRetry(rateLimitUrl, rateLimitConfig);

    if (result.success) {
        writefln("✓ Eventually succeeded on attempt %d", result.attempts);
    } else {
        writefln("✗ Failed after %d attempts: %s", result.attempts, result.errorMessage);
        writefln("  Total time: %s", result.totalDuration);
    }

    writefln("\nRate limit best practices:");
    writefln("• Use longer initial delays for 429 errors");
    writefln("• Implement exponential backoff");
    writefln("• Check for Retry-After headers (not implemented in this demo)");
    writefln("• Consider using different endpoints or API keys");
}

/**
 * Demonstrate circuit breaker pattern (simplified)
 */
void demonstrateCircuitBreaker() {
    writeln("\n=== Circuit Breaker Pattern (Simplified) ===");

    // Simple circuit breaker state
    enum CircuitState { Closed, Open, HalfOpen }
    CircuitState state = CircuitState.Closed;
    int failureCount = 0;
    int successCount = 0;
    const int failureThreshold = 3;
    const int successThreshold = 2;

    writefln("Simulating circuit breaker behavior:");

    // Simulate a series of requests
    string[] simulatedResults = ["success", "success", "failure", "failure", "failure",
                                "failure", "success", "success"];

    foreach (i, result; simulatedResults) {
        writefln("Request %d: %s", i + 1, result);

        final switch (state) {
            case CircuitState.Closed:
                if (result == "failure") {
                    failureCount++;
                    if (failureCount >= failureThreshold) {
                        state = CircuitState.Open;
                        writefln("  → Circuit opened (too many failures)");
                    }
                } else {
                    failureCount = 0;  // Reset on success
                }
                break;

            case CircuitState.Open:
                writefln("  → Circuit is open, request blocked");
                // In a real implementation, we'd wait for a timeout before going to HalfOpen
                state = CircuitState.HalfOpen;
                successCount = 0;
                break;

            case CircuitState.HalfOpen:
                if (result == "success") {
                    successCount++;
                    if (successCount >= successThreshold) {
                        state = CircuitState.Closed;
                        writefln("  → Circuit closed (service recovered)");
                        failureCount = 0;
                    }
                } else {
                    state = CircuitState.Open;
                    writefln("  → Circuit re-opened (still failing)");
                    successCount = 0;
                }
                break;
        }

        writefln("  Circuit state: %s", state);
    }

    writefln("\nCircuit breaker protects against cascading failures.");
}

/**
 * Check if retry logic functionality works
 */
bool testRetryLogicCapability() {
    try {
        // Test retry configuration
        RetryConfig config = RetryConfig();
        auto delay = config.calculateDelay(1);
        assert(delay > Duration.zero);

        // Test with a simple HTTP request (may fail, that's OK)
        auto result = httpGetWithRetry("https://httpbin.org/get", config);
        // We don't assert success since network may not be available

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the retry logic example
 */
void runExample() {
    writeln("=== Retry Logic Demonstration ===\n");

    if (!testRetryLogicCapability()) {
        writeln("ERROR: Retry logic functionality test failed!");
        return;
    }

    writeln("✓ Retry logic functionality confirmed\n");

    demonstrateBasicRetry();
    demonstrateExponentialBackoff();
    demonstrateJitter();
    demonstrateRetryStrategies();
    demonstrateRateLimitHandling();
    demonstrateCircuitBreaker();

    writeln("\n=== Summary ===");
    writeln("• Implement retry logic for transient network failures");
    writeln("• Use exponential backoff to avoid overwhelming servers");
    writeln("• Add jitter to prevent thundering herd problems");
    writeln("• Different strategies for different types of operations");
    writeln("• Handle rate limits (429) with appropriate delays");
    writeln("• Consider circuit breakers for protecting against cascading failures");
    writeln("• Always limit maximum retry attempts and total timeout");
}

unittest {
    writeln("=== Running retry_logic tests ===");

    // Test retry configuration
    RetryConfig config = RetryConfig();
    assert(config.maxRetries == 3);
    assert(config.initialDelay == 1.seconds);
    assert(config.backoffMultiplier == 2.0f);

    // Test delay calculation
    auto delay1 = config.calculateDelay(1);
    auto delay2 = config.calculateDelay(2);
    auto delay3 = config.calculateDelay(3);

    assert(delay1 >= 100.msecs && delay1 <= 2.seconds);  // Reasonable delay range
    assert(delay2 >= 100.msecs && delay2 <= 10.seconds);  // Should generally increase
    assert(delay3 >= 100.msecs && delay3 <= 30.seconds);  // Should generally increase further
    writeln("✓ Delay calculation works");

    // Test jitter (basic check that it's applied)
    config.useJitter = true;
    // Hard to test randomness deterministically, just ensure it doesn't crash
    auto jitterDelay = config.calculateDelay(1);
    assert(jitterDelay > Duration.zero);
    writeln("✓ Jitter application works");

    // Test error classification
    assert(isRetryableError(cast(CurlCode)7));  // CURLE_COULDNT_CONNECT
    assert(isRetryableError(cast(CurlCode)28)); // CURLE_OPERATION_TIMEDOUT
    assert(!isRetryableError(cast(CurlCode)0)); // CURLE_OK
    assert(!isRetryableError(cast(CurlCode)6)); // CURLE_COULDNT_RESOLVE_HOST (not retryable in our implementation)
    writeln("✓ Error classification works");

    assert(isRetryableHTTPStatus(500));
    assert(isRetryableHTTPStatus(429));
    assert(isRetryableHTTPStatus(503));
    assert(!isRetryableHTTPStatus(400));
    assert(!isRetryableHTTPStatus(404));
    writeln("✓ HTTP status classification works");

    // Test retry result structure
    auto successResult = RetryResult!string.ok("response", 2, 5.seconds);
    assert(successResult.success);
    assert(successResult.value == "response");
    assert(successResult.attempts == 2);
    assert(successResult.totalDuration == 5.seconds);

    auto errorResult = RetryResult!string.error("failed", 3, 10.seconds);
    assert(!errorResult.success);
    assert(errorResult.errorMessage == "failed");
    assert(errorResult.attempts == 3);
    writeln("✓ Retry result structure works");

    writeln("All retry_logic tests passed!");
    writeln("=== retry_logic tests completed ===");
}
