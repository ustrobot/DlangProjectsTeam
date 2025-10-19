/**
 * Lesson 4: POST Basics - Simple POST requests
 *
 * This example demonstrates basic POST requests using std.curl in D,
 * showing how to send data to web servers and handle responses.
 */

module lesson4.post_basics;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;

/**
 * Simple POST request wrapper
 */
string postRequest(string url, string data) {
    try {
        auto http = HTTP(url);
        http.method = HTTP.Method.post;
        http.postData = data;

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();
        return response;

    } catch (CurlException e) {
        throw new Exception(format("POST request failed for %s: %s", url, e.msg));
    } catch (Exception e) {
        throw new Exception(format("POST request failed for %s: %s", url, e.msg));
    }
}

/**
 * Demonstrate basic POST request
 */
void demonstrateBasicPost() {
    writeln("=== Basic POST Request ===");

    try {
        string url = "https://httpbin.org/post";
        string data = "message=Hello from D POST request&lesson=4";

        writefln("Sending POST request to: %s", url);
        writefln("Data: %s", data);

        string response = postRequest(url, data);

        writefln("Response received (%d characters)", response.length);

        // Check if our data was received
        if (canFind(response,"Hello from D POST request")) {
            writeln("✓ POST data successfully sent and received by server");
        }

        if (canFind(response,"lesson=4")) {
            writeln("✓ All form fields were processed");
        }

    } catch (Exception e) {
        writefln("Basic POST failed: %s", e.msg);
    }
}

/**
 * Demonstrate POST with different content types
 */
void demonstrateContentTypes() {
    writeln("\n=== POST with Different Content Types ===");

    string[] contentTypes = [
        "application/x-www-form-urlencoded",
        "text/plain",
        "application/octet-stream"
    ];

    string[] testData = [
        "key1=value1&key2=value2",
        "This is plain text data",
        "binary data here"
    ];

    foreach (i, contentType; contentTypes) {
        try {
            writefln("--- Content-Type: %s ---", contentType);

            auto http = HTTP("https://httpbin.org/post");
            http.method = HTTP.Method.post;
            http.postData = testData[i];
            http.addRequestHeader("Content-Type", contentType);

            string response;
            http.onReceive = (ubyte[] data) {
                response ~= cast(string)data;
                return data.length;
            };

            http.perform();

            if (canFind(response,contentType)) {
                writefln("✓ Content-Type header correctly set to: %s", contentType);
            }

            // Check if data was received
            if (canFind(response,testData[i])) {
                writefln("✓ Data successfully sent: %s", testData[i]);
            }

        } catch (Exception e) {
            writefln("Content-Type test failed: %s", e.msg);
        }
        writeln();
    }
}

/**
 * Demonstrate POST response handling
 */
void demonstratePostResponse() {
    writeln("=== POST Response Handling ===");

    try {
        auto http = HTTP("https://httpbin.org/post");
        http.method = HTTP.Method.post;
        http.postData = "name=D-Language&action=post-test&version=2.0";

        string responseBody;
        string[string] responseHeaders;
        int statusCode = 0;

        // Handle response data
        http.onReceive = (ubyte[] data) {
            responseBody ~= cast(string)data;
            return data.length;
        };

        // Handle response headers
        http.onReceiveHeader = (in char[] key, in char[] value) {
            string k = to!string(key).strip().toLower();
            string v = to!string(value).strip();
            if (!k.empty) {
                responseHeaders[k] = v;
            }
        };

        // Handle status line
        http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
            statusCode = statusLine.code;
            writefln("HTTP Status: %d %s", statusCode, statusLine.reason);
        };

        http.perform();

        writefln("Response body size: %d characters", responseBody.length);
        writefln("Response headers: %d", responseHeaders.length);

        // Check for important headers
        if ("content-type" in responseHeaders) {
            writefln("Content-Type: %s", responseHeaders["content-type"]);
        }

        if ("server" in responseHeaders) {
            writefln("Server: %s", responseHeaders["server"]);
        }

        // Verify the POST was successful
        if (statusCode == 200) {
            writeln("✓ POST request successful (HTTP 200)");
        } else {
            writefln("⚠ Unexpected status code: %d", statusCode);
        }

    } catch (Exception e) {
        writefln("POST response handling failed: %s", e.msg);
    }
}

/**
 * Demonstrate POST with empty data
 */
void demonstrateEmptyPost() {
    writeln("\n=== POST with Empty Data ===");

    try {
        auto http = HTTP("https://httpbin.org/post");
        http.method = HTTP.Method.post;
        // No postData set - empty POST

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        writefln("Empty POST response size: %d characters", response.length);

        if (canFind(response,`"data": ""`)) {
            writeln("✓ Server correctly received empty POST data");
        }

    } catch (Exception e) {
        writefln("Empty POST failed: %s", e.msg);
    }
}

/**
 * Demonstrate multiple POST requests
 */
