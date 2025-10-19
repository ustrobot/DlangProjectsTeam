/**
 * Lesson 2: HTTP Methods - Demonstrate different HTTP methods
 *
 * This example shows how to use curl to perform different HTTP methods:
 * GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS
 */

module lesson2.http_methods;

import std.stdio;
import std.string;
import std.process;
import std.array;
import std.algorithm;
import std.conv;

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
 * HTTP method types
 */
enum HttpMethod {
    GET,
    POST,
    PUT,
    DELETE,
    PATCH,
    HEAD,
    OPTIONS
}

/**
 * Execute curl with specific HTTP method
 */
CurlResult executeHttpMethod(HttpMethod method, string url, string[] extraArgs = []) {
    string methodFlag;

    switch (method) {
        case HttpMethod.GET:
            methodFlag = "";
            break;
        case HttpMethod.POST:
            methodFlag = "-X POST";
            break;
        case HttpMethod.PUT:
            methodFlag = "-X PUT";
            break;
        case HttpMethod.DELETE:
            methodFlag = "-X DELETE";
            break;
        case HttpMethod.PATCH:
            methodFlag = "-X PATCH";
            break;
        case HttpMethod.HEAD:
            methodFlag = "-I";  // HEAD request
            break;
        case HttpMethod.OPTIONS:
            methodFlag = "-X OPTIONS";
            break;
        default:
            methodFlag = "";
            break;
    }

    // Build command arguments
    string[] args;
    if (!methodFlag.empty) {
        args = methodFlag.split() ~ extraArgs ~ [url];
    } else {
        args = extraArgs ~ [url];
    }

    writefln("HTTP %s request to: %s", method, url);

    // For demonstration, we'll use httpbin.org which supports all HTTP methods
    // and returns information about the request
    string testUrl = "https://httpbin.org/" ~ toLower(to!string(method));

    try {
        string[] fullCommand = ["curl"] ~ args;
        if (args[$-1] == url) {
            fullCommand[$-1] = testUrl;  // Replace URL with test URL
        }

        writefln("Executing: curl %s", fullCommand[1..$].join(" "));

        auto process = execute(fullCommand);
        string output = process.output;
        int exitCode = process.status;
        bool success = (exitCode == 0);

        if (success) {
            writefln("✓ %s request successful", method);
        } else {
            writefln("✗ %s request failed (exit code: %d)", method, exitCode);
        }

        CurlResult result;
        result.stdout = output;
        result.exitCode = exitCode;
        result.success = success;
        return result;

    } catch (Exception e) {
        writefln("Error executing curl: %s", e.msg);
        CurlResult result;
        result.success = false;
        result.stderr = e.msg;
        return result;
    }
}

/**
 * Demonstrate GET method
 */
void demonstrateGet() {
    writeln("=== GET Method ===");
    writeln("GET retrieves data from a server without modifying it.");
    writeln("It's the most common HTTP method and is safe/idempotent.\n");

    auto result = executeHttpMethod(HttpMethod.GET, "https://httpbin.org/get");

    if (result.isSuccess()) {
        // Parse and show some response info
        if (canFind(result.stdout, "url")) {
            writeln("Response contains request information from httpbin.org");
        }
    }
}

/**
 * Demonstrate HEAD method
 */
void demonstrateHead() {
    writeln("\n=== HEAD Method ===");
    writeln("HEAD is identical to GET but only returns headers, no body.");
    writeln("Useful for checking resource existence and size without downloading.\n");

    auto result = executeHttpMethod(HttpMethod.HEAD, "https://httpbin.org/get");

    if (result.isSuccess()) {
        // HEAD responses typically show headers
        auto lines = result.stdout.split("\n");
        foreach (line; lines) {
            if (line.startsWith("Content-") || line.startsWith("Server") || line.startsWith("Date")) {
                writeln("Header: ", line);
            }
        }
    }
}

/**
 * Demonstrate POST method
 */
void demonstratePost() {
    writeln("\n=== POST Method ===");
    writeln("POST submits data to be processed by the server.");
    writeln("Commonly used for creating new resources.\n");

    auto result = executeHttpMethod(HttpMethod.POST, "https://httpbin.org/post",
                                  ["-d", "name=Alice&age=25"]);

    if (result.isSuccess()) {
        if (canFind(result.stdout, "form")) {
            writeln("POST data was received and processed by the server");
        }
    }
}

/**
 * Demonstrate PUT method
 */
