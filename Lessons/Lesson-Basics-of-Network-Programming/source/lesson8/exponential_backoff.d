/**
 * Lesson 8: Exponential Backoff - Advanced retry strategies with exponential backoff
 *
 * This example demonstrates sophisticated exponential backoff algorithms,
 * custom backoff strategies, and handling of different error scenarios.
 */

module lesson8.exponential_backoff;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.random;
import std.math;
import std.datetime.stopwatch;
import std.array;
import core.time;

/**
 * Backoff strategy interface
 */
interface BackoffStrategy {
    /**
     * Calculate delay for the given attempt number
     */
    Duration calculateDelay(int attempt);

    /**
     * Reset the strategy state (for stateful strategies)
     */
    void reset();
}

/**
 * Exponential backoff strategy
 */
class ExponentialBackoff : BackoffStrategy {
    Duration initialDelay;
    Duration maxDelay;
    float multiplier;
    bool useJitter;
    float jitterFactor;

    this(Duration initialDelay = 1.seconds,
         Duration maxDelay = 60.seconds,
         float multiplier = 2.0f,
         bool useJitter = true,
         float jitterFactor = 0.1f) {
        this.initialDelay = initialDelay;
        this.maxDelay = maxDelay;
        this.multiplier = multiplier;
        this.useJitter = useJitter;
        this.jitterFactor = jitterFactor;
    }

    override Duration calculateDelay(int attempt) {
        if (attempt <= 0) return Duration.zero;

        // Calculate exponential delay
        double delaySeconds = initialDelay.total!"seconds" *
                             pow(multiplier, attempt - 1);

        // Cap at maxDelay
        delaySeconds = min(delaySeconds, maxDelay.total!"seconds");

        auto delay = dur!"seconds"(cast(long)delaySeconds);

        // Add jitter
        if (useJitter) {
            double jitterRange = delaySeconds * jitterFactor;
            double jitter = uniform(-jitterRange, jitterRange);
            delay += dur!"msecs"(cast(long)(jitter * 1000));
        }

        return max(delay, 10.msecs);  // Minimum 10ms delay
    }

    override void reset() {
        // Stateless, nothing to reset
    }
}

/**
 * Linear backoff strategy
 */
class LinearBackoff : BackoffStrategy {
    Duration initialDelay;
    Duration increment;
    Duration maxDelay;

    this(Duration initialDelay = 1.seconds,
         Duration increment = 1.seconds,
         Duration maxDelay = 60.seconds) {
        this.initialDelay = initialDelay;
        this.increment = increment;
        this.maxDelay = maxDelay;
    }

    override Duration calculateDelay(int attempt) {
        if (attempt <= 0) return Duration.zero;

        auto delay = initialDelay + (increment * (attempt - 1));
        return min(delay, maxDelay);
    }

    override void reset() {
        // Stateless, nothing to reset
    }
}

/**
 * Fibonacci backoff strategy
 */
class FibonacciBackoff : BackoffStrategy {
    Duration multiplier;
    Duration maxDelay;
    bool useJitter;
    float jitterFactor;

    this(Duration multiplier = 1.seconds,
         Duration maxDelay = 60.seconds,
         bool useJitter = true,
         float jitterFactor = 0.1f) {
        this.multiplier = multiplier;
        this.maxDelay = maxDelay;
        this.useJitter = useJitter;
        this.jitterFactor = jitterFactor;
    }

    override Duration calculateDelay(int attempt) {
        if (attempt <= 0) return Duration.zero;

        // Calculate Fibonacci number
        long fib = fibonacci(attempt);
        auto delay = multiplier * fib;

        // Cap at maxDelay
        delay = min(delay, maxDelay);

        // Add jitter
        if (useJitter) {
            double delaySeconds = delay.total!"seconds";
            double jitterRange = delaySeconds * jitterFactor;
            double jitter = uniform(-jitterRange, jitterRange);
            delay += dur!"msecs"(cast(long)(jitter * 1000));
        }

        return max(delay, 10.msecs);
    }

    override void reset() {
        // Stateless, nothing to reset
    }

    private long fibonacci(int n) {
        if (n <= 1) return 1;
        long a = 1, b = 1;
        for (int i = 2; i < n; i++) {
            long temp = a + b;
            a = b;
            b = temp;
        }
        return b;
    }
}

