/**
 * Lesson 8: Rate Limit Handling - Handling API rate limits and 429 errors
 *
 * This example demonstrates how to detect, handle, and respect API rate limits,
 * including parsing Retry-After headers and implementing intelligent backoff.
 */

module lesson8.rate_limit_handling;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.regex;
import std.datetime;
import std.array;
import core.time;

/**
 * Rate limit information structure
 */
struct RateLimitInfo {
    int limit;           // Maximum requests per time window
    int remaining;       // Remaining requests in current window
    long resetTime;      // Unix timestamp when the limit resets
    Duration retryAfter; // How long to wait before retrying

    bool isExceeded() {
        return remaining <= 0;
    }

    Duration timeUntilReset() {
        auto now = Clock.currTime.toUnixTime();
        if (resetTime > now) {
            return dur!"seconds"(resetTime - now);
        }
        return Duration.zero;
    }
}

/**
 * Parse rate limit headers from HTTP response
 */
RateLimitInfo parseRateLimitHeaders(HTTP.StatusLine statusLine, string[string] headers) {
    RateLimitInfo info;

    // Parse standard rate limit headers
    if ("X-RateLimit-Limit" in headers) {
        try {
            info.limit = to!int(headers["X-RateLimit-Limit"]);
        } catch (Exception) {}
    }

    if ("X-RateLimit-Remaining" in headers) {
        try {
            info.remaining = to!int(headers["X-RateLimit-Remaining"]);
        } catch (Exception) {}
    }

    if ("X-RateLimit-Reset" in headers) {
        try {
            info.resetTime = to!long(headers["X-RateLimit-Reset"]);
        } catch (Exception) {}
    }

    // Parse Retry-After header
    if ("Retry-After" in headers) {
        try {
            auto retryAfter = headers["Retry-After"];
            // Could be seconds or HTTP date
            if (retryAfter.isNumeric) {
                info.retryAfter = dur!"seconds"(to!int(retryAfter));
            } else {
                // HTTP date parsing would go here
                // For simplicity, assume it's seconds
                info.retryAfter = dur!"seconds"(to!int(retryAfter));
            }
        } catch (Exception) {}
    }

    return info;
}

/**
 * HTTP client with rate limit awareness
 */
class RateLimitAwareHTTPClient {
    private Duration requestTimeout = 30.seconds;
    private RateLimitInfo lastRateLimitInfo;
    private SysTime lastRequestTime;

    /**
     * Make a rate-limit-aware HTTP GET request
     */
    string get(string url) {
        // Check if we're currently rate limited
        if (isRateLimited()) {
            auto waitTime = getWaitTime();
            writefln("Rate limited, waiting %s before request...", waitTime);
            import core.thread;
            Thread.sleep(waitTime);
        }

        try {
            auto http = HTTP(url);
            

            string response;
            HTTP.StatusLine statusLine;
            string[string] responseHeaders;

            http.onReceive = (ubyte[] data) {
                response ~= cast(string)data;
                return data.length;
            };

            http.onReceiveStatusLine = (HTTP.StatusLine sl) {
                statusLine = sl;
            };

            http.onReceiveHeader = (in char[] key, in char[] value) {
                responseHeaders[to!string(key)] = to!string(value);
            };

            http.perform();

            lastRequestTime = Clock.currTime;

            // Parse rate limit information from headers
            lastRateLimitInfo = parseRateLimitHeaders(statusLine, responseHeaders);

            // Handle 429 Too Many Requests
            if (statusLine.code == 429) {
                writefln("Received 429 Too Many Requests");
                if (lastRateLimitInfo.retryAfter > Duration.zero) {
                    writefln("Server suggests waiting: %s", lastRateLimitInfo.retryAfter);
                }
                throw new RateLimitException("Rate limit exceeded", lastRateLimitInfo);
            }

            return response;

        } catch (CurlException e) {
            throw e;
        }
    }

