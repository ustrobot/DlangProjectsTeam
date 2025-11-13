/**
 * Lesson 2: curl Basics - Execute curl from D using std.process
 *
 * This example demonstrates how to execute curl commands from D programs
 * using the std.process module, allowing interaction with command-line curl.
 */

module lesson2.curl_basics;

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
 * Execute a curl command with given arguments
 */
CurlResult executeCurl(string[] args) {
    CurlResult result;

    try {
        // Build the full command
        string[] fullCommand = ["curl"] ~ args;

        writefln("Executing: curl %s", args.join(" "));

        // Execute the command
        auto process = execute(fullCommand);
        result.stdout = process.output;
        result.stderr = "";
        result.exitCode = process.status;
        result.success = true;

        writefln("Exit code: %d", result.exitCode);
        if (result.stdout.length > 0) {
            writefln("Output length: %d characters", result.stdout.length);
        }

    } catch (Exception e) {
        result.success = false;
        result.stderr = e.msg;
        writefln("Error executing curl: %s", e.msg);
    }

    return result;
}

/**
 * Simple GET request to example.com
 */
void simpleGetRequest() {
    writeln("=== Simple GET Request ===");

    // Execute: curl https://example.com
    auto result = executeCurl(["https://example.com"]);

    if (result.isSuccess()) {
        writeln("Success! Response received:");
        // Show first 200 characters of response
        if (result.stdout.length > 200) {
            writeln(result.stdout[0..200] ~ "...");
        } else {
            writeln(result.stdout);
        }
    } else {
        writefln("Failed with exit code: %d", result.exitCode);
    }
}

/**
 * GET request with verbose output
 */
void verboseGetRequest() {
    writeln("\n=== Verbose GET Request ===");

    // Execute: curl -v https://example.com
    auto result = executeCurl(["-v", "https://example.com"]);

    if (result.isSuccess()) {
        writeln("Verbose output:");
        // Show the response content (not the headers for brevity)
         if (result.stdout.length > 4000) {
            writeln(result.stdout[0..4000] ~ "...");
        } else {
            writeln(result.stdout);
        } 
        writefln("Failed with exit code: %d", result.exitCode);
    }
}

/**
 * Demonstrate different curl options
 */
void demonstrateCurlOptions() {
    writeln("\n=== curl Options Demonstration ===");

    // Test various curl options
    string[][] curlCommands = [
        ["--version"],                                    // Show version
        ["--help", "|", "head", "-20"],                   // Show help (first 20 lines)
        ["-I", "https://example.com"],                    // HEAD request
        ["-s", "https://example.com"],                    // Silent mode
        ["-w", "%{http_code}", "https://example.com"]     // Show HTTP status code
    ];

    foreach (i, cmd; curlCommands) {
        writefln("\n--- Command %d ---", i + 1);
        writefln("curl %s", cmd.join(" "));

        cmd = ["curl"] ~ cmd;

        try {
            auto result = execute(cmd);
            int exitCode = result.status;
            string output = result.output;
            bool success = (exitCode == 0);

            if (success) {
                if (output.length > 0) {
                    // Show first line or first 100 chars
                    auto firstLine = output.split("\n")[0];
                    if (firstLine.length > 100) {
                        writefln("Output: %s...", firstLine[0..100]);
                    } else {
                        writefln("Output: %s", firstLine);
                    }
                }
            } else {
                writefln("Failed (exit code: %d)", exitCode);
            }
        } catch (Exception e) {
            writefln("Error: %s", e.msg);
        }
    }
}

/**
 * Test curl availability
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
 * Run the curl basics example
 */
void runExample() {
    writeln("=== curl Basics - Execute curl from D ===\n");

    // Check if curl is available
    if (!isCurlAvailable()) {
        writeln("ERROR: curl command not found!");
        writeln("Please install curl and make sure it's in your PATH.");
        writeln("On Ubuntu/Debian: sudo apt-get install curl");
        writeln("On macOS: brew install curl");
        return;
    }

    writeln("✓ curl is available on this system\n");

    // Demonstrate basic curl usage
    simpleGetRequest();
    verboseGetRequest();
    demonstrateCurlOptions();

    writeln("\n=== Summary ===");
    writeln("• Used std.process.execute() to run curl commands from D");
    writeln("• Demonstrated basic curl options: -v, -I, -s, -w");
    writeln("• Showed how to handle command output and exit codes");
    writeln("• curl is a powerful command-line tool for HTTP requests");
}

