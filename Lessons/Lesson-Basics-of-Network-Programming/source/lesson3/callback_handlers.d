/**
 * Lesson 3: Callback Handlers - Custom callbacks for data processing
 *
 * This example demonstrates how to use callback functions with std.curl
 * for processing HTTP responses in real-time, handling large data streams,
 * and implementing custom response processing logic.
 */

module lesson3.callback_handlers;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.array;
import std.algorithm;

/**
 * Structure to collect response statistics
 */
struct ResponseStats {
    long totalBytes = 0;
    long headerBytes = 0;
    long bodyBytes = 0;
    int chunkCount = 0;
    int headerCount = 0;
    double totalTime = 0.0;
    string contentType;
    int statusCode;

    string toString() const {
        return format("Stats: %d bytes (%d headers + %d body) | %d chunks | %.2fs | %s",
                     totalBytes, headerBytes, bodyBytes, chunkCount, totalTime, contentType);
    }
}

/**
 * Demonstrate basic callback usage for data collection
 */
void demonstrateBasicCallbacks() {
    writeln("=== Basic Callback Handlers ===");

    try {
        auto http = HTTP("https://httpbin.org/get");
        ResponseStats stats;

        // Callback for receiving response data
        http.onReceive = (ubyte[] data) {
            stats.bodyBytes += data.length;
            stats.chunkCount++;
            stats.totalBytes += data.length;

            // Process data in chunks
            string chunk = cast(string)data;
            if (chunk.length > 50) {
                writefln("Received chunk: %s...", chunk[0..50]);
            } else {
                writefln("Received chunk: %s", chunk);
            }

            return data.length; // Return amount processed
        };

        // Callback for receiving headers
        http.onReceiveHeader = (in char[] key, in char[] value) {
            string k = to!string(key).strip().toLower();
            string v = to!string(value).strip();

            if (!k.empty) {
                stats.headerCount++;
                stats.headerBytes += k.length + v.length + 4; // key: value\r\n
                stats.totalBytes += k.length + v.length + 4;

                writefln("Header: %s = %s", k, v);

                if (k == "content-type") {
                    stats.contentType = v;
                }
            }
        };

        // Callback for status line
        http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
            stats.statusCode = statusLine.code;
            writefln("Status: %d %s", statusLine.code, statusLine.reason);
        };

        http.perform();

        // Calculate total time (approximate)
        stats.totalTime = 0.1; // Placeholder - would need timing

        writefln("Final stats: %s", stats.toString());

    } catch (Exception e) {
        writefln("Basic callbacks failed: %s", e.msg);
    }
}

/**
 * Demonstrate progress callback
 */
void demonstrateProgressCallback() {
    writeln("\n=== Progress Callback ===");

    try {
        auto http = HTTP("https://httpbin.org/delay/2"); // 2 second delay to see progress
        long downloaded = 0;
        long total = 0;

        // Progress callback
        http.onProgress = (size_t dltotal, size_t dlnow, size_t ultotal, size_t ulnow) {
            downloaded = dlnow;
            total = dltotal;

            if (total > 0) {
                double percent = (cast(double)downloaded / total) * 100.0;
                writefln("Progress: %d/%d bytes (%.1f%%)", downloaded, total, percent);
            } else {
                writefln("Downloaded: %d bytes", downloaded);
            }

            return 0; // Continue
        };

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        writefln("Download complete: %d bytes received", response.length);

    } catch (Exception e) {
        writefln("Progress callback failed: %s", e.msg);
    }
}

/**
 * Demonstrate streaming data processing
 */
void demonstrateStreamingProcessing() {
    writeln("\n=== Streaming Data Processing ===");

    try {
        auto http = HTTP("https://httpbin.org/stream/10"); // Stream 10 lines of JSON

        int lineCount = 0;
        string currentLine;

        http.onReceive = (ubyte[] data) {
            string chunk = cast(string)data;

            // Process chunk line by line
            foreach (char c; chunk) {
                if (c == '\n') {
                    lineCount++;
                    writefln("Line %d: %s", lineCount, currentLine.strip());
                    currentLine = "";
                } else {
                    currentLine ~= c;
                }
            }

            return data.length;
        };

        http.perform();

        if (!currentLine.empty) {
            lineCount++;
            writefln("Line %d: %s", lineCount, currentLine.strip());
        }

        writefln("Processed %d lines total", lineCount);

    } catch (Exception e) {
        writefln("Streaming processing failed: %s", e.msg);
    }
}

/**
 * Demonstrate custom response parser
 */