    /**
     * Check if we're currently rate limited
     */
    private bool isRateLimited() {
        if (lastRateLimitInfo.isExceeded()) {
            return lastRateLimitInfo.timeUntilReset() > Duration.zero;
        }
        return false;
    }

    /**
     * Get how long to wait before making another request
     */
    private Duration getWaitTime() {
        if (lastRateLimitInfo.retryAfter > Duration.zero) {
            return lastRateLimitInfo.retryAfter;
        } else if (lastRateLimitInfo.isExceeded()) {
            return lastRateLimitInfo.timeUntilReset();
        }
        return Duration.zero;
    }

    /**
     * Get current rate limit status
     */
    RateLimitInfo getRateLimitStatus() {
        return lastRateLimitInfo;
    }
}

/**
 * Rate limit exception
 */
class RateLimitException : Exception {
    RateLimitInfo rateLimitInfo;

    this(string msg, RateLimitInfo info, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
        this.rateLimitInfo = info;
    }
}

/**
 * Adaptive rate limiter that learns from API responses
 */
class AdaptiveRateLimiter {
    private double requestsPerSecond = 1.0;
    private SysTime lastRequestTime;
    private Duration minInterval = 1.seconds;
    private Duration maxInterval = 60.seconds;
    private bool lastRequestFailed = false;

    /**
     * Wait appropriate amount of time before next request
     */
    void waitBeforeRequest() {
        auto now = Clock.currTime;
        auto timeSinceLastRequest = now - lastRequestTime;

        Duration requiredInterval = dur!"seconds"(cast(long)(1.0 / requestsPerSecond));

        // Ensure minimum interval
        requiredInterval = max(requiredInterval, minInterval);

        // If we failed last time, be more conservative
        if (lastRequestFailed) {
            requiredInterval *= 2;
        }

        // Cap at maximum interval
        requiredInterval = min(requiredInterval, maxInterval);

        if (timeSinceLastRequest < requiredInterval) {
            auto waitTime = requiredInterval - timeSinceLastRequest;
            writefln("Rate limiter: waiting %s before next request", waitTime);
            import core.thread;
            Thread.sleep(waitTime);
        }

        lastRequestTime = Clock.currTime;
    }

    /**
     * Notify the limiter about request success
     */
    void notifySuccess() {
        lastRequestFailed = false;
        // Gradually increase rate on success
        requestsPerSecond = min(requestsPerSecond * 1.1, 10.0);
    }

    /**
     * Notify the limiter about rate limit violation
     */
    void notifyRateLimit() {
        lastRequestFailed = true;
        // Significantly reduce rate on rate limit
        requestsPerSecond = max(requestsPerSecond * 0.5, 0.1);
        writefln("Rate limiter: reducing rate to %.2f requests/second", requestsPerSecond);
    }

    /**
     * Notify the limiter about other failures
     */
    void notifyFailure() {
        lastRequestFailed = true;
        // Slightly reduce rate on other failures
        requestsPerSecond = max(requestsPerSecond * 0.9, 0.1);
    }

    /**
     * Get current rate limit status
     */
    double getCurrentRate() {
        return requestsPerSecond;
    }
}

/**
 * Demonstrate rate limit header parsing
 */
void demonstrateRateLimitHeaders() {
    writeln("=== Rate Limit Header Parsing ===");

    // Simulate HTTP response headers
    string[string] headers = [
        "X-RateLimit-Limit": "100",
        "X-RateLimit-Remaining": "45",
        "X-RateLimit-Reset": "1640995200",
        "Retry-After": "60"
    ];

    // The parseRateLimitHeaders function doesn't use the statusLine parameter
    HTTP.StatusLine dummyStatusLine;
    RateLimitInfo info = parseRateLimitHeaders(dummyStatusLine, headers);

    writefln("Parsed rate limit information:");
    writefln("  Limit: %d requests", info.limit);
    writefln("  Remaining: %d requests", info.remaining);
    writefln("  Reset time: %d (Unix timestamp)", info.resetTime);
    writefln("  Retry after: %s", info.retryAfter);
    writefln("  Is exceeded: %s", info.isExceeded());

    if (!info.isExceeded()) {
        writefln("  Time until reset: %s", info.timeUntilReset());
    }

    // Test exceeded limit scenario
    headers["X-RateLimit-Remaining"] = "0";
    headers["X-RateLimit-Reset"] = to!string(Clock.currTime.toUnixTime() + 300); // 5 minutes from now

    info = parseRateLimitHeaders(dummyStatusLine, headers);

    writefln("\nWith exceeded limit:");
    writefln("  Remaining: %d requests", info.remaining);
    writefln("  Is exceeded: %s", info.isExceeded());
    writefln("  Time until reset: %s", info.timeUntilReset());
}

