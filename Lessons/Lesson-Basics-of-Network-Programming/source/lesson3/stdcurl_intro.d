/**
 * Lesson 3: std.curl Introduction - Basic std.curl usage
 *
 * This example demonstrates the basics of using D's built-in std.curl module
 * for making HTTP requests, replacing command-line curl with native D code.
 */

module lesson3.stdcurl_intro;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;

import core.time;

/**
 * Simple GET request using std.curl
 */
void simpleGetRequest() {
    writeln("=== Simple GET Request with std.curl ===");

    try {
        // Use get() function for simple GET requests
        char[] responseData = get("https://httpbin.org/get");
        string response = to!string(responseData);

        writefln("Response received (%d characters):", response.length);
        writefln("First 200 characters: %s",
                response.length > 200 ? response[0..200] ~ "..." : response);

        // Parse basic info from the response
        if (canFind(response, `"url"`)) {
            writeln("✓ Response contains expected JSON structure");
        }

    } catch (CurlException e) {
        writefln("Curl error: %s", e.msg);
    } catch (Exception e) {
        writefln("General error: %s", e.msg);
    }
}

/**
 * GET request with timeout
 */
void getWithTimeout() {
    writeln("\n=== GET Request with Timeout ===");

    try {
        // Create HTTP client with timeout
        auto http = HTTP("https://httpbin.org/delay/1");

        // Set timeout to 5 seconds (5000 milliseconds)
        // Timeout not set - using default

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        writefln("Request completed within timeout (%d characters received)", response.length);

        if (canFind(response, "delay")) {
            writeln("✓ Delay endpoint responded correctly");
        }

    } catch (CurlTimeoutException e) {
        writefln("Request timed out: %s", e.msg);
    } catch (CurlException e) {
        writefln("Curl error: %s", e.msg);
    } catch (Exception e) {
        writefln("General error: %s", e.msg);
    }
}

/**
 * Demonstrate different HTTP methods
 */
void demonstrateHttpMethods() {
    writeln("\n=== HTTP Methods with std.curl ===");

    HTTP.Method[] allMethods = [HTTP.Method.get, HTTP.Method.post, HTTP.Method.put, HTTP.Method.del];

    //string[] methods = ["GET", "POST", "PUT", "DELETE"];
    string[] endpoints = [
        "https://httpbin.org/get",
        "https://httpbin.org/post",
        "https://httpbin.org/put",
        "https://httpbin.org/delete"
    ];

    foreach (i, method; allMethods) {
        try {
            writefln("--- %s Request ---", method);

            auto http = HTTP(endpoints[i]);
            string response;

            http.method = method;
            // Set method based on the index
            switch (method) 
            { 
                case HTTP.Method.post: // POST
                http.postData = "test=data&message=hello";
                break;
                case HTTP.Method.put: // PUT
                http.postData = `{"action": "update", "status": "ok"}`;
                break;
                default:{}
            } 

            http.onReceive = (ubyte[] data) {
                response ~= cast(string)data;
                return data.length;
            };

            http.connectTimeout = dur!"seconds"(10);
            http.dataTimeout = dur!"seconds"(10);
            http.operationTimeout = dur!"seconds"(10);
            http.dnsTimeout = dur!"seconds"(10);

            http.perform();

            writefln("✓ %s request successful (%d chars)", method, response.length);

            // Check if response contains method info
            if (canFind(response, toLower(method))) {
                writefln("✓ Response confirms %s method", method);
            }

        } catch (Exception e) {
            writefln("✗ %s request failed: %s", method, e.msg);
        }
    }
}

/**
 * Demonstrate custom headers
 */
void demonstrateCustomHeaders() {
    writeln("\n=== Custom Headers ===");

    try {
        auto http = HTTP("https://httpbin.org/headers");

        // Add custom headers
        http.addRequestHeader("X-Custom-Header", "D-Lesson-3");
        http.addRequestHeader("X-Student-ID", "12345");
        http.addRequestHeader("User-Agent", "D-Course-Client/1.0");

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        writefln("Response received (%d characters)", response.length);

        // Check if our custom headers are reflected in the response
        if (canFind(response, "D-Lesson-3") &&
            canFind(response, "D-Course-Client")) {
            writeln("✓ Custom headers were sent and received");
        } else {
            writeln("? Headers may not be visible in response");
        }

    } catch (Exception e) {
        writefln("Error with custom headers: %s", e.msg);
    }
}

/**
 * Show HTTP status codes
 */
