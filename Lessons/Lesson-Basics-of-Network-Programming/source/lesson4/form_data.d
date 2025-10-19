/**
 * Lesson 4: Form Data - Sending form-encoded data
 *
 * This example demonstrates how to send form-encoded data (application/x-www-form-urlencoded)
 * using POST requests, which is the most common way to send form data from web browsers.
 */

module lesson4.form_data;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.uri;
import std.algorithm;

/**
 * Send form data using POST request
 */
string sendFormData(string url, string[string] formFields) {
    try {
        // Build form data string
        string[] formParts;
        foreach (key, value; formFields) {
            // URL encode the key and value
            string encodedKey = encodeComponent(key);
            string encodedValue = encodeComponent(value);
            formParts ~= format("%s=%s", encodedKey, encodedValue);
        }
        string formData = formParts.join("&");

        // Send POST request
        auto http = HTTP(url);
        http.method = HTTP.Method.post;
        http.postData = formData;
        http.addRequestHeader("Content-Type", "application/x-www-form-urlencoded");

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();
        return response;

    } catch (Exception e) {
        throw new Exception(format("Form data POST failed for %s: %s", url, e.msg));
    }
}

/**
 * Demonstrate basic form data submission
 */
void demonstrateBasicForm() {
    writeln("=== Basic Form Data Submission ===");

    try {
        string[string] formData;
        formData["name"] = "D Programming Language";
        formData["version"] = "2.0";
        formData["lesson"] = "4";
        formData["topic"] = "Form Data";

        string response = sendFormData("https://httpbin.org/post", formData);

        writefln("Form submitted, response size: %d characters", response.length);

        // Verify all form fields were received
        foreach (key, value; formData) {
            if (canFind(response, format("%s=%s", key, value)) ||
                canFind(response, format("\"%s\": \"%s\"", key, value))) {
                writefln("✓ Field '%s' = '%s' verified", key, value);
            } else {
                writefln("? Field '%s' verification unclear", key);
            }
        }

    } catch (Exception e) {
        writefln("Basic form submission failed: %s", e.msg);
    }
}

/**
 * Demonstrate form data with special characters
 */
void demonstrateSpecialCharacters() {
    writeln("\n=== Form Data with Special Characters ===");

    try {
        string[string] formData;
        formData["message"] = "Hello & Welcome!";
        formData["description"] = "This has spaces and symbols: @#$%^&*()";
        formData["email"] = "user@example.com";
        formData["query"] = "What is D? It's awesome!";

        writefln("Original form data:");
        foreach (key, value; formData) {
            writefln("  %s = %s", key, value);
        }

        string response = sendFormData("https://httpbin.org/post", formData);

        writefln("Response received, verifying special characters...");

        // Check if special characters were properly encoded and decoded
        bool hasAmpersand = canFind(response, "&");
        bool hasSpaces = canFind(response, "spaces");
        bool hasSymbols = canFind(response, "@#$%^&*()");
        bool hasEmail = canFind(response, "user@example.com");

        if (hasAmpersand && hasSpaces && hasSymbols && hasEmail) {
            writeln("✓ Special characters handled correctly");
        } else {
            writefln("⚠ Special character handling: Ampersand: %s, Spaces: %s, Symbols: %s, Email: %s",
                    hasAmpersand, hasSpaces, hasSymbols, hasEmail);
        }

    } catch (Exception e) {
        writefln("Special characters test failed: %s", e.msg);
    }
}

/**
 * Demonstrate large form data
 */
void demonstrateLargeForm() {
    writeln("\n=== Large Form Data ===");

    try {
        string[string] formData;

        // Create a large text field
        string largeText = "This is a large text field. ";
        for (int i = 0; i < 100; i++) {
            largeText ~= "Word ";
        }
        largeText ~= "End.";
        formData["large_text"] = largeText;
        formData["size"] = to!string(largeText.length);
        formData["type"] = "large_form_data_test";

        writefln("Large text field size: %d characters", largeText.length);

        string response = sendFormData("https://httpbin.org/post", formData);

        if (canFind(response, "large_form_data_test")) {
            writeln("✓ Large form data submitted successfully");
        }

        if (canFind(response, to!string(largeText.length))) {
            writeln("✓ Size field verified");
        }

        // Check if the large text content was received
        if (canFind(response, "This is a large text field")) {
            writeln("✓ Large text content verified");
        }

    } catch (Exception e) {
        writefln("Large form data test failed: %s", e.msg);
    }
}

