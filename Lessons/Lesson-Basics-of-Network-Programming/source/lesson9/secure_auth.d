/**
 * Lesson 9: Secure Authentication - Implementing secure authentication for APIs
 *
 * This example demonstrates secure authentication practices, API key management,
 * and secure communication patterns for web APIs.
 */

module lesson9.secure_auth;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;
import std.random;
import std.array;
import std.json;
import core.time;

/**
 * API key manager for secure key storage and rotation
 */
class APIKeyManager {
    private string[] keys;
    private size_t currentKeyIndex = 0;
    private string[string] keyMetadata;

    /**
     * Add an API key with optional metadata
     */
    void addKey(string key, string metadata = "") {
        keys ~= key;
        if (!metadata.empty) {
            keyMetadata[key] = metadata;
        }
    }

    /**
     * Get next available key (round-robin)
     */
    string getNextKey() {
        if (keys.empty) {
            throw new Exception("No API keys available");
        }

        string key = keys[currentKeyIndex];
        currentKeyIndex = (currentKeyIndex + 1) % keys.length;
        return key;
    }

    /**
     * Mark a key as failed (temporarily disable)
     */
    void markKeyFailed(string key) {
        // In a real implementation, you might move failed keys to a cooldown list
        writefln("API key marked as failed (would be disabled): %s", key);
    }

    /**
     * Get all available keys count
     */
    size_t keyCount() {
        return keys.length;
    }
}

/**
 * Secure HTTP client with authentication
 */
class SecureHTTPClient {
    private APIKeyManager keyManager;
    private string baseUrl;
    private Duration requestTimeout = 30.seconds;

    this(string baseUrl, APIKeyManager keyManager = null) {
        this.baseUrl = baseUrl;
        this.keyManager = keyManager;
    }

    /**
     * Make authenticated GET request
     */
    string get(string endpoint, string[string] headers = null) {
        return makeRequest("GET", endpoint, "", headers);
    }

    /**
     * Make authenticated POST request
     */
    string post(string endpoint, string data, string[string] headers = null) {
        return makeRequest("POST", endpoint, data, headers);
    }

    /**
     * Make authenticated request
     */
    private string makeRequest(string method, string endpoint, string data, string[string] headers) {
        string url = baseUrl ~ endpoint;

        auto http = HTTP(url);
        

        // Add authentication
        if (keyManager) {
            string authHeader = "Bearer " ~ keyManager.getNextKey();
            http.addRequestHeader("Authorization", authHeader);
        }

        // Add custom headers
        if (headers) {
            foreach (key, value; headers) {
                http.addRequestHeader(key, value);
            }
        }

        // Always add content type for POST
        if (method == "POST" && !data.empty) {
            http.addRequestHeader("Content-Type", "application/json");
            http.postData = data;
        }

        // Set method for non-GET requests
        if (method != "GET") {
            http.method = method == "POST" ? HTTP.Method.post :
                         method == "PUT" ? HTTP.Method.put :
                         method == "DELETE" ? HTTP.Method.del :
                         HTTP.Method.get;
        }

        string response;
        http.onReceive = (ubyte[] chunk) {
            response ~= cast(string)chunk;
            return chunk.length;
        };

        try {
            http.perform();
            return response;
        } catch (CurlException e) {
            // On authentication failure, mark key as failed
            // curlCode not available in this version, simplified check
            if (e.msg.canFind("401") || e.msg.canFind("403")) {
                // In a real implementation, check status code
                if (keyManager) {
                    // This is a simplified example
                    writefln("Authentication might have failed for this key");
                }
            }
            throw e;
        }
    }
}

/**
 * Demonstrate API key management
 */
void demonstrateAPIKeyManagement() {
    writeln("=== API Key Management ===");

    auto keyManager = new APIKeyManager();

    // Add some example keys (don't use real keys!)
    keyManager.addKey("sk-example-key-1", "Primary production key");
    keyManager.addKey("sk-example-key-2", "Secondary production key");
    keyManager.addKey("sk-example-key-3", "Development key");

    writefln("API Key Manager initialized with %d keys", keyManager.keyCount());

    // Demonstrate round-robin key selection
    writefln("\nRound-robin key selection:");
    for (int i = 0; i < 5; i++) {
        string key = keyManager.getNextKey();
        // Mask the key for security
        string maskedKey = key[0..4] ~ "..." ~ key[$-4..$];
        writefln("Request %d: Using key %s", i + 1, maskedKey);
    }

    writefln("\nAPI key security best practices:");
    writefln("• Store keys in environment variables, not code");
    writefln("• Use different keys for different environments");
    writefln("• Rotate keys regularly");
    writefln("• Monitor key usage patterns");
    writefln("• Implement key revocation procedures");
    writefln("• Use key management services (AWS KMS, Azure Key Vault, etc.)");
}

/**
 * Demonstrate secure authentication patterns
 */