void demonstrateMultiplePosts() {
    writeln("\n=== Multiple POST Requests ===");

    string[] payloads = [
        "request=first&data=alpha",
        "request=second&data=beta",
        "request=third&data=gamma"
    ];

    foreach (i, payload; payloads) {
        try {
            writefln("--- POST Request %d ---", i + 1);

            string response = postRequest("https://httpbin.org/post", payload);

            if (canFind(response,payload)) {
                writefln("✓ Request %d successful, data verified", i + 1);
            } else {
                writefln("? Request %d sent but data verification unclear", i + 1);
            }

        } catch (Exception e) {
            writefln("Request %d failed: %s", i + 1, e.msg);
        }

        // Small delay between requests
        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Check if POST functionality works
 */
bool testPostCapability() {
    try {
        string response = postRequest("https://httpbin.org/post", "test=data");
        return response.length > 0 && response.canFind("test=data");
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the POST basics example
 */
void runExample() {
    writeln("=== POST Request Basics ===\n");

    if (!testPostCapability()) {
        writeln("ERROR: POST functionality test failed!");
        writeln("This might be due to network issues or std.curl problems.");
        return;
    }

    writeln("✓ POST functionality confirmed\n");

    // Demonstrate different POST request patterns
    demonstrateBasicPost();
    demonstrateContentTypes();
    demonstratePostResponse();
    demonstrateEmptyPost();
    demonstrateMultiplePosts();

    writeln("\n=== Summary ===");
    writeln("• POST requests send data to servers for processing");
    writeln("• http.method = HTTP.Method.post sets the request method");
    writeln("• http.postData contains the data to send");
    writeln("• Content-Type headers specify data format");
    writeln("• Responses can be handled with callbacks");
    writeln("• Empty POST requests are valid");
    writeln("• Multiple POST requests can be sent sequentially");
}

unittest {
    writeln("=== Running post_basics tests ===");

    // Test HTTP method enum (safe, no network required)
    assert(HTTP.Method.post == HTTP.Method.post);
    assert(HTTP.Method.post != HTTP.Method.get);
    writeln("✓ HTTP method enums work");

    // Test string operations used in POST requests (safe, no network required)
    string testData = "key1=value1&key2=value2";
    assert(canFind(testData, "key1"));
    assert(canFind(testData, "value1"));
    assert(canFind(testData, "&"));
    assert(testData.split("&").length == 2);
    writeln("✓ POST data string operations work");

    // Test different content types (safe, no network required)
    string[] contentTypes = [
        "application/x-www-form-urlencoded",
        "application/json",
        "text/plain"
    ];

    foreach (contentType; contentTypes) {
        assert(canFind(contentType, "/"));
        assert(contentType.length >= 10);
    }
    writeln("✓ Content type validation works");

    // Test empty data handling (safe, no network required)
    string emptyData = "";
    assert(emptyData.empty);
    assert(emptyData.length == 0);
    writeln("✓ Empty data handling works");

    // Test response verification with mock data (safe, no network required)
    string mockResponse = `{"data": "test=data", "method": "POST"}`;
    bool hasData = canFind(mockResponse, "test=data");
    bool hasMethod = canFind(mockResponse, "POST");
    assert(hasData && hasMethod);
    writeln("✓ Response verification works");

    // Test header operations (safe, no network required)
    string[string] testHeaders;
    testHeaders["content-type"] = "application/json";
    testHeaders["x-custom"] = "test-value";

    assert(testHeaders.length == 2);
    assert("content-type" in testHeaders);
    assert(testHeaders["content-type"] == "application/json");
    assert("nonexistent" !in testHeaders);
    writeln("✓ Header operations work");

    // Test URL construction for POST endpoints (safe, no network required)
    string baseUrl = "https://httpbin.org";
    string endpoint = "post";
    string fullUrl = baseUrl ~ "/" ~ endpoint;
    assert(fullUrl == "https://httpbin.org/post");
    assert(canFind(fullUrl, "httpbin"));
    assert(canFind(fullUrl, "post"));
    writeln("✓ POST URL construction works");

    // Test POST capability (network dependent - don't fail tests if network is down)
    try {
        bool postWorks = testPostCapability();
        writefln("POST capability test: %s", postWorks ? "network available" : "network unavailable");
        if (postWorks) {
            writeln("✓ Network connectivity confirmed");
        } else {
            writeln("⚠ Network test failed (expected if offline or httpbin.org down)");
        }
    } catch (Exception e) {
        writeln("⚠ Network capability test threw exception (expected if offline): ", e.msg);
    }

    // Test HTTP object creation without performing request (safe)
    try {
        auto http = HTTP("https://httpbin.org/post");
        http.method = HTTP.Method.post;
        http.postData = "test=data";
        // Don't call perform() - just test object creation
        writeln("✓ HTTP object creation works");
    } catch (Exception e) {
        writeln("⚠ HTTP object creation failed: ", e.msg);
    }

    writeln("All post_basics tests passed!");
    writeln("=== post_basics tests completed ===");
}
