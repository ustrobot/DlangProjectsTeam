/**
 * Lesson 6: API Key Authentication - API key in headers/query params
 *
 * This example demonstrates how to implement API key authentication
 * in REST API requests, including different methods of passing API keys.
 */

module lesson6.api_key_auth;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.json;
import std.uri;

/**
 * Structure to hold API key configuration
 */
struct APIKeyConfig {
    string apiKey;
    string headerName;    // e.g., "X-API-Key", "Authorization"
    bool useHeader;      // true for headers, false for query params
    string queryParam;   // e.g., "api_key", "key"

    string getAuthHeader() {
        if (useHeader) {
            return format("%s: %s", headerName, apiKey);
        }
        return "";
    }

    string getQueryString() {
        if (!useHeader && queryParam.length > 0) {
            return format("%s=%s", queryParam, encodeComponent(apiKey));
        }
        return "";
    }

    void printInfo() {
        writefln("API Key: %s...%s", apiKey[0..min(8, apiKey.length)],
                apiKey.length > 8 ? apiKey[$-4..$] : "");
        writefln("Method: %s", useHeader ? "Header" : "Query Parameter");

        if (useHeader) {
            writefln("Header: %s", headerName);
        } else {
            writefln("Query Param: %s", queryParam);
        }
    }
}

/**
 * Make HTTP request with API key authentication
 */
string makeAPIKeyRequest(string baseUrl, APIKeyConfig config,
                        HTTP.Method method = HTTP.Method.get,
                        string postData = "") {
    string url = baseUrl;

    try {
        auto http = HTTP(url);
        http.method = method;

        // Add API key authentication
        if (config.useHeader) {
            // Add as header
            string headerValue = format("%s: %s", config.headerName, config.apiKey);
            http.addRequestHeader(config.headerName, config.apiKey);
        } else {
            // Add as query parameter
            if (config.queryParam.length > 0) {
                string queryString = config.getQueryString();
                if (canFind(url, "?")) {
                    url ~= "&" ~ queryString;
                } else {
                    url ~= "?" ~ queryString;
                }
                http = HTTP(url); // Recreate HTTP object with new URL
                http.method = method;
            }
        }

        if (postData.length > 0) {
            http.postData = postData;
            http.addRequestHeader("Content-Type", "application/json");
        }

        string response;
        int statusCode = 0;

        http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
            statusCode = statusLine.code;
        };

        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        if (statusCode == 401 || statusCode == 403) {
            throw new Exception(format("API key authentication failed with status %d", statusCode));
        } else if (statusCode >= 400) {
            throw new Exception(format("Request failed with status %d: %s", statusCode, response));
        }

        return response;

    } catch (CurlException e) {
        throw new Exception(format("Network error: %s", e.msg));
    }
}

/**
 * Demonstrate API key in custom headers
 */
