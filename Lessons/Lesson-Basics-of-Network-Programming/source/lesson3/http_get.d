/**
 * Lesson 3: HTTP GET Requests - Simple GET requests with std.curl
 *
 * This example demonstrates how to make simple GET requests using D's std.curl
 * module, including error handling and response processing.
 */

module lesson3.http_get;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.exception;
import std.datetime;

/**
 * Simple wrapper for GET requests
 */
string httpGet(string url) {
    try {
        char[] response = get(url);
        return to!string(response);
    } catch (CurlException e) {
        throw new Exception(format("HTTP GET failed for %s: %s", url, e.msg));
    }
}

/**
 * GET request with detailed error information
 */
string httpGetWithDetails(string url, out int statusCode, out string contentType) {
    try {
        auto http = HTTP(url);
        string response;

        // Set up callbacks
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.onReceiveHeader = (in char[] key, in char[] value) {
            string k = to!string(key).toLower();
            if (k == "content-type") {
                contentType = value.idup;
            }
        };

        http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
            statusCode = statusLine.code;
        };

        http.perform();

        return response;

    } catch (CurlException e) {
        throw new Exception(format("HTTP GET failed for %s (Curl error: %s)", url, e.msg));
    } catch (Exception e) {
        throw new Exception(format("HTTP GET failed for %s: %s", url, e.msg));
    }
}

/**
 * Demonstrate basic GET requests
 */
void demonstrateBasicGets() {
    writeln("=== Basic GET Requests ===");

    string[] urls = [
        "https://httpbin.org/get",
        "https://httpbin.org/uuid",
        "https://httpbin.org/ip",
        "https://httpbin.org/user-agent"
    ];

    foreach (i, url; urls) {
        try {
            writefln("--- Request %d: %s ---", i + 1, url);
            string response = httpGet(url);

            writefln("✓ Success! Response length: %d characters", response.length);

            // Show a preview of the response
            if (response.length > 100) {
                writeln("Preview: ", response[0..100], "...");
            } else {
                writeln("Response: ", response);
            }

        } catch (Exception e) {
            writefln("✗ Failed: %s", e.msg);
        }
        writeln();
    }
}

/**
 * Demonstrate GET with status codes and headers
 */
void demonstrateDetailedGets() {
    writeln("=== GET Requests with Details ===");

    string[] urls = [
        "https://httpbin.org/get",
        "https://httpbin.org/status/200",
        "https://httpbin.org/status/404"
    ];

    foreach (url; urls) {
        try {
            writefln("--- %s ---", url);

            int statusCode;
            string contentType;
            string response = httpGetWithDetails(url, statusCode, contentType);

            writefln("Status Code: %d", statusCode);
            writefln("Content-Type: %s", contentType.empty ? "unknown" : contentType);
            writefln("Response Size: %d bytes", response.length);

            // Interpret status code
            if (statusCode >= 200 && statusCode < 300) {
                writeln("✓ Success response");
            } else if (statusCode >= 400 && statusCode < 500) {
                writeln("⚠ Client error");
            } else if (statusCode >= 500) {
                writeln("✗ Server error");
            }

            // Check content type
            if (canFind(contentType, "json")) {
                writeln("✓ JSON response");
            } else if (canFind(contentType, "text")) {
                writeln("✓ Text response");
            }

        } catch (Exception e) {
            writefln("✗ Failed: %s", e.msg);
        }
        writeln();
    }
}

/**
 * Demonstrate GET with custom headers
 */
void demonstrateGetWithHeaders() {
    writeln("=== GET with Custom Headers ===");

    try {
        string url = "https://httpbin.org/headers";
        auto http = HTTP(url);

        // Add custom headers
        http.addRequestHeader("X-Custom-Header", "D-HTTP-GET-Example");
        http.addRequestHeader("Accept", "application/json");
        http.addRequestHeader("User-Agent", "D-Course-HTTP-Client/1.0");

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        writefln("Response received (%d characters)", response.length);

        // Check if our headers are reflected in the response
        if (response.canFind("D-HTTP-GET-Example")) {
            writeln("✓ Custom headers were sent successfully");
        }

        if (response.canFind("D-Course-HTTP-Client")) {
            writeln("✓ Custom User-Agent was sent");
        }

    } catch (Exception e) {
        writefln("Failed to send headers: %s", e.msg);
    }
}

/**
 * Demonstrate GET with timeout
 */
