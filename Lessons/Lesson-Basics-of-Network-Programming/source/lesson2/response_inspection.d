/**
 * Lesson 2: Response Inspection - Parse curl verbose output
 *
 * This example demonstrates how to interpret curl's verbose output (-v flag)
 * to understand HTTP request/response details including headers, status codes,
 * and connection information.
 */

module lesson2.response_inspection;

import std.stdio;
import std.string;
import std.process;
import std.array;
import std.algorithm;
import std.conv;

/**
 * Structure to hold parsed HTTP response information
 */
struct HttpResponseInfo {
    int statusCode;
    string statusText;
    string[string] responseHeaders;
    string responseBody;
    string requestMethod;
    string requestUrl;
    string serverInfo;
    string contentType;
    long contentLength;
    bool isSuccessful;

    /**
     * Get a summary of the response
     */
    string getSummary() const {
        return format("HTTP %d %s | Content-Type: %s | Size: %d bytes",
                     statusCode, statusText,
                     contentType.empty ? "unknown" : contentType,
                     contentLength);
    }
}

/**
 * Execute curl with verbose output and parse the response
 */
HttpResponseInfo inspectResponse(string url, string[] extraArgs = []) {
    HttpResponseInfo info;
    string output = "";
    bool success = false;

    string[] args = ["-v", "-s"] ~ extraArgs ~ [url];  // verbose but silent (no progress meter)

    try {
        string[] fullCommand = ["curl"] ~ args;
        auto process = execute(fullCommand);
        output = process.output;
        int exitCode = process.status;
        success = (exitCode == 0);

    } catch (Exception e) {
        return info;
    }

    if (success) {
        info = parseVerboseOutput(output, url);
    }

    return info;
}

/**
 * Parse curl's verbose output to extract HTTP information
 */
HttpResponseInfo parseVerboseOutput(string verboseOutput, string requestUrl) {
    HttpResponseInfo info;
    info.requestUrl = requestUrl;
    info.requestMethod = "GET";  // Default, could be overridden

    auto lines = verboseOutput.split("\n");
    bool inResponseHeaders = false;
    bool inResponseBody = false;

    foreach (line; lines) {
        line = line.strip();

        if (line.empty) {
            if (inResponseHeaders) {
                inResponseBody = true;
                inResponseHeaders = false;
            }
            continue;
        }

        // Parse status line (e.g., "HTTP/1.1 200 OK")
        if (line.startsWith("HTTP/")) {
            auto parts = line.split();
            if (parts.length >= 3) {
                try {
                    info.statusCode = to!int(parts[1]);
                    info.statusText = parts[2..$].join(" ");
                    info.isSuccessful = (info.statusCode >= 200 && info.statusCode < 300);
                } catch (Exception e) {
                    // Ignore parsing errors
                }
            }
            inResponseHeaders = true;
            continue;
        }

        // Parse response headers
        if (inResponseHeaders && line.canFind(":")) {
            auto colonIndex = line.indexOf(":");
            if (colonIndex > 0) {
                string headerName = line[0..colonIndex].strip().toLower();
                string headerValue = line[colonIndex + 1..$].strip();

                info.responseHeaders[headerName] = headerValue;

                // Extract specific headers
                switch (headerName) {
                    case "server":
                        info.serverInfo = headerValue;
                        break;
                    case "content-type":
                        info.contentType = headerValue;
                        break;
                    case "content-length":
                        try {
                            info.contentLength = to!long(headerValue);
                        } catch (Exception e) {
                            // Ignore parsing errors
                        }
                        break;
                    default:
                        break;
                }
            }
        }

        // Parse request method from curl output
        if (line.canFind("GET") || line.canFind("POST") || line.canFind("PUT") ||
            line.canFind("DELETE") || line.canFind("HEAD")) {
            auto parts = line.split();
            if (parts.length > 0) {
                info.requestMethod = parts[0];
            }
        }

        // Collect response body (after headers)
        if (inResponseBody) {
            if (info.responseBody.empty) {
                info.responseBody = line;
            } else {
                info.responseBody ~= "\n" ~ line;
            }
        }
    }

    return info;
}

/**
 * Demonstrate basic response inspection
 */
void demonstrateBasicInspection() {
    writeln("=== Basic Response Inspection ===");
    writeln("Inspecting a simple GET request to example.com:\n");

    auto response = inspectResponse("https://example.com");

    writefln("Request: %s %s", response.requestMethod, response.requestUrl);
    writefln("Status: %s", response.getSummary());
    writefln("Server: %s", response.serverInfo);
    writefln("Success: %s", response.isSuccessful ? "Yes" : "No");

    if (!response.responseBody.empty) {
        writefln("Response body preview: %s...",
                response.responseBody.length > 50 ?
                response.responseBody[0..50] : response.responseBody);
    }
}

/**
 * Demonstrate header inspection
 */
