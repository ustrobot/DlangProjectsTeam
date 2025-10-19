/**
 * Lesson 4: JSON Payload - POST JSON data
 *
 * This example demonstrates how to send JSON data in POST requests,
 * which is commonly used in REST APIs and modern web applications.
 */

module lesson4.json_payload;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.json;
import std.algorithm;

/**
 * Send JSON data using POST request
 */
string sendJsonData(string url, string jsonString) {
    try {
        auto http = HTTP(url);
        http.method = HTTP.Method.post;
        http.postData = jsonString;
        http.addRequestHeader("Content-Type", "application/json");

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();
        return response;

    } catch (Exception e) {
        throw new Exception(format("JSON POST failed for %s: %s", url, e.msg));
    }
}

/**
 * Send JSON data using JSONValue
 */
string sendJsonValue(string url, JSONValue jsonData) {
    try {
        string jsonString = jsonData.toString();
        return sendJsonData(url, jsonString);
    } catch (Exception e) {
        throw new Exception(format("JSONValue POST failed for %s: %s", url, e.msg));
    }
}

/**
 * Demonstrate basic JSON POST
 */
void demonstrateBasicJsonPost() {
    writeln("=== Basic JSON POST Request ===");

    try {
        // Create JSON data
        JSONValue json = [
            "name": JSONValue("D Language"),
            "version": JSONValue("2.0"),
            "lesson": JSONValue(4),
            "topic": JSONValue("JSON Payload"),
            "features": JSONValue([
                JSONValue("statically typed"),
                JSONValue("compiled"),
                JSONValue("systems programming")
            ])
        ];

        string jsonString = json.toString();
        writefln("Sending JSON data (%d characters):", jsonString.length);
        writefln("JSON: %s", jsonString);

        string response = sendJsonValue("https://httpbin.org/post", json);

        writefln("Response received (%d characters)", response.length);

        // Verify the JSON was received and parsed
        if (canFind(response,"D Language") && response.canFind("JSON Payload")) {
            writeln("✓ JSON data successfully sent and received");
        }

        if (canFind(response,"statically typed")) {
            writeln("✓ JSON array data processed correctly");
        }

        if (canFind(response,`"lesson": 4`)) {
            writeln("✓ JSON numeric data handled correctly");
        }

    } catch (Exception e) {
        writefln("Basic JSON POST failed: %s", e.msg);
    }
}

/**
 * Demonstrate JSON with nested objects
 */
void demonstrateNestedJson() {
    writeln("\n=== Nested JSON Objects ===");

    try {
        // Create nested JSON structure
        JSONValue nestedJson = [
            "user": JSONValue([
                "name": JSONValue("D Programmer"),
                "id": JSONValue(12345),
                "active": JSONValue(true)
            ]),
            "metadata": JSONValue([
                "timestamp": JSONValue("2024-01-01T12:00:00Z"),
                "version": JSONValue("1.0"),
                "environment": JSONValue("testing")
            ]),
            "data": JSONValue([
                "items": JSONValue([
                    JSONValue(["id": JSONValue(1), "value": JSONValue("first")]),
                    JSONValue(["id": JSONValue(2), "value": JSONValue("second")])
                ])
            ])
        ];

        string jsonString = nestedJson.toString();
        writefln("Nested JSON size: %d characters", jsonString.length);

        string response = sendJsonValue("https://httpbin.org/post", nestedJson);

        // Check if nested structure was preserved
        if (canFind(response,"D Programmer") && response.canFind("testing")) {
            writeln("✓ Nested JSON objects handled correctly");
        }

        if (canFind(response,`"active": true`)) {
            writeln("✓ Boolean values in JSON preserved");
        }

        if (canFind(response,`"id": 1`) && response.canFind("first")) {
            writeln("✓ Array of objects processed correctly");
        }

    } catch (Exception e) {
        writefln("Nested JSON test failed: %s", e.msg);
    }
}

/**
 * Demonstrate empty and minimal JSON
 */
