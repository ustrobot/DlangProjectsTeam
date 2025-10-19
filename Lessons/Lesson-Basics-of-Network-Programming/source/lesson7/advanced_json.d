/**
 * Lesson 7: Advanced JSON Handling - Error handling, custom parsing, and complex structures
 *
 * This example demonstrates advanced JSON processing techniques including error handling,
 * custom parsing strategies, and working with complex nested structures.
 */

module lesson7.advanced_json;

import std.stdio;
import std.json;
import std.string;
import std.conv;
import std.algorithm;
import std.exception;
import std.array;

/**
 * Custom exception for JSON processing errors
 */
class JSONProcessingException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}

/**
 * Result type for safe JSON operations
 */
struct JSONResult(T) {
    bool success;
    T value;
    string errorMessage;

    static JSONResult!T ok(T val) {
        return JSONResult!T(true, val, "");
    }

    static JSONResult!T error(string err) {
        return JSONResult!T(false, T.init, err);
    }
}

/**
 * Demonstrate error handling in JSON processing
 */
void demonstrateErrorHandling() {
    writeln("=== Error Handling in JSON Processing ===");

    // Test cases with various JSON errors
    string[] testCases = [
        // Valid JSON
        `{"name": "Valid", "value": 123}`,

        // Invalid JSON - missing comma
        `{"name": "Invalid" "value": 123}`,

        // Invalid JSON - unclosed brace
        `{"name": "Incomplete", "value": 123`,

        // Valid JSON but missing expected field
        `{"name": "Missing Field"}`,

        // Valid JSON but wrong type
        `{"name": "Wrong Type", "value": "not_a_number"}`
    ];

    foreach (i, jsonStr; testCases) {
        writefln("Test case %d:", i + 1);
        writefln("  Input: %s", jsonStr);

        try {
            // Try to parse JSON
            JSONValue data = parseJSON(jsonStr);
            writefln("  Parse: ✓ Success");

            // Try to extract expected data
            auto result = safeExtractUserData(data);
            if (result.success) {
                writefln("  Extract: ✓ Success - Name: %s, Value: %d",
                        result.value.name, result.value.value);
            } else {
                writefln("  Extract: ✗ Failed - %s", result.errorMessage);
            }

        } catch (JSONException e) {
            writefln("  Parse: ✗ Failed - %s", e.msg);
        } catch (Exception e) {
            writefln("  Unexpected error: %s", e.msg);
        }
        writeln();
    }
}

/**
 * User data structure for testing
 */
struct UserData {
    string name;
    int value;
}

/**
 * Safely extract user data with detailed error reporting
 */
JSONResult!UserData safeExtractUserData(JSONValue json) {
    // Check if it's an object
    if (json.type != JSONType.object) {
        return JSONResult!UserData.error("Expected JSON object, got " ~ to!string(json.type));
    }

    // Check for required fields
    if ("name" !in json) {
        return JSONResult!UserData.error("Missing required field 'name'");
    }

    if ("value" !in json) {
        return JSONResult!UserData.error("Missing required field 'value'");
    }

    // Extract name
    if (json["name"].type != JSONType.string) {
        return JSONResult!UserData.error("Field 'name' must be a string");
    }
    string name = json["name"].str;

    // Extract value
    if (json["value"].type != JSONType.integer) {
        return JSONResult!UserData.error("Field 'value' must be an integer");
    }
    int value = cast(int)json["value"].integer;

    return JSONResult!UserData.ok(UserData(name, value));
}

/**
 * Demonstrate custom JSON parsing with validation
 */
void demonstrateCustomParsing() {
    writeln("\n=== Custom JSON Parsing with Validation ===");

    string configJson = `{
        "server": {
            "host": "localhost",
            "port": 8080,
            "ssl": true,
            "timeout": 30
        },
        "database": {
            "type": "postgresql",
            "host": "db.example.com",
            "port": 5432,
            "name": "myapp",
            "credentials": {
                "username": "app_user",
                "password": "secret123"
            }
        },
        "features": ["auth", "logging", "metrics"]
    }`;

    writefln("Parsing configuration with validation:");

    try {
        JSONValue config = parseJSON(configJson);

        // Parse server configuration
        auto serverResult = parseServerConfig(config);
        if (serverResult.success) {
            writefln("✓ Server config: %s:%d (SSL: %s, Timeout: %d)",
                    serverResult.value.host, serverResult.value.port,
                    serverResult.value.ssl, serverResult.value.timeout);
        } else {
            writefln("✗ Server config error: %s", serverResult.errorMessage);
        }

        // Parse database configuration
        auto dbResult = parseDatabaseConfig(config);
        if (dbResult.success) {
            writefln("✓ Database config: %s@%s:%d/%s",
                    dbResult.value.username, dbResult.value.host,
                    dbResult.value.port, dbResult.value.database);
        } else {
            writefln("✗ Database config error: %s", dbResult.errorMessage);
        }

        // Parse features
        auto featuresResult = parseFeatures(config);
        if (featuresResult.success) {
            writefln("✓ Features: [%s]", featuresResult.value.join(", "));
        } else {
            writefln("✗ Features error: %s", featuresResult.errorMessage);
        }

    } catch (JSONException e) {
        writefln("✗ JSON parsing error: %s", e.msg);
    }
}