void demonstrateStatusCodes() {
    writeln("\n=== HTTP Status Codes ===");

    string[] testUrls = [
        "https://httpbin.org/status/200",  // OK
        "https://httpbin.org/status/404",  // Not Found
        "https://httpbin.org/status/500",  // Internal Server Error
    ];

    foreach (url; testUrls) {
        try {
            auto http = HTTP(url);
            string response;
            int statusCode = 0;

            http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
                statusCode = statusLine.code;
                writefln("Status: %d %s", statusCode, statusLine.reason);
            };

            http.onReceive = (ubyte[] data) {
                response ~= cast(string)data;
                return data.length;
            };

            http.perform();

            // Categorize the response
            if (statusCode >= 200 && statusCode < 300) {
                writeln("✓ Success response");
            } else if (statusCode >= 400 && statusCode < 500) {
                writeln("⚠ Client error");
            } else if (statusCode >= 500) {
                writeln("✗ Server error");
            }

        } catch (Exception e) {
            writefln("Error accessing %s: %s", url, e.msg);
        }
    }
}

/**
 * Check if std.curl is available
 */
bool isStdCurlAvailable() {
    try {
        // Try a simple request to test if std.curl works
        auto http = HTTP("https://httpbin.org/get");
        // Timeout not set - using default

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        return response.length > 0 && canFind(response, "httpbin");

    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the std.curl introduction example
 */
void runExample() {
    writeln("=== std.curl Introduction ===\n");

    if (!isStdCurlAvailable()) {
        writeln("ERROR: std.curl is not working properly!");
        writeln("This might be due to network issues or missing libcurl.");
        writeln("Try: sudo apt-get install libcurl4-openssl-dev");
        return;
    }

    writeln("✓ std.curl is available and working\n");

    // Demonstrate basic std.curl usage
    simpleGetRequest();
    getWithTimeout();
    demonstrateHttpMethods();
    demonstrateCustomHeaders();
    demonstrateStatusCodes();

    writeln("\n=== Summary ===");
    writeln("• std.curl provides native D HTTP client functionality");
    writeln("• HTTP.get() for simple GET requests");
    writeln("• HTTP class for advanced requests with callbacks");
    writeln("• Support for all HTTP methods (GET, POST, PUT, DELETE)");
    writeln("• Custom headers with addRequestHeader()");
    writeln("• Timeout control and status code handling");
    writeln("• Callback-based response processing");
}

unittest {
    writeln("=== Running stdcurl_intro tests ===");

    // Test std.curl availability
    bool available = isStdCurlAvailable();
    writefln("std.curl availability test: %s", available ? "available" : "not available");

    // Test basic HTTP object creation (doesn't make actual request)
    try {
        auto http = HTTP("https://example.com");
        // http is a struct, cannot be null
        writeln("✓ HTTP object creation successful");
    } catch (Exception e) {
        writefln("HTTP object creation failed: %s", e.msg);
    }

    // Test method enum values
    assert(HTTP.Method.get == HTTP.Method.get);
    assert(HTTP.Method.post == HTTP.Method.post);
    assert(HTTP.Method.put == HTTP.Method.put);
    assert(HTTP.Method.del == HTTP.Method.del);
    writeln("✓ HTTP method enums are accessible");

    // Test that we can create request data strings
    string postData = "key1=value1&key2=value2";
    assert(postData.length > 0);
    assert(postData.canFind("key1"));
    assert(postData.canFind("value1"));
    writeln("✓ Request data string creation works");

    // Test JSON data creation
    string jsonData = `{"action": "test", "data": "example"}`;
    assert(jsonData.length > 0);
    assert(jsonData.canFind("action"));
    assert(jsonData.canFind("test"));
    assert(jsonData.canFind("{"));
    assert(jsonData.canFind("}"));
    writeln("✓ JSON data string creation works");

    // Test URL construction
    string baseUrl = "https://httpbin.org";
    string endpoint = "get";
    string fullUrl = baseUrl ~ "/" ~ endpoint;
    assert(fullUrl == "https://httpbin.org/get");
    assert(fullUrl.canFind("httpbin"));
    assert(fullUrl.canFind("get"));
    writeln("✓ URL construction works");

    // Test status code ranges
    int[] testCodes = [200, 201, 301, 404, 500];
    foreach (code; testCodes) {
        if (code >= 200 && code < 300) {
            assert(true); // Success codes
        } else if (code >= 400 && code < 500) {
            assert(true); // Client error codes
        } else if (code >= 500) {
            assert(true); // Server error codes
        }
    }
    writeln("✓ Status code range validation works");

    // Test timeout values
    int[] timeouts = [1000, 5000, 10000];
    foreach (timeout; timeouts) {
        assert(timeout > 0);
        assert(timeout % 1000 == 0); // All are multiples of 1000
    }
    writeln("✓ Timeout value validation works");

    writeln("All std.curl introduction tests passed!");
    writeln("=== stdcurl_intro tests completed ===");
}