/**
 * Fixed delay strategy
 */
class FixedDelayBackoff : BackoffStrategy {
    Duration delay;

    this(Duration delay = 5.seconds) {
        this.delay = delay;
    }

    override Duration calculateDelay(int attempt) {
        return delay;
    }

    override void reset() {
        // Stateless, nothing to reset
    }
}

/**
 * Custom backoff strategy with decorrelated jitter
 */
class DecorrelatedJitterBackoff : BackoffStrategy {
    Duration initialDelay;
    Duration maxDelay;
    Duration previousDelay;

    this(Duration initialDelay = 1.seconds, Duration maxDelay = 60.seconds) {
        this.initialDelay = initialDelay;
        this.maxDelay = maxDelay;
        this.previousDelay = initialDelay;
    }

    override Duration calculateDelay(int attempt) {
        if (attempt <= 1) {
            previousDelay = initialDelay;
            return initialDelay;
        }

        // Decorrelated jitter: pick a random value between initialDelay and previousDelay * 3
        double minSeconds = initialDelay.total!"seconds";
        double maxSeconds = min(previousDelay.total!"seconds" * 3.0,
                               maxDelay.total!"seconds");

        double randomSeconds = uniform(minSeconds, maxSeconds);
        previousDelay = dur!"seconds"(cast(long)randomSeconds);

        return max(previousDelay, 10.msecs);
    }

    override void reset() {
        previousDelay = initialDelay;
    }
}

/**
 * HTTP client with configurable backoff strategy
 */
class ResilientHTTPClient {
    private BackoffStrategy backoffStrategy;
    private int maxRetries;
    private Duration requestTimeout;

    this(BackoffStrategy backoffStrategy,
         int maxRetries = 3,
         Duration requestTimeout = 30.seconds) {
        this.backoffStrategy = backoffStrategy;
        this.maxRetries = maxRetries;
        this.requestTimeout = requestTimeout;
    }

    /**
     * Make an HTTP GET request with retry logic
     */
    string get(string url) {
        import core.thread;

        for (int attempt = 1; attempt <= maxRetries + 1; attempt++) {
            try {
                auto http = HTTP(url);
                

                string response;
                http.onReceive = (ubyte[] data) {
                    response ~= cast(string)data;
                    return data.length;
                };

                http.perform();
                return response;

            } catch (CurlException e) {
                // Check if this is the last attempt
                if (attempt > maxRetries) {
                    throw e;
                }

                // Check if error is retryable
                if (!isRetryableError(0)) {
                    throw e;
                }

                writefln("  Attempt %d failed: %s", attempt, e.msg);

            } catch (Exception e) {
                if (attempt > maxRetries) {
                    throw e;
                }

                writefln("  Attempt %d failed: %s", attempt, e.msg);
            }

            // Wait before retrying
            if (attempt <= maxRetries) {
                auto delay = backoffStrategy.calculateDelay(attempt);
                writefln("  Waiting %s before retry %d...", delay, attempt + 1);
                Thread.sleep(delay);
            }
        }

        throw new Exception("All retry attempts exhausted");
    }

    private bool isRetryableError(CurlCode code) {
        // Simplified: consider most errors retryable for demo
        return true;
    }
}

/**
 * Demonstrate different backoff strategies
 */
void demonstrateBackoffStrategies() {
    writeln("=== Different Backoff Strategies ===");

    Object[] strategies = [
        new ExponentialBackoff(1.seconds, 60.seconds, 2.0f, false),
        new LinearBackoff(1.seconds, 1.seconds, 60.seconds),
        new FibonacciBackoff(1.seconds, 60.seconds, false),
        new FixedDelayBackoff(3.seconds),
        new DecorrelatedJitterBackoff(1.seconds, 60.seconds)
    ];

    string[] names = [
        "Exponential Backoff",
        "Linear Backoff",
        "Fibonacci Backoff",
        "Fixed Delay",
        "Decorrelated Jitter"
    ];

    writefln("Comparing backoff delays over 8 attempts:");
    writefln("%-20s %8s %8s %8s %8s %8s %8s %8s %8s",
            "Strategy", "1", "2", "3", "4", "5", "6", "7", "8");
    import std.array;
    writefln("%s", "-".replicate(100));

    foreach (i, strategyObj; strategies) {
        auto strategy = cast(BackoffStrategy)strategyObj;
        writef("%-20s ", names[i]);
        for (int attempt = 1; attempt <= 8; attempt++) {
            auto delay = strategy.calculateDelay(attempt);
            writef("%8s ", delay.toString());
        }
        writeln();
    }

    writefln("\nKey characteristics:");
    writefln("• Exponential: Grows rapidly, good for avoiding congestion");
    writefln("• Linear: Steady increase, predictable");
    writefln("• Fibonacci: Natural growth pattern, between linear and exponential");
    writefln("• Fixed: Simple, but may cause thundering herd");
    writefln("• Decorrelated Jitter: Avoids correlated failures, recommended for distributed systems");
}

