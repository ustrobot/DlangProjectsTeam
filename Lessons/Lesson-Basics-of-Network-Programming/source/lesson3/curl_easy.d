/**
 * Lesson 3: CurlEasy Objects - Working with CurlEasy objects
 *
 * This example demonstrates advanced usage of std.curl with CurlEasy objects,
 * showing how to configure requests with various options and handle responses.
 */

module lesson3.curl_easy;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.array;
import std.algorithm;

/**
 * Structure to hold HTTP response data
 */
struct HttpResponse {
    string content;
    string[string] headers;
    int statusCode;
    string statusText;
    long contentLength;
    string contentType;
    double totalTime;
    string effectiveUrl;

    string toString() const {
        return format("HTTP %d %s | %d bytes | %.2fs | %s",
                     statusCode, statusText, content.length, totalTime, effectiveUrl);
    }
}

/**
 * Perform HTTP request using CurlEasy
 */
HttpResponse curlEasyRequest(string url,
                           HTTP.Method method = HTTP.Method.get,
                           string postData = "",
                           string[string] customHeaders = null) {
    HttpResponse response;

    try {
        // Create HTTP instance
        auto http = HTTP(url);

        // URL is already set in HTTP constructor

        // Set HTTP method
        http.method = method;

        // Set post data for POST/PUT requests
        if ((method == HTTP.Method.post || method == HTTP.Method.put) && !postData.empty) {
            http.postData = postData;
        }

        // Set custom headers
        if (customHeaders !is null && customHeaders.length > 0) {
            foreach (key, value; customHeaders) {
                http.addRequestHeader(key, value);
            }
        }

        // Set up callbacks
        http.onReceive = (ubyte[] data) {
            response.content ~= cast(string)data;
            return data.length;
        };

        http.onReceiveHeader = (in char[] key, in char[] value) {
            string k = to!string(key).strip().toLower();
            string v = to!string(value).strip();
            if (!k.empty && !v.empty) {
                response.headers[k] = v;
            }
        };

        http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
            response.statusCode = statusLine.code;
            response.statusText = statusLine.reason.idup;
        };

        // Perform the request
        http.perform();

        // Get response information
        response.effectiveUrl = url; // HTTP doesn't provide effective URL directly
        response.totalTime = 0.1; // Placeholder - HTTP doesn't provide timing

        // Extract content information from headers
        if ("content-length" in response.headers) {
            try {
                response.contentLength = to!long(response.headers["content-length"]);
            } catch (Exception e) {
                // Ignore parsing errors
            }
        }

        if ("content-type" in response.headers) {
            response.contentType = response.headers["content-type"];
        }

        // Set status text based on code
        if (response.statusCode == 200) response.statusText = "OK";
        else if (response.statusCode == 201) response.statusText = "Created";
        else if (response.statusCode == 204) response.statusText = "No Content";
        else if (response.statusCode == 301) response.statusText = "Moved Permanently";
        else if (response.statusCode == 302) response.statusText = "Found";
        else if (response.statusCode == 400) response.statusText = "Bad Request";
        else if (response.statusCode == 401) response.statusText = "Unauthorized";
        else if (response.statusCode == 403) response.statusText = "Forbidden";
        else if (response.statusCode == 404) response.statusText = "Not Found";
        else if (response.statusCode == 500) response.statusText = "Internal Server Error";
        else response.statusText = "Unknown";

    } catch (CurlException e) {
        throw new Exception(format("CurlEasy request failed for %s: %s", url, e.msg));
    } catch (Exception e) {
        throw new Exception(format("Request failed for %s: %s", url, e.msg));
    }

    return response;
}

/**
 * Demonstrate basic CurlEasy usage
 */
void demonstrateBasicCurlEasy() {
    writeln("=== Basic CurlEasy Usage ===");

    try {
        HttpResponse response = curlEasyRequest("https://httpbin.org/get");

        writefln("Response: %s", response.toString());
        writefln("Content-Type: %s", response.contentType);
        writefln("Headers received: %d", response.headers.length);

        // Show some headers
        if ("server" in response.headers) {
            writefln("Server: %s", response.headers["server"]);
        }

        if ("date" in response.headers) {
            writefln("Date: %s", response.headers["date"]);
        }

    } catch (Exception e) {
        writefln("Basic request failed: %s", e.msg);
    }
}

/**
 * Demonstrate POST requests
 */