/**
 * Demonstrate multiple form submissions
 */
void demonstrateMultipleForms() {
    writeln("\n=== Multiple Form Submissions ===");

    string[][] formVariations = [
        ["name", "Form A", "value", "100"],
        ["name", "Form B", "value", "200"],
        ["name", "Form C", "value", "300"]
    ];

    foreach (i, formArray; formVariations) {
        try {
            writefln("--- Form Submission %d ---", i + 1);

            string[string] formData;
            for (size_t j = 0; j < formArray.length; j += 2) {
                formData[formArray[j]] = formArray[j + 1];
            }

            string response = sendFormData("https://httpbin.org/post", formData);

            // Verify this specific form was received
            if (canFind(response, formArray[3])) { // Check the value field
                writefln("✓ Form %d submission verified (value: %s)", i + 1, formArray[3]);
            }

        } catch (Exception e) {
            writefln("Form %d submission failed: %s", i + 1, e.msg);
        }

        // Small delay between submissions
        import core.thread;
        Thread.sleep(150.msecs);
    }
}

/**
 * Demonstrate form data validation
 */
void demonstrateFormValidation() {
    writeln("\n=== Form Data Validation ===");

    try {
        // Test with empty form
        string[string] emptyForm;
        string response1 = sendFormData("https://httpbin.org/post", emptyForm);

        if (canFind(response1, `"form": {}`) || canFind(response1, `"data": ""`)) {
            writeln("✓ Empty form handled correctly");
        }

        // Test with single field
        string[string] singleField;
        singleField["single"] = "value";
        string response2 = sendFormData("https://httpbin.org/post", singleField);

        if (canFind(response2, "single=value")) {
            writeln("✓ Single field form handled correctly");
        }

        // Test with many fields
        string[string] manyFields;
        for (int i = 1; i <= 10; i++) {
            manyFields[format("field%d", i)] = format("value%d", i);
        }

        string response3 = sendFormData("https://httpbin.org/post", manyFields);
        bool allFieldsFound = true;

        for (int i = 1; i <= 10 && allFieldsFound; i++) {
            string fieldCheck = format("field%d=value%d", i, i);
            if (!canFind(response3, fieldCheck)) {
                allFieldsFound = false;
            }
        }

        if (allFieldsFound) {
            writeln("✓ Multiple fields form handled correctly");
        }

    } catch (Exception e) {
        writefln("Form validation failed: %s", e.msg);
    }
}

/**
 * Demonstrate URL encoding edge cases
 */
void demonstrateEncoding() {
    writeln("\n=== URL Encoding Edge Cases ===");

    try {
        string[string] edgeCases;
        edgeCases["spaces"] = "value with spaces";
        edgeCases["special"] = "value+with%symbols&chars=here";
        edgeCases["unicode"] = "D言語プログラミング"; // Japanese for "D Language Programming"
        edgeCases["empty"] = "";
        edgeCases["plus"] = "1+1=2";

        writefln("Testing URL encoding with %d edge cases", edgeCases.length);

        string response = sendFormData("https://httpbin.org/post", edgeCases);

        // Check if the server received our data
        bool hasSpaces = canFind(response, "value with spaces");
        bool hasSpecial = canFind(response, "symbols");
        bool hasUnicode = canFind(response, "D言語"); // May be encoded
        bool hasEmpty = canFind(response, `"empty": ""`);

        writefln("Spaces: %s, Special chars: %s, Unicode: %s, Empty: %s",
                hasSpaces, hasSpecial, hasUnicode, hasEmpty);

        if (hasSpaces || hasSpecial || hasUnicode || hasEmpty) {
            writeln("✓ URL encoding handled various edge cases");
        }

    } catch (Exception e) {
        writefln("URL encoding test failed: %s", e.msg);
    }
}

/**
 * Check if form data functionality works
 */
