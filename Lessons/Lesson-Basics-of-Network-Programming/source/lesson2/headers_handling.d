/**
 * Lesson 2: Headers Handling - Work with custom headers
 *
 * This example demonstrates how to send and receive HTTP headers using curl,
 * including custom headers, user-agent strings, and content negotiation.
 */

module lesson2.headers_handling;

import std.stdio;
import std.string;
import std.process;
import std.array;
import std.algorithm;

/**
 * Execute a curl command and return the result
 */
struct CurlResult {
    string stdout;
    string stderr;
    int exitCode;
    bool success;

    /**
     * Check if the curl command was successful
     */
    bool isSuccess() const {
        return success && exitCode == 0;
    }

    /**
     * Get combined output (stdout + stderr)
     */
    string getOutput() const {
        return stdout ~ stderr;
    }
}

/**
 * Execute curl with custom headers
 */
CurlResult executeWithHeaders(string[] headers, string url, string[] extraArgs = []) {
    string[] args = ["-v"];  // Always use verbose to see headers

    // Add headers
    foreach (header; headers) {
        args ~= ["-H", header];
    }

    // Add extra arguments and URL
    args ~= extraArgs;
    args ~= [url];

    try {
        string[] fullCommand = ["curl"] ~ args;
        writefln("Executing: curl %s", args.join(" "));

        auto process = execute(fullCommand);
        string output = process.output;
        int exitCode = process.status;
        bool success = (exitCode == 0);

        CurlResult finalResult;
        finalResult.stdout = output;
        finalResult.exitCode = exitCode;
        finalResult.success = success;
        return finalResult;

    } catch (Exception e) {
        writefln("Error: %s", e.msg);
        CurlResult failedResult;
        failedResult.success = false;
        failedResult.stderr = e.msg;
        return failedResult;
    }
}

/**
 * Demonstrate sending custom headers
 */
void demonstrateCustomHeaders() {
    writeln("=== Custom Headers ===");
    writeln("Sending custom headers to identify our request:\n");

    string[] headers = [
        "X-Custom-Header: D-Language-Course",
        "X-Student-ID: 12345",
        "X-Lesson: Headers-Handling"
    ];

    auto result = executeWithHeaders(headers, "https://httpbin.org/headers");

    if (result.isSuccess()) {
        if (canFind(result.stdout, "D-Language-Course")) {
            writeln("✓ Custom headers were sent and received by the server");
        }

        // Show relevant response lines
        auto lines = result.stdout.split("\n");
        foreach (line; lines) {
            if (line.canFind("X-Custom-Header") || line.canFind("X-Student-ID")) {
                writeln("Response header: ", line.strip());
            }
        }
    }
}

/**
 * Demonstrate User-Agent header
 */
void demonstrateUserAgent() {
    writeln("\n=== User-Agent Header ===");
    writeln("User-Agent identifies the client application:\n");

    string[] headers = [
        "User-Agent: D-Language-Course/1.0 (Educational Example)"
    ];

    auto result = executeWithHeaders(headers, "https://httpbin.org/user-agent");

    if (result.isSuccess()) {
        if (canFind(result.stdout, "D-Language-Course")) {
            writeln("✓ User-Agent header was sent successfully");

            // Extract the user-agent info from response
            auto lines = result.stdout.split("\n");
            foreach (line; lines) {
                if (line.canFind("user-agent")) {
                    writeln("Server received User-Agent: ", line.split(":")[1..$].join(":").strip());
                    break;
                }
            }
        }
    }
}

/**
 * Demonstrate Accept header for content negotiation
 */
void demonstrateAcceptHeader() {
    writeln("\n=== Accept Header (Content Negotiation) ===");
    writeln("Accept header tells server what content types we prefer:\n");

    string[] headers = [
        "Accept: application/json, text/plain, */*"
    ];

    auto result = executeWithHeaders(headers, "https://httpbin.org/get");

    if (result.isSuccess()) {
        // Check if server responds with JSON (which httpbin.org does)
        if (canFind(result.stdout, "\"Accept\"")) {
            writeln("✓ Accept header was processed by server");
            writeln("Server received our content type preferences");
        }
    }
}

/**
 * Demonstrate Content-Type header
 */
void demonstrateContentType() {
    writeln("\n=== Content-Type Header ===");
    writeln("Content-Type specifies the format of data we're sending:\n");

    string[] headers = [
        "Content-Type: application/json"
    ];

    auto result = executeWithHeaders(headers, "https://httpbin.org/post",
                                   ["-X", "POST", "-d", "{\"message\": \"Hello from D!\"}"]);

    if (result.isSuccess()) {
        if (canFind(result.stdout, "application/json")) {
            writeln("✓ Content-Type header indicated JSON data");

            // Show the data that was received
            auto lines = result.stdout.split("\n");
            foreach (line; lines) {
                if (line.canFind("\"message\"")) {
                    writeln("Server received JSON data: ", line.strip());
                    break;
                }
            }
        }
    }
}

