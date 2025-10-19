/**
 * Lesson 2: File Operations - Save responses to files
 *
 * This example demonstrates how to save curl responses to files,
 * including downloading content, handling different file types,
 * and managing file operations from D programs.
 */

module lesson2.file_operations;

import std.stdio;
import std.string;
import std.process;
import std.file;
import std.path;
import std.array;
import std.algorithm;

/**
 * Save curl response to a file
 */
bool saveResponseToFile(string url, string filename, string[] extraArgs = []) {
    string[] args = ["-o", filename] ~ extraArgs ~ [url];
    bool success = false;

    try {
        string[] fullCommand = ["curl"] ~ args;
        writefln("Executing: curl %s", args.join(" "));
        writefln("Saving to file: %s", filename);

        auto process = execute(fullCommand);
        int exitCode = process.status;
        string output = process.output;
        success = (exitCode == 0);

        if (success) {
            writefln("✓ Successfully saved response to %s", filename);

            // Check if file exists and show size
            if (exists(filename)) {
                auto size = getSize(filename);
                writefln("File size: %d bytes", size);
            }
        } else {
            writefln("✗ Failed to save response (exit code: %d)", exitCode);
        }

    } catch (Exception e) {
        writefln("Error: %s", e.msg);
        return false;
    }

    return success;
}

/**
 * Download a text file
 */
void demonstrateTextFileDownload() {
    writeln("=== Text File Download ===");
    writeln("Downloading a text file from example.com:\n");

    string filename = "example_homepage.html";
    bool success = saveResponseToFile("https://example.com", filename);

    if (success && exists(filename)) {
        // Show first few lines of the downloaded file
        try {
            auto file = File(filename, "r");
            writeln("First 5 lines of downloaded file:");
            int lineCount = 0;
            foreach (line; file.byLine()) {
                if (lineCount >= 5) break;
                writefln("  %s", line);
                lineCount++;
            }
            file.close();

            // Clean up
            remove(filename);
            writeln("✓ File cleaned up");
        } catch (Exception e) {
            writefln("Error reading file: %s", e.msg);
        }
    }
}

/**
 * Download JSON data
 */
void demonstrateJsonDownload() {
    writeln("\n=== JSON Data Download ===");
    writeln("Downloading JSON data from httpbin.org:\n");

    string filename = "test_data.json";
    bool success = saveResponseToFile("https://httpbin.org/json", filename);

    if (success && exists(filename)) {
        // Read and display the JSON content
        try {
            string content = readText(filename);
            writefln("Downloaded JSON content (%d characters):", content.length);

            // Show a preview of the JSON
            if (content.length > 200) {
                writeln(content[0..200] ~ "...");
            } else {
                writeln(content);
            }

            // Clean up
            remove(filename);
            writeln("✓ JSON file cleaned up");
        } catch (Exception e) {
            writefln("Error reading JSON file: %s", e.msg);
        }
    }
}

/**
 * Download with progress indicator
 */
void demonstrateProgressDownload() {
    writeln("\n=== Download with Progress ===");
    writeln("Downloading with progress indicator:\n");

    string filename = "progress_test.html";
    bool success = saveResponseToFile("https://httpbin.org/delay/1", filename, ["-#"]);

    if (success && exists(filename)) {
        auto size = getSize(filename);
        writefln("Downloaded file size: %d bytes", size);

        // Clean up
        remove(filename);
        writeln("✓ Progress test file cleaned up");
    }
}

/**
 * Download multiple files
 */
void demonstrateMultipleDownloads() {
    writeln("\n=== Multiple File Downloads ===");
    writeln("Downloading multiple files in sequence:\n");

    string[] urls = [
        "https://httpbin.org/uuid",
        "https://httpbin.org/user-agent",
        "https://httpbin.org/ip"
    ];

    string[] filenames = [
        "uuid_response.json",
        "user_agent_response.json",
        "ip_response.json"
    ];

    int successCount = 0;

    foreach (i, url; urls) {
        string filename = filenames[i];
        writefln("--- Download %d ---", i + 1);
        bool success = saveResponseToFile(url, filename, ["-s"]);  // silent mode

        if (success) {
            successCount++;

            // Show a brief preview
            try {
                string content = readText(filename);
                string preview = content.length > 50 ? content[0..50] ~ "..." : content;
                writefln("Preview: %s", preview.strip());
            } catch (Exception e) {
                writefln("Could not read preview");
            }
        }
        writeln();
    }

    writefln("Downloaded %d out of %d files successfully", successCount, urls.length);

    // Clean up all files
    foreach (filename; filenames) {
        if (exists(filename)) {
            remove(filename);
        }
    }
    writeln("✓ All downloaded files cleaned up");
}

/**
 * Download with custom headers
 */