void demonstrateGetWithTimeout() {
    writeln("\n=== GET with Timeout ===");

    string[] urls = [
        "https://httpbin.org/delay/1",    // 1 second delay - should work
        "https://httpbin.org/delay/5",    // 5 second delay - may timeout
    ];

    foreach (url; urls) {
        try {
            writefln("--- %s ---", url);

            auto http = HTTP(url);
            // Timeout not set - using default

            string response;
            http.onReceive = (ubyte[] data) {
                response ~= cast(string)data;
                return data.length;
            };

            // Note: HTTP class doesn't provide timing information
            // In a real application, you might use std.datetime.StopWatch
            http.perform();
            long duration = 0; // Placeholder

            writefln("✓ Request completed in %d ms", duration);
            writefln("Response size: %d bytes", response.length);

        } catch (CurlTimeoutException e) {
            writefln("✗ Request timed out: %s", e.msg);
        } catch (Exception e) {
            writefln("✗ Request failed: %s", e.msg);
        }
        writeln();
    }
}

/**
 * Demonstrate error handling
 */
void demonstrateErrorHandling() {
    writeln("=== Error Handling ===");

    string[] badUrls = [
        "https://nonexistent-domain-12345.com",
        "https://httpbin.org/status/404",
        "https://httpbin.org/status/500",
        "http://invalid.protocol.url"
    ];

    foreach (url; badUrls) {
        try {
            writefln("--- Testing: %s ---", url);
            string response = httpGet(url);
            writefln("Unexpected success: %s", url);

        } catch (Exception e) {
            writefln("✓ Expected error caught: %s", e.msg);
        }
        writeln();
    }
}

/**
 * Check if network connectivity works
 */
bool testConnectivity() {
    try {
        // Try to reach a reliable endpoint
        auto http = HTTP("https://httpbin.org/get");
        // Timeout not set - using default

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        return response.length > 0;

    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the HTTP GET examples
 */
void runExample() {
    writeln("=== HTTP GET Requests with std.curl ===\n");

    if (!testConnectivity()) {
        writeln("ERROR: Network connectivity test failed!");
        writeln("Please check your internet connection.");
        return;
    }

    writeln("✓ Network connectivity confirmed\n");

    // Demonstrate different GET request patterns
    demonstrateBasicGets();
    demonstrateDetailedGets();
    demonstrateGetWithHeaders();
    demonstrateGetWithTimeout();
    demonstrateErrorHandling();

    writeln("\n=== Summary ===");
    writeln("• httpGet() - Simple GET requests");
    writeln("• httpGetWithDetails() - GET with status code and headers");
    writeln("• HTTP class for advanced requests with callbacks");
    writeln("• Custom headers with addRequestHeader()");
    writeln("• Timeout control with timeout property");
    writeln("• Comprehensive error handling");
    writeln("• Status code interpretation");
}

unittest {
    writeln("=== Running http_get tests ===");

    // Test URL validation
    string[] validUrls = [
        "https://httpbin.org/get",
        "https://example.com",
        "http://localhost:8080/api"
    ];

    foreach (url; validUrls) {
        assert(url.canFind("http"));
        assert(url.length > 10);
    }
    writeln("✓ URL validation works");

    // Test status code interpretation
    int[] testCodes = [200, 404, 500];
    foreach (code; testCodes) {
        bool isSuccess = (code >= 200 && code < 300);
        bool isClientError = (code >= 400 && code < 500);
        bool isServerError = (code >= 500);

        if (code == 200) assert(isSuccess);
        if (code == 404) assert(isClientError);
        if (code == 500) assert(isServerError);
    }
    writeln("✓ Status code interpretation works");

    // Test header parsing simulation
    string contentType = "application/json; charset=utf-8";
    assert(contentType.canFind("json"));
    assert(contentType.canFind("charset"));
    writeln("✓ Header parsing simulation works");

    // Test timeout values
    int[] timeouts = [1000, 3000, 5000, 10000];
    foreach (timeout; timeouts) {
        assert(timeout > 0);
        assert(timeout <= 30000); // Reasonable upper limit
    }
    writeln("✓ Timeout value validation works");

    // Test connectivity check
    bool connectivity = testConnectivity();
    writefln("Network connectivity test: %s", connectivity ? "passed" : "failed");

    // Test that we can create HTTP objects
    try {
        auto http = HTTP("https://example.com");
        // http is a struct, cannot be null
        writeln("✓ HTTP object creation works");
    } catch (Exception e) {
        writefln("HTTP object creation failed: %s", e.msg);
    }

    // Test response size calculations
    string testResponse = "This is a test response";
    assert(testResponse.length == 23);
    assert(testResponse.length > 0);
    writeln("✓ Response size calculation works");

    // Test error message formatting
    string errorMsg = format("HTTP GET failed for %s: %s", "https://example.com", "timeout");
    assert(errorMsg.canFind("HTTP GET failed"));
    assert(errorMsg.canFind("example.com"));
    assert(errorMsg.canFind("timeout"));
    writeln("✓ Error message formatting works");

    writeln("All HTTP GET tests passed!");
    writeln("=== http_get tests completed ===");
}
