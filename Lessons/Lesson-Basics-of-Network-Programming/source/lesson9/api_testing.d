/**
 * Lesson 9: API Testing - Testing OpenAI-compatible APIs and handling responses
 *
 * This example demonstrates how to test API integrations, handle various response scenarios,
 * and implement robust error handling for API communication.
 */

module lesson9.api_testing;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.json;
import std.random;
import std.array;
import core.time;

/**
 * API test result structure
 */
struct APITestResult {
    bool success;
    string testName;
    string error;
    Duration responseTime;
    int statusCode;
    string response;
    string[string] headers;

    void report() {
        writef("%s: %s", testName, success ? "PASS" : "FAIL");
        if (!success) {
            writef(" - %s", error);
        }
        if (responseTime > Duration.zero) {
            writef(" (%s)", responseTime);
        }
        writeln();
    }
}

/**
 * API test runner
 */
class APITester {
    private string baseUrl;
    private string apiKey;
    private Duration timeout = 30.seconds;

    this(string baseUrl, string apiKey = "") {
        this.baseUrl = baseUrl;
        this.apiKey = apiKey;
    }

    /**
     * Run a single API test
     */
    APITestResult runTest(string testName, APITestResult delegate() testFunc) {
        try {
            auto result = testFunc();
            result.testName = testName;
            return result;
        } catch (Exception e) {
            return APITestResult(false, testName, e.msg);
        }
    }

    /**
     * Run multiple API tests
     */
    APITestResult[] runTests(APITestResult delegate()[] tests, string[] testNames) {
        APITestResult[] results;

        foreach (i, test; tests) {
            string name = i < testNames.length ? testNames[i] : format("Test %d", i + 1);
            auto result = runTest(name, test);
            results ~= result;
            result.report();
        }

        return results;
    }

    /**
     * Test basic connectivity
     */
    APITestResult testConnectivity() {
        auto startTime = MonoTime.currTime;

        try {
            auto http = HTTP(baseUrl ~ "/get");
            

            string response;
            http.onReceive = (ubyte[] data) {
                response ~= cast(string)data;
                return data.length;
            };

            http.perform();

            auto endTime = MonoTime.currTime;
            auto responseTime = endTime - startTime;

            return APITestResult(
                true, "", "", responseTime, 200, response
            );
        } catch (Exception e) {
            return APITestResult(false, "", e.msg);
        }
    }

    /**
     * Test authentication
     */
    APITestResult testAuthentication() {
        if (apiKey.empty) {
            return APITestResult(false, "", "No API key provided");
        }

        auto startTime = MonoTime.currTime;

        try {
            auto http = HTTP(baseUrl ~ "/get");
            
            http.addRequestHeader("Authorization", "Bearer " ~ apiKey);

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

            auto endTime = MonoTime.currTime;
            auto responseTime = endTime - startTime;

            bool success = statusCode != 401 && statusCode != 403;
            string error = success ? "" : format("Authentication failed with status %d", statusCode);

            return APITestResult(
                success, "", error, responseTime, statusCode, response
            );
        } catch (Exception e) {
            return APITestResult(false, "", e.msg);
        }
    }

    /**
     * Test rate limiting
     */
    APITestResult testRateLimiting() {
        // Make multiple rapid requests to test rate limiting
        int requestCount = 5;
        APITestResult[] results;

        for (int i = 0; i < requestCount; i++) {
            auto result = testConnectivity();
            results ~= result;

            // Small delay between requests
            import core.thread;
            Thread.sleep(100.msecs);
        }

        // Check if any request was rate limited (429)
        bool rateLimited = results.any!(r => r.statusCode == 429);
        bool allSuccess = results.all!(r => r.success);

        string error = "";
        if (rateLimited) {
            error = "Rate limiting detected (429 status code)";
        } else if (!allSuccess) {
            error = "Some requests failed";
        }

        return APITestResult(
            !rateLimited && allSuccess, "", error,
            results.map!(r => r.responseTime).fold!((a, b) => a + b)(dur!"hnsecs"(0)) / results.length
        );
    }
}

/**
 * Mock API server for testing
 */