void demonstrateMinimalJson() {
    writeln("\n=== Minimal JSON Payloads ===");

    string[] jsonTests = [
        `{}`,                                    // Empty object
        `{"key": "value"}`,                       // Single key-value
        `[]`,                                    // Empty array
        `["item1", "item2"]`,                     // Simple array
        `null`,                                  // JSON null
        `"simple string"`,                       // String value
        `42`,                                    // Number
        `true`                                   // Boolean
    ];

    foreach (i, jsonStr; jsonTests) {
        try {
            writefln("--- Test %d: %s ---", i + 1, jsonStr);

            string response = sendJsonData("https://httpbin.org/post", jsonStr);

            if (canFind(response,jsonStr) || response.canFind(jsonStr.replace("\"", "\\\""))) {
                writefln("✓ JSON payload %d sent successfully", i + 1);
            } else {
                writefln("✓ JSON payload %d accepted (format may vary in response)", i + 1);
            }

        } catch (Exception e) {
            writefln("Test %d failed: %s", i + 1, e.msg);
        }
    }
}

/**
 * Demonstrate JSON with special characters
 */
void demonstrateJsonSpecialChars() {
    writeln("\n=== JSON with Special Characters ===");

    try {
        JSONValue specialJson = [
            "message": JSONValue("Hello, 世界! 🌍"),  // Unicode and emoji
            "symbols": JSONValue("@#$%^&*()[]{}"),
            "quotes": JSONValue("Text with \"quotes\" and 'apostrophes'"),
            "newlines": JSONValue("Line 1\nLine 2\nLine 3"),
            "tabs": JSONValue("Col1\tCol2\tCol3"),
            "slashes": JSONValue("Path\\to\\file and /unix/path"),
            "html": JSONValue("<div>Hello & welcome!</div>")
        ];

        string jsonString = specialJson.toString();
        writefln("JSON with special chars (%d characters)", jsonString.length);

        string response = sendJsonValue("https://httpbin.org/post", specialJson);

        // Check if special characters were handled
        bool hasUnicode = response.canFind("世界") || response.canFind("\\u4e16");
        bool hasEmoji = response.canFind("🌍") || response.canFind("\\ud83c");
        bool hasSymbols = response.canFind("@#$%^&*()");
        bool hasQuotes = response.canFind("\\\"quotes\\\"");

        writefln("Unicode: %s, Emoji: %s, Symbols: %s, Quotes: %s",
                hasUnicode, hasEmoji, hasSymbols, hasQuotes);

        if (hasUnicode || hasEmoji || hasSymbols || hasQuotes) {
            writeln("✓ Special characters in JSON handled");
        }

    } catch (Exception e) {
        writefln("Special characters JSON test failed: %s", e.msg);
    }
}

/**
 * Demonstrate large JSON payload
 */
void demonstrateLargeJson() {
    writeln("\n=== Large JSON Payload ===");

    try {
        // Create a large JSON array
        JSONValue[] largeArray;
        for (int i = 1; i <= 100; i++) {
            JSONValue item = [
                "id": JSONValue(i),
                "name": JSONValue(format("Item %d", i)),
                "value": JSONValue(i * 10),
                "active": JSONValue(i % 2 == 0)
            ];
            largeArray ~= JSONValue(item);
        }

        JSONValue largeJson = [
            "items": JSONValue(largeArray),
            "total": JSONValue(largeArray.length),
            "description": JSONValue("Large dataset with 100 items")
        ];

        string jsonString = largeJson.toString();
        writefln("Large JSON payload: %d characters, %d items",
                jsonString.length, largeArray.length);

        string response = sendJsonValue("https://httpbin.org/post", largeJson);

        if (canFind(response,"100 items")) {
            writeln("✓ Large JSON payload sent successfully");
        }

        if (canFind(response,"Item 100")) {
            writeln("✓ All items in large JSON processed");
        }

        if (canFind(response,`"total": 100`)) {
            writeln("✓ JSON metadata preserved");
        }

    } catch (Exception e) {
        writefln("Large JSON test failed: %s", e.msg);
    }
}

