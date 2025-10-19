/**
 * Lesson 6: Status Codes - Handle different HTTP status codes
 *
 * This example demonstrates how to handle various HTTP status codes
 * in REST API responses, including success, redirection, client error,
 * and server error codes.
 */

module lesson6.status_codes;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.json;

/**
 * Structure to hold HTTP response information
 */
struct HTTPResponse {
    int statusCode;
    string statusText;
    string responseBody;
    string[string] headers;
    bool success;
    string errorMessage;

    void printInfo() {
        writefln("Status: %d %s", statusCode, statusText);
        writefln("Success: %s", success ? "Yes" : "No");
        writefln("Response size: %d bytes", responseBody.length);

        if (headers.length > 0) {
            writefln("Headers (%d total):", headers.length);
            foreach (key, value; headers) {
                writefln("  %s: %s", key, value);
            }
        }

        if (!success && errorMessage.length > 0) {
            writefln("Error: %s", errorMessage);
        }
    }
}

/**
 * Make HTTP request and capture status information
 */
HTTPResponse makeRequest(string url, HTTP.Method method = HTTP.Method.get,
                        string postData = "", string[string] customHeaders = null) {
    HTTPResponse response;

    try {
        auto http = HTTP(url);
        http.method = method;

        if (postData.length > 0) {
            http.postData = postData;
        }

        if (customHeaders !is null) {
            foreach (key, value; customHeaders) {
                http.addRequestHeader(key, value);
            }
        }

        // Capture status line
        http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
            response.statusCode = statusLine.code;
            response.statusText = statusLine.reason;
        };

        // Capture headers
        http.onReceiveHeader = (in char[] key, in char[] value) {
            response.headers[to!string(key)] = to!string(value);
        };

        // Capture response body
        http.onReceive = (ubyte[] data) {
            response.responseBody ~= cast(string)data;
            return data.length;
        };

        http.perform();

        // Determine success based on status code
        response.success = (response.statusCode >= 200 && response.statusCode < 300);

    } catch (Exception e) {
        response.success = false;
        response.errorMessage = e.msg;
        response.statusCode = 0;
        response.statusText = "Request Failed";
    }

    return response;
}

/**
 * Demonstrate 2xx Success status codes
 */
