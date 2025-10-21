/**
 * Lesson 7: JSON Basics - Introduction to std.json parsing and serialization
 *
 * This example demonstrates fundamental JSON operations using D's std.json module,
 * including parsing JSON strings, accessing values, and serializing data back to JSON.
 */

module lesson7.json_basics;

import std.stdio;
import std.json;
import std.string;
import std.conv;

/**
 * Demonstrate basic JSON parsing
 */
void demonstrateJSONParsing() {
    writeln("=== Basic JSON Parsing ===");

    // Simple JSON string
    string jsonString = `{
        "name": "John Doe",
        "age": 30,
        "isStudent": false,
        "grades": [85, 92, 78],
        "address": {
            "street": "123 Main St",
            "city": "Anytown",
            "zipCode": "12345"
        }
    }`;

    writefln("Original JSON string:");
    writefln("%s", jsonString);
    writeln();

    try {
        // Parse JSON
        JSONValue json = parseJSON(jsonString);

        // Access basic values
        writefln("Name: %s", json["name"].str);
        writefln("Age: %d", json["age"].integer);
        writefln("Is Student: %s", json["isStudent"].boolean);

        // Access array elements
        writefln("First grade: %d", json["grades"][0].integer);
        writefln("Number of grades: %d", json["grades"].array.length);

        // Access nested object
        writefln("City: %s", json["address"]["city"].str);
        writefln("ZIP Code: %s", json["address"]["zipCode"].str);

        writeln("✓ JSON parsing successful");

    } catch (JSONException e) {
        writefln("✗ JSON parsing failed: %s", e.msg);
    }
}

/**
 * Demonstrate JSON serialization
 */
void demonstrateJSONSerialization() {
    writeln("\n=== JSON Serialization ===");

    // Create JSON values
    JSONValue person = JSONValue([
        "name": JSONValue("Alice Smith"),
        "age": JSONValue(25),
        "hobbies": JSONValue(["reading", "coding", "gaming"]),
        "contact": JSONValue([
            "email": JSONValue("alice@example.com"),
            "phone": JSONValue("555-0123")
        ])
    ]);

    // Convert to JSON string
    string jsonString = person.toString();

    writefln("Serialized JSON:");
    writefln("%s", jsonString);
    writeln();

    // Pretty print (formatted)
    string prettyJson = person.toPrettyString();
    writefln("Pretty-printed JSON:");
    writefln("%s", prettyJson);
    writeln();

    // Verify we can parse it back
    try {
        JSONValue parsed = parseJSON(jsonString);
        writefln("✓ Serialization round-trip successful");
        writefln("Parsed name: %s", parsed["name"].str);
    } catch (JSONException e) {
        writefln("✗ Round-trip failed: %s", e.msg);
    }
}

/**
 * Demonstrate different JSON value types
 */
void demonstrateJSONTypes() {
    writeln("\n=== JSON Value Types ===");

    // Create different types of JSON values
    JSONValue nullValue = JSONValue(null);
    JSONValue boolValue = JSONValue(true);
    JSONValue intValue = JSONValue(42);
    JSONValue floatValue = JSONValue(3.14159);
    JSONValue stringValue = JSONValue("Hello, JSON!");
    JSONValue arrayValue = JSONValue([1, 2, 3, 4, 5]);
    JSONValue objectValue = JSONValue(["key": JSONValue("value")]);

    writefln("null value: %s", nullValue.toString());
    writefln("boolean value: %s", boolValue.toString());
    writefln("integer value: %s", intValue.toString());
    writefln("float value: %s", floatValue.toString());
    writefln("string value: %s", stringValue.toString());
    writefln("array value: %s", arrayValue.toString());
    writefln("object value: %s", objectValue.toString());
    writeln();

    // Check types
    writefln("Type checks:");
    writefln("nullValue is null: %s", nullValue.isNull);
    writefln("boolValue is boolean: %s", boolValue.type == JSONType.true_ || boolValue.type == JSONType.false_);
    writefln("intValue is integer: %s", intValue.type == JSONType.integer);
    writefln("floatValue is float: %s", floatValue.type == JSONType.float_);
    writefln("stringValue is string: %s", stringValue.type == JSONType.string);
    writefln("arrayValue is array: %s", arrayValue.type == JSONType.array);
    writefln("objectValue is object: %s", objectValue.type == JSONType.object);
}

/**
 * Demonstrate JSON manipulation
 */
void demonstrateJSONManipulation() {
    writeln("\n=== JSON Manipulation ===");

    // Start with a base object
    JSONValue user = JSONValue([
        "username": JSONValue("johndoe"),
        "email": JSONValue("john@example.com"),
        "active": JSONValue(true)
    ]);

    writefln("Original user object:");
    writefln("%s", user.toPrettyString());
    writeln();

    // Add new fields
    user["fullName"] = JSONValue("John Doe");
    user["age"] = JSONValue(28);
    user["tags"] = JSONValue(["developer", "admin"]);

    // Modify existing fields
    user["email"] = JSONValue("john.doe@example.com");

    // Remove a field
    user.object.remove("active");

    writefln("Modified user object:");
    writefln("%s", user.toPrettyString());
    writeln();

    // Array manipulation
    JSONValue scores = JSONValue([85, 92, 78]);
    scores.array ~= JSONValue(88);  // Add element
    scores[0] = JSONValue(90);      // Modify element

    writefln("Modified scores array: %s", scores.toString());
}

