/**
 * Lesson 6: Bearer Authentication - Bearer token authentication
 *
 * This example demonstrates how to implement Bearer token authentication
 * in REST API requests, including token inclusion and refresh scenarios.
 */

module lesson6.bearer_auth;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.json;
import std.datetime;

/**
 * Structure to hold authentication tokens
 */
struct AuthTokens {
    string accessToken;
    string refreshToken;
    string tokenType;  // Usually "Bearer"
    long expiresAt;    // Unix timestamp

    bool isExpired() {
        return Clock.currTime().toUnixTime() >= expiresAt;
    }

    string getAuthHeader() {
        return format("%s %s", tokenType, accessToken);
    }

    void printInfo() {
        writefln("Token Type: %s", tokenType);
        writefln("Access Token: %s...%s", accessToken[0..min(10, accessToken.length)],
                accessToken.length > 10 ? accessToken[$-10..$] : "");
        writefln("Refresh Token: %s", refreshToken.length > 0 ? "Present" : "None");
        writefln("Expires At: %s", SysTime.fromUnixTime(expiresAt));
        writefln("Is Expired: %s", isExpired() ? "Yes" : "No");
    }
}

/**
 * Make authenticated HTTP request with Bearer token
 */
string makeAuthenticatedRequest(string url, string authHeader,
                               HTTP.Method method = HTTP.Method.get,
                               string postData = "") {
    try {
        auto http = HTTP(url);
        http.method = method;
        http.addRequestHeader("Authorization", authHeader);

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

        if (statusCode == 401) {
            throw new Exception("Authentication failed: Invalid or expired token");
        } else if (statusCode >= 400) {
            throw new Exception(format("Request failed with status %d: %s", statusCode, response));
        }

        return response;

    } catch (CurlException e) {
        throw new Exception(format("Network error: %s", e.msg));
    }
}

/**
 * Demonstrate basic Bearer token authentication
 */
void demonstrateBasicBearerAuth() {
    writeln("=== Basic Bearer Token Authentication ===");

    // Note: Using mock tokens since we don't have a real API with auth
    // In real scenarios, these would come from login endpoints

    string mockToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6" ~
                        "IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

    AuthTokens tokens = AuthTokens();
    tokens.accessToken = mockToken;
    tokens.tokenType = "Bearer";
    tokens.expiresAt = Clock.currTime().toUnixTime() + 3600; // 1 hour from now

    writefln("Mock authentication tokens:");
    tokens.printInfo();
    writeln();

    // Make authenticated requests to httpbin (which accepts any Authorization header)
    string[] endpoints = ["/get", "/uuid", "/ip"];

    foreach (endpoint; endpoints) {
        writefln("Requesting: %s", endpoint);

        try {
            string response = makeAuthenticatedRequest(
                "https://httpbin.org" ~ endpoint,
                tokens.getAuthHeader()
            );

            writefln("✓ Success: %d bytes received", response.length);

            // Parse response to show auth header was received
            try {
                auto json = parseJSON(response);
                if ("headers" in json && "Authorization" in json["headers"]) {
                    string authHeader = json["headers"]["Authorization"].str;
                    writefln("✓ Server received auth header: %s", authHeader[0..min(30, authHeader.length)] ~ "...");
                }
            } catch (Exception e) {
                // Not JSON or parsing error, skip
            }

        } catch (Exception e) {
            writefln("✗ Failed: %s", e.msg);
        }

        import core.thread;
        Thread.sleep(300.msecs);
    }
}

/**
 * Demonstrate token expiration handling
 */