/**
 * Server configuration structure
 */
struct ServerConfig {
    string host;
    int port;
    bool ssl;
    int timeout;
}

/**
 * Parse server configuration from JSON
 */
JSONResult!ServerConfig parseServerConfig(JSONValue config) {
    if ("server" !in config || config["server"].type != JSONType.object) {
        return JSONResult!ServerConfig.error("Missing or invalid 'server' configuration");
    }

    JSONValue server = config["server"];

    ServerConfig result;

    // Validate and extract host
    if ("host" !in server || server["host"].type != JSONType.string) {
        return JSONResult!ServerConfig.error("Server host must be a string");
    }
    result.host = server["host"].str;

    // Validate and extract port
    if ("port" !in server || server["port"].type != JSONType.integer) {
        return JSONResult!ServerConfig.error("Server port must be an integer");
    }
    result.port = cast(int)server["port"].integer;
    if (result.port < 1 || result.port > 65535) {
        return JSONResult!ServerConfig.error("Server port must be between 1 and 65535");
    }

    // Extract SSL (optional, defaults to false)
    result.ssl = ("ssl" in server && server["ssl"].type == JSONType.true_);

    // Extract timeout (optional, defaults to 30)
    result.timeout = 30;
    if ("timeout" in server && server["timeout"].type == JSONType.integer) {
        result.timeout = cast(int)server["timeout"].integer;
        if (result.timeout < 1) {
            return JSONResult!ServerConfig.error("Timeout must be positive");
        }
    }

    return JSONResult!ServerConfig.ok(result);
}

/**
 * Database configuration structure
 */
struct DatabaseConfig {
    string type;
    string host;
    int port;
    string database;
    string username;
    string password;
}

/**
 * Parse database configuration from JSON
 */
JSONResult!DatabaseConfig parseDatabaseConfig(JSONValue config) {
    if ("database" !in config || config["database"].type != JSONType.object) {
        return JSONResult!DatabaseConfig.error("Missing or invalid 'database' configuration");
    }

    JSONValue db = config["database"];

    DatabaseConfig result;

    // Extract required fields
    string[] requiredFields = ["type", "host", "port", "name"];
    foreach (field; requiredFields) {
        if (field !in db) {
            return JSONResult!DatabaseConfig.error("Missing required database field: " ~ field);
        }
    }

    result.type = db["type"].str;
    result.host = db["host"].str;
    result.port = cast(int)db["port"].integer;
    result.database = db["name"].str;

    // Extract credentials
    if ("credentials" in db && db["credentials"].type == JSONType.object) {
        JSONValue creds = db["credentials"];
        result.username = ("username" in creds) ? creds["username"].str : "";
        result.password = ("password" in creds) ? creds["password"].str : "";
    }

    return JSONResult!DatabaseConfig.ok(result);
}

/**
 * Parse features array from JSON
 */
JSONResult!(string[]) parseFeatures(JSONValue config) {
    if ("features" !in config || config["features"].type != JSONType.array) {
        return JSONResult!(string[]).error("Missing or invalid 'features' array");
    }

    string[] features;
    foreach (feature; config["features"].array) {
        if (feature.type != JSONType.string) {
            return JSONResult!(string[]).error("All features must be strings");
        }
        features ~= feature.str;
    }

    return JSONResult!(string[]).ok(features);
}

/**
 * Demonstrate JSON transformation and filtering
 */