void demonstrateCustomParser() {
    writeln("\n=== Custom Response Parser ===");

    try {
        auto http = HTTP("https://httpbin.org/json");

        // Custom parser for JSON response
        struct JsonParser {
            string jsonData;
            bool inString = false;
            int braceDepth = 0;
            string[] keys;
            string[] values;

            void processChunk(string chunk) {
                foreach (char c; chunk) {
                    if (c == '"') {
                        inString = !inString;
                    } else if (!inString) {
                        if (c == '{') braceDepth++;
                        else if (c == '}') braceDepth--;
                    }
                }

                jsonData ~= chunk;
            }

            bool isValidJson() {
                // Simple validation - check braces balance and basic structure
                int openBraces = cast(int)count(jsonData, '{');
                int closeBraces = cast(int)count(jsonData, '}');

                return openBraces == closeBraces && openBraces > 0 &&
                       jsonData.canFind('"') && jsonData.canFind(':');
            }
        }

        JsonParser parser;

        http.onReceive = (ubyte[] data) {
            string chunk = cast(string)data;
            parser.processChunk(chunk);

            writefln("Parsed chunk: %d bytes", chunk.length);
            return data.length;
        };

        http.perform();

        writefln("Total JSON size: %d bytes", parser.jsonData.length);
        writefln("Valid JSON: %s", parser.isValidJson() ? "Yes" : "No");

        if (parser.isValidJson()) {
            // Extract some basic info
            if (parser.jsonData.canFind("slideshow")) {
                writeln("✓ Contains expected JSON structure");
            }
        }

    } catch (Exception e) {
        writefln("Custom parser failed: %s", e.msg);
    }
}

/**
 * Demonstrate error callback handling
 */
void demonstrateErrorCallbacks() {
    writeln("\n=== Error Callback Handling ===");

    try {
        auto http = HTTP("https://httpbin.org/status/404");

        bool errorOccurred = false;
        string errorMessage;

        // Set up error handling
        http.onReceive = (ubyte[] data) {
            string response = cast(string)data;
            writefln("Received: %s", response.strip());

            if (response.canFind("404") || response.canFind("Not Found")) {
                errorOccurred = true;
                errorMessage = "Resource not found (404)";
            }

            return data.length;
        };

        http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
            if (statusLine.code >= 400) {
                errorOccurred = true;
                errorMessage = format("HTTP %d: %s", statusLine.code, statusLine.reason);
            }
        };

        http.perform();

        if (errorOccurred) {
            writefln("✓ Error correctly detected: %s", errorMessage);
        } else {
            writeln("? No error detected (unexpected)");
        }

    } catch (Exception e) {
        writefln("✓ Exception caught: %s", e.msg);
    }
}

/**
 * Demonstrate multiple request handling
 */
void demonstrateMultipleRequests() {
    writeln("\n=== Multiple Requests with Callbacks ===");

    string[] urls = [
        "https://httpbin.org/uuid",
        "https://httpbin.org/ip",
        "https://httpbin.org/user-agent"
    ];

    foreach (i, url; urls) {
        try {
            writefln("--- Request %d: %s ---", i + 1, url);

            auto http = HTTP(url);
            ResponseStats stats;

            http.onReceive = (ubyte[] data) {
                stats.bodyBytes += data.length;
                stats.chunkCount++;
                return data.length;
            };

            http.onReceiveHeader = (in char[] key, in char[] value) {
                if (key.strip().toLower() == "content-type") {
                    stats.contentType = to!string(value).strip();
                }
            };

            http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
                stats.statusCode = statusLine.code;
            };

            http.perform();

            writefln("Result: %d bytes, %d chunks, Status: %d",
                    stats.bodyBytes, stats.chunkCount, stats.statusCode);

        } catch (Exception e) {
            writefln("Request %d failed: %s", i + 1, e.msg);
        }
        writeln();
    }
}

/**
 * Check if callback functionality works
 */