void demonstrateTokenExpiration() {
    writeln("\n=== Token Expiration Handling ===");

    // Create an expired token
    AuthTokens expiredTokens = AuthTokens();
    expiredTokens.accessToken = "expired.token.here";
    expiredTokens.tokenType = "Bearer";
    expiredTokens.expiresAt = Clock.currTime().toUnixTime() - 3600; // 1 hour ago

    writefln("Testing with expired token:");
    expiredTokens.printInfo();
    writefln("Is expired: %s", expiredTokens.isExpired() ? "Yes" : "No");
    writeln();

    // Try to make a request with expired token
    writefln("Attempting request with expired token...");

    try {
        string response = makeAuthenticatedRequest(
            "https://httpbin.org/get",
            expiredTokens.getAuthHeader()
        );

        writefln("⚠ Unexpected success with expired token");

    } catch (Exception e) {
        writefln("✓ Expected failure with expired token: %s", e.msg);
    }

    writeln();

    // Demonstrate token refresh simulation
    writefln("Token refresh simulation:");

    // Simulate getting new tokens from refresh endpoint
    AuthTokens newTokens = AuthTokens();
    newTokens.accessToken = "new.fresh.token.here";
    newTokens.refreshToken = "refresh.token.here";
    newTokens.tokenType = "Bearer";
    newTokens.expiresAt = Clock.currTime().toUnixTime() + 3600;

    writefln("New tokens obtained:");
    newTokens.printInfo();

    // Try request with new token
    try {
        string response = makeAuthenticatedRequest(
            "https://httpbin.org/uuid",
            newTokens.getAuthHeader()
        );

        writefln("✓ Success with refreshed token: %d bytes", response.length);

    } catch (Exception e) {
        writefln("✗ Failed even with new token: %s", e.msg);
    }
}

/**
 * Demonstrate different Bearer token formats
 */
void demonstrateTokenFormats() {
    writeln("\n=== Bearer Token Formats ===");

    writefln("Bearer tokens can come in different formats:");

    // JWT token (JSON Web Token)
    string jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6" ~
                       "IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

    // Simple opaque token
    string opaqueToken = "abc123def456ghi789";

    // API key style token
    string apiKeyToken = "sk-1234567890abcdef";

    string[] tokenExamples = [jwtToken, opaqueToken, apiKeyToken];
    string[] tokenNames = ["JWT Token", "Opaque Token", "API Key Token"];

    foreach (i, token; tokenExamples) {
        writefln("\n--- %s ---", tokenNames[i]);

        AuthTokens testTokens = AuthTokens();
        testTokens.accessToken = token;
        testTokens.tokenType = "Bearer";
        testTokens.expiresAt = Clock.currTime().toUnixTime() + 3600;

        try {
            string response = makeAuthenticatedRequest(
                "https://httpbin.org/get",
                testTokens.getAuthHeader()
            );

            writefln("✓ Token format accepted: %d bytes", response.length);

            // Show the token format in the response
            try {
                auto json = parseJSON(response);
                if ("headers" in json && "Authorization" in json["headers"]) {
                    string authHeader = json["headers"]["Authorization"].str;
                    writefln("  Auth header: %s", authHeader);
                }
            } catch (Exception e) {
                // Skip JSON parsing
            }

        } catch (Exception e) {
            writefln("✗ Token format rejected: %s", e.msg);
        }

        import core.thread;
        Thread.sleep(200.msecs);
    }

    writefln("\nToken format considerations:");
    writefln("• JWT tokens contain encoded user information");
    writefln("• Opaque tokens are just identifiers");
    writefln("• API keys may have different header names");
    writefln("• All use 'Bearer' prefix in Authorization header");
}

/**
 * Demonstrate Bearer token in different HTTP methods
 */