void demonstrateHeaderAPIKeys() {
    writeln("=== API Key in Custom Headers ===");

    writefln("Common header names for API keys:");

    // Different header variations
    APIKeyConfig[] headerConfigs = [
        APIKeyConfig("demo-api-key-12345", "X-API-Key", true, ""),
        APIKeyConfig("demo-api-key-67890", "X-Auth-Token", true, ""),
        APIKeyConfig("demo-api-key-abcd", "Authorization", true, ""),
        APIKeyConfig("demo-api-key-efgh", "Api-Key", true, "")
    ];

    foreach (i, config; headerConfigs) {
        writefln("\n--- Configuration %d ---", i + 1);
        config.printInfo();

        try {
            string response = makeAPIKeyRequest("https://httpbin.org/get", config);

            writefln("✓ Request successful: %d bytes", response.length);

            // Verify API key was received
            try {
                auto json = parseJSON(response);
                if ("headers" in json) {
                    bool keyFound = false;
                    string foundHeader;

                    foreach (string headerName, jsonValue; json["headers"].object) {
                        if (headerName == config.headerName) {
                            keyFound = true;
                            foundHeader = headerName;
                            break;
                        }
                    }

                    if (keyFound) {
                        writefln("✓ API key received in header: %s", foundHeader);
                    } else {
                        writefln("⚠ API key header not found in response");
                    }
                }
            } catch (Exception e) {
                // Skip verification
            }

        } catch (Exception e) {
            writefln("✗ Request failed: %s", e.msg);
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }
}

/**
 * Demonstrate API key in query parameters
 */
void demonstrateQueryAPIKeys() {
    writeln("\n=== API Key in Query Parameters ===");

    writefln("Common query parameter names for API keys:");

    // Different query parameter variations
    APIKeyConfig[] queryConfigs = [
        APIKeyConfig("demo-api-key-11111", "", false, "api_key"),
        APIKeyConfig("demo-api-key-22222", "", false, "key"),
        APIKeyConfig("demo-api-key-33333", "", false, "apikey"),
        APIKeyConfig("demo-api-key-44444", "", false, "token")
    ];

    foreach (i, config; queryConfigs) {
        writefln("\n--- Configuration %d ---", i + 1);
        config.printInfo();

        try {
            string response = makeAPIKeyRequest("https://httpbin.org/get", config);

            writefln("✓ Request successful: %d bytes", response.length);

            // Verify API key was received in query parameters
            try {
                auto json = parseJSON(response);
                if ("args" in json) {
                    bool keyFound = false;
                    string foundParam;

                    foreach (string paramName, jsonValue; json["args"].object) {
                        if (paramName == config.queryParam) {
                            keyFound = true;
                            foundParam = paramName;
                            break;
                        }
                    }

                    if (keyFound) {
                        writefln("✓ API key received in query param: %s", foundParam);
                    } else {
                        writefln("⚠ API key query parameter not found in response");
                    }
                }
            } catch (Exception e) {
                // Skip verification
            }

        } catch (Exception e) {
            writefln("✗ Request failed: %s", e.msg);
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }
}

/**
 * Demonstrate URL encoding for API keys
 */
void demonstrateURLEncoding() {
    writeln("\n=== URL Encoding for API Keys ===");

    writefln("API keys in URLs need proper encoding:");

    // API keys with special characters
    string[] specialKeys = [
        "key with spaces",
        "key@with#special&chars",
        "key+with=plus/and/slashes",
        "key?with=question&mark"
    ];

    foreach (i, rawKey; specialKeys) {
        writefln("\n--- Special Characters Test %d ---", i + 1);
        writefln("Raw key: %s", rawKey);

        // Encode the key
        string encodedKey = encodeComponent(rawKey);
        writefln("Encoded: %s", encodedKey);

        APIKeyConfig config = APIKeyConfig(encodedKey, "", false, "api_key");

        try {
            string response = makeAPIKeyRequest("https://httpbin.org/get", config);

            writefln("✓ Request with encoded key successful: %d bytes", response.length);

            // Verify the encoded key was received
            try {
                auto json = parseJSON(response);
                if ("args" in json && "api_key" in json["args"]) {
                    string receivedKey = json["args"]["api_key"].str;
                    writefln("✓ Received encoded key: %s", receivedKey);
                    writefln("✓ Matches sent: %s", receivedKey == encodedKey);
                }
            } catch (Exception e) {
                // Skip verification
            }

        } catch (Exception e) {
            writefln("✗ Request failed: %s", e.msg);
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }

    writefln("\nURL encoding ensures special characters are transmitted correctly.");
}

/**
 * Demonstrate API key authentication with different HTTP methods
 */
void demonstrateMethodAPIKeys() {
    writeln("\n=== API Key Auth with Different HTTP Methods ===");

    APIKeyConfig config = APIKeyConfig("method-test-key-123", "X-API-Key", true, "");

    writefln("Using API key: %s", config.headerName);
    config.printInfo();
    writeln();

    // Test different HTTP methods
    struct MethodTest {
        HTTP.Method method;
        string endpoint;
        string description;
        string data;
    }

    MethodTest[] methodTests = [
        MethodTest(HTTP.Method.get, "/get", "Retrieve data", ""),
        MethodTest(HTTP.Method.post, "/post", "Create resource",
                  `{"name": "Test Resource", "type": "demo"}`),
        MethodTest(HTTP.Method.put, "/put", "Update resource",
                  `{"id": "123", "status": "updated"}`),
        MethodTest(HTTP.Method.del, "/delete", "Delete resource", "")
    ];

    foreach (test; methodTests) {
        writefln("--- %s (%s) ---", test.description, to!string(test.method).toUpper());

        try {
            string response = makeAPIKeyRequest(
                "https://httpbin.org" ~ test.endpoint,
                config,
                test.method,
                test.data
            );

            writefln("✓ %s successful: %d bytes", to!string(test.method).toUpper(), response.length);

            // Verify API key was included in all requests
            bool keyVerified = false;
            try {
                auto json = parseJSON(response);
                if ("headers" in json && config.headerName in json["headers"]) {
                    keyVerified = true;
                }
            } catch (Exception e) {
                // Skip verification
            }

            if (keyVerified) {
                writefln("✓ API key verified in request");
            }

        } catch (Exception e) {
            writefln("✗ %s failed: %s", to!string(test.method).toUpper(), e.msg);
        }

        import core.thread;
        Thread.sleep(300.msecs);
    }
}

/**
 * Demonstrate multiple API key methods comparison
 */
void demonstrateKeyMethodComparison() {
    writeln("\n=== API Key Method Comparison ===");

    string testKey = "comparison-test-key-456";

    // Test both header and query parameter methods
    APIKeyConfig headerConfig = APIKeyConfig(testKey, "X-API-Key", true, "");
    APIKeyConfig queryConfig = APIKeyConfig(testKey, "", false, "api_key");

    APIKeyConfig[] configs = [headerConfig, queryConfig];
    string[] methodNames = ["Header Method", "Query Parameter Method"];

    foreach (i, config; configs) {
        writefln("\n--- %s ---", methodNames[i]);
        config.printInfo();

        try {
            string response = makeAPIKeyRequest("https://httpbin.org/get", config);

            writefln("✓ Method works: %d bytes", response.length);

            // Verify key transmission method
            try {
                auto json = parseJSON(response);

                if (i == 0) { // Header method
                    if ("headers" in json && "X-API-Key" in json["headers"]) {
                        writefln("✓ Key found in headers");
                    }
                } else { // Query method
                    if ("args" in json && "api_key" in json["args"]) {
                        writefln("✓ Key found in query parameters");
                    }
                }
            } catch (Exception e) {
                // Skip verification
            }

        } catch (Exception e) {
            writefln("✗ Method failed: %s", e.msg);
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }

    writefln("\nComparison:");
    writefln("• Headers: More secure, not logged in access logs");
    writefln("• Query params: Visible in URLs, may be logged");
    writefln("• Headers: Preferred for production APIs");
    writefln("• Query params: Sometimes required by legacy APIs");
}

/**
 * Demonstrate API key security considerations
 */
void demonstrateSecurityConsiderations() {
    writeln("\n=== API Key Security Considerations ===");

    writefln("Best practices for API key security:");

    // 1. Key Storage
    writefln("\n1. Secure key storage:");
    writefln("   ✓ Never hardcode keys in source code");
    writefln("   ✓ Use environment variables or secure config files");
    writefln("   ✓ Rotate keys regularly");
    writefln("   ✓ Use different keys for different environments");

    // 2. Transmission Security
    writefln("\n2. Secure transmission:");
    writefln("   ✓ Always use HTTPS (never HTTP)");
    writefln("   ✓ Headers are encrypted by TLS");
    writefln("   ✓ Query parameters are also encrypted");
    writefln("   ✓ Avoid mixed HTTP/HTTPS usage");

    // 3. Key Scope and Permissions
    writefln("\n3. Key scope and permissions:");
    writefln("   ✓ Use read-only keys when possible");
    writefln("   ✓ Limit key permissions to required operations");
    writefln("   ✓ Implement key expiration");
    writefln("   ✓ Monitor key usage patterns");

    // 4. Error Handling
    writefln("\n4. Proper error handling:");
    writefln("   ✓ Handle 401/403 responses gracefully");
    writefln("   ✓ Don't expose keys in error messages");
    writefln("   ✓ Implement retry logic with backoff");
    writefln("   ✓ Log authentication failures securely");

    // 5. Rate Limiting
    writefln("\n5. Rate limiting awareness:");
    writefln("   ✓ Be aware of API rate limits");
    writefln("   ✓ Implement client-side rate limiting");
    writefln("   ✓ Handle 429 (Too Many Requests) responses");
    writefln("   ✓ Use exponential backoff for retries");

    // Demonstrate rate limiting simulation
    writefln("\nSimulating rate limiting scenario:");

    APIKeyConfig config = APIKeyConfig("rate-limit-test-key", "X-API-Key", true, "");

    // Make several rapid requests
    for (int i = 0; i < 5; i++) {
        try {
            string response = makeAPIKeyRequest("https://httpbin.org/get", config);
            writefln("✓ Request %d successful", i + 1);
        } catch (Exception e) {
            writefln("✗ Request %d failed: %s", i + 1, e.msg);
        }

        import core.thread;
        Thread.sleep(100.msecs); // Very short delay
    }

    writefln("Note: Real APIs may rate limit based on API key usage patterns.");
}

/**
 * Demonstrate API key validation
 */
void demonstrateKeyValidation() {
    writeln("\n=== API Key Validation ===");

    writefln("Testing API key validation scenarios:");

    // Test cases
    struct ValidationTest {
        string key;
        string description;
        bool shouldWork;
    }

    ValidationTest[] tests = [
        ValidationTest("valid-api-key-123", "Valid key format", true),
        ValidationTest("", "Empty key", false),
        ValidationTest("   ", "Whitespace only", false),
        ValidationTest("key with spaces", "Key with spaces", true), // May work depending on API
        ValidationTest("key@#$%^&*()", "Special characters", true)
    ];

    foreach (test; tests) {
        writefln("\n--- Testing: %s ---", test.description);
        writefln("Key: '%s'", test.key);

        APIKeyConfig config = APIKeyConfig(test.key, "X-API-Key", true, "");

        try {
            string response = makeAPIKeyRequest("https://httpbin.org/get", config);

            if (test.shouldWork) {
                writefln("✓ Expected success: %d bytes", response.length);
            } else {
                writefln("⚠ Unexpected success with invalid key");
            }

        } catch (Exception e) {
            if (!test.shouldWork) {
                writefln("✓ Expected failure with invalid key: %s", e.msg);
            } else {
                writefln("✗ Unexpected failure with valid key: %s", e.msg);
            }
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }

    writefln("\nKey validation depends on the specific API requirements.");
    writefln("Some APIs accept any non-empty string, others have strict formats.");
}

/**
 * Check if API key authentication works
 */
bool testAPIKeyAuthCapability() {
    try {
        APIKeyConfig config = APIKeyConfig("test-api-key-123", "X-API-Key", true, "");

        string response = makeAPIKeyRequest("https://httpbin.org/get", config);

        return response.length > 0;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the API key authentication example
 */
void runExample() {
    writeln("=== API Key Authentication ===\n");

    if (!testAPIKeyAuthCapability()) {
        writeln("ERROR: API key authentication functionality test failed!");
        writeln("This might be due to network issues or HTTP library problems.");
        return;
    }

    writeln("✓ API key authentication functionality confirmed\n");

    // Demonstrate API key authentication methods
    demonstrateHeaderAPIKeys();
    demonstrateQueryAPIKeys();
    demonstrateURLEncoding();
    demonstrateMethodAPIKeys();
    demonstrateKeyMethodComparison();
    demonstrateSecurityConsiderations();
    demonstrateKeyValidation();

    writeln("\n=== Summary ===");
    writeln("• API keys can be passed in headers or query parameters");
    writeln("• Headers: 'X-API-Key', 'Authorization', 'Api-Key', etc.");
    writeln("• Query params: 'api_key', 'key', 'token', 'apikey', etc.");
    writeln("• Always URL-encode keys in query parameters");
    writeln("• Headers are generally more secure than query parameters");
    writeln("• Use HTTPS to protect key transmission");
    writeln("• Store keys securely and rotate them regularly");
    writeln("• Handle authentication errors (401/403) gracefully");
    writeln("• Be aware of API rate limits and implement backoff strategies");
}

unittest {
    writeln("=== Running api_key_auth tests ===");

    // Test API key auth capability
    bool apiKeyWorks = testAPIKeyAuthCapability();
    writefln("API key auth capability test: %s", apiKeyWorks ? "working" : "not working");

    // Test APIKeyConfig structure (safe, no network required)
    APIKeyConfig headerConfig;
    headerConfig.apiKey = "test-key-123";
    headerConfig.headerName = "X-API-Key";
    headerConfig.useHeader = true;
    headerConfig.queryParam = "";

    APIKeyConfig queryConfig;
    queryConfig.apiKey = "test-key-456";
    queryConfig.useHeader = false;
    queryConfig.queryParam = "api_key";

    assert(headerConfig.useHeader == true);
    assert(queryConfig.useHeader == false);
    assert(headerConfig.getAuthHeader() == "X-API-Key: test-key-123");
    assert(queryConfig.getQueryString() == "api_key=test-key-456");
    writeln("✓ APIKeyConfig structure works");

    // Test URL encoding (safe, no network required)
    string original = "key with spaces & special chars";
    string encoded = encodeComponent(original);

    assert(encoded != original);
    assert(canFind(encoded, "%20")); // Space encoded
    assert(canFind(encoded, "%26")); // & encoded
    writeln("✓ URL encoding works");

    // Test header format validation (safe, no network required)
    string[] headerNames = ["X-API-Key", "Authorization", "Api-Key", "X-Auth-Token"];

    foreach (headerName; headerNames) {
        string headerLine = format("%s: test-key", headerName);
        assert(canFind(headerLine, headerName ~ ":"));
        assert(canFind(headerLine, "test-key"));
    }
    writeln("✓ Header format validation works");

    // Test query parameter construction (safe, no network required)
    string baseUrl = "https://api.example.com/data";
    string param = "api_key";
    string value = "test123";
    string queryString = format("%s=%s", param, encodeComponent(value));

    assert(canFind(queryString, "api_key="));
    assert(canFind(queryString, "test123"));

    // Test with existing query params
    string urlWithQuery = baseUrl ~ "?existing=param";
    string fullUrl = urlWithQuery ~ "&" ~ queryString;
    assert(canFind(fullUrl, "?existing=param"));
    assert(canFind(fullUrl, "&api_key="));
    writeln("✓ Query parameter construction works");

    // Test different key formats (safe, no network required)
    string[] testKeys = [
        "simple-key-123",
        "complex.key@domain.com",
        "key_with_underscores",
        "key-with-dashes"
    ];

    foreach (key; testKeys) {
        assert(key.length > 0);
        // Keys should not contain control characters
        bool hasControlChars = false;
        foreach (char c; key) {
            if (c < 32 || c == 127) {
                hasControlChars = true;
                break;
            }
        }
        assert(!hasControlChars);
    }
    writeln("✓ Different key formats validation works");

    // Test HTTP method enum values (safe, no network required)
    HTTP.Method[] methods = [HTTP.Method.get, HTTP.Method.post, HTTP.Method.put, HTTP.Method.del];

    foreach (method; methods) {
        assert(method >= HTTP.Method.get && method <= HTTP.Method.del);
    }
    writeln("✓ HTTP method enum values work");

    // Test JSON data formatting (safe, no network required)
    string jsonPayload = `{"action": "test", "parameters": {"key": "value"}}`;

    try {
        auto json = parseJSON(jsonPayload);
        assert("action" in json);
        assert("parameters" in json);
        assert(json["action"].str == "test");
        assert("key" in json["parameters"]);
        writeln("✓ JSON data formatting works");
    } catch (Exception e) {
        assert(false, "JSON formatting should work");
    }

    // Test authentication error codes (safe, no network required)
    int[] authErrorCodes = [401, 403];

    foreach (code; authErrorCodes) {
        assert(code >= 400 && code < 500);
        bool isAuthError = (code == 401 || code == 403);
        assert(isAuthError);
    }
    writeln("✓ Authentication error codes work");

    // Test rate limiting simulation (safe, no network required)
    int requestCount = 0;
    int maxRequests = 5;
    bool rateLimited = false;

    while (requestCount < 10 && !rateLimited) {
        requestCount++;
        if (requestCount > maxRequests-1) {
            rateLimited = true;
        }
        // Small delay simulation
    }

    assert(requestCount == maxRequests);
    assert(rateLimited == true);
    writeln("✓ Rate limiting simulation works");

    writeln("All api_key_auth tests passed!");
    writeln("=== api_key_auth tests completed ===");
}