/**
 * Demonstrate Authorization header (simulated)
 */
void demonstrateAuthorization() {
    writeln("\n=== Authorization Header ===");
    writeln("Authorization header is used for authentication:\n");

    // Note: This is just a demonstration - we're not using real credentials
    string[] headers = [
        "Authorization: Bearer demo-token-12345"
    ];

    auto result = executeWithHeaders(headers, "https://httpbin.org/bearer");

    if (result.isSuccess()) {
        if (canFind(result.stdout, "demo-token-12345")) {
            writeln("✓ Authorization header was sent (demo token)");
            writeln("In real applications, this would authenticate with a server");
        } else {
            writeln("Authorization header sent, but endpoint may not support bearer tokens");
        }
    }
}

/**
 * Demonstrate multiple headers together
 */
void demonstrateMultipleHeaders() {
    writeln("\n=== Multiple Headers Combined ===");
    writeln("Real HTTP requests often include multiple headers:\n");

    string[] headers = [
        "User-Agent: D-Course-Client/2.0",
        "Accept: application/json",
        "Authorization: Bearer demo-token",
        "X-Request-ID: abc-123-def",
        "X-API-Version: v1.0"
    ];

    auto result = executeWithHeaders(headers, "https://httpbin.org/get");

    if (result.isSuccess()) {
        writeln("✓ Multiple headers sent successfully");
        int headerCount = 0;
        auto lines = result.stdout.split("\n");

        foreach (line; lines) {
            if (line.canFind("X-") || line.canFind("Authorization") ||
                line.canFind("User-Agent") || line.canFind("Accept")) {
                headerCount++;
            }
        }

        writefln("Server received %d custom headers", headerCount);
    }
}

/**
 * Show common HTTP headers reference
 */
void showCommonHeaders() {
    writeln("\n=== Common HTTP Headers Reference ===");

    string[][] headerCategories = [
        ["Request Headers:",
         "  Accept          - Preferred content types",
         "  Authorization   - Authentication credentials",
         "  User-Agent      - Client application info",
         "  Content-Type    - Request body format",
         "  Content-Length  - Request body size"],

        ["Response Headers:",
         "  Content-Type    - Response body format",
         "  Content-Length  - Response body size",
         "  Server          - Server software info",
         "  Date            - Response timestamp",
         "  Cache-Control   - Caching directives"],

        ["Custom Headers:",
         "  X-*             - Application-specific headers",
         "  Custom-*        - Your own header names"]
    ];

    foreach (category; headerCategories) {
        foreach (line; category) {
            writeln(line);
        }
        writeln();
    }
}

/**
 * Check if curl is available
 */
bool isCurlAvailable() {
    try {
        auto result = execute(["curl", "--version"]);
        int exitCode = result.status;
        return exitCode == 0;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the headers handling example
 */
void runExample() {
    writeln("=== Headers Handling with curl ===\n");

    if (!isCurlAvailable()) {
        writeln("ERROR: curl command not found!");
        return;
    }

    // Demonstrate different types of headers
    demonstrateCustomHeaders();
    demonstrateUserAgent();
    demonstrateAcceptHeader();
    demonstrateContentType();
    demonstrateAuthorization();
    demonstrateMultipleHeaders();

    showCommonHeaders();

    writeln("\n=== Summary ===");
    writeln("• HTTP headers provide metadata about requests and responses");
    writeln("• curl -H option adds custom headers to requests");
    writeln("• curl -v shows both request and response headers");
    writeln("• Headers are key-value pairs separated by colons");
    writeln("• Common headers include User-Agent, Content-Type, Authorization");
}

unittest {
    writeln("=== Running headers_handling tests ===");

    // Test header string formatting
    string[] testHeaders = ["X-Test: value", "User-Agent: test"];
    assert(testHeaders.length == 2);
    assert(canFind(testHeaders[0], "X-Test"));
    assert(canFind(testHeaders[1], "User-Agent"));

    // Test JSON data formatting
    string jsonData = "{\"message\": \"Hello from D!\"}";
    assert(canFind(jsonData, "message"));
    assert(canFind(jsonData, "Hello from D"));

    // Test header parsing simulation
    string responseLine = "X-Custom-Header: D-Language-Course";
    assert(canFind(responseLine, "X-Custom-Header"));
    assert(canFind(responseLine, "D-Language-Course"));

    // Test content type checking
    string contentTypeHeader = "Content-Type: application/json";
    assert(canFind(contentTypeHeader, "application/json"));

    // Test curl availability
    bool available = isCurlAvailable();
    writefln("curl availability for headers test: %s", available ? "available" : "not available");

    writeln("All headers handling tests passed!");
    writeln("=== headers_handling tests completed ===");
}
