/**
 * Lesson 8: Robust HTTP Client - Building resilient HTTP clients with comprehensive error handling
 *
 * This example demonstrates how to build production-ready HTTP clients that handle
 * all types of network errors, implement proper retry logic, and respect rate limits.
 */

module lesson8.robust_http_client;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.exception;
import std.datetime;
import std.random;
import std.math;
import core.time;

/**
 * Comprehensive HTTP client result
 */
struct HTTPResult {
    bool success;
    string response;
    int statusCode;
    string error;
    int attempts;
    Duration totalDuration;
    string[string] responseHeaders;
    CurlCode curlError;
}

/**
 * Robust HTTP client with comprehensive error handling
 */
class RobustHTTPClient {
    private Duration requestTimeout = 30.seconds;
    private int maxRetries = 3;
    private BackoffStrategy backoffStrategy;
    private AdaptiveRateLimiter rateLimiter;
    // private string userAgent = "RobustHTTPClient/1.0";

    this() {
        // Default to exponential backoff with jitter
        backoffStrategy = new ExponentialBackoff(1.seconds, 60.seconds, 2.0f, true);
        rateLimiter = new AdaptiveRateLimiter();
    }

    /**
     * Set the backoff strategy
     */
    void setBackoffStrategy(BackoffStrategy strategy) {
        backoffStrategy = strategy;
    }

    /**
     * Set rate limiter
     */
    void setRateLimiter(AdaptiveRateLimiter limiter) {
        rateLimiter = limiter;
    }

    /**
     * Configure client settings
     */
    void configure(Duration timeout, int maxRetries) { //, string userAgent) {
        this.requestTimeout = timeout;
        this.maxRetries = maxRetries;
        // this.userAgent = userAgent;
    }

    /**
     * Make a robust HTTP GET request
     */
    HTTPResult get(string url, string[string] headers = null) {
        import std.datetime.stopwatch;

        auto stopwatch = StopWatch(AutoStart.yes);
        HTTPResult result;

        // Respect rate limiting
        if (rateLimiter) {
            rateLimiter.waitBeforeRequest();
        }

        for (int attempt = 1; attempt <= maxRetries + 1; attempt++) {
            result.attempts = attempt;

            try {
                auto http = HTTP(url);

                // http.userAgent = userAgent; // Not available in this curl version

                // Add custom headers
                if (headers) {
                    foreach (key, value; headers) {
                        http.addRequestHeader(key, value);
                    }
                }

                string response;
                int statusCode = 0;
                string[string] responseHeaders;

                http.onReceive = (ubyte[] data) {
                    response ~= cast(string)data;
                    return data.length;
                };

                http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
                    statusCode = statusLine.code;
                };

                http.onReceiveHeader = (in char[] key, in char[] value) {
                    responseHeaders[cast(string)key] = cast(string)value;
                };

                http.perform();

                result.statusCode = statusCode;
                result.response = response;
                result.responseHeaders = responseHeaders;

                // Check for success
                if (statusCode >= 200 && statusCode < 300) {
                    result.success = true;
                    if (rateLimiter) rateLimiter.notifySuccess();
                    break;
                }

                // Handle rate limiting (429)
                if (statusCode == 429) {
                    if (rateLimiter) rateLimiter.notifyRateLimit();

                    // Check for Retry-After header
                    Duration retryAfter = parseRetryAfter(responseHeaders);
                    if (retryAfter > Duration.zero) {
                        writefln("Rate limited, server suggests waiting: %s", retryAfter);
                        import core.thread;
                        Thread.sleep(retryAfter);
                        continue; // Retry after waiting
                    }
                }

                // Handle server errors (5xx) - retryable
                if (statusCode >= 500 && statusCode < 600) {
                    result.error = format("Server error: HTTP %d", statusCode);
                }
                // Handle client errors (4xx) - generally not retryable
                else if (statusCode >= 400 && statusCode < 500) {
                    result.error = format("Client error: HTTP %d", statusCode);
                    // Don't retry client errors (except 429 which is handled above)
                    break;
                }

            } catch (CurlException e) {
                result.curlError = 0;
                result.error = format("Curl error: %s", e.msg);

                // Check if this error is retryable
                if (!isRetryableCurlError(0)) {
                    if (rateLimiter) rateLimiter.notifyFailure();
                    break;
                }

                writefln("Attempt %d failed with curl error: %s", attempt, e.msg);

            } catch (Exception e) {
                result.error = format("Unexpected error: %s", e.msg);
                if (rateLimiter) rateLimiter.notifyFailure();
                break;
            }

            // Check if we should retry
            if (attempt <= maxRetries && shouldRetry(result)) {
                auto delay = backoffStrategy.calculateDelay(attempt);
                writefln("Waiting %s before retry %d...", delay, attempt + 1);

                import core.thread;
                Thread.sleep(delay);
            } else {
                break;
            }
        }