void demonstrateTransformation() {
    writeln("\n=== JSON Transformation and Filtering ===");

    string rawData = `[
        {"id": 1, "name": "Alice", "age": 25, "city": "New York", "active": true},
        {"id": 2, "name": "Bob", "age": 30, "city": "London", "active": false},
        {"id": 3, "name": "Charlie", "age": 35, "city": "New York", "active": true},
        {"id": 4, "name": "Diana", "age": 28, "city": "Paris", "active": true}
    ]`;

    JSONValue users = parseJSON(rawData);

    writefln("Original user data:");
    writefln("%s", users.toPrettyString());
    writeln();

    // Filter active users
    JSONValue activeUsers = filterUsers(users, "active", true);
    writefln("Active users only:");
    writefln("%s", activeUsers.toPrettyString());
    writeln();

    // Transform to summary format
    JSONValue summary = transformUsersToSummary(users);
    writefln("Transformed to summary format:");
    writefln("%s", summary.toPrettyString());
    writeln();

    // Group by city
    auto grouped = groupUsersByCity(users);
    writefln("Grouped by city:");
    foreach (city, cityUsers; grouped) {
        writefln("  %s: %d users", city, cityUsers.array.length);
    }
}

/**
 * Filter users by a boolean field
 */
JSONValue filterUsers(JSONValue users, string field, bool value) {
    if (users.type != JSONType.array) {
        return parseJSON("[]");
    }

    JSONValue[] filtered;
    foreach (user; users.array) {
        if (user.type == JSONType.object && field in user) {
            bool fieldValue = (user[field].type == JSONType.true_);
            if (fieldValue == value) {
                filtered ~= user;
            }
        }
    }

    return JSONValue(filtered);
}

/**
 * Transform users to summary format
 */
JSONValue transformUsersToSummary(JSONValue users) {
    if (users.type != JSONType.array) {
        return parseJSON("[]");
    }

    JSONValue[] summaries;
    foreach (user; users.array) {
        if (user.type == JSONType.object) {
            JSONValue summary = JSONValue([
                "name": ("name" in user) ? user["name"] : JSONValue("Unknown"),
                "age": ("age" in user) ? user["age"] : JSONValue(0),
                "location": ("city" in user) ? user["city"] : JSONValue("Unknown")
            ]);
            summaries ~= summary;
        }
    }

    return JSONValue(summaries);
}

/**
 * Group users by city
 */
JSONValue[string] groupUsersByCity(JSONValue users) {
    JSONValue[string] groups;

    if (users.type != JSONType.array) {
        return groups;
    }

    foreach (user; users.array) {
        if (user.type == JSONType.object && "city" in user && user["city"].type == JSONType.string) {
            string city = user["city"].str;

            if (city !in groups) {
                groups[city] = parseJSON("[]");
            }

            groups[city].array ~= user;
        }
    }

    return groups;
}

/**
 * Demonstrate JSON schema validation
 */
void demonstrateSchemaValidation() {
    writeln("\n=== JSON Schema Validation ===");

    // Define a simple schema for user objects
    string[] requiredFields = ["name", "email", "age"];
    string[][string] fieldTypes = [
        "name": ["string"],
        "email": ["string"],
        "age": ["integer"],
        "active": ["boolean"]
    ];

    // Test data
    string[] testUsers = [
        `{"name": "Alice", "email": "alice@example.com", "age": 25, "active": true}`,
        `{"name": "Bob", "email": "bob@example.com"}`,  // Missing age
        `{"name": "Charlie", "email": "charlie@example.com", "age": "thirty"}`,  // Wrong type
        `{"email": "diana@example.com", "age": 30}`,  // Missing name
        `{"name": "Eve", "email": "eve@example.com", "age": 28, "department": "IT"}`  // Extra field (OK)
    ];

    foreach (i, userJson; testUsers) {
        writefln("Validating user %d: %s", i + 1, userJson);

        try {
            JSONValue user = parseJSON(userJson);
            string[] validationErrors = validateUserSchema(user, requiredFields, fieldTypes);

            if (validationErrors.empty) {
                writefln("  ✓ Valid");
            } else {
                writefln("  ✗ Invalid:");
                foreach (error; validationErrors) {
                    writefln("    - %s", error);
                }
            }
        } catch (JSONException e) {
            writefln("  ✗ JSON parsing error: %s", e.msg);
        }
        writeln();
    }
}

/**
 * Validate user object against schema
 */
string[] validateUserSchema(JSONValue user, string[] requiredFields, string[][string] fieldTypes) {
    string[] errors;

    // Check if it's an object
    if (user.type != JSONType.object) {
        errors ~= "Must be a JSON object";
        return errors;
    }

    // Check required fields
    foreach (field; requiredFields) {
        if (field !in user) {
            errors ~= "Missing required field: " ~ field;
        }
    }

    // Check field types
    foreach (field, expectedTypes; fieldTypes) {
        if (field in user) {
            JSONType actualType = user[field].type;
            string actualTypeStr = to!string(actualType);

            bool typeValid = false;
            foreach (expectedType; expectedTypes) {
                if (actualTypeStr == expectedType) {
                    typeValid = true;
                    break;
                }
            }

            if (!typeValid) {
                errors ~= format("Field '%s' has wrong type: expected %s, got %s",
                               field, expectedTypes.join(" or "), actualTypeStr);
            }
        }
    }

    return errors;
}