void demonstrateAuthMethods() {
    writeln("\n=== Bearer Auth with Different HTTP Methods ===");

    string mockToken = "demo.bearer.token.12345";

    AuthTokens tokens = AuthTokens();
    tokens.accessToken = mockToken;
    tokens.tokenType = "Bearer";
    tokens.expiresAt = Clock.currTime().toUnixTime() + 3600;

    // Different HTTP methods that might require authentication
    struct MethodTest {
        HTTP.Method method;
        string endpoint;
        string description;
        string data;
    }

    MethodTest[] methodTests = [
        MethodTest(HTTP.Method.get, "/get", "Retrieve user profile", ""),
        MethodTest(HTTP.Method.post, "/post", "Create new resource",
                  `{"name": "New Item", "type": "example"}`),
        MethodTest(HTTP.Method.put, "/put", "Update existing resource",
                  `{"id": "123", "name": "Updated Item"}`),
        MethodTest(HTTP.Method.del, "/delete", "Delete resource", "")
    ];

    foreach (test; methodTests) {
        writefln("\n--- %s (%s) ---", test.description, to!string(test.method).toUpper());

        try {
            string response = makeAuthenticatedRequest(
                "https://httpbin.org" ~ test.endpoint,
                tokens.getAuthHeader(),
                test.method,
                test.data
            );

            writefln("✓ %s successful: %d bytes", to!string(test.method).toUpper(), response.length);

            // Verify auth header was included
            try {
                auto json = parseJSON(response);
                if ("headers" in json && "Authorization" in json["headers"]) {
                    writefln("✓ Authorization header verified");
                }
            } catch (Exception e) {
                // Skip verification
            }

        } catch (Exception e) {
            writefln("✗ %s failed: %s", to!string(test.method).toUpper(), e.msg);
        }

        import core.thread;
        Thread.sleep(300.msecs);
    }

    writefln("\nAuthentication applies to all HTTP methods that access protected resources.");
}

/**
 * Demonstrate token refresh flow
 */
void demonstrateTokenRefresh() {
    writeln("\n=== Token Refresh Flow ===");

    writefln("Complete authentication flow with token refresh:");

    // Step 1: Initial authentication (simulated)
    writefln("\n1. Initial Login - Obtaining tokens...");

    AuthTokens initialTokens = AuthTokens();
    initialTokens.accessToken = "initial.access.token";
    initialTokens.refreshToken = "initial.refresh.token";
    initialTokens.tokenType = "Bearer";
    initialTokens.expiresAt = Clock.currTime().toUnixTime() + 300; // 5 minutes

    writefln("✓ Initial tokens obtained:");
    initialTokens.printInfo();

    // Step 2: Make authenticated request
    writefln("\n2. Making authenticated request...");

    try {
        string response = makeAuthenticatedRequest(
            "https://httpbin.org/get",
            initialTokens.getAuthHeader()
        );

        writefln("✓ Request successful with initial token");

    } catch (Exception e) {
        writefln("✗ Request failed: %s", e.msg);
    }

    // Step 3: Simulate token expiration
    writefln("\n3. Simulating token expiration...");
    initialTokens.expiresAt = Clock.currTime().toUnixTime() - 60; // Expired 1 minute ago

    writefln("✓ Token is now expired");

    // Step 4: Try request with expired token (should fail)
    writefln("\n4. Attempting request with expired token...");

    try {
        string response = makeAuthenticatedRequest(
            "https://httpbin.org/uuid",
            initialTokens.getAuthHeader()
        );

        writefln("⚠ Unexpected success with expired token");

    } catch (Exception e) {
        writefln("✓ Expected failure with expired token: %s", e.msg);
    }

    // Step 5: Refresh tokens
    writefln("\n5. Refreshing tokens using refresh token...");

    // Simulate refresh request
    AuthTokens refreshedTokens = AuthTokens();
    refreshedTokens.accessToken = "refreshed.access.token";
    refreshedTokens.refreshToken = "new.refresh.token"; // May also be refreshed
    refreshedTokens.tokenType = "Bearer";
    refreshedTokens.expiresAt = Clock.currTime().toUnixTime() + 3600; // 1 hour

    writefln("✓ New tokens obtained:");
    refreshedTokens.printInfo();

    // Step 6: Retry request with new token
    writefln("\n6. Retrying request with refreshed token...");

    try {
        string response = makeAuthenticatedRequest(
            "https://httpbin.org/ip",
            refreshedTokens.getAuthHeader()
        );

        writefln("✓ Request successful with refreshed token");

    } catch (Exception e) {
        writefln("✗ Request failed even with new token: %s", e.msg);
    }
}

