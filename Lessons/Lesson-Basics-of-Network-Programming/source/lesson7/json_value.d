/**
 * Lesson 7: Working with JsonValue - Advanced JsonValue operations
 *
 * This example demonstrates advanced operations with JSONValue objects,
 * including type checking, value extraction, iteration, and manipulation.
 */

module lesson7.json_value;

import std.stdio;
import std.json;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

/**
 * Demonstrate JsonValue type system
 */
void demonstrateValueTypes() {
    writeln("=== JsonValue Type System ===");

    // Create values of different types
    JSONValue stringVal = JSONValue("Hello World");
    JSONValue intVal = JSONValue(42);
    JSONValue floatVal = JSONValue(3.14159);
    JSONValue boolTrue = JSONValue(true);
    JSONValue boolFalse = JSONValue(false);
    JSONValue nullVal = JSONValue(null);
    JSONValue arrayVal = JSONValue([1, 2, 3]);
    JSONValue objectVal = JSONValue(["key": JSONValue("value")]);

    writefln("String value: %s (type: %s)", stringVal, stringVal.type);
    writefln("Integer value: %s (type: %s)", intVal, intVal.type);
    writefln("Float value: %s (type: %s)", floatVal, floatVal.type);
    writefln("Boolean true: %s (type: %s)", boolTrue, boolTrue.type);
    writefln("Boolean false: %s (type: %s)", boolFalse, boolFalse.type);
    writefln("Null value: %s (type: %s)", nullVal, nullVal.type);
    writefln("Array value: %s (type: %s)", arrayVal, arrayVal.type);
    writefln("Object value: %s (type: %s)", objectVal, objectVal.type);
    writeln();

    // Type checking methods
    writefln("Type checking:");
    writefln("stringVal is string: %s", stringVal.type == JSONType.string);
    writefln("intVal is integer: %s", intVal.type == JSONType.integer);
    writefln("floatVal is float: %s", floatVal.type == JSONType.float_);
    writefln("boolTrue is boolean: %s", boolTrue.type == JSONType.true_ || boolTrue.type == JSONType.false_);
    writefln("nullVal is null: %s", nullVal.isNull);
    writefln("arrayVal is array: %s", arrayVal.type == JSONType.array);
    writefln("objectVal is object: %s", objectVal.type == JSONType.object);
}

/**
 * Demonstrate safe value extraction
 */
void demonstrateSafeExtraction() {
    writeln("\n=== Safe Value Extraction ===");

    string jsonText = `{
        "name": "API Response",
        "status": 200,
        "success": true,
        "data": {
            "count": 5,
            "items": ["apple", "banana", "cherry"]
        },
        "metadata": null
    }`;

    JSONValue json = parseJSON(jsonText);

    writefln("Safe extraction examples:");

    // Extract string with type check
    if (json.type == JSONType.object && "name" in json) {
        JSONValue nameVal = json["name"];
        if (nameVal.type == JSONType.string) {
            writefln("Name: %s", nameVal.str);
        }
    }

    // Extract integer with type check
    if ("status" in json && json["status"].type == JSONType.integer) {
        writefln("Status: %d", json["status"].integer);
    }

    // Extract boolean with type check
    if ("success" in json && (json["success"].type == JSONType.true_ || json["success"].type == JSONType.false_)) {
        writefln("Success: %s", json["success"].boolean);
    }

    // Extract nested values safely
    if ("data" in json && json["data"].type == JSONType.object) {
        JSONValue data = json["data"];

        if ("count" in data && data["count"].type == JSONType.integer) {
            writefln("Count: %d", data["count"].integer);
        }

        if ("items" in data && data["items"].type == JSONType.array) {
            writefln("Items: %s", data["items"].array.map!(item => item.str).join(", "));
        }
    }

    // Handle null values
    if ("metadata" in json && json["metadata"].isNull) {
        writefln("Metadata: null (handled safely)");
    }

    // Handle missing keys
    if ("missingKey" !in json) {
        writefln("Missing key handled gracefully");
    }
}

/**
 * Demonstrate array operations
 */