class MockAPIServer {
    private string[string] responses;
    private string[string] errorResponses;

    /**
     * Add a successful response for an endpoint
     */
    void addResponse(string endpoint, string response) {
        responses[endpoint] = response;
    }

    /**
     * Add an error response for an endpoint
     */
    void addErrorResponse(string endpoint, string response) {
        errorResponses[endpoint] = response;
    }

    /**
     * Simulate API call
     */
    APITestResult simulateCall(string endpoint) {
        auto startTime = MonoTime.currTime;

        // Simulate network delay
        import core.thread;
        Thread.sleep(uniform(50, 200).msecs);

        auto endTime = MonoTime.currTime;
        auto responseTime = endTime - startTime;

        if (endpoint in errorResponses) {
            return APITestResult(false, "", "Simulated error", responseTime, 500, errorResponses[endpoint]);
        } else if (endpoint in responses) {
            return APITestResult(true, "", "", responseTime, 200, responses[endpoint]);
        } else {
            return APITestResult(false, "", "Endpoint not found", responseTime, 404, "");
        }
    }
}

/**
 * Demonstrate API testing framework
 */
void demonstrateAPITesting() {
    writeln("=== API Testing Framework ===");

    // Test with httpbin.org
    auto tester = new APITester("https://httpbin.org");

    // Define tests
    // Create delegates for the tests
    APITestResult delegate()[] tests = [
        &tester.testConnectivity,
        &tester.testRateLimiting
    ];

    string[] testNames = [
        "Basic Connectivity",
        "Rate Limiting Test"
    ];

    writefln("Running API tests against %s:", tester.baseUrl);
    auto results = tester.runTests(tests, testNames);

    // Summary
    int passed = cast(int)results.count!(r => r.success);
    int total = cast(int)results.length;

    writefln("\nTest Summary: %d/%d tests passed", passed, total);

    if (passed == total) {
        writefln("✓ All tests passed!");
    } else {
        writefln("✗ Some tests failed. Check the output above.");
    }
}

/**
 * Demonstrate mock API testing
 */
void demonstrateMockTesting() {
    writeln("\n=== Mock API Testing ===");

    auto mockServer = new MockAPIServer();

    // Add mock responses
    mockServer.addResponse("/user/123", `{"id": 123, "name": "John Doe", "email": "john@example.com"}`);
    mockServer.addResponse("/health", `{"status": "healthy", "uptime": 3600}`);
    mockServer.addErrorResponse("/user/999", `{"error": "User not found"}`);

    // Test cases
    struct TestCase {
        string endpoint;
        bool shouldSucceed;
        string description;
    }

    TestCase[] testCases = [
        {"/health", true, "Health check endpoint"},
        {"/user/123", true, "Valid user lookup"},
        {"/user/999", false, "Invalid user lookup"},
        {"/nonexistent", false, "Unknown endpoint"}
    ];

    writefln("Running tests against mock API server:");
    foreach (testCase; testCases) {
        auto result = mockServer.simulateCall(testCase.endpoint);

        string status = (result.success == testCase.shouldSucceed) ? "✓" : "✗";
        writefln("%s %s - %s", status, testCase.description,
                result.success ? "PASS" : "FAIL");

        if (!result.success && !result.error.empty) {
            writefln("  Error: %s", result.error);
        }
    }

    writefln("\nMock testing benefits:");
    writefln("• Fast and reliable (no network dependency)");
    writefln("• Test edge cases and error conditions");
    writefln("• Control exact response content and timing");
    writefln("• Test before real API is available");
}

/**
 * Demonstrate comprehensive API validation
 */