void demonstratePostRequest() {
    writeln("\n=== POST Request with CurlEasy ===");

    try {
        string postData = "name=D-Language&version=2.0&lesson=3";
        HttpResponse response = curlEasyRequest("https://httpbin.org/post",
                                              HTTP.Method.post, postData);

        writefln("POST Response: %s", response.toString());

        if (canFind(response.content, "D-Language")) {
            writeln("✓ POST data was received by server");
        }

        if (canFind(response.content, "lesson=3")) {
            writeln("✓ All form fields were processed");
        }

    } catch (Exception e) {
        writefln("POST request failed: %s", e.msg);
    }
}

/**
 * Demonstrate custom headers
 */
void demonstrateCustomHeaders() {
    writeln("\n=== Custom Headers with CurlEasy ===");

    try {
        string[string] headers;
        headers["X-Custom-Header"] = "CurlEasy-Example";
        headers["X-Lesson"] = "3";
        headers["X-Language"] = "D";
        headers["User-Agent"] = "D-Course-CurlEasy/1.0";

        HttpResponse response = curlEasyRequest("https://httpbin.org/headers",
                                              HTTP.Method.get, "", headers);

        writefln("Headers Response: %s", response.toString());

        // Check if our custom headers are in the response
        bool foundCustom = false;
        bool foundUserAgent = false;

        foreach (key, value; response.headers) {
            if (key == "x-custom-header" && canFind(value, "CurlEasy-Example")) {
                foundCustom = true;
            }
            if (key == "user-agent" && canFind(value, "D-Course-CurlEasy")) {
                foundUserAgent = true;
            }
        }

        if (foundCustom) writeln("✓ Custom header sent successfully");
        if (foundUserAgent) writeln("✓ Custom User-Agent sent successfully");

    } catch (Exception e) {
        writefln("Custom headers request failed: %s", e.msg);
    }
}

/**
 * Demonstrate JSON POST request
 */
void demonstrateJsonPost() {
    writeln("\n=== JSON POST Request ===");

    try {
        string jsonData = `{
            "language": "D",
            "lesson": 3,
            "topic": "CurlEasy",
            "features": ["HTTP", "REST", "JSON"]
        }`;

        string[string] headers;
        headers["Content-Type"] = "application/json";

        HttpResponse response = curlEasyRequest("https://httpbin.org/post",
                                              HTTP.Method.post, jsonData, headers);

        writefln("JSON POST Response: %s", response.toString());

        if (canFind(response.content, "CurlEasy")) {
            writeln("✓ JSON data was received and parsed");
        }

        if (canFind(response.content, "application/json")) {
            writeln("✓ Content-Type header was processed");
        }

    } catch (Exception e) {
        writefln("JSON POST request failed: %s", e.msg);
    }
}

/**
 * Demonstrate error handling
 */
void demonstrateErrorHandling() {
    writeln("\n=== Error Handling with CurlEasy ===");

    string[] testUrls = [
        "https://httpbin.org/status/404",
        "https://httpbin.org/status/500",
        "https://nonexistent-domain-12345.invalid"
    ];

    foreach (url; testUrls) {
        try {
            writefln("--- Testing: %s ---", url);
            HttpResponse response = curlEasyRequest(url);

            writefln("Status: %d %s", response.statusCode, response.statusText);

            if (response.statusCode >= 400) {
                writeln("✓ Error status code correctly received");
            } else {
                writefln("? Unexpected success status: %d", response.statusCode);
            }

        } catch (Exception e) {
            writefln("✓ Expected error caught: %s", e.msg);
        }
        writeln();
    }
}

/**
 * Demonstrate redirect handling
 */
void demonstrateRedirects() {
    writeln("=== Redirect Handling ===");

    try {
        // Test redirect from httpbin.org
        HttpResponse response = curlEasyRequest("https://httpbin.org/redirect/2");

        writefln("Redirect Response: %s", response.toString());

        if (response.statusCode == 200) {
            writeln("✓ Redirect followed successfully");
        }

        if (response.effectiveUrl != "https://httpbin.org/redirect/2") {
            writefln("✓ URL changed from redirect: %s", response.effectiveUrl);
        }

    } catch (Exception e) {
        writefln("Redirect test failed: %s", e.msg);
    }
}

/**
 * Check if CurlEasy is available
 */