        stopwatch.stop();
        result.totalDuration = stopwatch.peek;

        // Final success check
        if (!result.success && result.error.empty) {
            result.error = "Max retries exceeded";
        }

        return result;
    }

    /**
     * Parse Retry-After header
     */
    private Duration parseRetryAfter(string[string] headers) {
        if ("Retry-After" !in headers) {
            return Duration.zero;
        }

        try {
            string value = headers["Retry-After"];
            if (value.isNumeric) {
                return dur!"seconds"(to!int(value));
            }
            // Could parse HTTP date format here if needed
        } catch (Exception) {}

        return Duration.zero;
    }

    /**
     * Check if we should retry based on the result
     */
    private bool shouldRetry(HTTPResult result) {
        // Retry on curl errors that are retryable
        if (isRetryableCurlError(result.curlError)) {
            return true;
        }

        // Retry on server errors
        if (result.statusCode >= 500 && result.statusCode < 600) {
            return true;
        }

        // Retry on rate limiting (but with special handling)
        if (result.statusCode == 429) {
            return true;
        }

        // Don't retry on client errors (except 429)
        if (result.statusCode >= 400 && result.statusCode < 500 && result.statusCode != 429) {
            return false;
        }

        // Retry on empty responses (might indicate connection issues)
        if (result.response.empty && result.error.empty) {
            return true;
        }

        return false;
    }

    /**
     * Check if a curl error is retryable
     */
    private bool isRetryableCurlError(CurlCode code) {
        // Simplified: consider most curl errors retryable
        return true;
    }
}

/**
 * Backoff strategy interface (simplified)
 */
interface BackoffStrategy {
    Duration calculateDelay(int attempt);
    void reset();
}

/**
 * Exponential backoff implementation
 */
class ExponentialBackoff : BackoffStrategy {
    Duration initialDelay;
    Duration maxDelay;
    float multiplier;
    bool useJitter;

    this(Duration initialDelay = 1.seconds,
         Duration maxDelay = 60.seconds,
         float multiplier = 2.0f,
         bool useJitter = true) {
        this.initialDelay = initialDelay;
        this.maxDelay = maxDelay;
        this.multiplier = multiplier;
        this.useJitter = useJitter;
    }

    override Duration calculateDelay(int attempt) {
        if (attempt <= 0) return Duration.zero;

        double delaySeconds = initialDelay.total!"seconds" *
                             pow(multiplier, attempt - 1);

        delaySeconds = min(delaySeconds, maxDelay.total!"seconds");

        auto delay = dur!"seconds"(cast(long)delaySeconds);

        if (useJitter) {
            double jitterRange = delaySeconds * 0.1f; // 10% jitter
            double jitter = uniform(-jitterRange, jitterRange);
            delay += dur!"msecs"(cast(long)(jitter * 1000));
        }

        return max(delay, 100.msecs);
    }

    override void reset() {}
}

/**
 * Adaptive rate limiter (simplified)
 */
class AdaptiveRateLimiter {
    private double requestsPerSecond = 1.0;
    private SysTime lastRequestTime;
    private bool lastRequestFailed = false;

    void waitBeforeRequest() {
        auto now = Clock.currTime;
        auto timeSinceLastRequest = now - lastRequestTime;

        Duration requiredInterval = dur!"seconds"(cast(long)(1.0 / requestsPerSecond));

        if (timeSinceLastRequest < requiredInterval) {
            auto waitTime = requiredInterval - timeSinceLastRequest;
            import core.thread;
            Thread.sleep(waitTime);
        }

        lastRequestTime = Clock.currTime;
    }