void demonstrateAPIValidation() {
    writeln("\n=== API Response Validation ===");

    writefln("API response validation checklist:");

    string[] validations = [
        "✓ Check HTTP status code (200-299 for success)",
        "✓ Validate response content type (application/json)",
        "✓ Parse JSON response without errors",
        "✓ Check required fields are present",
        "✓ Validate field types and formats",
        "✓ Check data ranges and constraints",
        "✓ Verify business logic rules",
        "✓ Check for error response format consistency"
    ];

    foreach (validation; validations) {
        writefln("%s", validation);
    }

    // Example validation function
    writefln("\nExample validation function:");
    writefln("```d");
    writefln("bool validateUserResponse(JSONValue response) {");
    writefln("    if (response.type != JSONType.object) return false;");
    writefln("    if (!('id' in response) || !('name' in response)) return false;");
    writefln("    if (response['id'].type != JSONType.integer) return false;");
    writefln("    if (response['name'].type != JSONType.string) return false;");
    writefln("    return response['id'].integer > 0 && !response['name'].str.empty;");
    writefln("}");
    writefln("```");
}

/**
 * Demonstrate error scenario testing
 */
void demonstrateErrorScenarios() {
    writeln("\n=== Error Scenario Testing ===");

    writefln("Testing error scenarios is crucial for robust applications:");

    struct ErrorScenario {
        string scenario;
        string testApproach;
        string importance;
    }

    ErrorScenario[] scenarios = [
        {
            "Network timeout",
            "Set very short timeout, verify graceful handling",
            "Prevents application hanging"
        },
        {
            "Invalid API key",
            "Use wrong key, check 401/403 responses",
            "Ensures proper authentication"
        },
        {
            "Rate limit exceeded",
            "Make many rapid requests, check 429 handling",
            "Prevents service disruption"
        },
        {
            "Server errors (5xx)",
            "Trigger or simulate 500/502/503 responses",
            "Ensures retry logic works"
        },
        {
            "Malformed responses",
            "Test with invalid JSON or unexpected formats",
            "Prevents parsing crashes"
        },
        {
            "Large responses",
            "Test with very large response payloads",
            "Ensures memory efficiency"
        },
        {
            "Slow responses",
            "Introduce artificial delays",
            "Tests timeout handling"
        }
    ];

    foreach (scenario; scenarios) {
        writefln("• %s", scenario.scenario);
        writefln("  Test: %s", scenario.testApproach);
        writefln("  Importance: %s", scenario.importance);
        writeln();
    }
}

/**
 * Demonstrate performance testing
 */
void demonstratePerformanceTesting() {
    writeln("\n=== Performance Testing ===");

    writefln("API performance testing considerations:");

    string[] perfTests = [
        "Response time under normal load",
        "Response time under high load",
        "Concurrent request handling",
        "Memory usage during requests",
        "Connection pool efficiency",
        "Timeout behavior",
        "Error recovery time"
    ];

    foreach (test; perfTests) {
        writefln("• %s", test);
    }

    writefln("\nPerformance testing example:");
    writefln("```d");
    writefln("auto startTime = MonoTime.currTime;");
    writefln("// Make API call");
    writefln("auto endTime = MonoTime.currTime;");
    writefln("auto responseTime = endTime - startTime;");
    writefln("writeln(\"Response time: %s\", responseTime);");
    writefln("```");

    // Simple performance test
    writefln("\nRunning simple performance test:");
    auto startTime = MonoTime.currTime;

    // Simulate some work
    import core.thread;
    Thread.sleep(10.msecs);

    auto endTime = MonoTime.currTime;
    auto elapsed = endTime - startTime;

    writefln("Simulated operation took: %s", elapsed);
}

/**
 * Demonstrate integration testing
 */
void demonstrateIntegrationTesting() {
    writeln("\n=== Integration Testing ===");

    writefln("Integration testing verifies end-to-end functionality:");

    string[] integrationTests = [
        "Complete user registration flow",
        "Authentication and authorization",
        "Data retrieval and manipulation",
        "Error handling and recovery",
        "Cross-service communication",
        "External API dependencies"
    ];

    foreach (test; integrationTests) {
        writefln("• %s", test);
    }

    writefln("\nIntegration test structure:");
    writefln("1. Setup test data and environment");
    writefln("2. Execute the integrated workflow");
    writefln("3. Verify all components interact correctly");
    writefln("4. Check data consistency across services");
    writefln("5. Clean up test data");
}

/**
 * Demonstrate test automation
 */