void demonstrateArrayOperations() {
    writeln("\n=== Array Operations ===");

    // Create array
    JSONValue numbers = JSONValue([1, 2, 3, 4, 5]);
    writefln("Original array: %s", numbers);

    // Access elements
    writefln("First element: %d", numbers[0].integer);
    writefln("Last element: %d", numbers[numbers.array.length - 1].integer);
    writefln("Array length: %d", numbers.array.length);

    // Modify elements
    numbers[0] = JSONValue(10);
    numbers.array ~= JSONValue(6);  // Append
    writefln("Modified array: %s", numbers);

    // Iterate over array
    writefln("Iterating over array:");
    foreach (i, JSONValue item; numbers.array) {
        writefln("  [%d]: %s", i, item.integer);
    }

    // Mixed-type arrays
    JSONValue mixed = JSONValue([
        JSONValue("string"),
        JSONValue(42),
        JSONValue(true),
        JSONValue(null),
        JSONValue(["nested", "array"])
    ]);

    writefln("\nMixed-type array: %s", mixed);
    writefln("Element types:");
    foreach (i, JSONValue item; mixed.array) {
        writefln("  [%d]: %s (%s)", i, item, item.type);
    }
}

/**
 * Demonstrate object operations
 */
void demonstrateObjectOperations() {
    writeln("\n=== Object Operations ===");

    // Create object
    JSONValue person = JSONValue([
        "name": JSONValue("Alice"),
        "age": JSONValue(30),
        "city": JSONValue("New York")
    ]);

    writefln("Original object: %s", person.toPrettyString());

    // Access properties
    writefln("Name: %s", person["name"].str);
    writefln("Age: %d", person["age"].integer);

    // Check if keys exist
    writefln("Has 'name' key: %s", "name" in person);
    writefln("Has 'email' key: %s", "email" in person);

    // Add new properties
    person["email"] = JSONValue("alice@example.com");
    person["active"] = JSONValue(true);

    // Modify existing properties
    person["age"] = JSONValue(31);

    // Remove properties
    person.object.remove("city");

    writefln("Modified object: %s", person.toPrettyString());

    // Iterate over object properties
    writefln("Iterating over object properties:");
    foreach (string key, JSONValue value; person.object) {
        writefln("  %s: %s (%s)", key, value, value.type);
    }
}

/**
 * Demonstrate complex nested structures
 */
void demonstrateNestedStructures() {
    writeln("\n=== Nested Structures ===");

    // Create a complex nested structure
    JSONValue company = JSONValue([
        "name": JSONValue("Tech Corp"),
        "founded": JSONValue(2010),
        "active": JSONValue(true),
        "departments": JSONValue([
            JSONValue([
                "name": JSONValue("Engineering"),
                "headcount": JSONValue(25),
                "teams": JSONValue([
                    JSONValue([
                        "name": JSONValue("Frontend"),
                        "members": JSONValue(8)
                    ]),
                    JSONValue([
                        "name": JSONValue("Backend"),
                        "members": JSONValue(10)
                    ])
                ])
            ]),
            JSONValue([
                "name": JSONValue("Sales"),
                "headcount": JSONValue(15)
            ])
        ])
    ]);

    writefln("Complex nested structure:");
    writefln("%s", company.toPrettyString());

    // Extract nested data safely
    writefln("Extracting nested data:");

    if ("departments" in company && company["departments"].type == JSONType.array) {
        JSONValue depts = company["departments"];

        foreach (i, JSONValue dept; depts.array) {
            if ("name" in dept && dept["name"].type == JSONType.string) {
                writefln("Department %d: %s", i + 1, dept["name"].str);

                if ("teams" in dept && dept["teams"].type == JSONType.array) {
                    foreach (j, JSONValue team; dept["teams"].array) {
                        if ("name" in team && "members" in team) {
                            writefln("  Team %s: %d members",
                                team["name"].str, team["members"].integer);
                        }
                    }
                }
            }
        }
    }
}

/**
 * Demonstrate value conversion utilities
 */