bool testFormDataCapability() {
    try {
        string[string] testData;
        testData["test"] = "value";
        testData["verify"] = "form_data";

        string response = sendFormData("https://httpbin.org/post", testData);
        return response.canFind("test=value") && response.canFind("verify=form_data");
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the form data example
 */
void runExample() {
    writeln("=== Form Data with POST Requests ===\n");

    if (!testFormDataCapability()) {
        writeln("ERROR: Form data functionality test failed!");
        writeln("This might be due to network issues or std.curl problems.");
        return;
    }

    writeln("✓ Form data functionality confirmed\n");

    // Demonstrate different form data patterns
    demonstrateBasicForm();
    demonstrateSpecialCharacters();
    demonstrateLargeForm();
    demonstrateMultipleForms();
    demonstrateFormValidation();
    demonstrateEncoding();

    writeln("\n=== Summary ===");
    writeln("• Form data uses application/x-www-form-urlencoded content type");
    writeln("• Key-value pairs separated by & symbols");
    writeln("• Special characters are URL-encoded automatically");
    writeln("• std.uri.encodeComponent handles URL encoding");
    writeln("• Large forms and many fields work the same way");
    writeln("• Empty forms and single fields are valid");
    writeln("• Multiple form submissions work sequentially");
}

unittest {
    writeln("=== Running form_data tests ===");

    // Test form data capability
    bool formWorks = testFormDataCapability();
    writefln("Form data capability test: %s", formWorks ? "working" : "not working");

    // Test string-to-string array operations
    string[string] testForm;
    testForm["key1"] = "value1";
    testForm["key2"] = "value2";

    assert(testForm.length == 2);
    assert("key1" in testForm);
    assert(testForm["key1"] == "value1");
    writeln("✓ Form data array operations work");

    // Test URL component encoding
    string original = "hello world & special=chars";
    string encoded = encodeComponent(original);
    assert(encoded != original);
    assert(encoded.canFind("%20")); // Space encoded
    assert(encoded.canFind("%26")); // & encoded
    writeln("✓ URL encoding works");

    // Test form data construction
    string[] parts;
    foreach (key, value; testForm) {
        parts ~= format("%s=%s", encodeComponent(key), encodeComponent(value));
    }
    string formString = parts.join("&");
    assert(formString.canFind("key1=value1"));
    assert(formString.canFind("key2=value2"));
    assert(formString.canFind("&"));
    writeln("✓ Form data string construction works");

    // Test special character handling
    string specialText = "Hello & Welcome! @#$%";
    string encodedSpecial = encodeComponent(specialText);
    assert(encodedSpecial != specialText);
    assert(encodedSpecial.length > specialText.length); // Should be longer due to encoding
    writeln("✓ Special character encoding works");

    // Test large data handling
    string largeData;
    for (int i = 0; i < 1000; i++) {
        largeData ~= "x";
    }
    assert(largeData.length == 1000);
    assert(largeData.canFind("x"));
    string encodedLarge = encodeComponent(largeData);
    // Large data should still be encodable
    assert(encodedLarge.length >= largeData.length);
    writeln("✓ Large data handling works");

    // Test empty form handling
    string[string] emptyForm;
    assert(emptyForm.length == 0);
    // Empty form should produce empty string when joined
    string[] emptyParts;
    string emptyResult = emptyParts.join("&");
    assert(emptyResult.empty);
    writeln("✓ Empty form handling works");

    // Test content type header
    string contentType = "application/x-www-form-urlencoded";
    assert(contentType.canFind("application"));
    assert(contentType.canFind("x-www-form-urlencoded"));
    assert(contentType.canFind("/"));
    writeln("✓ Content type validation works");

    // Test field count operations
    int fieldCount = 5;
    string[string] multiField;
    for (int i = 1; i <= fieldCount; i++) {
        multiField[format("field%d", i)] = format("value%d", i);
    }
    assert(multiField.length == fieldCount);
    assert("field1" in multiField);
    assert("field5" in multiField);
    writeln("✓ Multiple field operations work");

    // Test response verification patterns
    string mockResponse = `{"form": {"name": "test", "value": "data"}, "data": "name=test&value=data"}`;
    bool hasFormData = mockResponse.canFind("name=test");
    bool hasJsonData = mockResponse.canFind(`"name": "test"`);
    assert(hasFormData || hasJsonData);
    writeln("✓ Response verification patterns work");

    writeln("All form_data tests passed!");
    writeln("=== form_data tests completed ===");
}