void demonstrateSuccessCodes() {
    writeln("=== 2xx Success Status Codes ===");

    string[][] successTests = [
        ["https://httpbin.org/status/200", "200 OK - Standard success response"],
        ["https://httpbin.org/status/201", "201 Created - Resource created successfully"],
        ["https://httpbin.org/status/202", "202 Accepted - Request accepted for processing"],
        ["https://httpbin.org/status/204", "204 No Content - Success with no response body"]
    ];

    foreach (test; successTests) {
        string url = test[0];
        string description = test[1];

        writefln("\nTesting: %s", description);

        auto response = makeRequest(url);
        response.printInfo();

        if (response.success) {
            writefln("✓ Correctly identified as successful");
        } else {
            writefln("✗ Should have been successful");
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }
}

/**
 * Demonstrate 3xx Redirection status codes
 */
void demonstrateRedirectionCodes() {
    writeln("\n=== 3xx Redirection Status Codes ===");

    string[][] redirectTests = [
        ["https://httpbin.org/status/301", "301 Moved Permanently"],
        ["https://httpbin.org/status/302", "302 Found (temporary redirect)"],
        ["https://httpbin.org/status/307", "307 Temporary Redirect"],
        ["https://httpbin.org/status/308", "308 Permanent Redirect"]
    ];

    foreach (test; redirectTests) {
        string url = test[0];
        string description = test[1];

        writefln("\nTesting: %s", description);

        auto response = makeRequest(url);
        response.printInfo();

        // For these test endpoints, we expect the actual status codes
        if (response.statusCode >= 300 && response.statusCode < 400) {
            writefln("✓ Correctly received redirection status");

            // Check for Location header
            if ("location" in response.headers) {
                writefln("✓ Redirection location: %s", response.headers["location"]);
            } else {
                writefln("⚠ No Location header in redirection response");
            }
        } else {
            writefln("⚠ Expected redirection status, got %d", response.statusCode);
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }
}

/**
 * Demonstrate 4xx Client Error status codes
 */
void demonstrateClientErrorCodes() {
    writeln("\n=== 4xx Client Error Status Codes ===");

    string[][] clientErrorTests = [
        ["https://httpbin.org/status/400", "400 Bad Request - Malformed request"],
        ["https://httpbin.org/status/401", "401 Unauthorized - Authentication required"],
        ["https://httpbin.org/status/403", "403 Forbidden - Access denied"],
        ["https://httpbin.org/status/404", "404 Not Found - Resource doesn't exist"],
        ["https://httpbin.org/status/405", "405 Method Not Allowed - Wrong HTTP method"],
        ["https://httpbin.org/status/409", "409 Conflict - Resource conflict"],
        ["https://httpbin.org/status/422", "422 Unprocessable Entity - Validation error"],
        ["https://httpbin.org/status/429", "429 Too Many Requests - Rate limited"]
    ];

    foreach (test; clientErrorTests) {
        string url = test[0];
        string description = test[1];

        writefln("\nTesting: %s", description);

        auto response = makeRequest(url);
        response.printInfo();

        if (response.statusCode >= 400 && response.statusCode < 500) {
            writefln("✓ Correctly identified client error");

            // Provide handling suggestions based on status code
            switch (response.statusCode) {
                case 400:
                    writefln("→ Fix: Check request format and required fields");
                    break;
                case 401:
                    writefln("→ Fix: Provide valid authentication credentials");
                    break;
                case 403:
                    writefln("→ Fix: Check user permissions and access rights");
                    break;
                case 404:
                    writefln("→ Fix: Verify resource URL and existence");
                    break;
                case 405:
                    writefln("→ Fix: Use correct HTTP method (GET, POST, PUT, DELETE)");
                    break;
                case 409:
                    writefln("→ Fix: Resolve resource conflicts");
                    break;
                case 422:
                    writefln("→ Fix: Validate and correct input data");
                    break;
                case 429:
                    writefln("→ Fix: Implement rate limiting or exponential backoff");
                    break;
                default:
                    writefln("→ Fix: Check API documentation for this status code");
                    break;
            }
        } else {
            writefln("⚠ Expected client error status, got %d", response.statusCode);
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }
}

/**
 * Demonstrate 5xx Server Error status codes
 */
void demonstrateServerErrorCodes() {
    writeln("\n=== 5xx Server Error Status Codes ===");

    string[][] serverErrorTests = [
        ["https://httpbin.org/status/500", "500 Internal Server Error"],
        ["https://httpbin.org/status/502", "502 Bad Gateway"],
        ["https://httpbin.org/status/503", "503 Service Unavailable"],
        ["https://httpbin.org/status/504", "504 Gateway Timeout"]
    ];

    foreach (test; serverErrorTests) {
        string url = test[0];
        string description = test[1];

        writefln("\nTesting: %s", description);

        auto response = makeRequest(url);
        response.printInfo();

        if (response.statusCode >= 500 && response.statusCode < 600) {
            writefln("✓ Correctly identified server error");

            // Provide retry suggestions based on status code
            switch (response.statusCode) {
                case 500:
                    writefln("→ Action: Server error - consider retrying with backoff");
                    break;
                case 502:
                    writefln("→ Action: Gateway issue - retry or try alternative endpoint");
                    break;
                case 503:
                    writefln("→ Action: Service temporarily unavailable - retry later");
                    break;
                case 504:
                    writefln("→ Action: Gateway timeout - retry with longer timeout");
                    break;
                default:
                    writefln("→ Action: Server error - implement retry logic");
                    break;
            }
        } else {
            writefln("⚠ Expected server error status, got %d", response.statusCode);
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }
}

/**
 * Demonstrate practical status code handling
 */
void demonstratePracticalHandling() {
    writeln("\n=== Practical Status Code Handling ===");

    writefln("Implementing robust API client with proper status code handling:");

    // Simulate API operations that might fail
    string[] operations = [
        "create_user",
        "get_user",
        "update_user",
        "delete_user"
    ];

    foreach (operation; operations) {
        writefln("\n--- Operation: %s ---", operation);

        string url;
        HTTP.Method method;

        // Set up the operation
        switch (operation) {
            case "create_user":
                url = "https://httpbin.org/post";
                method = HTTP.Method.post;
                break;
            case "get_user":
                url = "https://httpbin.org/status/404"; // Simulate not found
                method = HTTP.Method.get;
                break;
            case "update_user":
                url = "https://httpbin.org/put";
                method = HTTP.Method.put;
                break;
            case "delete_user":
                url = "https://httpbin.org/delete";
                method = HTTP.Method.del;
                break;
            default:
                continue;
        }

        auto response = makeRequest(url, method,
                                  operation == "create_user" ? `{"name": "Test User"}` : "");

        // Handle response based on status code
        if (response.success) {
            writefln("✓ Operation successful");
        } else {
            writefln("✗ Operation failed: %s", response.statusText);

            // Provide specific handling logic
            if (response.statusCode == 404) {
                writefln("→ Handling: Resource not found - check if user exists");
            } else if (response.statusCode == 401) {
                writefln("→ Handling: Authentication required - refresh token");
            } else if (response.statusCode == 429) {
                writefln("→ Handling: Rate limited - implement backoff strategy");
            } else if (response.statusCode >= 500) {
                writefln("→ Handling: Server error - retry with exponential backoff");
            } else {
                writefln("→ Handling: Client error - validate request and retry");
            }
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }
}

/**
 * Demonstrate status code categories
 */
void demonstrateStatusCategories() {
    writeln("\n=== Status Code Categories ===");

    writefln("HTTP status codes are organized into categories:");

    // Define status code ranges and their meanings
    struct StatusCategory {
        string range;
        string name;
        string meaning;
        string[] examples;
    }

    StatusCategory[] categories = [
        StatusCategory("1xx", "Informational", "Request received, continuing process",
                      ["100 Continue", "101 Switching Protocols"]),
        StatusCategory("2xx", "Success", "Action was successfully received, understood, and accepted",
                      ["200 OK", "201 Created", "204 No Content"]),
        StatusCategory("3xx", "Redirection", "Further action needs to be taken to complete the request",
                      ["301 Moved Permanently", "302 Found", "307 Temporary Redirect"]),
        StatusCategory("4xx", "Client Error", "Request contains bad syntax or cannot be fulfilled",
                      ["400 Bad Request", "401 Unauthorized", "404 Not Found", "429 Too Many Requests"]),
        StatusCategory("5xx", "Server Error", "Server failed to fulfill an apparently valid request",
                      ["500 Internal Server Error", "502 Bad Gateway", "503 Service Unavailable"])
    ];

    foreach (category; categories) {
        writefln("\n%s - %s", category.range, category.name);
        writefln("  Meaning: %s", category.meaning);
        writefln("  Examples: %s", category.examples);
    }

    writefln("\nGeneral handling strategies:");
    writefln("• 1xx: Usually handled automatically by HTTP clients");
    writefln("• 2xx: Success - proceed with normal flow");
    writefln("• 3xx: Follow redirects or update resource locations");
    writefln("• 4xx: Fix client-side issues (auth, validation, etc.)");
    writefln("• 5xx: Retry with backoff or contact service administrators");
}

/**
 * Check if status code handling works
 */
bool testStatusCodeCapability() {
    try {
        // Test successful request
        auto successResponse = makeRequest("https://httpbin.org/get");
        if (!successResponse.success || successResponse.statusCode != 200) {
            return false;
        }

        // Test error request
        auto errorResponse = makeRequest("https://httpbin.org/status/404");
        if (errorResponse.success || errorResponse.statusCode != 404) {
            return false;
        }

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the status codes example
 */
void runExample() {
    writeln("=== HTTP Status Code Handling ===\n");

    if (!testStatusCodeCapability()) {
        writeln("ERROR: Status code handling functionality test failed!");
        writeln("This might be due to network issues or HTTP library problems.");
        return;
    }

    writeln("✓ Status code handling functionality confirmed\n");

    // Demonstrate different status code categories
    demonstrateSuccessCodes();
    demonstrateRedirectionCodes();
    demonstrateClientErrorCodes();
    demonstrateServerErrorCodes();
    demonstratePracticalHandling();
    demonstrateStatusCategories();

    writeln("\n=== Summary ===");
    writeln("• HTTP status codes provide detailed response information");
    writeln("• 2xx codes indicate success");
    writeln("• 3xx codes indicate redirection (follow Location header)");
    writeln("• 4xx codes indicate client errors (fix request)");
    writeln("• 5xx codes indicate server errors (retry or escalate)");
    writeln("• Proper status code handling improves API reliability");
    writeln("• Different codes require different response strategies");
    writeln("• Status codes guide error recovery and retry logic");
}

unittest {
    writeln("=== Running status_codes tests ===");

    // Test status code capability
    bool statusWorks = testStatusCodeCapability();
    writefln("Status code capability test: %s", statusWorks ? "working" : "not working");

    // Test HTTPResponse structure (safe, no network required)
    HTTPResponse testResponse;
    testResponse.statusCode = 200;
    testResponse.statusText = "OK";
    testResponse.responseBody = `{"test": "data"}`;
    testResponse.headers["content-type"] = "application/json";
    testResponse.success = true;

    assert(testResponse.statusCode == 200);
    assert(testResponse.statusText == "OK");
    assert(testResponse.success == true);
    assert("content-type" in testResponse.headers);
    assert(testResponse.responseBody.length > 0);
    writeln("✓ HTTPResponse structure works");

    // Test status code range validation (safe, no network required)
    int[] testCodes = [200, 301, 404, 500];

    foreach (code; testCodes) {
        bool isSuccess = (code >= 200 && code < 300);
        bool isRedirect = (code >= 300 && code < 400);
        bool isClientError = (code >= 400 && code < 500);
        bool isServerError = (code >= 500 && code < 600);

        if (code == 200) assert(isSuccess && !isRedirect && !isClientError && !isServerError);
        if (code == 301) assert(!isSuccess && isRedirect && !isClientError && !isServerError);
        if (code == 404) assert(!isSuccess && !isRedirect && isClientError && !isServerError);
        if (code == 500) assert(!isSuccess && !isRedirect && !isClientError && isServerError);
    }
    writeln("✓ Status code range validation works");

    // Test HTTP method enum values (safe, no network required)
    assert(HTTP.Method.get != HTTP.Method.post);
    assert(HTTP.Method.put != HTTP.Method.del);
    assert(HTTP.Method.post != HTTP.Method.put);

    // Verify all methods are different
    HTTP.Method[] methods = [HTTP.Method.get, HTTP.Method.post, HTTP.Method.put, HTTP.Method.del];
    for (int i = 0; i < methods.length; i++) {
        for (int j = i + 1; j < methods.length; j++) {
            assert(methods[i] != methods[j]);
        }
    }
    writeln("✓ HTTP method enum values work");

    // Test header handling simulation (safe, no network required)
    string[string] testHeaders;
    testHeaders["content-type"] = "application/json";
    testHeaders["authorization"] = "Bearer token123";
    testHeaders["user-agent"] = "TestClient/1.0";

    assert(testHeaders.length == 3);
    assert(testHeaders["content-type"] == "application/json");
    assert("authorization" in testHeaders);
    assert(testHeaders.get("nonexistent", "default") == "default");
    writeln("✓ Header handling simulation works");

    // Test error message handling (safe, no network required)
    HTTPResponse errorResponse;
    errorResponse.success = false;
    errorResponse.errorMessage = "Connection timeout";
    errorResponse.statusCode = 0;

    assert(!errorResponse.success);
    assert(errorResponse.errorMessage.length > 0);
    assert(canFind(errorResponse.errorMessage, "timeout"));
    assert(errorResponse.statusCode == 0);
    writeln("✓ Error message handling works");

    // Test response body parsing simulation (safe, no network required)
    string jsonResponse = `{"status": "success", "data": {"id": 123, "name": "test"}}`;

    try {
        auto json = parseJSON(jsonResponse);
        assert("status" in json);
        assert("data" in json);
        assert(json["status"].str == "success");
        assert(json["data"].type == JSONType.object);
        writeln("✓ Response body parsing simulation works");
    } catch (Exception e) {
        assert(false, "JSON parsing should work");
    }

    // Test redirection logic simulation (safe, no network required)
    string[string] redirectHeaders;
    redirectHeaders["location"] = "https://example.com/new-location";

    if ("location" in redirectHeaders) {
        string newUrl = redirectHeaders["location"];
        assert(canFind(newUrl, "https://"));
        assert(canFind(newUrl, "new-location"));
        writeln("✓ Redirection logic simulation works");
    }

    writeln("All status_codes tests passed!");
    writeln("=== status_codes tests completed ===");
}
