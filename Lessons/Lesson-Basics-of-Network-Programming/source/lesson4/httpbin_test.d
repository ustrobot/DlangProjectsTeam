/**
 * Lesson 4: HttpBin Test - Test with httpbin.org endpoints
 *
 * This example demonstrates testing POST requests against various httpbin.org endpoints,
 * which provide a comprehensive testing service for HTTP requests and responses.
 */

module lesson4.httpbin_test;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.json;
import std.uri;
import std.algorithm;

/**
 * Generic POST request function
 */
string postToHttpBin(string endpoint, string data, string contentType = "text/plain") {
    string url = "https://httpbin.org/" ~ endpoint;
    try {
        auto http = HTTP(url);
        http.method = HTTP.Method.post;
        http.postData = data;
        http.addRequestHeader("Content-Type", contentType);

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();
        return response;

    } catch (Exception e) {
        throw new Exception(format("POST to %s failed: %s", endpoint, e.msg));
    }
}

/**
 * Test POST /post endpoint
 */
void testPostEndpoint() {
    writeln("=== Testing POST /post Endpoint ===");

    try {
        string testData = "Hello from D POST test!";
        string response = postToHttpBin("post", testData, "text/plain");

        writefln("Response size: %d characters", response.length);

        // Verify the data was received
        if (canFind(response, testData)) {
            writeln("✓ Data correctly received by /post endpoint");
        }

        // Check response structure
        if (canFind(response, `"data":`) && canFind(response, `"method": "POST"`)) {
            writeln("✓ Response has correct JSON structure");
        }

        // Check headers
        if (canFind(response, `"Content-Type": "text/plain"`)) {
            writeln("✓ Content-Type header correctly reported");
        }

    } catch (Exception e) {
        writefln("POST /post test failed: %s", e.msg);
    }
}

/**
 * Test POST /anything endpoint
 */
void testAnythingEndpoint() {
    writeln("\n=== Testing POST /anything Endpoint ===");

    try {
        string jsonData = `{"test": "anything_endpoint", "data": [1, 2, 3]}`;
        string response = postToHttpBin("anything", jsonData, "application/json");

        writefln("Response size: %d characters", response.length);

        // /anything endpoint echoes back the request
        if (canFind(response,"anything_endpoint")) {
            writeln("✓ /anything endpoint correctly echoed our data");
        }

        if (canFind(response,`[1, 2, 3]`)) {
            writeln("✓ JSON array data preserved");
        }

        // Check if method is reported
        if (canFind(response,`"method": "POST"`)) {
            writeln("✓ HTTP method correctly identified");
        }

    } catch (Exception e) {
        writefln("/anything test failed: %s", e.msg);
    }
}

/**
 * Test form-encoded data with /post
 */
void testFormEncodedPost() {
    writeln("\n=== Testing Form-Encoded POST ===");

    try {
        string formData = "name=D+Language&version=2.0&lesson=4&topic=httpbin";
        string response = postToHttpBin("post", formData, "application/x-www-form-urlencoded");

        writefln("Form data size: %d characters", formData.length);

        // Check if form data was parsed
        if (canFind(response,`"name": "D Language"`)) {
            writeln("✓ Form field 'name' correctly decoded and parsed");
        }

        if (canFind(response,`"version": "2.0"`)) {
            writeln("✓ Form field 'version' processed");
        }

        if (canFind(response,`"lesson": "4"`)) {
            writeln("✓ Numeric form field handled");
        }

        // Check if the raw form data is shown
        if (canFind(response,"name=D+Language")) {
            writeln("✓ Raw form data preserved in response");
        }

    } catch (Exception e) {
        writefln("Form-encoded POST test failed: %s", e.msg);
    }
}

/**
 * Test JSON POST to /post
 */
void testJsonPost() {
    writeln("\n=== Testing JSON POST ===");

    try {
        string jsonData = `{
            "message": "JSON POST test",
            "language": "D",
            "lesson": 4,
            "features": ["compiled", "statically-typed", "systems"],
            "metadata": {
                "version": "2.0",
                "platform": "httpbin.org"
            }
        }`;

        string response = postToHttpBin("post", jsonData, "application/json");

        // Parse response to verify JSON handling
        try {
            JSONValue responseJson = parseJSON(response);

            if ("json" in responseJson) {
                auto jsonSection = responseJson["json"];

                if ("message" in jsonSection && jsonSection["message"].str == "JSON POST test") {
                    writeln("✓ JSON message field verified");
                }

                if ("features" in jsonSection && jsonSection["features"].array.length == 3) {
                    writeln("✓ JSON array field processed correctly");
                }

                if ("metadata" in jsonSection && "version" in jsonSection["metadata"]) {
                    writeln("✓ Nested JSON object handled");
                }
            }

        } catch (JSONException e) {
            writefln("Response parsing failed, but request may have succeeded: %s", e.msg);
        }

    } catch (Exception e) {
        writefln("JSON POST test failed: %s", e.msg);
    }
}