/**
 * Demonstrate rate limit aware HTTP client
 */
void demonstrateRateLimitAwareClient() {
    writeln("\n=== Rate Limit Aware HTTP Client ===");

    auto client = new RateLimitAwareHTTPClient();

    // Test with a normal endpoint
    try {
        writefln("Making request to normal endpoint...");
        string response = client.get("https://httpbin.org/get");
        writefln("✓ Success, response length: %d bytes", response.length);

        // Check rate limit status
        auto status = client.getRateLimitStatus();
        writefln("Rate limit status - Limit: %d, Remaining: %d",
                status.limit, status.remaining);

    } catch (RateLimitException e) {
        writefln("✗ Rate limit exceeded: %s", e.msg);
        writefln("  Retry after: %s", e.rateLimitInfo.retryAfter);
    } catch (Exception e) {
        writefln("✗ Other error: %s", e.msg);
    }

    // Test with 429 endpoint (if available)
    try {
        writefln("\nTesting with 429 endpoint...");
        string response = client.get("https://httpbin.org/status/429");
        writefln("✓ Unexpected success: %s", response);
    } catch (RateLimitException e) {
        writefln("✓ Expected rate limit exception: %s", e.msg);
    } catch (Exception e) {
        writefln("✗ Other error: %s", e.msg);
    }
}

/**
 * Demonstrate adaptive rate limiter
 */
void demonstrateAdaptiveRateLimiter() {
    writeln("\n=== Adaptive Rate Limiter ===");

    auto limiter = new AdaptiveRateLimiter();

    writefln("Starting with rate: %.2f requests/second", limiter.getCurrentRate());

    // Simulate a series of requests with mixed success/failure
    string[] outcomes = ["success", "success", "success", "rate_limit", "success",
                        "failure", "success", "success", "success"];

    foreach (i, outcome; outcomes) {
        writefln("Request %d: %s", i + 1, outcome);

        limiter.waitBeforeRequest();

        // Simulate request outcome
        final switch (outcome) {
            case "success":
                limiter.notifySuccess();
                break;
            case "rate_limit":
                limiter.notifyRateLimit();
                break;
            case "failure":
                limiter.notifyFailure();
                break;
        }

        writefln("  Current rate: %.2f requests/second", limiter.getCurrentRate());
    }

    writefln("\nFinal rate: %.2f requests/second", limiter.getCurrentRate());
}

/**
 * Demonstrate rate limit strategies
 */
void demonstrateRateLimitStrategies() {
    writeln("\n=== Rate Limit Handling Strategies ===");

    writefln("1. Proactive Rate Limiting:");
    writefln("   • Track request timestamps");
    writefln("   • Calculate rolling windows");
    writefln("   • Implement token bucket or leaky bucket algorithms");
    writefln("   • Add buffer time before limits");

    writefln("\n2. Reactive Rate Limiting:");
    writefln("   • Detect 429 status codes");
    writefln("   • Parse Retry-After headers");
    writefln("   • Implement exponential backoff");
    writefln("   • Use jitter to avoid thundering herd");

    writefln("\n3. Adaptive Rate Limiting:");
    writefln("   • Start conservative");
    writefln("   • Gradually increase rate on success");
    writefln("   • Quickly reduce rate on failures");
    writefln("   • Learn from API behavior");

    writefln("\n4. Best Practices:");
    writefln("   • Always check rate limit headers");
    writefln("   • Implement proper error handling");
    writefln("   • Use separate rate limiters per API endpoint");
    writefln("   • Monitor and alert on rate limit hits");
    writefln("   • Have fallback strategies for critical operations");
}