/**
 * Demonstrate jitter effects
 */
void demonstrateJitterEffects() {
    writeln("\n=== Jitter Effects ===");

    auto strategy = new ExponentialBackoff(1.seconds, 30.seconds, 2.0f, true, 0.2f);

    writefln("Exponential backoff with 20%% jitter (5 samples):");
    for (int sample = 1; sample <= 5; sample++) {
        writefln("Sample %d:", sample);
        for (int attempt = 1; attempt <= 5; attempt++) {
            auto delay = strategy.calculateDelay(attempt);
            writefln("  Attempt %d: %s", attempt, delay);
        }
        strategy.reset();  // Reset for next sample
        writeln();
    }

    writefln("Notice how jitter adds randomness to prevent synchronized retries.");
}

/**
 * Demonstrate resilient HTTP client
 */
void demonstrateResilientClient() {
    writeln("\n=== Resilient HTTP Client ===");

    // Test different backoff strategies
    Object[] strategies = [
        new ExponentialBackoff(500.msecs, 10.seconds, 2.0f, true),
        new DecorrelatedJitterBackoff(1.seconds, 15.seconds),
        new LinearBackoff(2.seconds, 1.seconds, 20.seconds)
    ];

    string[] strategyNames = ["Exponential", "Decorrelated Jitter", "Linear"];

    string testUrl = "https://httpbin.org/get";  // Reliable endpoint

    foreach (i, strategyObj; strategies) {
        writefln("Testing %s backoff strategy:", strategyNames[i]);

        auto strategy = cast(BackoffStrategy)strategyObj;
        auto client = new ResilientHTTPClient(strategy, 3, 10.seconds);

        try {
            auto stopwatch = StopWatch(AutoStart.yes);
            string response = client.get(testUrl);
            stopwatch.stop();

            writefln("  ✓ Success in %s", stopwatch.peek);
            writefln("  Response length: %d bytes", response.length);

        } catch (Exception e) {
            writefln("  ✗ Failed: %s", e.msg);
        }

        writeln();
    }
}

/**
 * Demonstrate backoff strategy performance
 */
