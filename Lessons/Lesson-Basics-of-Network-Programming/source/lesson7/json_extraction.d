/**
 * Lesson 7: JSON Field Extraction - Extracting and processing JSON fields
 *
 * This example demonstrates techniques for extracting specific fields from JSON data,
 * handling missing fields, type conversion, and processing nested structures.
 */

module lesson7.json_extraction;

import std.stdio;
import std.json;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

/**
 * User profile structure for demonstration
 */
struct UserProfile {
    string username;
    string email;
    int age;
    bool active;
    string[] tags;
    string city;
}

/**
 * Demonstrate basic field extraction
 */
void demonstrateBasicExtraction() {
    writeln("=== Basic Field Extraction ===");

    string jsonData = `{
        "user": {
            "username": "johndoe",
            "email": "john@example.com",
            "age": 28,
            "active": true,
            "tags": ["developer", "admin"],
            "location": {
                "city": "San Francisco",
                "country": "USA"
            }
        }
    }`;

    JSONValue data = parseJSON(jsonData);

    writefln("Extracting user information from JSON:");
    writefln("%s", data["user"].toPrettyString());
    writeln();

    // Extract individual fields
    if (auto user = "user" in data) {
        JSONValue userObj = *user;

        // Extract with type checking
        string username = extractString(userObj, "username", "unknown");
        string email = extractString(userObj, "email", "");
        int age = extractInt(userObj, "age", 0);
        bool active = extractBool(userObj, "active", false);
        string[] tags = extractStringArray(userObj, "tags");

        writefln("Username: %s", username);
        writefln("Email: %s", email);
        writefln("Age: %d", age);
        writefln("Active: %s", active);
        writefln("Tags: [%s]", tags.join(", "));
    }
}

/**
 * Helper function to extract string from JSON with default value
 */
string extractString(JSONValue json, string key, string defaultValue = "") {
    if (key in json && json[key].type == JSONType.string) {
        return json[key].str;
    }
    return defaultValue;
}

/**
 * Helper function to extract int from JSON with default value
 */
int extractInt(JSONValue json, string key, int defaultValue = 0) {
    if (key in json && json[key].type == JSONType.integer) {
        return cast(int)json[key].integer;
    }
    return defaultValue;
}

/**
 * Helper function to extract bool from JSON with default value
 */
bool extractBool(JSONValue json, string key, bool defaultValue = false) {
    if (key in json) {
        if (json[key].type == JSONType.true_) return true;
        if (json[key].type == JSONType.false_) return false;
    }
    return defaultValue;
}

/**
 * Helper function to extract float from JSON with default value
 */
double extractFloat(JSONValue json, string key, double defaultValue = 0.0) {
    if (key in json && json[key].type == JSONType.float_) {
        return json[key].floating;
    }
    return defaultValue;
}

/**
 * Helper function to extract string array from JSON
 */
string[] extractStringArray(JSONValue json, string key) {
    if (key in json && json[key].type == JSONType.array) {
        string[] result;
        foreach (item; json[key].array) {
            if (item.type == JSONType.string) {
                result ~= item.str;
            }
        }
        return result;
    }
    return [];
}

/**
 * Helper function to extract int array from JSON
 */
int[] extractIntArray(JSONValue json, string key) {
    if (key in json && json[key].type == JSONType.array) {
        int[] result;
        foreach (item; json[key].array) {
            if (item.type == JSONType.integer) {
                result ~= cast(int)item.integer;
            }
        }
        return result;
    }
    return [];
}

/**
 * Demonstrate extracting nested fields
 */
void demonstrateNestedExtraction() {
    writeln("\n=== Nested Field Extraction ===");

    string apiResponse = `{
        "status": "success",
        "data": {
            "user": {
                "id": 12345,
                "profile": {
                    "firstName": "Jane",
                    "lastName": "Smith",
                    "contact": {
                        "email": "jane.smith@example.com",
                        "phone": "+1-555-0123"
                    }
                },
                "preferences": {
                    "notifications": {
                        "email": true,
                        "sms": false,
                        "push": true
                    },
                    "theme": "dark"
                }
            },
            "metadata": {
                "lastLogin": "2024-01-15T10:30:00Z",
                "accountType": "premium"
            }
        }
    }`;

    JSONValue response = parseJSON(apiResponse);

    writefln("Extracting nested user data:");

    // Navigate through nested structure
    if ("data" in response && "user" in response["data"]) {
        JSONValue user = response["data"]["user"];

        // Extract basic info
        int userId = extractInt(user, "id");
        writefln("User ID: %d", userId);

        // Extract nested profile info
        if ("profile" in user) {
            JSONValue profile = user["profile"];
            string firstName = extractString(profile, "firstName");
            string lastName = extractString(profile, "lastName");
            writefln("Name: %s %s", firstName, lastName);

            // Extract contact info
            if ("contact" in profile) {
                JSONValue contact = profile["contact"];
                string email = extractString(contact, "email");
                string phone = extractString(contact, "phone");
                writefln("Email: %s", email);
                writefln("Phone: %s", phone);
            }
        }

        // Extract preferences
        if ("preferences" in user && "notifications" in user["preferences"]) {
            JSONValue notifications = user["preferences"]["notifications"];
            bool emailNotif = extractBool(notifications, "email");
            bool smsNotif = extractBool(notifications, "sms");
            bool pushNotif = extractBool(notifications, "push");
            writefln("Notifications - Email: %s, SMS: %s, Push: %s",
                    emailNotif, smsNotif, pushNotif);
        }
    }

    // Extract metadata
    if ("data" in response && "metadata" in response["data"]) {
        JSONValue metadata = response["data"]["metadata"];
        string lastLogin = extractString(metadata, "lastLogin");
        string accountType = extractString(metadata, "accountType");
        writefln("Last Login: %s", lastLogin);
        writefln("Account Type: %s", accountType);
    }
}