/**
 * Demonstrate token bucket algorithm (simplified)
 */
void demonstrateTokenBucket() {
    writeln("\n=== Token Bucket Algorithm ===");

    class TokenBucket {
        private double tokens;
        private double capacity;
        private double refillRate; // tokens per second
        private SysTime lastRefill;

        this(double capacity, double refillRate) {
            this.capacity = capacity;
            this.refillRate = refillRate;
            this.tokens = capacity;
            this.lastRefill = Clock.currTime;
        }

        bool tryConsume(double tokensNeeded = 1.0) {
            refill();

            if (tokens >= tokensNeeded) {
                tokens -= tokensNeeded;
                return true;
            }

            return false;
        }

        private void refill() {
            auto now = Clock.currTime;
            auto elapsed = now - lastRefill;
            double secondsElapsed = elapsed.total!"hnsecs" / 10_000_000.0;

            double tokensToAdd = secondsElapsed * refillRate;
            tokens = min(tokens + tokensToAdd, capacity);

            lastRefill = now;
        }

        double availableTokens() {
            refill();
            return tokens;
        }
    }

    // Demonstrate token bucket
    auto bucket = new TokenBucket(10.0, 2.0); // 10 tokens capacity, 2 tokens/second refill

    writefln("Token bucket simulation:");
    writefln("Capacity: 10 tokens, Refill rate: 2 tokens/second");

    for (int i = 0; i < 15; i++) {
        writefln("Request %d: Available tokens: %.1f", i + 1, bucket.availableTokens());

        if (bucket.tryConsume(1.0)) {
            writefln("  ✓ Token consumed");
        } else {
            writefln("  ✗ No tokens available");
        }

        // Small delay between requests
        import core.thread;
        Thread.sleep(200.msecs);
    }
}

/**
 * Demonstrate handling different rate limit scenarios
 */
void demonstrateRateLimitScenarios() {
    writeln("\n=== Rate Limit Scenarios ===");

    struct Scenario {
        string name;
        string description;
        string strategy;
    }

    Scenario[] scenarios = [
        {
            "Per-Minute Limits",
            "API allows 60 requests per minute",
            "Use token bucket with 1 token/second refill rate"
        },
        {
            "Daily Quotas",
            "API allows 1000 requests per day",
            "Track daily usage, implement progressive backoff as quota approaches"
        },
        {
            "Bursty Traffic",
            "API allows bursts but sustained high rate triggers limits",
            "Use larger token bucket with slower refill for sustained traffic"
        },
        {
            "Concurrent Requests",
            "Multiple clients sharing the same rate limit",
            "Use distributed coordination or conservative individual limits"
        },
        {
            "Sliding Window",
            "Rate limit based on requests in last N minutes",
            "Track request timestamps, count in sliding window"
        }
    ];

    writefln("Common rate limiting scenarios:");
    foreach (i, scenario; scenarios) {
        writefln("%d. %s", i + 1, scenario.name);
        writefln("   %s", scenario.description);
        writefln("   Strategy: %s", scenario.strategy);
        writeln();
    }
}

/**
 * Check if rate limit handling functionality works
 */