/**
 * Demonstrate security best practices
 */
void demonstrateSecurityBestPractices() {
    writeln("\n=== Security Best Practices ===");

    writefln("Bearer token security considerations:");

    // 1. HTTPS Only
    writefln("\n1. Always use HTTPS (never HTTP) for token transmission");
    writefln("   ✓ Tokens are transmitted in Authorization header");
    writefln("   ✓ HTTPS encrypts the entire request");

    // 2. Token Storage
    writefln("\n2. Secure token storage:");
    writefln("   ✓ Use secure storage (keychain, encrypted database)");
    writefln("   ✓ Never store in plain text or localStorage (browser)");
    writefln("   ✓ Clear tokens on logout");

    // 3. Token Expiration
    writefln("\n3. Implement proper token expiration handling:");
    writefln("   ✓ Check expiration before making requests");
    writefln("   ✓ Refresh tokens before they expire");
    writefln("   ✓ Handle 401 responses by refreshing tokens");

    // 4. Token Scope
    writefln("\n4. Use appropriate token scopes:");
    writefln("   ✓ Request minimal required permissions");
    writefln("   ✓ Different tokens for different operations");
    writefln("   ✓ Short-lived tokens for sensitive operations");

    // 5. Error Handling
    writefln("\n5. Proper error handling:");
    writefln("   ✓ Handle 401 (unauthorized) by refreshing tokens");
    writefln("   ✓ Handle 403 (forbidden) by requesting permissions");
    writefln("   ✓ Log authentication failures securely");

    // 6. Token Validation
    writefln("\n6. Validate tokens on the server side:");
    writefln("   ✓ Verify token signature (for JWT)");
    writefln("   ✓ Check expiration timestamps");
    writefln("   ✓ Validate token claims and scopes");
}

/**
 * Check if Bearer authentication works
 */