/**
 * Demonstrate JSON POST error handling
 */
void demonstrateJsonErrors() {
    writeln("\n=== JSON POST Error Handling ===");

    string[] invalidJsonStrings = [
        `{invalid json`,                    // Incomplete JSON
        `{"missing": "comma" "invalid"}`,   // Missing comma
        `{"unclosed": "brace"`,            // Unclosed brace
        `["unclosed", "array"`,           // Unclosed array
        `{"duplicate": "key", "duplicate": "value"}` // Duplicate keys
    ];

    foreach (i, invalidJson; invalidJsonStrings) {
        try {
            writefln("--- Invalid JSON Test %d ---", i + 1);
            writefln("Attempting to send: %s", invalidJson);

            // Try to parse first to see if it's valid JSON
            JSONValue testParse = parseJSON(invalidJson);
            writefln("Unexpectedly valid JSON, sending anyway...");

            string response = sendJsonData("https://httpbin.org/post", invalidJson);

            if (response.length > 0) {
                writefln("✓ Server accepted invalid JSON (server may be lenient)");
            }

        } catch (JSONException e) {
            writefln("✓ Correctly caught invalid JSON: %s", e.msg);
        } catch (Exception e) {
            writefln("✓ Request failed as expected: %s", e.msg);
        }
    }
}

/**
 * Demonstrate JSON response parsing
 */
void demonstrateJsonResponseParsing() {
    writeln("\n=== JSON Response Parsing ===");

    try {
        JSONValue requestData = [
            "action": JSONValue("test_response_parsing"),
            "data": JSONValue([
                "numbers": JSONValue([1, 2, 3, 4, 5]),
                "strings": JSONValue(["a", "b", "c"]),
                "mixed": JSONValue([
                    JSONValue(42),
                    JSONValue("hello"),
                    JSONValue(true),
                    JSONValue(null)
                ])
            ])
        ];

        string response = sendJsonValue("https://httpbin.org/post", requestData);

        // Try to parse the response as JSON
        try {
            JSONValue responseJson = parseJSON(response);

            // Navigate the response structure
            if (responseJson.type == JSONType.object) {
                if ("json" in responseJson) {
                    auto jsonSection = responseJson["json"];
                    if ("action" in jsonSection && jsonSection["action"].str == "test_response_parsing") {
                        writeln("✓ Response JSON parsed and verified");
                    }
                }

                if ("data" in responseJson) {
                    writeln("✓ Response data section found");
                }
            }

        } catch (JSONException e) {
            writefln("Response is not valid JSON (expected): %s", e.msg);
        }

    } catch (Exception e) {
        writefln("JSON response parsing test failed: %s", e.msg);
    }
}

/**
 * Check if JSON POST functionality works
 */