void demonstrateSecureAuthPatterns() {
    writeln("\n=== Secure Authentication Patterns ===");

    writefln("Common authentication methods:");

    struct AuthMethod {
        string name;
        string description;
        string useCase;
        string security;
    }

    AuthMethod[] methods = [
        {
            "API Keys",
            "Simple token-based authentication",
            "Internal APIs, simple services",
            "Moderate - keys can be compromised"
        },
        {
            "Bearer Tokens",
            "OAuth 2.0 style tokens",
            "Web APIs, third-party access",
            "Good - tokens can be short-lived"
        },
        {
            "JWT Tokens",
            "JSON Web Tokens with claims",
            "Microservices, stateless auth",
            "Good - self-contained, verifiable"
        },
        {
            "OAuth 2.0",
            "Authorization framework",
            "Third-party application access",
            "Excellent - delegated authorization"
        },
        {
            "Mutual TLS",
            "Client and server certificates",
            "High-security enterprise APIs",
            "Excellent - cryptographic verification"
        },
        {
            "AWS IAM",
            "AWS Identity and Access Management",
            "AWS services, EC2 instances",
            "Excellent - integrated with AWS"
        }
    ];

    foreach (method; methods) {
        writefln("• %s: %s", method.name, method.description);
        writefln("  Use case: %s", method.useCase);
        writefln("  Security: %s", method.security);
        writeln();
    }
}

/**
 * Demonstrate JWT token handling (simplified)
 */
void demonstrateJWTHandling() {
    writeln("\n=== JWT Token Handling ===");

    writefln("JWT (JSON Web Token) structure:");
    writefln("Header.Payload.Signature");

    writefln("\nExample JWT token (decoded):");
    string header = `{"alg": "HS256", "typ": "JWT"}`;
    string payload = `{"sub": "user123", "exp": 1640995200, "iat": 1640991600}`;

    writefln("Header: %s", header);
    writefln("Payload: %s", payload);

    writefln("\nJWT security considerations:");
    writefln("• Always validate token signatures");
    writefln("• Check expiration times (exp claim)");
    writefln("• Validate issuer (iss claim)");
    writefln("• Check audience (aud claim)");
    writefln("• Use HTTPS for token transmission");
    writefln("• Store tokens securely (httpOnly cookies, secure storage)");

    // Show how to extract JWT claims (simplified)
    writefln("\nExtracting JWT claims:");
    JSONValue jwtPayload = parseJSON(payload);
    writefln("Subject: %s", jwtPayload["sub"].str);
    writefln("Expires: %d", jwtPayload["exp"].integer);
    writefln("Issued: %d", jwtPayload["iat"].integer);
}

/**
 * Demonstrate secure client implementation
 */
void demonstrateSecureClient() {
    writeln("\n=== Secure HTTP Client Implementation ===");

    // Create key manager and client
    auto keyManager = new APIKeyManager();
    keyManager.addKey("demo-key-1");
    keyManager.addKey("demo-key-2");

    auto client = new SecureHTTPClient("https://httpbin.org", keyManager);

    writefln("Making authenticated requests to httpbin.org:");

    // Test GET request
    try {
        string response = client.get("/get");
        writefln("✓ GET request successful");
        writefln("Response length: %d bytes", response.length);

        // Test POST request
        string postData = `{"message": "Hello from secure client", "timestamp": 1234567890}`;
        string postResponse = client.post("/post", postData);
        writefln("✓ POST request successful");
        writefln("Response length: %d bytes", postResponse.length);

    } catch (Exception e) {
        writefln("✗ Request failed: %s", e.msg);
    }
}

/**
 * Demonstrate authentication error handling
 */
void demonstrateAuthErrorHandling() {
    writeln("\n=== Authentication Error Handling ===");

    writefln("Common authentication errors and responses:");

    struct AuthError {
        int statusCode;
        string error;
        string description;
        string action;
    }

    AuthError[] errors = [
        {401, "Unauthorized", "Invalid or missing credentials", "Check API key and try again"},
        {403, "Forbidden", "Valid credentials but insufficient permissions", "Check account permissions"},
        {429, "Too Many Requests", "Rate limit exceeded", "Wait and retry with backoff"},
        {422, "Unprocessable Entity", "Request valid but server can't process", "Check request format and parameters"}
    ];

    foreach (error; errors) {
        writefln("• %d %s: %s", error.statusCode, error.error, error.description);
        writefln("  Action: %s", error.action);
        writeln();
    }

    writefln("Authentication error handling strategies:");
    writefln("• Implement retry logic for transient errors");
    writefln("• Rotate API keys on authentication failures");
    writefln("• Log authentication failures for monitoring");
    writefln("• Implement circuit breaker patterns");
    writefln("• Cache authentication state when appropriate");
}

/**
 * Demonstrate secure storage practices
 */