void demonstratePut() {
    writeln("\n=== PUT Method ===");
    writeln("PUT uploads a resource to the specified URI.");
    writeln("If the resource exists, it's replaced; if not, it's created.\n");

    auto result = executeHttpMethod(HttpMethod.PUT, "https://httpbin.org/put",
                                  ["-d", `{"title": "Updated Resource", "completed": true}`,
                                   "-H", "Content-Type: application/json"]);

    if (result.isSuccess()) {
        if (canFind(result.stdout, "json")) {
            writeln("PUT data was sent to update/create a resource");
        }
    }
}

/**
 * Demonstrate DELETE method
 */
void demonstrateDelete() {
    writeln("\n=== DELETE Method ===");
    writeln("DELETE removes the specified resource from the server.\n");

    auto result = executeHttpMethod(HttpMethod.DELETE, "https://httpbin.org/delete");

    if (result.isSuccess()) {
        writeln("DELETE request sent to remove a resource");
    }
}

/**
 * Demonstrate PATCH method
 */
void demonstratePatch() {
    writeln("\n=== PATCH Method ===");
    writeln("PATCH applies partial modifications to a resource.\n");

    auto result = executeHttpMethod(HttpMethod.PATCH, "https://httpbin.org/patch",
                                  ["-d", `{"status": "updated"}`,
                                   "-H", "Content-Type: application/json"]);

    if (result.isSuccess()) {
        if (canFind(result.stdout, "json")) {
            writeln("PATCH data was sent to partially update a resource");
        }
    }
}

/**
 * Demonstrate OPTIONS method
 */
void demonstrateOptions() {
    writeln("\n=== OPTIONS Method ===");
    writeln("OPTIONS describes the communication options for a resource.\n");

    auto result = executeHttpMethod(HttpMethod.OPTIONS, "https://httpbin.org/get");

    if (result.isSuccess()) {
        // Look for Allow header or similar
        if (canFind(result.stdout, "Allow") || canFind(result.stdout, "OPTIONS")) {
            writeln("Server responded with available options");
        }
    }
}

/**
 * Summary of HTTP methods
 */
void showMethodsSummary() {
    writeln("\n=== HTTP Methods Summary ===");
    writeln("• GET    - Retrieve data (safe, idempotent)");
    writeln("• HEAD   - Get headers only (safe, idempotent)");
    writeln("• POST   - Create new resource (not idempotent)");
    writeln("• PUT    - Replace/create resource (idempotent)");
    writeln("• PATCH  - Partial update (not necessarily idempotent)");
    writeln("• DELETE - Remove resource (idempotent)");
    writeln("• OPTIONS - Get communication options (safe, idempotent)");
    writeln();
    writeln("Safe methods: Don't modify server state");
    writeln("Idempotent methods: Can be called multiple times with same result");
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
 * Run the HTTP methods example
 */
void runExample() {
    writeln("=== HTTP Methods Demonstration ===\n");

    if (!isCurlAvailable()) {
        writeln("ERROR: curl command not found!");
        writeln("Please install curl to run this example.");
        return;
    }

    // Demonstrate each HTTP method
    demonstrateGet();
    demonstrateHead();
    demonstratePost();
    demonstratePut();
    demonstrateDelete();
    demonstratePatch();
    demonstrateOptions();

    showMethodsSummary();

    writeln("\n=== Notes ===");
    writeln("• This example uses httpbin.org, a service for testing HTTP requests");
    writeln("• Each method demonstrates different server interaction patterns");
    writeln("• Real applications would use proper APIs instead of httpbin.org");
}

unittest {
    writeln("=== Running http_methods tests ===");

    // Test HTTP method enum
    assert(HttpMethod.GET == HttpMethod.GET);
    assert(HttpMethod.POST != HttpMethod.GET);

    // Test method string conversion
    assert(to!string(HttpMethod.GET) == "GET");
    assert(to!string(HttpMethod.POST) == "POST");

    // Test curl availability (might not be available in test environment)
    bool available = isCurlAvailable();
    writefln("curl availability for HTTP methods test: %s", available ? "available" : "not available");

    // Test basic string operations used in the code
    string testStr = "GET request to: https://example.com";
    assert(canFind(testStr, "GET"));
    assert(canFind(testStr, "example.com"));

    string jsonData = "{\"name\": \"test\"}";
    assert(canFind(jsonData, "name"));
    assert(jsonData.length > 0);

    writeln("All HTTP methods tests passed!");
    writeln("=== http_methods tests completed ===");
}