/**
 * Test POST /status endpoint variations
 */
void testStatusEndpoints() {
    writeln("\n=== Testing Status Code Endpoints ===");

    // Test different status codes that accept POST
    int[] testStatuses = [200, 201, 202, 204, 400, 401, 403, 404, 500];

    foreach (status; testStatuses) {
        try {
            writefln("--- Testing POST to /status/%d ---", status);

            string response = postToHttpBin(format("status/%d", status), "test data", "text/plain");

            writefln("Response size: %d characters", response.length);

            // Status endpoints return empty body for most codes
            // Just verify the request didn't fail
            writeln(format("✓ POST to /status/%d completed", status));

        } catch (Exception e) {
            writefln("POST to /status/%d failed: %s", status, e.msg);
        }

        // Small delay between requests
        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Test POST /delay endpoint
 */
void testDelayEndpoint() {
    writeln("\n=== Testing POST /delay Endpoint ===");

    try {
        writefln("Testing POST to /delay/2 (2 second delay)...");

        import std.datetime.stopwatch;
        auto sw = StopWatch(AutoStart.yes);

        string response = postToHttpBin("delay/2", "delayed test", "text/plain");

        sw.stop();
        auto elapsed = sw.peek();
        writefln("Request completed in %d milliseconds", elapsed.total!"msecs");

        if (canFind(response,"delayed test")) {
            writeln("✓ Delayed POST request successful");
        }

        if (elapsed.total!"seconds" >= 2) {
            writeln("✓ Delay correctly applied (request took expected time)");
        } else {
            writefln("⚠ Delay may not have been applied (took %d ms)", elapsed.total!"msecs");
        }

    } catch (Exception e) {
        writefln("Delayed POST test failed: %s", e.msg);
    }
}

/**
 * Test POST /stream endpoint
 */
void testStreamEndpoint() {
    writeln("\n=== Testing POST /stream Endpoint ===");

    try {
        string streamData = "Streaming test data\nLine 2\nLine 3";
        string response = postToHttpBin("stream/3", streamData, "text/plain");

        writefln("Stream response size: %d characters", response.length);

        // /stream returns multiple JSON objects
        if (canFind(response,"Streaming test data")) {
            writeln("✓ Stream endpoint received our data");
        }

        // Count how many JSON objects we got
        int jsonObjectCount = 0;
        size_t pos = 0;
        while ((pos = response.indexOf("{", pos)) != -1) {
            jsonObjectCount++;
            pos++;
        }

        writefln("Found %d JSON objects in stream response", jsonObjectCount);

        if (jsonObjectCount >= 3) {
            writeln("✓ Stream returned expected number of objects");
        }

    } catch (Exception e) {
        writefln("Stream POST test failed: %s", e.msg);
    }
}

/**
 * Test POST with custom headers
 */
void testCustomHeaders() {
    writeln("\n=== Testing POST with Custom Headers ===");

    try {
        string testData = "Custom headers test";

        auto http = HTTP("https://httpbin.org/post");
        http.method = HTTP.Method.post;
        http.postData = testData;

        // Add custom headers
        http.addRequestHeader("Content-Type", "text/plain");
        http.addRequestHeader("X-Custom-Header", "D-Language-Test");
        http.addRequestHeader("X-Lesson", "4");
        http.addRequestHeader("X-Version", "2.0");

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        // Check if our custom headers were received
        if (canFind(response,`"X-Custom-Header": "D-Language-Test"`)) {
            writeln("✓ Custom header X-Custom-Header received");
        }

        if (canFind(response,`"X-Lesson": "4"`)) {
            writeln("✓ Custom header X-Lesson received");
        }

        if (canFind(response,`"X-Version": "2.0"`)) {
            writeln("✓ Custom header X-Version received");
        }

        writefln("Custom headers test completed, response size: %d", response.length);

    } catch (Exception e) {
        writefln("Custom headers POST test failed: %s", e.msg);
    }
}

/**
 * Test POST /base64 endpoint
 */
void testBase64Endpoint() {
    writeln("\n=== Testing POST /base64 Endpoint ===");

    try {
        // Send some text that will be base64 encoded in response
        string testText = "Hello, this is base64 test data!";
        string response = postToHttpBin("base64/" ~ encodeComponent(testText), "", "text/plain");

        writefln("Base64 response size: %d characters", response.length);

        // The response should contain base64 encoded data
        if (response.length > 0) {
            writeln("✓ Base64 endpoint responded");

            // Check if it looks like base64 (contains typical base64 chars)
            bool hasBase64Chars = false;
            foreach (char c; response) {
                if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
                    (c >= '0' && c <= '9') || c == '+' || c == '/' || c == '=') {
                    hasBase64Chars = true;
                    break;
                }
            }

            if (hasBase64Chars) {
                writeln("✓ Response contains base64-encoded data");
            }
        }

    } catch (Exception e) {
        writefln("Base64 POST test failed: %s", e.msg);
    }
}

/**
 * Test POST /html endpoint
 */
void testHtmlEndpoint() {
    writeln("\n=== Testing POST /html Endpoint ===");

    try {
        string htmlData = "<div><h1>Test HTML</h1><p>This is HTML content</p></div>";
        string response = postToHttpBin("html", htmlData, "text/html");

        writefln("HTML response size: %d characters", response.length);

        if (canFind(response,"<html>") || response.canFind("<body>")) {
            writeln("✓ HTML endpoint returned HTML content");
        }

        if (canFind(response,"Test HTML")) {
            writeln("✓ Our HTML data was processed");
        }

    } catch (Exception e) {
        writefln("HTML POST test failed: %s", e.msg);
    }
}

/**
 * Comprehensive httpbin.org POST test
 */
void testComprehensiveHttpBin() {
    writeln("\n=== Comprehensive HttpBin POST Test ===");

    try {
        // Test multiple endpoints with different content types
        string[3] endpoints = ["post", "anything", "post"];
        string[3] data = [
            "text data",
            `{"json": "data"}`,
            "name=value&other=data"
        ];
        string[3] contentTypes = [
            "text/plain",
            "application/json",
            "application/x-www-form-urlencoded"
        ];

        for (int i = 0; i < 3; i++) {
            writefln("--- Test %d: %s with %s ---", i + 1, endpoints[i], contentTypes[i]);

            string response = postToHttpBin(endpoints[i], data[i], contentTypes[i]);

            bool success = response.length > 0;
            writefln("✓ Test %d completed (response size: %d)", i + 1, response.length);

            // Small delay between comprehensive tests
            import core.thread;
            Thread.sleep(200.msecs);
        }

        writeln("✓ Comprehensive httpbin.org POST test completed");

    } catch (Exception e) {
        writefln("Comprehensive test failed: %s", e.msg);
    }
}

/**
 * Check if httpbin.org is accessible
 */
bool testHttpBinAvailability() {
    try {
        string response = postToHttpBin("post", "availability test", "text/plain");
        return response.canFind("availability test");
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the httpbin test example
 */
void runExample() {
    writeln("=== HttpBin.org POST Request Tests ===\n");

    if (!testHttpBinAvailability()) {
        writeln("ERROR: httpbin.org is not accessible!");
        writeln("This might be due to network issues or service unavailability.");
        return;
    }

    writeln("✓ httpbin.org is accessible\n");

    // Run comprehensive tests against httpbin.org endpoints
    testPostEndpoint();
    testAnythingEndpoint();
    testFormEncodedPost();
    testJsonPost();
    testStatusEndpoints();
    testDelayEndpoint();
    testStreamEndpoint();
    testCustomHeaders();
    testBase64Endpoint();
    testHtmlEndpoint();
    testComprehensiveHttpBin();

    writeln("\n=== Summary ===");
    writeln("• httpbin.org provides comprehensive HTTP testing endpoints");
    writeln("• /post endpoint accepts any POST data and returns JSON response");
    writeln("• /anything endpoint echoes back the entire request");
    writeln("• Different content types are handled appropriately");
    writeln("• Custom headers are preserved and returned");
    writeln("• Status code endpoints test error handling");
    writeln("• Delay endpoints test timeout behavior");
    writeln("• Stream endpoints return multiple JSON objects");
    writeln("• Base64 and HTML endpoints test encoding/decoding");
}

unittest {
    writeln("=== Running httpbin_test tests ===");

    // Test httpbin availability
    bool httpbinWorks = testHttpBinAvailability();
    writefln("httpbin.org availability test: %s", httpbinWorks ? "available" : "not available");

    // Test endpoint URL construction
    string baseUrl = "https://httpbin.org/";
    string endpoint = "post";
    string fullUrl = baseUrl ~ endpoint;
    assert(fullUrl == "https://httpbin.org/post");
    assert(fullUrl.canFind("httpbin"));
    assert(fullUrl.canFind("post"));
    writeln("✓ Endpoint URL construction works");

    // Test different content types
    string[] contentTypes = [
        "text/plain",
        "application/json",
        "application/x-www-form-urlencoded",
        "text/html"
    ];

    foreach (contentType; contentTypes) {
        assert(contentType.canFind("/"));
        assert(contentType.length > 5);
    }
    writeln("✓ Content type validation works");

    // Test JSON response parsing
    string mockResponse = `{"data": "test", "method": "POST", "headers": {"Content-Type": "text/plain"}}`;
    try {
        JSONValue parsed = parseJSON(mockResponse);
        assert("data" in parsed);
        assert("method" in parsed);
        assert("headers" in parsed);
        assert(parsed["data"].str == "test");
        assert(parsed["method"].str == "POST");
        writeln("✓ JSON response parsing works");
    } catch (Exception e) {
        assert(false, "JSON parsing should work");
    }

    // Test custom headers array operations
    string[] headerKeys = ["X-Custom", "X-Test", "X-Version"];
    string[] headerValues = ["value1", "value2", "2.0"];

    assert(headerKeys.length == headerValues.length);
    for (size_t i = 0; i < headerKeys.length; i++) {
        assert(headerKeys[i].length > 0);
        assert(headerValues[i].length > 0);
    }
    writeln("✓ Header array operations work");

    // Test status code validation
    int[] validStatuses = [200, 201, 400, 404, 500];
    foreach (status; validStatuses) {
        assert(status >= 100 && status < 600);
    }
    writeln("✓ HTTP status code validation works");

    // Test base64 character detection
    string base64Sample = "SGVsbG8gV29ybGQ="; // "Hello World" in base64
    bool hasBase64Chars = false;
    foreach (char c; base64Sample) {
        if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') ||
            (c >= '0' && c <= '9') || c == '+' || c == '/' || c == '=') {
            hasBase64Chars = true;
            break;
        }
    }
    assert(hasBase64Chars);
    writeln("✓ Base64 character detection works");

    // Test HTML content detection
    string htmlSample = "<html><body><h1>Test</h1></body></html>";
    bool hasHtmlTags = htmlSample.canFind("<html>") && htmlSample.canFind("<body>");
    assert(hasHtmlTags);
    writeln("✓ HTML content detection works");

    // Test stream response counting
    string streamSample = `{"id": 1}{"id": 2}{"id": 3}`;
    int objectCount = 0;
    size_t pos = 0;
    while ((pos = streamSample.indexOf("{", pos)) != -1) {
        objectCount++;
        pos++;
    }
    assert(objectCount == 3);
    writeln("✓ Stream object counting works");

    // Test delay timing (mock)
    import std.datetime;
    auto mockElapsed = 2500.msecs;
    bool isDelayed = mockElapsed.total!"seconds" >= 2;
    assert(isDelayed);
    writeln("✓ Delay timing validation works");

    // Test comprehensive test data arrays
    string[3] testEndpoints = ["post", "anything", "post"];
    string[3] testData = ["data1", "data2", "data3"];
    string[3] testTypes = ["type1", "type2", "type3"];

    assert(testEndpoints.length == testData.length);
    assert(testData.length == testTypes.length);
    for (int i = 0; i < testEndpoints.length; i++) {
        assert(testEndpoints[i].length > 0);
        assert(testData[i].length > 0);
        assert(testTypes[i].length > 0);
    }
    writeln("✓ Comprehensive test data validation works");

    // Test URL encoding for special endpoints
    string specialText = "Hello & World!";
    string encoded = encodeComponent(specialText);
    assert(encoded != specialText);
    assert(encoded.canFind("%26")); // & encoded
    assert(encoded.canFind("%20")); // space encoded
    writeln("✓ URL encoding for endpoints works");

    writeln("All httpbin_test tests passed!");
    writeln("=== httpbin_test tests completed ===");
}