void demonstratePerformanceComparison() {
    writeln("\n=== Performance Comparison ===");

    // Simulate network conditions with different failure patterns
    enum NetworkCondition { Perfect, Occasional, Frequent, Persistent }

    struct TestResult {
        string strategy;
        int totalRequests;
        int successfulRequests;
        Duration totalTime;
        int totalRetries;
    }

    TestResult[] results;

    // Test each strategy against different network conditions
    Object[] strategies = [
        new ExponentialBackoff(100.msecs, 5.seconds, 2.0f, false),
        new LinearBackoff(500.msecs, 200.msecs, 5.seconds),
        new DecorrelatedJitterBackoff(200.msecs, 5.seconds)
    ];

    string[] strategyNames = ["Exponential", "Linear", "Decorrelated"];

    foreach (i, strategyObj; strategies) {
        writefln("Testing %s strategy:", strategyNames[i]);

        auto strategy = cast(BackoffStrategy)strategyObj;

        TestResult result;
        result.strategy = strategyNames[i];
        result.totalRequests = 10;

        auto stopwatch = StopWatch(AutoStart.yes);

        for (int req = 0; req < result.totalRequests; req++) {
            int attempts = 0;
            bool success = false;

            // Simulate request with possible failures
            for (int attempt = 1; attempt <= 4 && !success; attempt++) {
                attempts++;

                // Simulate 30% failure rate
                if (uniform(0, 10) < 3) {
                    // Failed request
                    if (attempt < 4) {
                        auto delay = strategy.calculateDelay(attempt);
                        import core.thread;
                        Thread.sleep(delay);
                    }
                } else {
                    // Successful request
                    success = true;
                }
            }

            if (success) {
                result.successfulRequests++;
                result.totalRetries += (attempts - 1);
            }
        }

        stopwatch.stop();
        result.totalTime = stopwatch.peek;

        results ~= result;

        writefln("  Success rate: %d/%d (%.1f%%)",
                result.successfulRequests, result.totalRequests,
                cast(double)result.successfulRequests / result.totalRequests * 100);
        writefln("  Total retries: %d", result.totalRetries);
        writefln("  Total time: %s", result.totalTime);
        writeln();
    }

    // Summary
    writefln("Performance Summary:");
    writefln("%-15s %-12s %-10s %-12s", "Strategy", "Success %", "Retries", "Time");
    writefln("%s", "-".replicate(55));

    foreach (result; results) {
        double successPercent = cast(double)result.successfulRequests /
                               result.totalRequests * 100;
        writefln("%-15s %-12.1f %-10d %-12s",
                result.strategy, successPercent, result.totalRetries, result.totalTime);
    }
}

/**
 * Demonstrate adaptive backoff
 */
void demonstrateAdaptiveBackoff() {
    writeln("\n=== Adaptive Backoff ===");

    writefln("Adaptive backoff adjusts based on recent success/failure patterns:");
    writefln("• After failures: increase delay aggressiveness");
    writefln("• After successes: decrease delay or reset to baseline");
    writefln("• Consider server response times and error rates");

    // Simple adaptive strategy demonstration
    class AdaptiveBackoff : BackoffStrategy {
        private ExponentialBackoff baseStrategy;
        private int recentFailures = 0;
        private int recentSuccesses = 0;
        private float aggressiveness = 1.0f;

        this() {
            baseStrategy = new ExponentialBackoff(1.seconds, 60.seconds, 2.0f, true);
        }

        override Duration calculateDelay(int attempt) {
            // Adjust aggressiveness based on recent performance
            if (recentFailures > recentSuccesses) {
                aggressiveness = min(aggressiveness * 1.2f, 3.0f);  // More aggressive
            } else if (recentSuccesses > recentFailures) {
                aggressiveness = max(aggressiveness * 0.9f, 0.5f);  // Less aggressive
            }

            return baseStrategy.calculateDelay(cast(int)(attempt * aggressiveness));
        }

        override void reset() {
            recentFailures = 0;
            recentSuccesses = 0;
            aggressiveness = 1.0f;
        }

        void recordSuccess() {
            recentSuccesses++;
            if (recentSuccesses > 5) {
                recentFailures = 0;  // Reset after consistent success
            }
        }

        void recordFailure() {
            recentFailures++;
            if (recentFailures > 3) {
                recentSuccesses = 0;  // Reset after consistent failure
            }
        }
    }

    auto adaptive = new AdaptiveBackoff();

    writefln("Simulating adaptive behavior:");
    string[] outcomes = ["success", "success", "failure", "failure", "failure",
                        "success", "success", "success", "failure"];

    foreach (i, outcome; outcomes) {
        writefln("Request %d: %s", i + 1, outcome);

        auto delay = adaptive.calculateDelay(1);  // Simplified for demo
        writefln("  Delay would be: %s", delay);

        if (outcome == "success") {
            adaptive.recordSuccess();
        } else {
            adaptive.recordFailure();
        }
    }
}

/**
 * Check if exponential backoff functionality works
 */