void demonstrateHeaderBasedDownload() {
    writeln("\n=== Download with Custom Headers ===");
    writeln("Downloading with custom headers (JSON format request):\n");

    string filename = "headers_response.json";
    bool success = saveResponseToFile("https://httpbin.org/headers", filename,
                                    ["-H", "Accept: application/json",
                                     "-H", "User-Agent: D-Course-Client/1.0"]);

    if (success && exists(filename)) {
        // Read and display the response
        try {
            string content = readText(filename);
            writefln("Response with custom headers (%d characters):", content.length);

            // Look for our custom headers in the response
            if (canFind(content, "D-Course-Client")) {
                writeln("✓ Custom User-Agent header was included in request");
            }
            if (canFind(content, "application/json")) {
                writeln("✓ Accept header was processed");
            }

            // Clean up
            remove(filename);
            writeln("✓ Headers test file cleaned up");
        } catch (Exception e) {
            writefln("Error reading headers response: %s", e.msg);
        }
    }
}

/**
 * Demonstrate error handling for file operations
 */
void demonstrateErrorHandling() {
    writeln("\n=== Error Handling ===");
    writeln("Testing error conditions:\n");

    // Test with invalid URL
    string filename = "error_test.txt";
    writefln("--- Testing with invalid URL ---");
    bool success = saveResponseToFile("https://invalid-domain-that-does-not-exist-12345.com", filename);

    if (!success) {
        writeln("✓ Correctly handled invalid URL");
    }

    // Test with invalid filename/path
    writefln("\n--- Testing with invalid filename ---");
    success = saveResponseToFile("https://example.com", "/invalid/path/that/does/not/exist/file.txt");

    if (!success) {
        writeln("✓ Correctly handled invalid file path");
    }

    // Clean up any files that might have been created
    if (exists(filename)) {
        remove(filename);
    }
}

/**
 * Show curl file operation options reference
 */
void showFileOptionsReference() {
    writeln("\n=== curl File Operation Options ===");

    string[][] options = [
        ["Basic Output:",
         "  -o <file>    Write output to <file> instead of stdout",
         "  -O           Write output to file named as remote file",
         "  -s           Silent mode (no progress meter)"],

        ["Resume Downloads:",
         "  -C -         Resume transfer from last point",
         "  -C <offset>  Resume from specific offset"],

        ["Progress & Info:",
         "  -#           Progress bar instead of meter",
         "  -v           Verbose output",
         "  -I           Show document info only (headers)"],

        ["Multiple Files:",
         "  -K <file>    Read URLs from file",
         "  --parallel   Download multiple files in parallel",
         "  --parallel-max <num>  Maximum parallel downloads"]
    ];

    foreach (category; options) {
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
 * Run the file operations example
 */
void runExample() {
    writeln("=== File Operations with curl ===\n");

    if (!isCurlAvailable()) {
        writeln("ERROR: curl command not found!");
        return;
    }

    // Demonstrate different file operations
    demonstrateTextFileDownload();
    demonstrateJsonDownload();
    demonstrateProgressDownload();
    demonstrateMultipleDownloads();
    demonstrateHeaderBasedDownload();
    demonstrateErrorHandling();

    showFileOptionsReference();

    writeln("\n=== Summary ===");
    writeln("• curl -o <filename> saves responses to files");
    writeln("• Files are created automatically if they don't exist");
    writeln("• Use -s for silent downloads (no progress output)");
    writeln("• Use -# for progress bars instead of verbose meters");
    writeln("• Always handle errors when working with files");
    writeln("• Clean up temporary files after use");
}

unittest {
    writeln("=== Running file_operations tests ===");

    // Test file path operations
    string filename = "test_file.txt";
    string filepath = buildPath(".", filename);
    assert(filepath.endsWith("test_file.txt"));

    // Test string operations used in the code
    string testContent = "This is test content for file operations";
    assert(testContent.length > 10);
    assert(canFind(testContent, "test"));

    string jsonContent = "{\"key\": \"value\"}";
    assert(canFind(jsonContent, "key"));
    assert(canFind(jsonContent, "value"));

    // Test URL array
    string[] testUrls = ["url1", "url2", "url3"];
    assert(testUrls.length == 3);
    assert(testUrls[0] == "url1");

    // Test filename array
    string[] testFiles = ["file1.txt", "file2.txt", "file3.txt"];
    assert(testFiles.length == 3);
    assert(testFiles[1] == "file2.txt");

    // Test curl availability
    bool available = isCurlAvailable();
    writefln("curl availability for file operations test: %s", available ? "available" : "not available");

    // Test header array operations
    string[] headers = ["Accept: application/json", "User-Agent: test"];
    assert(headers.length == 2);
    assert(canFind(headers[0], "Accept"));
    assert(canFind(headers[1], "User-Agent"));

    writeln("All file operations tests passed!");
    writeln("=== file_operations tests completed ===");
}