void demonstrateSecureStorage() {
    writeln("\n=== Secure API Key Storage ===");

    writefln("API key storage options (from most to least secure):");

    string[] storageOptions = [
        "Hardware Security Modules (HSM)",
        "Cloud Key Management Services (AWS KMS, Azure Key Vault)",
        "Environment variables (development)",
        "Encrypted configuration files",
        "Application configuration files (not recommended)",
        "Hardcoded in source code (never do this)"
    ];

    foreach (i, option; storageOptions) {
        string security = i < 3 ? "✓ Secure" : i < 5 ? "⚠️  Moderate" : "✗ Insecure";
        writefln("• %s - %s", option, security);
    }

    writefln("\nEnvironment variable usage:");
    writefln("```bash");
    writefln("export OPENAI_API_KEY=sk-your-key-here");
    writefln("export DATABASE_URL=postgres://user:pass@host/db");
    writefln("```");

    writefln("\n```d");
    writefln("string apiKey = environment.get(\"OPENAI_API_KEY\", \"\");");
    writefln("if (apiKey.empty) throw new Exception(\"API key not set\");");
    writefln("```");
}

/**
 * Demonstrate OAuth 2.0 flow (simplified)
 */
void demonstrateOAuthFlow() {
    writeln("\n=== OAuth 2.0 Authorization Flow ===");

    writefln("OAuth 2.0 grant types:");

    struct OAuthGrant {
        string type;
        string description;
        string useCase;
    }

    OAuthGrant[] grants = [
        {
            "Authorization Code",
            "Server-side apps, most secure",
            "Web applications, server-side APIs"
        },
        {
            "Implicit",
            "Client-side apps, less secure",
            "Single-page applications (legacy)"
        },
        {
            "Resource Owner Password",
            "Trusted clients only",
            "First-party mobile apps"
        },
        {
            "Client Credentials",
            "Service-to-service communication",
            "API-to-API authentication"
        },
        {
            "Device Code",
            "Input-constrained devices",
            "Smart TVs, gaming consoles"
        }
    ];

    foreach (grant; grants) {
        writefln("• %s: %s", grant.type, grant.description);
        writefln("  Use case: %s", grant.useCase);
        writeln();
    }

    writefln("OAuth 2.0 flow steps (Authorization Code):");
    writefln("1. Client requests authorization → User login → Authorization code");
    writefln("2. Client exchanges code for access token");
    writefln("3. Client uses access token for API calls");
    writefln("4. Token refresh when expired");
}

/**
 * Check if secure authentication functionality works
 */
bool testSecureAuthCapability() {
    try {
        // Test key manager
        auto keyManager = new APIKeyManager();
        keyManager.addKey("test-key-1");
        keyManager.addKey("test-key-2");

        assert(keyManager.keyCount() == 2);
        assert(keyManager.getNextKey() == "test-key-1");
        assert(keyManager.getNextKey() == "test-key-2");
        assert(keyManager.getNextKey() == "test-key-1"); // Round-robin

        // Test secure client (basic structure)
        auto client = new SecureHTTPClient("https://example.com", keyManager);
        // We don't test actual HTTP calls since they require network

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the secure authentication example
 */
void runExample() {
    writeln("=== Secure Authentication Demonstration ===\n");

    if (!testSecureAuthCapability()) {
        writeln("ERROR: Secure authentication functionality test failed!");
        return;
    }

    writeln("✓ Secure authentication functionality confirmed\n");

    demonstrateAPIKeyManagement();
    demonstrateSecureAuthPatterns();
    demonstrateJWTHandling();
    demonstrateSecureClient();
    demonstrateAuthErrorHandling();
    demonstrateSecureStorage();
    demonstrateOAuthFlow();

    writeln("\n=== Summary ===");
    writeln("• Use secure methods for API key storage");
    writeln("• Implement proper authentication error handling");
    writeln("• Rotate API keys regularly");
    writeln("• Use appropriate authentication methods for your use case");
    writeln("• Validate tokens and check expiration times");
    writeln("• Monitor authentication failures");
    writeln("• Implement rate limiting and abuse detection");
    writeln("• Use HTTPS for all authenticated communication");
}

unittest {
    writeln("=== Running secure_auth tests ===");

    // Test API key manager
    auto keyManager = new APIKeyManager();
    assert(keyManager.keyCount() == 0);

    keyManager.addKey("key1", "test key 1");
    keyManager.addKey("key2", "test key 2");
    assert(keyManager.keyCount() == 2);

    // Test round-robin selection
    assert(keyManager.getNextKey() == "key1");
    assert(keyManager.getNextKey() == "key2");
    assert(keyManager.getNextKey() == "key1");
    writeln("✓ API key manager works");

    // Test secure client initialization
    auto client = new SecureHTTPClient("https://api.example.com", keyManager);
    // We can't test actual HTTP calls without network access
    writeln("✓ Secure client initialization works");

    // Test JWT parsing (simplified)
    string jwtPayload = `{"sub": "user123", "exp": 1640995200}`;
    JSONValue payload = parseJSON(jwtPayload);
    assert(payload["sub"].str == "user123");
    assert(payload["exp"].integer == 1640995200);
    writeln("✓ JWT parsing works");

    // Test error handling structures
    struct AuthError {
        int statusCode;
        string error, description, action;
    }

    AuthError testError = {401, "Unauthorized", "Bad credentials", "Check API key"};
    assert(testError.statusCode == 401);
    assert(testError.error == "Unauthorized");
    writeln("✓ Error handling structures work");

    writeln("All secure_auth tests passed!");
    writeln("=== secure_auth tests completed ===");
}