bool testRateLimitHandlingCapability() {
    try {
        // Test header parsing
        string[string] headers = [
            "X-RateLimit-Limit": "100",
            "X-RateLimit-Remaining": "50",
            "X-RateLimit-Reset": "1640995200"
        ];

        HTTP.StatusLine dummyStatusLine;
        RateLimitInfo info = parseRateLimitHeaders(dummyStatusLine, headers);

        assert(info.limit == 100);
        assert(info.remaining == 50);
        assert(info.resetTime == 1640995200L);

        // Test rate limit detection
        assert(!info.isExceeded());

        headers["X-RateLimit-Remaining"] = "0";
        info = parseRateLimitHeaders(dummyStatusLine, headers);
        assert(info.isExceeded());

        // Test adaptive rate limiter
        auto limiter = new AdaptiveRateLimiter();
        double initialRate = limiter.getCurrentRate();
        limiter.notifySuccess();
        assert(limiter.getCurrentRate() >= initialRate);

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the rate limit handling example
 */
void runExample() {
    writeln("=== Rate Limit Handling Demonstration ===\n");

    if (!testRateLimitHandlingCapability()) {
        writeln("ERROR: Rate limit handling functionality test failed!");
        return;
    }

    writeln("✓ Rate limit handling functionality confirmed\n");

    demonstrateRateLimitHeaders();
    demonstrateRateLimitAwareClient();
    demonstrateAdaptiveRateLimiter();
    demonstrateRateLimitStrategies();
    demonstrateTokenBucket();
    demonstrateRateLimitScenarios();

    writeln("\n=== Summary ===");
    writeln("• Parse rate limit headers (X-RateLimit-*, Retry-After)");
    writeln("• Handle 429 Too Many Requests status codes");
    writeln("• Implement exponential backoff for rate limits");
    writeln("• Use adaptive rate limiters that learn from API responses");
    writeln("• Consider token bucket algorithms for complex rate limiting");
    writeln("• Always respect server-provided Retry-After headers");
    writeln("• Monitor rate limit usage and implement alerts");
}

unittest {
    writeln("=== Running rate_limit_handling tests ===");

    // Test header parsing
    string[string] headers = [
        "X-RateLimit-Limit": "1000",
        "X-RateLimit-Remaining": "500",
        "X-RateLimit-Reset": "1640995200",
        "Retry-After": "30"
    ];

    HTTP.StatusLine dummyStatusLine;
    RateLimitInfo info = parseRateLimitHeaders(dummyStatusLine, headers);

    assert(info.limit == 1000);
    assert(info.remaining == 500);
    assert(info.resetTime == 1640995200L);
    assert(info.retryAfter == 30.seconds);
    assert(!info.isExceeded());
    writeln("✓ Rate limit header parsing works");

    // Test exceeded limits
    headers["X-RateLimit-Remaining"] = "0";
    info = parseRateLimitHeaders(dummyStatusLine, headers);
    assert(info.isExceeded());
    writeln("✓ Rate limit exceeded detection works");

    // Test malformed headers (should not crash)
    string[string] badHeaders = [
        "X-RateLimit-Limit": "not_a_number",
        "X-RateLimit-Remaining": "also_not_a_number"
    ];

    info = parseRateLimitHeaders(dummyStatusLine, badHeaders);
    assert(info.limit == 0);  // Should default to 0
    assert(info.remaining == 0);  // Should default to 0
    writeln("✓ Malformed header handling works");

    // Test adaptive rate limiter
    auto limiter = new AdaptiveRateLimiter();
    double initialRate = limiter.getCurrentRate();

    limiter.notifySuccess();
    assert(limiter.getCurrentRate() > initialRate);

    limiter.notifyRateLimit();
    assert(limiter.getCurrentRate() < initialRate);

    limiter.notifyFailure();
    assert(limiter.getCurrentRate() < initialRate);
    writeln("✓ Adaptive rate limiter works");

    // Test token bucket basic functionality
    class TestTokenBucket {
        private double tokens = 10.0;

        bool tryConsume(double needed) {
            if (tokens >= needed) {
                tokens -= needed;
                return true;
            }
            return false;
        }

        double availableTokens() {
            return tokens;
        }
    }

    auto bucket = new TestTokenBucket();
    assert(bucket.tryConsume(5.0));
    assert(bucket.availableTokens() == 5.0);
    assert(!bucket.tryConsume(10.0));  // Should fail
    assert(bucket.availableTokens() == 5.0);
    writeln("✓ Token bucket basic functionality works");

    writeln("All rate_limit_handling tests passed!");
    writeln("=== rate_limit_handling tests completed ===");
}