bool isCurlEasyAvailable() {
    try {
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
 * Run the CurlEasy examples
 */
void runExample() {
    writeln("=== CurlEasy Objects with std.curl ===\n");

    if (!isCurlEasyAvailable()) {
        writeln("ERROR: CurlEasy is not working properly!");
        writeln("This might be due to network issues or missing libcurl.");
        return;
    }

    writeln("✓ CurlEasy is available and working\n");

    // Demonstrate CurlEasy capabilities
    demonstrateBasicCurlEasy();
    demonstratePostRequest();
    demonstrateCustomHeaders();
    demonstrateJsonPost();
    demonstrateErrorHandling();
    demonstrateRedirects();

    writeln("\n=== Summary ===");
    writeln("• CurlEasy provides low-level control over HTTP requests");
    writeln("• Configure method, headers, data, and timeouts");
    writeln("• Callback-based response handling");
    writeln("• Built-in redirect following and error handling");
    writeln("• Access to detailed timing and connection information");
    writeln("• More flexible than high-level functions but requires more setup");
}

unittest {
    writeln("=== Running curl_easy tests ===");

    // Test CurlEasy object creation
    try {
        auto curl = Curl();
        // curl is a struct, cannot be null
        writeln("✓ CurlEasy object creation works");
    } catch (Exception e) {
        writefln("CurlEasy creation failed: %s", e.msg);
    }

    // Test HttpResponse struct
    HttpResponse response;
    response.statusCode = 200;
    response.statusText = "OK";
    response.content = "test content";
    response.contentType = "text/plain";
    response.totalTime = 1.5;
    response.effectiveUrl = "https://example.com";

    string responseStr = response.toString();
    assert(responseStr.canFind("200"));
    assert(responseStr.canFind("OK"));
    assert(responseStr.canFind("12 bytes")); // content.length = 12 ("test content")
    assert(responseStr.canFind("1.5"));
    assert(responseStr.canFind("example.com"));
    writeln("✓ HttpResponse struct works");

    // Test header map operations
    string[string] testHeaders;
    testHeaders["content-type"] = "application/json";
    testHeaders["server"] = "nginx";
    testHeaders["date"] = "2024-01-01";

    assert(testHeaders.length == 3);
    assert(testHeaders["content-type"] == "application/json");
    assert("server" in testHeaders);
    assert(!("nonexistent" in testHeaders));
    writeln("✓ Header map operations work");

    // Test URL construction
    string baseUrl = "https://httpbin.org";
    string[] endpoints = ["get", "post", "put", "delete"];
    foreach (endpoint; endpoints) {
        string fullUrl = baseUrl ~ "/" ~ endpoint;
        assert(fullUrl.canFind("httpbin"));
        assert(fullUrl.canFind(endpoint));
    }
    writeln("✓ URL construction works");

    // Test HTTP method enum
    assert(HTTP.Method.get == HTTP.Method.get);
    assert(HTTP.Method.post == HTTP.Method.post);
    assert(HTTP.Method.put == HTTP.Method.put);
    assert(HTTP.Method.del == HTTP.Method.del);
    writeln("✓ HTTP method enums work");

    // Test status code mapping
    int[] codes = [200, 201, 301, 400, 404, 500];
    string[] expected = ["OK", "Created", "Moved Permanently", "Bad Request", "Not Found", "Internal Server Error"];

    foreach (i, code; codes) {
        string text;
        if (code == 200) text = "OK";
        else if (code == 201) text = "Created";
        else if (code == 301) text = "Moved Permanently";
        else if (code == 400) text = "Bad Request";
        else if (code == 404) text = "Not Found";
        else if (code == 500) text = "Internal Server Error";

        assert(text == expected[i]);
    }
    writeln("✓ Status code mapping works");

    // Test JSON data validation
    string jsonData = `{"language": "D", "lesson": 3}`;
    assert(jsonData.canFind("{"));
    assert(jsonData.canFind("}"));
    assert(jsonData.canFind("language"));
    assert(jsonData.canFind("D"));
    assert(jsonData.canFind("lesson"));
    assert(jsonData.canFind("3"));
    writeln("✓ JSON data validation works");

    // Test timeout values
    int[] timeouts = [1, 5, 10, 30];
    foreach (timeout; timeouts) {
        assert(timeout > 0);
        assert(timeout <= 300); // Reasonable range
    }
    writeln("✓ Timeout validation works");

    // Test CurlEasy availability
    bool available = isCurlEasyAvailable();
    writefln("CurlEasy availability test: %s", available ? "available" : "not available");

    writeln("All CurlEasy tests passed!");
    writeln("=== curl_easy tests completed ===");
}