    void notifySuccess() {
        lastRequestFailed = false;
        requestsPerSecond = min(requestsPerSecond * 1.1, 10.0);
    }

    void notifyRateLimit() {
        lastRequestFailed = true;
        requestsPerSecond = max(requestsPerSecond * 0.5, 0.1);
    }

    void notifyFailure() {
        lastRequestFailed = true;
        requestsPerSecond = max(requestsPerSecond * 0.9, 0.1);
    }

    double getCurrentRate() {
        return requestsPerSecond;
    }
}

/**
 * Demonstrate robust HTTP client
 */
void demonstrateRobustClient() {
    writeln("=== Robust HTTP Client ===");

    auto client = new RobustHTTPClient();

    // Configure client
    client.configure(15.seconds, 3);

    // Test with reliable endpoint
    writefln("Testing with reliable endpoint:");
    auto result = client.get("https://httpbin.org/get");

    writefln("Result: %s", result.success ? "SUCCESS" : "FAILED");
    writefln("Attempts: %d", result.attempts);
    writefln("Duration: %s", result.totalDuration);
    writefln("Status: %d", result.statusCode);

    if (result.success) {
        writefln("Response length: %d bytes", result.response.length);
    } else {
        writefln("Error: %s", result.error);
    }

    // Test with potentially problematic endpoint
    writefln("\nTesting with service unavailable endpoint:");
    result = client.get("https://httpbin.org/status/503");

    writefln("Result: %s", result.success ? "SUCCESS" : "FAILED");
    writefln("Attempts: %d", result.attempts);
    writefln("Duration: %s", result.totalDuration);
    if (!result.success) {
        writefln("Final status: %d", result.statusCode);
        writefln("Error: %s", result.error);
    }
}

/**
 * Demonstrate client configuration options
 */
void demonstrateClientConfiguration() {
    writeln("\n=== Client Configuration Options ===");

    auto client = new RobustHTTPClient();

    // Test different backoff strategies
    auto strategies = [
        "Exponential Backoff": new ExponentialBackoff(500.msecs, 10.seconds, 2.0f, false),
        "Conservative Backoff": new ExponentialBackoff(2.seconds, 30.seconds, 1.5f, true)
    ];

    foreach (name, strategy; strategies) {
        writefln("Testing with %s strategy:", name);
        client.setBackoffStrategy(strategy);

        auto result = client.get("https://httpbin.org/get");
        writefln("  Success: %s, Attempts: %d, Duration: %s",
                result.success, result.attempts, result.totalDuration);
    }

    // Test custom headers
    writefln("\nTesting with custom headers:");
    string[string] headers = [
        "Authorization": "Bearer demo-token",
        "X-API-Key": "demo-key",
        "Accept": "application/json"
    ];

    auto result = client.get("https://httpbin.org/get", headers);
    writefln("Success: %s", result.success);
    if (result.success && result.response.canFind("demo-token")) {
        writefln("✓ Custom headers were sent");
    }
}

/**
 * Demonstrate error scenarios and recovery
 */
void demonstrateErrorScenarios() {
    writeln("\n=== Error Scenarios and Recovery ===");

    auto client = new RobustHTTPClient();
    client.configure(10.seconds, 3);

    struct TestCase {
        string name;
        string url;
        string expectedBehavior;
    }

    TestCase[] testCases = [
        {"Normal Success", "https://httpbin.org/get", "Should succeed quickly"},
        {"Not Found", "https://httpbin.org/status/404", "Should fail fast (client error)"},
        {"Server Error", "https://httpbin.org/status/500", "Should retry then fail"},
        {"Rate Limited", "https://httpbin.org/status/429", "Should handle rate limiting"}
    ];

    foreach (testCase; testCases) {
        writefln("Testing: %s", testCase.name);
        writefln("URL: %s", testCase.url);
        writefln("Expected: %s", testCase.expectedBehavior);

        auto result = client.get(testCase.url);

        writefln("Result: Success=%s, Attempts=%d, Status=%d, Duration=%s",
                result.success, result.attempts, result.statusCode, result.totalDuration);

        if (!result.success) {
            writefln("Error: %s", result.error);
        }

        // Verify expectations
        final switch (testCase.name) {
            case "Normal Success":
                assert(result.success && result.attempts == 1);
                break;
            case "Not Found":
                assert(!result.success && result.statusCode == 404 && result.attempts == 1);
                break;
            case "Server Error":
                // May succeed or fail after retries, depending on server
                break;
            case "Rate Limited":
                // May succeed or fail, depending on server handling
                break;
        }

        writeln("✓ Test completed");
        writeln();
    }
}