/**
 * Demonstrate safe JSON access patterns
 */
void demonstrateSafeAccess() {
    writeln("\n=== Safe JSON Access ===");

    string jsonData = `{
        "user": {
            "name": "Bob",
            "profile": {
                "age": 35,
                "city": "Springfield"
            }
        },
        "permissions": ["read", "write"]
    }`;

    JSONValue data = parseJSON(jsonData);

    // Safe access with checks
    writefln("Safe access examples:");

    // Check if key exists before accessing
    if ("user" in data && data["user"].type == JSONType.object) {
        writefln("✓ User object found");
        if ("name" in data["user"]) {
            writefln("  Name: %s", data["user"]["name"].str);
        }
    }

    // Safe nested access
    if ("user" in data && "profile" in data["user"] && "city" in data["user"]["profile"]) {
        writefln("  City: %s", data["user"]["profile"]["city"].str);
    }

    // Safe array access
    if ("permissions" in data && data["permissions"].type == JSONType.array) {
        writefln("  Permissions count: %d", data["permissions"].array.length);
        if (data["permissions"].array.length > 0) {
            writefln("  First permission: %s", data["permissions"][0].str);
        }
    }

    // Accessing non-existent keys (will throw if not checked)
    try {
        if ("missingKey" in data) {
            writefln("Missing key value: %s", data["missingKey"].str);
        } else {
            writefln("✓ Missing key handled safely");
        }
    } catch (Exception e) {
        writefln("✗ Unexpected error: %s", e.msg);
    }
}

/**
 * Check if JSON functionality works
 */
bool testJSONCapability() {
    try {
        // Test basic parsing
        string testJson = `{"test": "value", "number": 42}`;
        JSONValue parsed = parseJSON(testJson);

        if (parsed["test"].str != "value" || parsed["number"].integer != 42) {
            return false;
        }

        // Test serialization
        JSONValue testObj = JSONValue(["key": JSONValue("value")]);
        string serialized = testObj.toString();
        JSONValue reparsed = parseJSON(serialized);

        return reparsed["key"].str == "value";
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the JSON basics example
 */
void runExample() {
    writeln("=== JSON Basics Demonstration ===\n");

    if (!testJSONCapability()) {
        writeln("ERROR: JSON functionality test failed!");
        writeln("This might be due to std.json module issues.");
        return;
    }

    writeln("✓ JSON functionality confirmed\n");

    demonstrateJSONParsing();
    demonstrateJSONSerialization();
    demonstrateJSONTypes();
    demonstrateJSONManipulation();
    demonstrateSafeAccess();

    writeln("\n=== Summary ===");
    writeln("• std.json provides JSON parsing and serialization");
    writeln("• JSONValue can represent all JSON data types");
    writeln("• Use parseJSON() to parse JSON strings");
    writeln("• Use toString() and toPrettyString() for serialization");
    writeln("• Always check types and keys before accessing values");
    writeln("• JSON objects are associative arrays, arrays are dynamic arrays");
}

unittest {
    writeln("=== Running json_basics tests ===");

    // Test JSON parsing capability
    bool jsonWorks = testJSONCapability();
    writefln("JSON capability test: %s", jsonWorks ? "working" : "not working");
    assert(jsonWorks);

    // Test basic JSON creation and access
    JSONValue test = JSONValue(["name": JSONValue("test"), "value": JSONValue(123)]);
    assert(test["name"].str == "test");
    assert(test["value"].integer == 123);
    writeln("✓ Basic JSON operations work");

    // Test array operations
    JSONValue arr = JSONValue([1, 2, 3]);
    assert(arr.array.length == 3);
    assert(arr[0].integer == 1);
    arr.array ~= JSONValue(4);
    assert(arr.array.length == 4);
    writeln("✓ JSON array operations work");

    // Test type checking
    JSONValue strVal = JSONValue("hello");
    JSONValue intVal = JSONValue(42);
    JSONValue boolVal = JSONValue(true);
    JSONValue nullVal = JSONValue(null);

    assert(strVal.type == JSONType.string);
    assert(intVal.type == JSONType.integer);
    assert(boolVal.type == JSONType.true_);
    assert(nullVal.isNull);
    writeln("✓ JSON type checking works");

    // Test serialization round-trip
    JSONValue original = JSONValue([
        "string": JSONValue("test"),
        "number": JSONValue(123),
        "array": JSONValue([1, 2, 3])
    ]);

    string serialized = original.toString();
    JSONValue deserialized = parseJSON(serialized);

    assert(deserialized["string"].str == "test");
    assert(deserialized["number"].integer == 123);
    assert(deserialized["array"].array.length == 3);
    writeln("✓ JSON serialization round-trip works");

    writeln("All json_basics tests passed!");
    writeln("=== json_basics tests completed ===");
}