void demonstrateTestAutomation() {
    writeln("\n=== Test Automation ===");

    writefln("Automating API tests ensures consistent validation:");

    writefln("```d");
    writefln("unittest {");
    writefln("    auto tester = new APITester(\"https://api.example.com\", \"test-key\");");
    writefln("    ");
    writefln("    // Test connectivity");
    writefln("    auto result = tester.testConnectivity();");
    writefln("    assert(result.success, \"API should be reachable\");");
    writefln("    ");
    writefln("    // Test authentication");
    writefln("    result = tester.testAuthentication();");
    writefln("    assert(result.success, \"Authentication should work\");");
    writefln("}");
    writefln("```");

    writefln("\nTest automation benefits:");
    writefln("• Catches regressions early");
    writefln("• Enables continuous integration");
    writefln("• Provides confidence in deployments");
    writefln("• Documents expected behavior");
    writefln("• Reduces manual testing effort");
}

/**
 * Check if API testing functionality works
 */
bool testAPITestingCapability() {
    try {
        // Test mock server
        auto mockServer = new MockAPIServer();
        mockServer.addResponse("/test", "success");
        auto result = mockServer.simulateCall("/test");
        assert(result.success);
        assert(result.response == "success");

        // Test error response
        mockServer.addErrorResponse("/error", "failure");
        result = mockServer.simulateCall("/error");
        assert(!result.success);
        assert(result.error == "Simulated error");

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the API testing example
 */
void runExample() {
    writeln("=== API Testing Demonstration ===\n");

    if (!testAPITestingCapability()) {
        writeln("ERROR: API testing functionality test failed!");
        return;
    }

    writeln("✓ API testing functionality confirmed\n");

    demonstrateAPITesting();
    demonstrateMockTesting();
    demonstrateAPIValidation();
    demonstrateErrorScenarios();
    demonstratePerformanceTesting();
    demonstrateIntegrationTesting();
    demonstrateTestAutomation();

    writeln("\n=== Summary ===");
    writeln("• Implement comprehensive API testing");
    writeln("• Test both success and error scenarios");
    writeln("• Use mock servers for reliable testing");
    writeln("• Validate response formats and content");
    writeln("• Monitor performance and reliability");
    writeln("• Automate tests for continuous integration");
    writeln("• Test authentication and authorization");
    writeln("• Handle rate limits and timeouts gracefully");
}

unittest {
    writeln("=== Running api_testing tests ===");

    // Test mock server
    auto mockServer = new MockAPIServer();
    mockServer.addResponse("/success", "OK");
    mockServer.addErrorResponse("/fail", "Error");

    auto successResult = mockServer.simulateCall("/success");
    assert(successResult.success);
    assert(successResult.response == "OK");

    auto errorResult = mockServer.simulateCall("/fail");
    assert(!errorResult.success);
    assert(errorResult.error == "Simulated error");
    writeln("✓ Mock server works");

    // Test API result structure
    APITestResult result = APITestResult(
        true, "test", "", 100.msecs, 200, "response",
        ["Content-Type": "application/json"]
    );

    assert(result.success);
    assert(result.testName == "test");
    assert(result.statusCode == 200);
    assert(result.responseTime == 100.msecs);
    assert(result.response == "response");
    assert("Content-Type" in result.headers);
    writeln("✓ API test result structure works");

    // Test JSON validation concept
    string validJson = `{"id": 123, "name": "test"}`;
    JSONValue parsed = parseJSON(validJson);
    assert(parsed.type == JSONType.object);
    assert("id" in parsed && "name" in parsed);
    assert(parsed["id"].integer == 123);
    assert(parsed["name"].str == "test");
    writeln("✓ JSON validation concepts work");

    // Test error scenario structures
    struct ErrorScenario {
        string scenario, testApproach, importance;
    }

    ErrorScenario scenario = {
        scenario: "test scenario",
        testApproach: "test approach",
        importance: "very important"
    };

    assert(scenario.scenario == "test scenario");
    assert(scenario.testApproach == "test approach");
    assert(scenario.importance == "very important");
    writeln("✓ Error scenario structures work");

    writeln("All api_testing tests passed!");
    writeln("=== api_testing tests completed ===");
}