/**
 * Check if advanced JSON functionality works
 */
bool testAdvancedJSONCapability() {
    try {
        // Test error handling
        string invalidJson = `{"incomplete": }`;
        bool caughtError = false;
        try {
            parseJSON(invalidJson);
        } catch (JSONException) {
            caughtError = true;
        }
        if (!caughtError) return false;

        // Test valid parsing and extraction
        string validJson = `{"name": "test", "value": 42}`;
        JSONValue data = parseJSON(validJson);
        auto result = safeExtractUserData(data);
        if (!result.success) return false;

        // Test schema validation
        string[] required = ["name"];
        string[][string] types = ["name": ["string"], "value": ["integer"]];
        string[] validationErrors = validateUserSchema(data, required, types);
        if (!validationErrors.empty) return false;

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the advanced JSON handling example
 */
void runExample() {
    writeln("=== Advanced JSON Handling Demonstration ===\n");

    if (!testAdvancedJSONCapability()) {
        writeln("ERROR: Advanced JSON functionality test failed!");
        writeln("This might be due to std.json module issues.");
        return;
    }

    writeln("✓ Advanced JSON functionality confirmed\n");

    demonstrateErrorHandling();
    demonstrateCustomParsing();
    demonstrateTransformation();
    demonstrateSchemaValidation();

    writeln("\n=== Summary ===");
    writeln("• Implement custom exceptions for JSON processing errors");
    writeln("• Use Result types for safe operations with detailed error messages");
    writeln("• Validate JSON schemas before processing data");
    writeln("• Transform and filter JSON data as needed");
    writeln("• Handle parsing errors gracefully with try-catch");
    writeln("• Create custom parsers for complex configuration files");
    writeln("• Group and aggregate JSON data for analysis");
}

unittest {
    writeln("=== Running advanced_json tests ===");

    // Test advanced JSON capability
    bool advancedWorks = testAdvancedJSONCapability();
    writefln("Advanced JSON capability test: %s", advancedWorks ? "working" : "not working");
    assert(advancedWorks);

    // Test JSONResult
    auto successResult = JSONResult!int.ok(42);
    assert(successResult.success);
    assert(successResult.value == 42);
    assert(successResult.errorMessage.empty);

    auto errorResult = JSONResult!int.error("test error");
    assert(!errorResult.success);
    assert(errorResult.value == 0);
    assert(errorResult.errorMessage == "test error");
    writeln("✓ JSONResult works");

    // Test safe extraction
    JSONValue validData = parseJSON(`{"name": "test", "value": 123}`);
    auto validExtract = safeExtractUserData(validData);
    assert(validExtract.success);
    assert(validExtract.value.name == "test");
    assert(validExtract.value.value == 123);

    JSONValue invalidData = parseJSON(`{"name": "test"}`);
    auto invalidExtract = safeExtractUserData(invalidData);
    assert(!invalidExtract.success);
    assert(invalidExtract.errorMessage.canFind("value"));
    writeln("✓ Safe extraction works");

    // Test schema validation
    JSONValue validUser = parseJSON(`{"name": "Alice", "email": "alice@test.com", "age": 25}`);
    string[] required = ["name", "email"];
    string[][string] types = ["name": ["string"], "email": ["string"], "age": ["integer"]];

    string[] errors = validateUserSchema(validUser, required, types);
    assert(errors.empty);

    JSONValue invalidUser = parseJSON(`{"name": "Bob"}`);
    errors = validateUserSchema(invalidUser, required, types);
    assert(errors.length > 0);
    writeln("✓ Schema validation works");

    // Test filtering
    JSONValue users = parseJSON(`[
        {"name": "Alice", "active": true},
        {"name": "Bob", "active": false},
        {"name": "Charlie", "active": true}
    ]`);

    JSONValue activeUsers = filterUsers(users, "active", true);
    assert(activeUsers.array.length == 2);
    assert(activeUsers[0]["name"].str == "Alice");
    assert(activeUsers[1]["name"].str == "Charlie");
    writeln("✓ Filtering works");

    writeln("All advanced_json tests passed!");
    writeln("=== advanced_json tests completed ===");
}