/**
 * Demonstrate converting JSON to custom structs
 */
void demonstrateStructConversion() {
    writeln("\n=== Converting JSON to Structs ===");

    string userJson = `{
        "username": "alice_wonder",
        "email": "alice@example.com",
        "age": 25,
        "active": true,
        "tags": ["photographer", "traveler", "artist"],
        "city": "Portland"
    }`;

    JSONValue userData = parseJSON(userJson);

    // Convert JSON to UserProfile struct
    UserProfile profile = jsonToUserProfile(userData);

    writefln("Converted to UserProfile struct:");
    writefln("Username: %s", profile.username);
    writefln("Email: %s", profile.email);
    writefln("Age: %d", profile.age);
    writefln("Active: %s", profile.active);
    writefln("Tags: [%s]", profile.tags.join(", "));
    writefln("City: %s", profile.city);
}

/**
 * Convert JSON to UserProfile struct
 */
UserProfile jsonToUserProfile(JSONValue json) {
    return UserProfile(
        extractString(json, "username"),
        extractString(json, "email"),
        extractInt(json, "age"),
        extractBool(json, "active"),
        extractStringArray(json, "tags"),
        extractString(json, "city")
    );
}

/**
 * Demonstrate extracting arrays of objects
 */
void demonstrateArrayExtraction() {
    writeln("\n=== Array of Objects Extraction ===");

    string productsJson = `{
        "products": [
            {
                "id": 1,
                "name": "Laptop",
                "price": 999.99,
                "category": "Electronics",
                "inStock": true
            },
            {
                "id": 2,
                "name": "Book",
                "price": 19.99,
                "category": "Education",
                "inStock": false
            },
            {
                "id": 3,
                "name": "Headphones",
                "price": 149.99,
                "category": "Electronics",
                "inStock": true
            }
        ]
    }`;

    JSONValue data = parseJSON(productsJson);

    writefln("Extracting product information:");

    if ("products" in data && data["products"].type == JSONType.array) {
        foreach (i, JSONValue product; data["products"].array) {
            int id = extractInt(product, "id");
            string name = extractString(product, "name");
            double price = extractFloat(product, "price");
            string category = extractString(product, "category");
            bool inStock = extractBool(product, "inStock");

            writefln("Product %d: %s ($%.2f) - %s [%s]",
                    id, name, price, category, inStock ? "In Stock" : "Out of Stock");
        }
    }

    // Extract all product names
    string[] productNames = extractFieldFromArray(data["products"], "name");
    writefln("All product names: [%s]", productNames.join(", "));

    // Extract products by category
    auto electronics = filterProductsByCategory(data["products"], "Electronics");
    writefln("Electronics products: %d found", electronics.length);
}

/**
 * Extract a specific field from all objects in a JSON array
 */
string[] extractFieldFromArray(JSONValue arrayJson, string fieldName) {
    if (arrayJson.type != JSONType.array) return [];

    string[] result;
    foreach (item; arrayJson.array) {
        if (item.type == JSONType.object && fieldName in item) {
            if (item[fieldName].type == JSONType.string) {
                result ~= item[fieldName].str;
            }
        }
    }
    return result;
}

/**
 * Filter products by category
 */
JSONValue[] filterProductsByCategory(JSONValue productsArray, string category) {
    if (productsArray.type != JSONType.array) return [];

    JSONValue[] result;
    foreach (product; productsArray.array) {
        if (product.type == JSONType.object) {
            string prodCategory = extractString(product, "category");
            if (prodCategory == category) {
                result ~= product;
            }
        }
    }
    return result;
}

/**
 * Demonstrate error handling in extraction
 */