void demonstrateValueConversion() {
    writeln("\n=== Value Conversion ===");

    // Sample JSON data
    JSONValue data = parseJSON(`{
        "text": "Hello",
        "number": 42,
        "decimal": 3.14,
        "flag": true,
        "items": [1, 2, 3]
    }`);

    writefln("Converting values to strings:");

    // Convert different types to string
    if (data["text"].type == JSONType.string) {
        writefln("Text as string: '%s'", data["text"].str);
    }

    if (data["number"].type == JSONType.integer) {
        writefln("Number as string: '%s'", to!string(data["number"].integer));
    }

    if (data["decimal"].type == JSONType.float_) {
        writefln("Decimal as string: '%s'", to!string(data["decimal"].floating));
    }

    if (data["flag"].type == JSONType.true_ || data["flag"].type == JSONType.false_) {
        writefln("Boolean as string: '%s'", to!string(data["flag"].boolean));
    }

    // Convert array elements
    if (data["items"].type == JSONType.array) {
        string[] stringItems = data["items"].array.map!(item => to!string(item.integer)).array;
        writefln("Array as strings: [%s]", stringItems.join(", "));
    }

    // Convert entire JSON to string
    writefln("Full JSON as string: %s", data.toString());
    writefln("Full JSON pretty-printed:");
    writefln("%s", data.toPrettyString());
}

/**
 * Check if JsonValue functionality works
 */
bool testJsonValueCapability() {
    try {
        // Test basic operations
        JSONValue obj = JSONValue(["key": JSONValue("value")]);
        if (obj["key"].str != "value") return false;

        JSONValue arr = JSONValue([1, 2, 3]);
        if (arr.array.length != 3 || arr[0].integer != 1) return false;

        // Test type checking
        JSONValue str = JSONValue("test");
        JSONValue num = JSONValue(42);
        if (str.type != JSONType.string || num.type != JSONType.integer) return false;

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the JsonValue example
 */
void runExample() {
    writeln("=== Working with JsonValue Demonstration ===\n");

    if (!testJsonValueCapability()) {
        writeln("ERROR: JsonValue functionality test failed!");
        writeln("This might be due to std.json module issues.");
        return;
    }

    writeln("✓ JsonValue functionality confirmed\n");

    demonstrateValueTypes();
    demonstrateSafeExtraction();
    demonstrateArrayOperations();
    demonstrateObjectOperations();
    demonstrateNestedStructures();
    demonstrateValueConversion();

    writeln("\n=== Summary ===");
    writeln("• JsonValue represents all JSON data types with type safety");
    writeln("• Always check types before accessing values (.type, .isNull)");
    writeln("• Use 'in' operator to check for object keys");
    writeln("• Arrays and objects can be modified after creation");
    writeln("• Nested structures require careful traversal");
    writeln("• Use toString() for compact JSON, toPrettyString() for readable JSON");
}

unittest {
    writeln("=== Running json_value tests ===");

    // Test JsonValue capability
    bool jsonValueWorks = testJsonValueCapability();
    writefln("JsonValue capability test: %s", jsonValueWorks ? "working" : "not working");
    assert(jsonValueWorks);

    // Test value creation and access
    JSONValue testObj = JSONValue(["string": JSONValue("hello"), "number": JSONValue(123)]);
    assert(testObj["string"].str == "hello");
    assert(testObj["number"].integer == 123);
    writeln("✓ Object creation and access works");

    // Test array operations
    JSONValue testArr = JSONValue([10, 20, 30]);
    assert(testArr.array.length == 3);
    assert(testArr[1].integer == 20);
    testArr.array ~= JSONValue(40);
    assert(testArr.array.length == 4);
    writeln("✓ Array operations work");

    // Test type enumeration
    assert(JSONType.string == JSONType.string);
    assert(JSONType.integer != JSONType.string);
    assert(JSONType.true_ != JSONType.false_);
    writeln("✓ JSON type enumeration works");

    // Test null handling
    JSONValue nullVal = JSONValue(null);
    assert(nullVal.isNull);
    assert(nullVal.type == JSONType.null_);
    writeln("✓ Null value handling works");

    // Test nested access
    JSONValue nested = JSONValue([
        "level1": JSONValue([
            "level2": JSONValue([
                "value": JSONValue("deep")
            ])
        ])
    ]);
    assert(nested["level1"]["level2"]["value"].str == "deep");
    writeln("✓ Nested access works");

    // Test key existence checking
    JSONValue obj = JSONValue(["exists": JSONValue("yes")]);
    assert("exists" in obj);
    assert("missing" !in obj);
    writeln("✓ Key existence checking works");

    writeln("All json_value tests passed!");
    writeln("=== json_value tests completed ===");
}