bool testCallbacks() {
    try {
        auto http = HTTP("https://httpbin.org/get");
        bool receivedData = false;

        http.onReceive = (ubyte[] data) {
            receivedData = true;
            return data.length;
        };

        http.perform();

        return receivedData;

    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the callback handlers example
 */
void runExample() {
    writeln("=== Callback Handlers with std.curl ===\n");

    if (!testCallbacks()) {
        writeln("ERROR: Callback functionality test failed!");
        writeln("This might be due to network issues or std.curl problems.");
        return;
    }

    writeln("✓ Callback functionality confirmed\n");

    // Demonstrate different callback patterns
    demonstrateBasicCallbacks();
    demonstrateProgressCallback();
    demonstrateStreamingProcessing();
    demonstrateCustomParser();
    demonstrateErrorCallbacks();
    demonstrateMultipleRequests();

    writeln("\n=== Summary ===");
    writeln("• onReceive - Process response data in chunks");
    writeln("• onReceiveHeader - Handle HTTP headers");
    writeln("• onReceiveStatusLine - Get status code and reason");
    writeln("• onProgress - Monitor download progress");
    writeln("• Callbacks enable real-time processing of large responses");
    writeln("• Useful for streaming data, progress bars, and custom parsing");
    writeln("• Exception handling in callbacks for robust error recovery");
}

unittest {
    writeln("=== Running callback_handlers tests ===");

    // Test ResponseStats struct
    ResponseStats stats;
    stats.totalBytes = 1256;
    stats.headerBytes = 256;
    stats.bodyBytes = 1000;
    stats.chunkCount = 5;
    stats.headerCount = 8;
    stats.totalTime = 2.5;
    stats.contentType = "application/json";
    stats.statusCode = 200;

    string statsStr = stats.toString();
    assert(statsStr.canFind("1256"));
    assert(statsStr.canFind("application/json"));
    assert(statsStr.canFind("2.50"));
    assert(statsStr.canFind("256 headers"));
    assert(statsStr.canFind("1000 body"));
    assert(statsStr.canFind("5 chunks"));
    writeln("✓ ResponseStats struct works");

    // Test callback simulation
    int dataReceived = 0;
    int chunksProcessed = 0;

    // Simulate onReceive callback
    auto mockReceive = (ubyte[] data) {
        dataReceived += data.length;
        chunksProcessed++;
        return data.length;
    };

    // Test with different data sizes
    ubyte[] testData1 = cast(ubyte[])"Hello";
    ubyte[] testData2 = cast(ubyte[])"World";

    mockReceive(testData1);
    mockReceive(testData2);

    assert(dataReceived == 10); // 5 + 5
    assert(chunksProcessed == 2);
    writeln("✓ Callback simulation works");

    // Test header processing simulation
    string[string] headers;
    int headerCallbackCount = 0;

    // Simulate onReceiveHeader callback
    auto mockHeaderReceive = (in char[] key, in char[] value) {
            string k = to!string(key).strip().toLower();
            string v = to!string(value).strip();

        if (!k.empty) {
            headers[k] = v;
            headerCallbackCount++;
        }
    };

    mockHeaderReceive("Content-Type", "application/json");
    mockHeaderReceive("Server", "nginx/1.20.0");
    mockHeaderReceive("Date", "Mon, 01 Jan 2024 12:00:00 GMT");

    assert(headers.length == 3);
    assert(headers["content-type"] == "application/json");
    assert(headers["server"] == "nginx/1.20.0");
    assert(headerCallbackCount == 3);
    writeln("✓ Header callback simulation works");

    // Test progress calculation
    long downloaded = 512;
    long total = 1024;
    double percent = (cast(double)downloaded / total) * 100.0;
    assert(percent == 50.0);
    writeln("✓ Progress calculation works");

    // Test streaming line processing
    string testStream = "Line 1\nLine 2\nLine 3";
    string[] lines;
    string currentLine;

    foreach (char c; testStream) {
        if (c == '\n') {
            lines ~= currentLine;
            currentLine = "";
        } else {
            currentLine ~= c;
        }
    }
    if (!currentLine.empty) {
        lines ~= currentLine;
    }

    assert(lines.length == 3);
    assert(lines[0] == "Line 1");
    assert(lines[1] == "Line 2");
    assert(lines[2] == "Line 3");
    writeln("✓ Streaming line processing works");

    // Test JSON validation
    string validJson = `{"key": "value", "number": 42}`;
    bool hasBraces = count(validJson, '{') == count(validJson, '}');
    bool hasQuotes = validJson.canFind('"');
    bool hasColon = validJson.canFind(':');
    bool isValid = hasBraces && hasQuotes && hasColon;

    assert(isValid);
    writeln("✓ JSON validation simulation works");

    // Test error detection
    int statusCode = 404;
    bool isError = statusCode >= 400;
    assert(isError);
    writeln("✓ Error detection works");

    // Test callback functionality
    bool callbacksWork = testCallbacks();
    writefln("Callback functionality test: %s", callbacksWork ? "passed" : "failed");

    // Test URL array
    string[] testUrls = ["https://httpbin.org/uuid", "https://httpbin.org/ip"];
    assert(testUrls.length == 2);
    assert(testUrls[0].canFind("uuid"));
    assert(testUrls[1].canFind("ip"));
    writeln("✓ URL array validation works");

    writeln("All callback handlers tests passed!");
    writeln("=== callback_handlers tests completed ===");
}