void demonstrateHeaderInspection() {
    writeln("\n=== Header Inspection ===");
    writeln("Examining response headers from httpbin.org:\n");

    auto response = inspectResponse("https://httpbin.org/get");

    writefln("Status: HTTP %d %s", response.statusCode, response.statusText);
    writeln("Response Headers:");

    foreach (headerName, headerValue; response.responseHeaders) {
        writefln("  %s: %s", headerName, headerValue);
    }

    // Show specific interesting headers
    if ("content-type" in response.responseHeaders) {
        writefln("\nContent-Type: %s", response.responseHeaders["content-type"]);
    }
    if ("server" in response.responseHeaders) {
        writefln("Server: %s", response.responseHeaders["server"]);
    }
}

/**
 * Demonstrate different HTTP methods
 */
void demonstrateMethodInspection() {
    writeln("\n=== Different HTTP Methods ===");

    string[] methods = ["GET", "HEAD", "POST"];
    string[][] methodArgs = [
        [],
        ["-I"],  // HEAD request
        ["-X", "POST", "-d", "test=data"]
    ];

    foreach (i, method; methods) {
        writefln("\n--- %s Request ---", method);
        auto response = inspectResponse("https://httpbin.org/get", methodArgs[i]);
        writefln("Method: %s", response.requestMethod);
        writefln("Status: HTTP %d %s", response.statusCode, response.statusText);
        writefln("Has body: %s", response.responseBody.empty ? "No" : "Yes");
    }
}

/**
 * Demonstrate error responses
 */
void demonstrateErrorResponses() {
    writeln("\n=== Error Response Inspection ===");
    writeln("Testing with invalid URLs and endpoints:\n");

    string[] testUrls = [
        "https://httpbin.org/status/404",
        "https://httpbin.org/status/500",
        "https://nonexistent-domain-12345.com"
    ];

    foreach (url; testUrls) {
        writefln("--- Testing: %s ---", url);
        auto response = inspectResponse(url);

        if (response.statusCode > 0) {
            writefln("Status: HTTP %d %s", response.statusCode, response.statusText);
            writefln("Success: %s", response.isSuccessful ? "Yes" : "No");
        } else {
            writeln("Failed to get response (network error or timeout)");
        }
    }
}

/**
 * Show curl verbose output format explanation
 */
void explainVerboseOutput() {
    writeln("\n=== curl Verbose Output Format ===");
    writeln("Understanding what curl -v shows:");
    writeln();
    writeln("1. Connection information (* lines)");
    writeln("   *   Trying 93.184.216.34:443...");
    writeln("   * Connected to example.com (93.184.216.34) port 443");
    writeln();
    writeln("2. SSL/TLS handshake (> and < lines show client/server communication)");
    writeln("   > GET / HTTP/1.1");
    writeln("   > Host: example.com");
    writeln("   > User-Agent: curl/7.81.0");
    writeln();
    writeln("3. Server response");
    writeln("   < HTTP/1.1 200 OK");
    writeln("   < Content-Type: text/html");
    writeln("   < Content-Length: 1256");
    writeln();
    writeln("4. Empty line separates headers from body");
    writeln("5. Response body content");
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
 * Run the response inspection example
 */
void runExample() {
    writeln("=== Response Inspection with curl -v ===\n");

    if (!isCurlAvailable()) {
        writeln("ERROR: curl command not found!");
        return;
    }

    // Demonstrate different aspects of response inspection
    demonstrateBasicInspection();
    demonstrateHeaderInspection();
    demonstrateMethodInspection();
    demonstrateErrorResponses();

    explainVerboseOutput();

    writeln("\n=== Summary ===");
    writeln("• curl -v provides detailed information about HTTP requests/responses");
    writeln("• Status line shows HTTP version, status code, and reason phrase");
    writeln("• Headers provide metadata about the request/response");
    writeln("• Response body contains the actual data");
    writeln("• Use this information for debugging and understanding HTTP interactions");
}

unittest {
    writeln("=== Running response_inspection tests ===");

    // Test HTTP response info structure
    HttpResponseInfo info;
    info.statusCode = 200;
    info.statusText = "OK";
    info.contentType = "text/html";
    info.contentLength = 1256;
    info.isSuccessful = true;

    string summary = info.getSummary();
    assert(canFind(summary, "200"));
    assert(canFind(summary, "OK"));
    assert(canFind(summary, "text/html"));
    assert(canFind(summary, "1256"));

    // Test header parsing simulation
    string testHeader = "Content-Type: application/json";
    auto colonIndex = testHeader.indexOf(":");
    assert(colonIndex == 12);
    string headerName = testHeader[0..colonIndex].strip().toLower();
    string headerValue = testHeader[colonIndex + 1..$].strip();
    assert(headerName == "content-type");
    assert(headerValue == "application/json");

    // Test status line parsing simulation
    string statusLine = "HTTP/1.1 200 OK";
    auto parts = statusLine.split();
    assert(parts.length >= 3);
    assert(parts[0] == "HTTP/1.1");
    assert(parts[1] == "200");
    assert(parts[2] == "OK");

    // Test URL and method storage
    info.requestUrl = "https://example.com";
    info.requestMethod = "GET";
    assert(info.requestUrl == "https://example.com");
    assert(info.requestMethod == "GET");

    // Test curl availability
    bool available = isCurlAvailable();
    writefln("curl availability for response inspection test: %s", available ? "available" : "not available");

    writeln("All response inspection tests passed!");
    writeln("=== response_inspection tests completed ===");
}