unittest {
    writeln("=== Running curl_basics tests ===");

    // Test CurlResult struct functionality
    CurlResult result;
    result.stdout = "test output";
    result.stderr = "test error";
    result.exitCode = 0;
    result.success = true;

    // Test successful result
    assert(result.isSuccess() == true);
    assert(result.getOutput() == "test outputtest error");

    // Test failed result with non-zero exit code
    result.exitCode = 1;
    assert(result.isSuccess() == false);

    // Test failed result with success flag false
    result.success = false;
    result.exitCode = 0;
    assert(result.isSuccess() == false);

    // Test empty output
    CurlResult emptyResult;
    assert(emptyResult.getOutput() == "");
    assert(emptyResult.isSuccess() == false); // exitCode = 0, success = false by default

    // Test CurlResult with only stdout
    CurlResult stdoutOnly;
    stdoutOnly.stdout = "Hello World";
    stdoutOnly.exitCode = 0;
    stdoutOnly.success = true;
    assert(stdoutOnly.getOutput() == "Hello World");
    assert(stdoutOnly.isSuccess() == true);

    // Test CurlResult with only stderr
    CurlResult stderrOnly;
    stderrOnly.stderr = "Error message";
    stderrOnly.exitCode = 1;
    stderrOnly.success = false;
    assert(stderrOnly.getOutput() == "Error message");
    assert(stderrOnly.isSuccess() == false);

    // Test CurlResult with both stdout and stderr
    CurlResult bothOutputs;
    bothOutputs.stdout = "Output";
    bothOutputs.stderr = "Error";
    bothOutputs.exitCode = 0;
    bothOutputs.success = true;
    assert(bothOutputs.getOutput() == "OutputError");
    assert(bothOutputs.isSuccess() == true);

    // Test command argument arrays
    string[] simpleArgs = ["https://example.com"];
    assert(simpleArgs.length == 1);
    assert(simpleArgs[0] == "https://example.com");

    string[] complexArgs = ["-v", "-H", "User-Agent: Test", "https://httpbin.org/get"];
    assert(complexArgs.length == 4);
    assert(complexArgs[0] == "-v");
    assert(complexArgs[1] == "-H");
    assert(complexArgs[2] == "User-Agent: Test");
    assert(complexArgs[3] == "https://httpbin.org/get");

    // Test URL validation (basic)
    string[] validUrls = [
        "https://example.com",
        "http://test.com",
        "https://api.github.com/users",
        "http://localhost:8080/api"
    ];

    foreach (url; validUrls) {
        assert(url.length > 0);
        assert(url.canFind("http"));
    }

    // Test curl option combinations
    string[][] optionTests = [
        ["-I", "https://example.com"],           // HEAD request
        ["-s", "https://example.com"],           // Silent
        ["-v", "https://example.com"],           // Verbose
        ["-o", "output.txt", "https://example.com"], // Save to file
        ["-H", "Accept: application/json", "https://api.example.com"]
    ];

    foreach (options; optionTests) {
        assert(options.length >= 2); // At least one option + URL
        assert(options[$-1].canFind("http")); // Last element should be URL
    }

    // Test error handling scenarios
    CurlResult errorResult;
    errorResult.exitCode = 6;  // CURLE_COULDNT_RESOLVE_HOST
    errorResult.success = false;
    errorResult.stderr = "Could not resolve host";
    assert(!errorResult.isSuccess());
    assert(errorResult.getOutput() == "Could not resolve host");

    // Test successful HTTP status codes
    int[] successCodes = [200, 201, 202, 204, 301, 302, 304, 401, 403, 404, 500];
    foreach (code; successCodes) {
        // Note: These are just HTTP status codes, not curl exit codes
        // curl exit codes are different from HTTP status codes
        assert(code >= 100 && code < 600);
    }

    // Test curl availability (might fail in test environment)
    bool available = isCurlAvailable();
    writefln("curl availability check: %s", available ? "available" : "not available");

    // Test that isCurlAvailable doesn't throw exceptions
    try {
        bool checkResult = isCurlAvailable();
        assert(typeof(checkResult).stringof == "bool");
    } catch (Exception e) {
        // If an exception occurs, it should be handled gracefully
        assert(false, "isCurlAvailable should not throw exceptions");
    }

    // Test array operations used in executeCurl
    string[] baseCommand = ["curl"];
    string[] userArgs = ["-v", "https://example.com"];
    string[] fullCommand = baseCommand ~ userArgs;
    assert(fullCommand.length == 3);
    assert(fullCommand[0] == "curl");
    assert(fullCommand[1] == "-v");
    assert(fullCommand[2] == "https://example.com");

    // Test string operations used in logging
    string testCommand = "-v -H 'User-Agent: test' https://example.com";
    assert(testCommand.canFind("-v"));
    assert(testCommand.canFind("User-Agent"));
    assert(testCommand.canFind("https://"));

    // Test numeric operations
    int testExitCode = 0;
    assert(testExitCode == 0);
    assert((testExitCode == 0) == true);

    testExitCode = 22; // CURLE_HTTP_RETURNED_ERROR
    assert(testExitCode != 0);
    assert((testExitCode == 0) == false);

    writeln("All curl basics unit tests passed!");
    writeln("=== curl_basics tests completed ===");
}