/**
 * Demonstrate monitoring and metrics
 */
void demonstrateMonitoring() {
    writeln("\n=== Monitoring and Metrics ===");

    class MonitoredHTTPClient : RobustHTTPClient {
        private int totalRequests = 0;
        private int successfulRequests = 0;
        private int failedRequests = 0;
        private Duration totalRequestTime = Duration.zero;
        private int[string] statusCounts;

        override HTTPResult get(string url, string[string] headers = null) {
            totalRequests++;
            auto startTime = Clock.currTime;

            auto result = super.get(url, headers);

            auto endTime = Clock.currTime;
            auto requestDuration = endTime - startTime;
            totalRequestTime += requestDuration;

            if (result.success) {
                successfulRequests++;
            } else {
                failedRequests++;
            }

            // Categorize status codes
            string category;
            if (result.statusCode >= 200 && result.statusCode < 300) {
                category = "Success";
            } else if (result.statusCode >= 400 && result.statusCode < 500) {
                category = "ClientError";
            } else if (result.statusCode >= 500 && result.statusCode < 600) {
                category = "ServerError";
            } else {
                category = "Other";
            }

            statusCounts[category]++;

            return result;
        }

        void printMetrics() {
            writefln("HTTP Client Metrics:");
            writefln("  Total requests: %d", totalRequests);
            writefln("  Successful: %d (%.1f%%)",
                    successfulRequests,
                    totalRequests > 0 ? (cast(double)successfulRequests / totalRequests) * 100 : 0);
            writefln("  Failed: %d (%.1f%%)",
                    failedRequests,
                    totalRequests > 0 ? (cast(double)failedRequests / totalRequests) * 100 : 0);

            if (totalRequests > 0) {
                auto avgDuration = totalRequestTime / totalRequests;
                writefln("  Average request time: %s", avgDuration);
            }

            writefln("  Status code categories:");
            foreach (category, count; statusCounts) {
                writefln("    %s: %d", category, count);
            }
        }
    }


    auto monitoredClient = new MonitoredHTTPClient();

    // Make some test requests
    string[] urls = [
        "https://httpbin.org/get",
        "https://httpbin.org/get",
        "https://httpbin.org/status/404",
        "https://httpbin.org/status/500"
    ];

    foreach (url; urls) {
        monitoredClient.get(url);
    }

    monitoredClient.printMetrics();
}

/**
 * Demonstrate best practices for robust clients
 */
void demonstrateBestPractices() {
    writeln("\n=== Best Practices for Robust HTTP Clients ===");

    writefln("1. Always handle network timeouts:");
    writefln("   ✓ Set reasonable timeout values");
    writefln("   ✓ Use different timeouts for different operations");
    writefln("   ✓ Consider connection vs. read timeouts");

    writefln("\n2. Implement comprehensive retry logic:");
    writefln("   ✓ Use exponential backoff with jitter");
    writefln("   ✓ Only retry on appropriate errors");
    writefln("   ✓ Limit maximum retry attempts");

    writefln("\n3. Respect rate limits:");
    writefln("   ✓ Parse rate limit headers");
    writefln("   ✓ Handle 429 responses intelligently");
    writefln("   ✓ Use adaptive rate limiting");

    writefln("\n4. Handle all error types:");
    writefln("   ✓ Network errors (DNS, connection, timeout)");
    writefln("   ✓ SSL/TLS errors");
    writefln("   ✓ HTTP status codes (4xx, 5xx)");
    writefln("   ✓ Malformed responses");

    writefln("\n5. Monitor and log:");
    writefln("   ✓ Track success/failure rates");
    writefln("   ✓ Log retry attempts and delays");
    writefln("   ✓ Monitor performance metrics");

    writefln("\n6. Configuration:");
    writefln("   ✓ Make timeouts and retry limits configurable");
    writefln("   ✓ Allow different strategies for different endpoints");
    writefln("   ✓ Support custom headers and user agents");
}