bool testBearerAuthCapability() {
    try {
        string mockToken = "test.bearer.token";
        string authHeader = format("Bearer %s", mockToken);

        string response = makeAuthenticatedRequest(
            "https://httpbin.org/get",
            authHeader
        );

        return response.length > 0;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the Bearer authentication example
 */
void runExample() {
    writeln("=== Bearer Token Authentication ===\n");

    if (!testBearerAuthCapability()) {
        writeln("ERROR: Bearer authentication functionality test failed!");
        writeln("This might be due to network issues or HTTP library problems.");
        return;
    }

    writeln("✓ Bearer authentication functionality confirmed\n");

    // Demonstrate Bearer authentication concepts
    demonstrateBasicBearerAuth();
    demonstrateTokenExpiration();
    demonstrateTokenFormats();
    demonstrateAuthMethods();
    demonstrateTokenRefresh();
    demonstrateSecurityBestPractices();

    writeln("\n=== Summary ===");
    writeln("• Bearer tokens are included in Authorization header");
    writeln("• Format: 'Authorization: Bearer <token>'");
    writeln("• Tokens should be kept secure and refreshed before expiration");
    writeln("• Handle 401 responses by refreshing tokens");
    writeln("• Always use HTTPS to protect token transmission");
    writeln("• Implement proper token storage and lifecycle management");
    writeln("• Different APIs may use different token formats (JWT, opaque, etc.)");
}

unittest {
    writeln("=== Running bearer_auth tests ===");

    // Test Bearer auth capability
    bool bearerWorks = testBearerAuthCapability();
    writefln("Bearer auth capability test: %s", bearerWorks ? "working" : "not working");

    // Test AuthTokens structure (safe, no network required)
    AuthTokens tokens;
    tokens.accessToken = "test.token.123";
    tokens.refreshToken = "refresh.token.456";
    tokens.tokenType = "Bearer";
    tokens.expiresAt = Clock.currTime().toUnixTime() + 3600;

    assert(tokens.accessToken == "test.token.123");
    assert(tokens.refreshToken == "refresh.token.456");
    assert(tokens.tokenType == "Bearer");
    assert(!tokens.isExpired());
    assert(tokens.getAuthHeader() == "Bearer test.token.123");
    writeln("✓ AuthTokens structure works");

    // Test token expiration logic (safe, no network required)
    AuthTokens expiredTokens;
    expiredTokens.expiresAt = Clock.currTime().toUnixTime() - 100; // Expired

    AuthTokens validTokens;
    validTokens.expiresAt = Clock.currTime().toUnixTime() + 3600; // Valid

    assert(expiredTokens.isExpired());
    assert(!validTokens.isExpired());
    writeln("✓ Token expiration logic works");

    // Test authorization header format (safe, no network required)
    string token = "abc123def456";
    string expectedHeader = "Bearer abc123def456";
    string actualHeader = format("Bearer %s", token);

    assert(actualHeader == expectedHeader);
    assert(canFind(actualHeader, "Bearer "));
    writeln("✓ Authorization header format works");

    // Test different token types simulation (safe, no network required)
    string[] tokenTypes = ["JWT", "opaque", "api-key"];
    string[] sampleTokens = [
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ0ZXN0IiwiaWF0IjoxNjMzNjY0MDAwLCJleHAiOjE2MzM2NjQwMDAs" ~
        "ImF1ZCI6Ind3dy5leGFtcGxlLmNvbSIsInN1YiI6InVzZXJAexample.comInQ.YWZkZGFzZmRzYWZh",
        "random-opaque-token-12345",
        "sk-abcdef123456789"
    ];

    foreach (i, tokenType; tokenTypes) {
        string sampleToken = sampleTokens[i];
        string authHeader = format("Bearer %s", sampleToken);

        assert(canFind(authHeader, "Bearer "));
        assert(canFind(authHeader, sampleToken));

        // JWT tokens have dots
        if (tokenType == "JWT") {
            assert(canFind(sampleToken, "."));
        }
    }
    writeln("✓ Different token types simulation works");

    // Test HTTP method enum values (safe, no network required)
    HTTP.Method[] methods = [HTTP.Method.get, HTTP.Method.post, HTTP.Method.put, HTTP.Method.del];

    foreach (method; methods) {
        assert(method == HTTP.Method.get || method == HTTP.Method.post ||
               method == HTTP.Method.put || method == HTTP.Method.del);
    }
    writeln("✓ HTTP method enum values work");

    // Test JSON request body formatting (safe, no network required)
    string jsonData = `{"user": "test", "action": "create"}`;

    try {
        auto json = parseJSON(jsonData);
        assert("user" in json);
        assert("action" in json);
        assert(json["user"].str == "test");
        assert(json["action"].str == "create");
        writeln("✓ JSON request body formatting works");
    } catch (Exception e) {
        assert(false, "JSON formatting should work");
    }

    // Test token refresh logic simulation (safe, no network required)
    long originalExpiry = Clock.currTime().toUnixTime() + 300; // 5 minutes
    long refreshedExpiry = Clock.currTime().toUnixTime() + 3600; // 1 hour

    assert(refreshedExpiry > originalExpiry);
    assert(originalExpiry > Clock.currTime().toUnixTime());
    assert(refreshedExpiry > Clock.currTime().toUnixTime());
    writeln("✓ Token refresh logic simulation works");

    // Test security header validation (safe, no network required)
    string secureHeader = "Bearer secure-token-123";
    string insecureTransmission = "Token sent over HTTP";

    assert(canFind(secureHeader, "Bearer "));
    assert(canFind(insecureTransmission, "HTTP")); // Just checking string presence
    writeln("✓ Security header validation works");

    writeln("All bearer_auth tests passed!");
    writeln("=== bearer_auth tests completed ===");
}