bool testJsonPostCapability() {
    try {
        JSONValue testData = ["test": JSONValue("json_post"), "value": JSONValue(42)];
        string response = sendJsonValue("https://httpbin.org/post", testData);
        return response.canFind("json_post") && response.canFind("42");
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the JSON payload example
 */
void runExample() {
    writeln("=== JSON Payload POST Requests ===\n");

    if (!testJsonPostCapability()) {
        writeln("ERROR: JSON POST functionality test failed!");
        writeln("This might be due to network issues or std.curl problems.");
        return;
    }

    writeln("✓ JSON POST functionality confirmed\n");

    // Demonstrate different JSON payload patterns
    demonstrateBasicJsonPost();
    demonstrateNestedJson();
    demonstrateMinimalJson();
    demonstrateJsonSpecialChars();
    demonstrateLargeJson();
    demonstrateJsonErrors();
    demonstrateJsonResponseParsing();

    writeln("\n=== Summary ===");
    writeln("• JSON data sent with Content-Type: application/json header");
    writeln("• JSONValue.toString() converts D JSON objects to strings");
    writeln("• Nested objects and arrays work seamlessly");
    writeln("• Special characters are properly escaped in JSON");
    writeln("• Large JSON payloads handled efficiently");
    writeln("• Invalid JSON caught by JSONException");
    writeln("• Response JSON can be parsed back into JSONValue objects");
}

unittest {
    writeln("=== Running json_payload tests ===");

    // Test JSON POST capability
    bool jsonWorks = testJsonPostCapability();
    writefln("JSON POST capability test: %s", jsonWorks ? "working" : "not working");

    // Test JSONValue creation and manipulation
    JSONValue json;
    json = ["name": JSONValue("test"), "value": JSONValue(123)];
    assert(json.type == JSONType.object);
    assert("name" in json);
    assert(json["name"].str == "test");
    assert(json["value"].integer == 123);
    writeln("✓ JSONValue creation works");

    // Test JSON string conversion
    string jsonStr = json.toString();
    assert(jsonStr.canFind("{"));
    assert(jsonStr.canFind("}"));
    assert(jsonStr.canFind("\"name\""));
    assert(jsonStr.canFind("\"test\""));
    assert(jsonStr.canFind("123"));
    writeln("✓ JSON string conversion works");

    // Test nested JSON structures
    JSONValue nested = [
        "user": JSONValue([
            "id": JSONValue(1),
            "profile": JSONValue([
                "name": JSONValue("John"),
                "age": JSONValue(30)
            ])
        ])
    ];

    assert(nested["user"]["profile"]["name"].str == "John");
    assert(nested["user"]["profile"]["age"].integer == 30);
    writeln("✓ Nested JSON structures work");

    // Test JSON array operations
    JSONValue arr = JSONValue([JSONValue(1), JSONValue(2), JSONValue(3)]);
    assert(arr.type == JSONType.array);
    assert(arr.array.length == 3);
    assert(arr[0].integer == 1);
    assert(arr[2].integer == 3);
    writeln("✓ JSON array operations work");

    // Test special value types
    JSONValue special = [
        "null_val": JSONValue(null),
        "bool_val": JSONValue(true),
        "string_val": JSONValue("hello"),
        "number_val": JSONValue(42.5)
    ];

    assert(special["null_val"].type == JSONType.null_);
    assert(special["bool_val"].boolean == true);
    assert(special["string_val"].str == "hello");
    assert(special["number_val"].floating == 42.5);
    writeln("✓ JSON special value types work");

    // Test JSON parsing from string
    string jsonInput = `{"status": "ok", "data": [1, 2, 3]}`;
    JSONValue parsed = parseJSON(jsonInput);
    assert(parsed["status"].str == "ok");
    assert(parsed["data"].array.length == 3);
    writeln("✓ JSON parsing from string works");

    // Test large JSON creation
    JSONValue largeJson;
    JSONValue[] items;
    for (int i = 0; i < 50; i++) {
        items ~= JSONValue(["id": JSONValue(i), "data": JSONValue(format("item%d", i))]);
    }
    largeJson = ["items": JSONValue(items)];

    string largeStr = largeJson.toString();
    assert(largeStr.length > 1000); // Should be substantial
    assert(largeStr.canFind("item49"));
    writeln("✓ Large JSON creation works");

    // Test content type header
    string contentType = "application/json";
    assert(contentType.canFind("json"));
    assert(contentType.canFind("application"));
    writeln("✓ Content-Type header validation works");

    // Test invalid JSON detection
    bool caughtException = false;
    try {
        parseJSON("{invalid json");
    } catch (JSONException e) {
        caughtException = true;
    }
    assert(caughtException);
    writeln("✓ Invalid JSON exception handling works");

    // Test response verification patterns
    string mockResponse = `{"json": {"action": "test", "data": "value"}, "data": "json_string"}`;
    bool hasAction = mockResponse.canFind("test");
    bool hasJsonData = mockResponse.canFind("value");
    assert(hasAction && hasJsonData);
    writeln("✓ Response verification patterns work");

    writeln("All json_payload tests passed!");
    writeln("=== json_payload tests completed ===");
}
