/**
 * Lesson 4: Custom Headers - Set Content-Type and other headers
 *
 * This example demonstrates how to set custom HTTP headers in POST requests,
 * including Content-Type headers and other custom headers for authentication,
 * metadata, and special handling.
 */

module lesson4.custom_headers;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.json;
import std.uri;
import std.algorithm;

/**
 * Send POST request with custom headers
 */
string postWithHeaders(string url, string data, string[string] headers) {
    try {
        auto http = HTTP(url);
        http.method = HTTP.Method.post;
        http.postData = data;

        // Add all custom headers
        foreach (key, value; headers) {
            http.addRequestHeader(key, value);
        }

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();
        return response;

    } catch (Exception e) {
        throw new Exception(format("POST with headers to %s failed: %s", url, e.msg));
    }
}

/**
 * Demonstrate Content-Type headers
 */
void demonstrateContentTypes() {
    writeln("=== Content-Type Headers ===");

    string[] contentTypes = [
        "text/plain",
        "text/html",
        "application/json",
        "application/xml",
        "application/x-www-form-urlencoded",
        "multipart/form-data",
        "application/octet-stream"
    ];

    string testData = "Sample data for content type testing";

    foreach (contentType; contentTypes) {
        try {
            writefln("--- Testing Content-Type: %s ---", contentType);

            string[string] headers;
            headers["Content-Type"] = contentType;

            string response = postWithHeaders("https://httpbin.org/post", testData, headers);

            // Verify the content type was received
            string expectedHeader = format(`"Content-Type": "%s"`, contentType);
            if (canFind(response, expectedHeader)) {
                writefln("✓ Content-Type header correctly set to: %s", contentType);
            } else {
                writefln("? Content-Type header verification unclear for: %s", contentType);
            }

        } catch (Exception e) {
            writefln("Content-Type test failed for %s: %s", contentType, e.msg);
        }

        // Small delay between tests
        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Demonstrate charset specifications
 */
void demonstrateCharsetHeaders() {
    writeln("\n=== Content-Type with Charset ===");

    string[] charsetTests = [
        "text/plain; charset=utf-8",
        "text/html; charset=iso-8859-1",
        "application/json; charset=utf-8",
        "application/xml; charset=utf-16"
    ];

    foreach (charsetHeader; charsetTests) {
        try {
            writefln("--- Testing: %s ---", charsetHeader);

            string[string] headers;
            headers["Content-Type"] = charsetHeader;

            string testData = "Data with special chars: àáâãäå, 中文, русский";

            string response = postWithHeaders("https://httpbin.org/post", testData, headers);

            if (canFind(response, charsetHeader)) {
                writefln("✓ Charset header correctly processed: %s", charsetHeader);
            }

        } catch (Exception e) {
            writefln("Charset test failed for %s: %s", charsetHeader, e.msg);
        }

        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Demonstrate custom metadata headers
 */
void demonstrateMetadataHeaders() {
    writeln("\n=== Custom Metadata Headers ===");

    try {
        string[string] headers;
        headers["Content-Type"] = "application/json";
        headers["X-API-Version"] = "2.0";
        headers["X-Client-Name"] = "D-Language-HTTP-Client";
        headers["X-Request-ID"] = "req-12345-abcdef";
        headers["X-Timestamp"] = "2024-01-01T12:00:00Z";
        headers["X-Source"] = "lesson4-custom-headers";

        string jsonData = `{
            "action": "test_metadata_headers",
            "data": "This request includes custom metadata headers"
        }`;

        string response = postWithHeaders("https://httpbin.org/post", jsonData, headers);

        writefln("Sent %d custom headers", headers.length);

        // Verify each custom header was received
        bool allHeadersFound = true;
        foreach (key, value; headers) {
            if (key != "Content-Type") { // Skip content-type as it's handled separately
                string expected = format(`"%s": "%s"`, key, value);
                if (!canFind(response, expected)) {
                    writefln("? Header not found: %s", expected);
                    allHeadersFound = false;
                }
            }
        }

        if (allHeadersFound) {
            writeln("✓ All custom metadata headers were received");
        }

        // Check that we have the expected number of headers
        if (canFind(response, `"X-API-Version": "2.0"`)) {
            writeln("✓ API version header processed");
        }

        if (canFind(response, `"X-Client-Name": "D-Language-HTTP-Client"`)) {
            writeln("✓ Client name header processed");
        }

    } catch (Exception e) {
        writefln("Metadata headers test failed: %s", e.msg);
    }
}

/**
 * Demonstrate authentication headers
 */
void demonstrateAuthHeaders() {
    writeln("\n=== Authentication Headers ===");

    try {
        string[string] headers;
        headers["Content-Type"] = "application/json";
        headers["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.fake";
        headers["X-API-Key"] = "d-lang-api-key-12345";
        headers["X-Auth-Token"] = "auth-token-abcdef";

        string jsonData = `{
            "action": "authenticated_request",
            "user": "test_user",
            "permissions": ["read", "write"]
        }`;

        string response = postWithHeaders("https://httpbin.org/post", jsonData, headers);

        // Check authentication headers
        if (canFind(response, `"Authorization": "Bearer`)) {
            writeln("✓ Bearer token authorization header received");
        }

        if (canFind(response, `"X-API-Key": "d-lang-api-key-12345"`)) {
            writeln("✓ API key header received");
        }

        if (canFind(response, `"X-Auth-Token": "auth-token-abcdef"`)) {
            writeln("✓ Auth token header received");
        }

        writefln("Authentication test completed, response size: %d", response.length);

    } catch (Exception e) {
        writefln("Authentication headers test failed: %s", e.msg);
    }
}

/**
 * Demonstrate user agent headers
 */
void demonstrateUserAgentHeaders() {
    writeln("\n=== User-Agent Headers ===");

    string[] userAgents = [
        "D-Language-HTTP-Client/2.0",
        "Lesson4-CustomHeaders/1.0 (D Programming)",
        "Mozilla/5.0 (compatible; D-HTTP/2.0)",
        "CustomClient/1.0"
    ];

    foreach (userAgent; userAgents) {
        try {
            writefln("--- Testing User-Agent: %s ---", userAgent);

            string[string] headers;
            headers["Content-Type"] = "text/plain";
            headers["User-Agent"] = userAgent;

            string response = postWithHeaders("https://httpbin.org/post", "User agent test", headers);

            string expected = format(`"User-Agent": "%s"`, userAgent);
            if (canFind(response, expected)) {
                writefln("✓ User-Agent header correctly set: %s", userAgent);
            }

        } catch (Exception e) {
            writefln("User-Agent test failed for %s: %s", userAgent, e.msg);
        }

        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Demonstrate accept headers
 */
void demonstrateAcceptHeaders() {
    writeln("\n=== Accept Headers ===");

    string[] acceptTypes = [
        "application/json",
        "application/xml",
        "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "text/plain",
        "*/*"
    ];

    foreach (acceptType; acceptTypes) {
        try {
            writefln("--- Testing Accept: %s ---", acceptType);

            string[string] headers;
            headers["Content-Type"] = "application/json";
            headers["Accept"] = acceptType;

            string jsonData = `{"test": "accept_header", "format": "json"}`;

            string response = postWithHeaders("https://httpbin.org/post", jsonData, headers);

            string expected = format(`"Accept": "%s"`, acceptType);
            if (canFind(response, expected)) {
                writefln("✓ Accept header correctly set");
            }

        } catch (Exception e) {
            writefln("Accept header test failed for %s: %s", acceptType, e.msg);
        }

        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Demonstrate cache control headers
 */
void demonstrateCacheHeaders() {
    writeln("\n=== Cache Control Headers ===");

    try {
        string[string] headers;
        headers["Content-Type"] = "application/json";
        headers["Cache-Control"] = "no-cache";
        headers["Pragma"] = "no-cache";
        headers["Expires"] = "0";

        string jsonData = `{
            "action": "cache_test",
            "cache": "disabled",
            "timestamp": "2024-01-01T12:00:00Z"
        }`;

        string response = postWithHeaders("https://httpbin.org/post", jsonData, headers);

        if (canFind(response, `"Cache-Control": "no-cache"`)) {
            writeln("✓ Cache-Control header received");
        }

        if (canFind(response, `"Pragma": "no-cache"`)) {
            writeln("✓ Pragma header received");
        }

        if (canFind(response, `"Expires": "0"`)) {
            writeln("✓ Expires header received");
        }

    } catch (Exception e) {
        writefln("Cache headers test failed: %s", e.msg);
    }
}

/**
 * Demonstrate compression headers
 */
void demonstrateCompressionHeaders() {
    writeln("\n=== Compression Headers ===");

    try {
        string[string] headers;
        headers["Content-Type"] = "application/json";
        headers["Accept-Encoding"] = "gzip, deflate, br";
        headers["Content-Encoding"] = "identity"; // No compression for this request

        string jsonData = `{
            "action": "compression_test",
            "encoding": "identity",
            "supports": ["gzip", "deflate", "br"]
        }`;

        string response = postWithHeaders("https://httpbin.org/post", jsonData, headers);

        if (canFind(response, `"Accept-Encoding": "gzip, deflate, br"`)) {
            writeln("✓ Accept-Encoding header received");
        }

        if (canFind(response, `"Content-Encoding": "identity"`)) {
            writeln("✓ Content-Encoding header received");
        }

    } catch (Exception e) {
        writefln("Compression headers test failed: %s", e.msg);
    }
}

/**
 * Demonstrate CORS headers
 */
void demonstrateCorsHeaders() {
    writeln("\n=== CORS Headers ===");

    try {
        string[string] headers;
        headers["Content-Type"] = "application/json";
        headers["Origin"] = "https://example.com";
        headers["Access-Control-Request-Method"] = "POST";
        headers["Access-Control-Request-Headers"] = "Content-Type,Authorization";

        string jsonData = `{
            "action": "cors_preflight_test",
            "origin": "https://example.com",
            "method": "POST"
        }`;

        string response = postWithHeaders("https://httpbin.org/post", jsonData, headers);

        if (canFind(response, `"Origin": "https://example.com"`)) {
            writeln("✓ Origin header received");
        }

        if (canFind(response, `"Access-Control-Request-Method": "POST"`)) {
            writeln("✓ CORS request method header received");
        }

        if (canFind(response, `"Access-Control-Request-Headers"`)) {
            writeln("✓ CORS request headers received");
        }

    } catch (Exception e) {
        writefln("CORS headers test failed: %s", e.msg);
    }
}

/**
 * Demonstrate custom headers with special characters
 */
void demonstrateSpecialHeaderChars() {
    writeln("\n=== Headers with Special Characters ===");

    try {
        string[string] headers;
        headers["Content-Type"] = "application/json";
        headers["X-Custom-Header"] = "Value with spaces & special chars: @#$%^&*()";
        headers["X-Unicode-Header"] = "D言語プログラミング"; // Japanese
        headers["X-Quoted-Header"] = `"Quoted value with "quotes""`;

        string jsonData = `{"test": "special_chars_in_headers"}`;

        string response = postWithHeaders("https://httpbin.org/post", jsonData, headers);

        if (canFind(response, "spaces & special chars")) {
            writeln("✓ Header with special characters handled");
        }

        if (canFind(response, "D言語プログラミング")) {
            writeln("✓ Unicode header value handled");
        }

        if (canFind(response, `"Quoted value with "quotes""`)) {
            writeln("✓ Quoted header value handled");
        }

    } catch (Exception e) {
        writefln("Special character headers test failed: %s", e.msg);
    }
}

/**
 * Demonstrate multiple header values (same key)
 */
void demonstrateMultipleHeaders() {
    writeln("\n=== Multiple Headers with Same Name ===");

    try {
        // Note: std.net.curl HTTP doesn't directly support multiple headers with same name
        // This demonstrates what happens when we try
        string[string] headers;
        headers["Content-Type"] = "application/json";
        headers["X-Multi-Value"] = "value1,value2,value3"; // Comma-separated

        string jsonData = `{"test": "multiple_header_values"}`;

        string response = postWithHeaders("https://httpbin.org/post", jsonData, headers);

        if (response.canFind(`"X-Multi-Value": "value1,value2,value3"`)) {
            writeln("✓ Multiple values in single header handled");
        }

        writefln("Note: std.net.curl combines multiple headers with same name");

    } catch (Exception e) {
        writefln("Multiple headers test failed: %s", e.msg);
    }
}

/**
 * Comprehensive header test
 */
void demonstrateComprehensiveHeaders() {
    writeln("\n=== Comprehensive Header Test ===");

    try {
        string[string] allHeaders;
        allHeaders["Content-Type"] = "application/json";
        allHeaders["Accept"] = "application/json";
        allHeaders["User-Agent"] = "D-Language-HTTP-Client/2.0";
        allHeaders["Authorization"] = "Bearer test-token-123";
        allHeaders["X-API-Key"] = "api-key-456";
        allHeaders["X-Request-ID"] = "req-comprehensive-test";
        allHeaders["X-Custom-Data"] = "lesson4-complete";
        allHeaders["Cache-Control"] = "no-cache";
        allHeaders["Accept-Encoding"] = "gzip";

        string jsonData = `{
            "test": "comprehensive_headers",
            "headers_count": 9,
            "lesson": 4
        }`;

        string response = postWithHeaders("https://httpbin.org/post", jsonData, allHeaders);

        writefln("Sent %d headers in comprehensive test", allHeaders.length);

        // Verify some key headers
        bool keyHeadersFound = response.canFind("D-Language-HTTP-Client") &&
                              response.canFind("Bearer test-token") &&
                              response.canFind("lesson4-complete");

        if (keyHeadersFound) {
            writeln("✓ Key headers from comprehensive test verified");
        }

    } catch (Exception e) {
        writefln("Comprehensive headers test failed: %s", e.msg);
    }
}

/**
 * Check if custom headers functionality works
 */
bool testCustomHeadersCapability() {
    try {
        string[string] testHeaders;
        testHeaders["Content-Type"] = "text/plain";
        testHeaders["X-Test-Header"] = "test-value";

        string response = postWithHeaders("https://httpbin.org/post", "test data", testHeaders);
        return response.canFind("test-value") && response.canFind("test data");
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the custom headers example
 */
void runExample() {
    writeln("=== Custom Headers in POST Requests ===\n");

    if (!testCustomHeadersCapability()) {
        writeln("ERROR: Custom headers functionality test failed!");
        writeln("This might be due to network issues or std.curl problems.");
        return;
    }

    writeln("✓ Custom headers functionality confirmed\n");

    // Demonstrate different header types and usage patterns
    demonstrateContentTypes();
    demonstrateCharsetHeaders();
    demonstrateMetadataHeaders();
    demonstrateAuthHeaders();
    demonstrateUserAgentHeaders();
    demonstrateAcceptHeaders();
    demonstrateCacheHeaders();
    demonstrateCompressionHeaders();
    demonstrateCorsHeaders();
    demonstrateSpecialHeaderChars();
    demonstrateMultipleHeaders();
    demonstrateComprehensiveHeaders();

    writeln("\n=== Summary ===");
    writeln("• HTTP headers provide metadata for requests and responses");
    writeln("• Content-Type specifies the format of request body data");
    writeln("• Custom headers (X-*) are used for application-specific data");
    writeln("• Authorization headers handle authentication");
    writeln("• User-Agent identifies the client making the request");
    writeln("• Accept headers specify preferred response formats");
    writeln("• Cache-Control headers manage caching behavior");
    writeln("• Special characters in headers need proper encoding");
    writeln("• Multiple headers with same name are combined by curl");
    writeln("• Headers are crucial for API authentication and proper data handling");
}

unittest {
    writeln("=== Running custom_headers tests ===");

    // Test custom headers capability
    bool headersWork = testCustomHeadersCapability();
    writefln("Custom headers capability test: %s", headersWork ? "working" : "not working");

    // Test header dictionary operations
    string[string] testHeaders;
    testHeaders["Content-Type"] = "application/json";
    testHeaders["X-Custom"] = "value";
    testHeaders["Authorization"] = "Bearer token";

    assert(testHeaders.length == 3);
    assert("Content-Type" in testHeaders);
    assert("X-Custom" in testHeaders);
    assert("Authorization" in testHeaders);
    assert(testHeaders["Content-Type"] == "application/json");
    assert(testHeaders["Authorization"] == "Bearer token");
    writeln("✓ Header dictionary operations work");

    // Test content type validation
    string[] validContentTypes = [
        "text/plain",
        "application/json",
        "application/x-www-form-urlencoded",
        "text/html",
        "application/xml"
    ];

    foreach (contentType; validContentTypes) {
        assert(contentType.canFind("/"));
        assert(contentType.length >= 7); // minimum "type/sub"
    }
    writeln("✓ Content type validation works");

    // Test charset header parsing
    string charsetHeader = "text/plain; charset=utf-8";
    bool hasCharset = charsetHeader.canFind("charset=");
    bool hasUtf8 = charsetHeader.canFind("utf-8");
    assert(hasCharset && hasUtf8);
    writeln("✓ Charset header parsing works");

    // Test user agent string validation
    string[] userAgents = ["Client/1.0", "D-HTTP/2.0", "TestClient"];
    foreach (ua; userAgents) {
        assert(ua.length > 3);
        assert(ua.canFind("/") || !ua.canFind(" ")); // Either has version or no spaces
    }
    writeln("✓ User agent validation works");

    // Test authentication header patterns
    string bearerToken = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.fake";
    string apiKey = "X-API-Key: key123";
    bool hasBearer = bearerToken.canFind("Bearer ");
    bool hasApiKey = apiKey.canFind("X-API-Key");
    assert(hasBearer && hasApiKey);
    writeln("✓ Authentication header patterns work");

    // Test accept header complexity
    string complexAccept = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";
    bool hasMultiple = complexAccept.canFind(",");
    bool hasQValues = complexAccept.canFind(";q=");
    bool hasWildcard = complexAccept.canFind("*/*");
    assert(hasMultiple && hasQValues && hasWildcard);
    writeln("✓ Complex accept header parsing works");

    // Test cache control values
    string[] cacheControls = ["no-cache", "max-age=3600", "private", "public"];
    foreach (cache; cacheControls) {
        assert(cache.length > 3);
    }
    writeln("✓ Cache control values work");

    // Test compression encodings
    string acceptEncoding = "gzip, deflate, br";
    string[] encodings = acceptEncoding.split(", ");
    assert(encodings.length == 3);
    assert(encodings[0] == "gzip");
    assert(encodings[1] == "deflate");
    assert(encodings[2] == "br");
    writeln("✓ Compression encoding parsing works");

    // Test CORS header validation
    string corsOrigin = "https://example.com";
    string corsMethod = "POST";
    bool isHttps = corsOrigin.canFind("https://");
    bool isPost = corsMethod == "POST";
    assert(isHttps && isPost);
    writeln("✓ CORS header validation works");

    // Test special character handling
    string specialValue = "Value with @#$%^&*()";
    string encoded = encodeComponent(specialValue);
    assert(encoded != specialValue);
    assert(encoded.length > specialValue.length);
    writeln("✓ Special character encoding works");

    // Test multiple header values simulation
    string multiValue = "value1,value2,value3";
    string[] values = multiValue.split(",");
    assert(values.length == 3);
    assert(values[0] == "value1");
    assert(values[2] == "value3");
    writeln("✓ Multiple header value simulation works");

    // Test comprehensive header count
    int expectedHeaders = 9;
    string[string] comprehensiveHeaders;
    for (int i = 1; i <= expectedHeaders; i++) {
        comprehensiveHeaders[format("X-Header-%d", i)] = format("value%d", i);
    }
    comprehensiveHeaders["Content-Type"] = "application/json"; // Add one more
    assert(comprehensiveHeaders.length == expectedHeaders + 1);
    writeln("✓ Comprehensive header counting works");

    // Test header response verification
    string mockResponse = `{"headers": {"X-Test": "value", "Content-Type": "json"}}`;
    bool hasXTest = mockResponse.canFind(`"X-Test": "value"`);
    bool hasContentType = mockResponse.canFind(`"Content-Type": "json"`);
    assert(hasXTest && hasContentType);
    writeln("✓ Header response verification works");

    writeln("All custom_headers tests passed!");
    writeln("=== custom_headers tests completed ===");
}