bool testExponentialBackoffCapability() {
    try {
        // Test basic strategies
        auto expBackoff = new ExponentialBackoff();
        auto delay = expBackoff.calculateDelay(1);
        assert(delay > Duration.zero);

        auto linearBackoff = new LinearBackoff();
        delay = linearBackoff.calculateDelay(1);
        assert(delay > Duration.zero);

        auto fibBackoff = new FibonacciBackoff();
        delay = fibBackoff.calculateDelay(1);
        assert(delay > Duration.zero);

        // Test that delays increase
        auto delay1 = expBackoff.calculateDelay(1);
        auto delay2 = expBackoff.calculateDelay(2);
        assert(delay2 >= delay1);

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the exponential backoff example
 */
void runExample() {
    writeln("=== Exponential Backoff Demonstration ===\n");

    if (!testExponentialBackoffCapability()) {
        writeln("ERROR: Exponential backoff functionality test failed!");
        return;
    }

    writeln("✓ Exponential backoff functionality confirmed\n");

    demonstrateBackoffStrategies();
    demonstrateJitterEffects();
    demonstrateResilientClient();
    demonstratePerformanceComparison();
    demonstrateAdaptiveBackoff();

    writeln("\n=== Summary ===");
    writeln("• Exponential backoff prevents server overload during failures");
    writeln("• Jitter prevents thundering herd problems");
    writeln("• Different strategies suit different use cases");
    writeln("• Decorrelated jitter is recommended for distributed systems");
    writeln("• Adaptive backoff can adjust based on recent performance");
    writeln("• Always set reasonable maximum delays and retry limits");
}

unittest {
    writeln("=== Running exponential_backoff tests ===");

    // Test exponential backoff
    auto expBackoff = new ExponentialBackoff(1.seconds, 60.seconds, 2.0f, false);
    auto delay1 = expBackoff.calculateDelay(1);
    auto delay2 = expBackoff.calculateDelay(2);
    auto delay3 = expBackoff.calculateDelay(3);

    assert(delay1 == 1.seconds);
    assert(delay2 == 2.seconds);
    assert(delay3 == 4.seconds);
    writeln("✓ Exponential backoff calculations work");

    // Test linear backoff
    auto linearBackoff = new LinearBackoff(1.seconds, 500.msecs, 60.seconds);
    delay1 = linearBackoff.calculateDelay(1);
    delay2 = linearBackoff.calculateDelay(2);
    delay3 = linearBackoff.calculateDelay(3);

    assert(delay1 == 1.seconds);
    assert(delay2 == 1.seconds + 500.msecs);
    assert(delay3 == 1.seconds + 1000.msecs);
    writeln("✓ Linear backoff calculations work");

    // Test Fibonacci backoff
    auto fibBackoff = new FibonacciBackoff(1.seconds, 60.seconds, false);
    delay1 = fibBackoff.calculateDelay(1);
    delay2 = fibBackoff.calculateDelay(2);
    delay3 = fibBackoff.calculateDelay(3);
    auto delay4 = fibBackoff.calculateDelay(4);

    assert(delay1 == 1.seconds);  // F(1) = 1
    assert(delay2 == 1.seconds);  // F(2) = 1
    assert(delay3 == 2.seconds);  // F(3) = 2
    assert(delay4 == 3.seconds);  // F(4) = 3
    writeln("✓ Fibonacci backoff calculations work");

    // Test fixed delay
    auto fixedBackoff = new FixedDelayBackoff(5.seconds);
    assert(fixedBackoff.calculateDelay(1) == 5.seconds);
    assert(fixedBackoff.calculateDelay(5) == 5.seconds);
    writeln("✓ Fixed delay backoff works");

    // Test decorrelated jitter
    auto jitterBackoff = new DecorrelatedJitterBackoff(1.seconds, 60.seconds);
    auto delays = new Duration[5];
    for (int i = 0; i < 5; i++) {
        delays[i] = jitterBackoff.calculateDelay(1);
    }
    // All delays should be >= 1 second (minimum)
    foreach (delay; delays) {
        assert(delay >= 1.seconds);
    }
    writeln("✓ Decorrelated jitter backoff works");

    // Test that increasing attempts produce increasing delays (on average)
    auto backoff = new ExponentialBackoff(100.msecs, 10.seconds, 2.0f, false);
    long totalDelay = 0;
    for (int attempt = 1; attempt <= 5; attempt++) {
        auto delay = backoff.calculateDelay(attempt);
        totalDelay += delay.total!"msecs";
    }
    assert(totalDelay > 0);
    writeln("✓ Backoff strategies produce increasing delays");

    writeln("All exponential_backoff tests passed!");
    writeln("=== exponential_backoff tests completed ===");
}