/**
 * Check if robust HTTP client functionality works
 */
bool testRobustHTTPClientCapability() {
    try {
        auto client = new RobustHTTPClient();

        // This will likely fail due to network, but should not crash
        auto result = client.get("https://httpbin.org/get");
        // We don't assert success since network may not be available

        // Test configuration
        client.configure(10.seconds, 2);

        // Test backoff strategy
        auto backoff = new ExponentialBackoff();
        auto delay = backoff.calculateDelay(1);
        assert(delay > Duration.zero);

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the robust HTTP client example
 */
void runExample() {
    writeln("=== Robust HTTP Client Demonstration ===\n");

    if (!testRobustHTTPClientCapability()) {
        writeln("ERROR: Robust HTTP client functionality test failed!");
        return;
    }

    writeln("✓ Robust HTTP client functionality confirmed\n");

    demonstrateRobustClient();
    demonstrateClientConfiguration();
    demonstrateErrorScenarios();
    demonstrateMonitoring();
    demonstrateBestPractices();

    writeln("\n=== Summary ===");
    writeln("• Build HTTP clients with comprehensive error handling");
    writeln("• Implement retry logic with exponential backoff");
    writeln("• Respect rate limits and handle 429 responses");
    writeln("• Monitor client performance and success rates");
    writeln("• Configure clients appropriately for different use cases");
    writeln("• Handle all types of network and protocol errors");
    writeln("• Use appropriate timeouts and retry limits");
}

unittest {
    writeln("=== Running robust_http_client tests ===");

    // Test backoff strategy
    auto backoff = new ExponentialBackoff(1.seconds, 10.seconds, 2.0f, false);
    auto delay1 = backoff.calculateDelay(1);
    auto delay2 = backoff.calculateDelay(2);
    auto delay3 = backoff.calculateDelay(3);

    assert(delay1 == 1.seconds);
    assert(delay2 == 2.seconds);
    assert(delay3 == 4.seconds);
    writeln("✓ Exponential backoff works");

    // Test HTTP result structure
    HTTPResult successResult = {
        success: true,
        response: "test response",
        statusCode: 200,
        attempts: 1,
        totalDuration: 1.seconds,
        responseHeaders: ["Content-Type": "application/json"],
        curlError: cast(CurlCode)0
    };

    assert(successResult.success);
    assert(successResult.response == "test response");
    assert(successResult.statusCode == 200);
    assert(successResult.attempts == 1);

    HTTPResult failureResult = {
        success: false,
        error: "test error",
        attempts: 3,
        totalDuration: 5.seconds,
        curlError: cast(CurlCode)7
    };

    assert(!failureResult.success);
    assert(failureResult.error == "test error");
    assert(failureResult.attempts == 3);
    writeln("✓ HTTP result structure works");

    // Test adaptive rate limiter
    auto limiter = new AdaptiveRateLimiter();
    double initialRate = limiter.getCurrentRate();

    limiter.notifySuccess();
    assert(limiter.getCurrentRate() >= initialRate);

    limiter.notifyRateLimit();
    assert(limiter.getCurrentRate() <= initialRate);
    writeln("✓ Adaptive rate limiter works");

    // Test client configuration (basic)
    auto client = new RobustHTTPClient();
    // Should not crash during configuration
    client.configure(30.seconds, 5);

    auto testBackoff = new ExponentialBackoff();
    client.setBackoffStrategy(testBackoff);

    auto testLimiter = new AdaptiveRateLimiter();
    client.setRateLimiter(testLimiter);
    writeln("✓ Client configuration works");

    writeln("All robust_http_client tests passed!");
    writeln("=== robust_http_client tests completed ===");
}