void demonstrateErrorHandling() {
    writeln("\n=== Error Handling in Extraction ===");

    // JSON with missing fields and wrong types
    string problematicJson = `{
        "user": {
            "username": "testuser",
            "age": "not_a_number",
            "active": "not_a_boolean",
            "tags": "not_an_array",
            "profile": null
        }
    }`;

    JSONValue data = parseJSON(problematicJson);

    writefln("Handling problematic JSON data:");

    if ("user" in data) {
        JSONValue user = data["user"];

        // Safe extraction with error handling
        string username = extractString(user, "username", "N/A");
        writefln("Username: %s", username);

        // Handle invalid age (string instead of number)
        int age = extractInt(user, "age", -1);
        if (age == -1) {
            writefln("Age: Invalid (not a number)");
        } else {
            writefln("Age: %d", age);
        }

        // Handle invalid boolean
        bool active = extractBool(user, "active", false);
        writefln("Active: %s (with fallback)", active);

        // Handle invalid array
        string[] tags = extractStringArray(user, "tags");
        if (tags.length == 0) {
            writefln("Tags: Invalid (not an array)");
        } else {
            writefln("Tags: [%s]", tags.join(", "));
        }

        // Handle null object
        if ("profile" in user && user["profile"].isNull) {
            writefln("Profile: null (handled gracefully)");
        }
    }
}

/**
 * Check if JSON extraction functionality works
 */
bool testJSONExtractionCapability() {
    try {
        // Test basic extraction
        string testJson = `{"name": "test", "value": 42, "active": true, "items": ["a", "b"]}`;
        JSONValue data = parseJSON(testJson);

        if (extractString(data, "name") != "test") return false;
        if (extractInt(data, "value") != 42) return false;
        if (extractBool(data, "active") != true) return false;
        if (extractStringArray(data, "items") != ["a", "b"]) return false;

        // Test struct conversion with proper data
        string profileJson = `{"username": "test", "email": "test@example.com", "age": 25, "active": true, "tags": ["a", "b"], "city": "TestCity"}`;
        JSONValue profileData = parseJSON(profileJson);
        UserProfile profile = jsonToUserProfile(profileData);
        if (profile.username != "test") return false;

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the JSON extraction example
 */
void runExample() {
    writeln("=== JSON Field Extraction Demonstration ===\n");

    if (!testJSONExtractionCapability()) {
        writeln("ERROR: JSON extraction functionality test failed!");
        writeln("This might be due to std.json module issues.");
        return;
    }

    writeln("✓ JSON extraction functionality confirmed\n");

    demonstrateBasicExtraction();
    demonstrateNestedExtraction();
    demonstrateStructConversion();
    demonstrateArrayExtraction();
    demonstrateErrorHandling();

    writeln("\n=== Summary ===");
    writeln("• Use helper functions for safe field extraction with defaults");
    writeln("• Always check types before accessing JSON values");
    writeln("• Handle nested structures by navigating step-by-step");
    writeln("• Convert JSON objects to D structs for type safety");
    writeln("• Process arrays of objects with loops and filtering");
    writeln("• Implement proper error handling for malformed data");
    writeln("• Use 'in' operator to check for key existence");
}

unittest {
    writeln("=== Running json_extraction tests ===");

    // Test extraction capability
    bool extractionWorks = testJSONExtractionCapability();
    writefln("JSON extraction capability test: %s", extractionWorks ? "working" : "not working");
    assert(extractionWorks);

    // Test helper functions
    JSONValue testData = parseJSON(`{"str": "hello", "num": 123, "bool": true, "arr": ["x", "y"]}`);

    assert(extractString(testData, "str") == "hello");
    assert(extractString(testData, "missing", "default") == "default");
    assert(extractInt(testData, "num") == 123);
    assert(extractInt(testData, "missing", 999) == 999);
    assert(extractBool(testData, "bool") == true);
    assert(extractBool(testData, "missing", true) == true);
    assert(extractStringArray(testData, "arr") == ["x", "y"]);
    assert(extractStringArray(testData, "missing") == []);
    writeln("✓ Helper functions work");

    // Test struct conversion
    JSONValue structData = parseJSON(`{
        "username": "testuser",
        "email": "test@example.com",
        "age": 30,
        "active": true,
        "tags": ["tag1", "tag2"],
        "city": "Test City"
    }`);

    UserProfile profile = jsonToUserProfile(structData);
    assert(profile.username == "testuser");
    assert(profile.email == "test@example.com");
    assert(profile.age == 30);
    assert(profile.active == true);
    assert(profile.tags == ["tag1", "tag2"]);
    assert(profile.city == "Test City");
    writeln("✓ Struct conversion works");

    // Test array field extraction
    JSONValue arrayData = parseJSON(`[{"name": "item1"}, {"name": "item2"}, {"name": "item3"}]`);
    string[] names = extractFieldFromArray(arrayData, "name");
    assert(names == ["item1", "item2", "item3"]);
    writeln("✓ Array field extraction works");

    // Test error handling
    JSONValue badData = parseJSON(`{"age": "not_number", "tags": "not_array"}`);
    assert(extractInt(badData, "age", -1) == -1);  // Should return default
    assert(extractStringArray(badData, "tags") == []);  // Should return empty array
    writeln("✓ Error handling works");

    writeln("All json_extraction tests passed!");
    writeln("=== json_extraction tests completed ===");
}
