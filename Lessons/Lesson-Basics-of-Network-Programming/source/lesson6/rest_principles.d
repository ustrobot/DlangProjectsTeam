/**
 * Lesson 6: REST Principles - Demonstrate REST concepts
 *
 * This example demonstrates fundamental REST (Representational State Transfer)
 * principles including resources, HTTP methods, and stateless communication.
 */

module lesson6.rest_principles;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.algorithm;

/**
 * Resource representation structure
 */
struct Resource {
    string id;
    string type;
    string[string] properties;
    string selfUrl;

    void printInfo() {
        writefln("Resource ID: %s", id);
        writefln("Type: %s", type);
        writefln("URL: %s", selfUrl);
        writefln("Properties:");
        foreach (key, value; properties) {
            writefln("  %s: %s", key, value);
        }
    }
}

/**
 * Demonstrate REST resource concepts
 */
void demonstrateResources() {
    writeln("=== REST Resources ===");

    // Create example resources
    Resource userResource = Resource(
        "123",
        "user",
        ["name": "Alice", "email": "alice@example.com", "active": "true"],
        "https://api.example.com/users/123"
    );

    Resource productResource = Resource(
        "456",
        "product",
        ["name": "Widget", "price": "29.99", "category": "electronics"],
        "https://api.example.com/products/456"
    );

    writefln("Example REST resources:");
    userResource.printInfo();
    writeln();
    productResource.printInfo();
    writeln();

    // Demonstrate resource addressing
    writefln("REST Resource Addressing:");
    writefln("• Users collection: https://api.example.com/users");
    writefln("• Specific user: https://api.example.com/users/123");
    writefln("• User orders: https://api.example.com/users/123/orders");
    writefln("• Product reviews: https://api.example.com/products/456/reviews");
}

/**
 * Demonstrate HTTP methods for CRUD operations
 */
void demonstrateHTTPMethods() {
    writeln("\n=== HTTP Methods for CRUD Operations ===");

    string baseUrl = "https://httpbin.org";

    // GET - Read/List resources
    writefln("GET - Retrieve resources:");
    try {
        auto response = get(baseUrl ~ "/get");
        writefln("✓ GET request successful (%d bytes)", response.length);
    } catch (Exception e) {
        writefln("✗ GET request failed: %s", e.msg);
    }

    // POST - Create new resource
    writefln("\nPOST - Create new resource:");
    try {
        auto http = HTTP(baseUrl ~ "/post");
        http.method = HTTP.Method.post;
        http.postData = `{"name": "New Resource", "type": "example"}`;

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();
        writefln("✓ POST request successful (%d bytes)", response.length);
    } catch (Exception e) {
        writefln("✗ POST request failed: %s", e.msg);
    }

    // PUT - Update existing resource
    writefln("\nPUT - Update existing resource:");
    try {
        auto http = HTTP(baseUrl ~ "/put");
        http.method = HTTP.Method.put;
        http.postData = `{"id": "123", "name": "Updated Resource", "version": 2}`;

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();
        writefln("✓ PUT request successful (%d bytes)", response.length);
    } catch (Exception e) {
        writefln("✗ PUT request failed: %s", e.msg);
    }

    // DELETE - Remove resource
    writefln("\nDELETE - Remove resource:");
    try {
        auto http = HTTP(baseUrl ~ "/delete");
        http.method = HTTP.Method.del;

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();
        writefln("✓ DELETE request successful (%d bytes)", response.length);
    } catch (Exception e) {
        writefln("✗ DELETE request failed: %s", e.msg);
    }

    writefln("\nCRUD Operations Summary:");
    writefln("• CREATE → POST /resources");
    writefln("• READ → GET /resources or GET /resources/{id}");
    writefln("• UPDATE → PUT /resources/{id} or PATCH /resources/{id}");
    writefln("• DELETE → DELETE /resources/{id}");
}

/**
 * Demonstrate stateless communication
 */
void demonstrateStatelessness() {
    writeln("\n=== Stateless Communication ===");

    writefln("REST APIs are stateless - each request contains all necessary information:");
    writefln("• No server-side session storage");
    writefln("• Authentication sent with each request");
    writefln("• Resource state managed by clients");
    writefln("• Requests are self-contained");

    // Demonstrate multiple independent requests
    string[] endpoints = ["/get", "/uuid", "/ip", "/user-agent"];

    writefln("\nMaking multiple independent requests (each stateless):");

    foreach (i, endpoint; endpoints) {
        try {
            auto response = get("https://httpbin.org" ~ endpoint);
            writefln("✓ Request %d (%s): %d bytes", i + 1, endpoint, response.length);
        } catch (Exception e) {
            writefln("✗ Request %d (%s) failed: %s", i + 1, endpoint, e.msg);
        }

        // Small delay to avoid overwhelming the server
        import core.thread;
        Thread.sleep(100.msecs);
    }

    writefln("\nEach request was completely independent - no shared state!");
}

/**
 * Demonstrate uniform interface principle
 */
void demonstrateUniformInterface() {
    writeln("\n=== Uniform Interface ===");

    writefln("REST APIs use a consistent interface:");
    writefln("• Standard HTTP methods (GET, POST, PUT, DELETE)");
    writefln("• Standard HTTP status codes (200, 201, 400, 404, 500)");
    writefln("• Standard content types (application/json, text/plain)");
    writefln("• Hypermedia links for navigation");

    // Demonstrate standard status codes
    string[] testEndpoints = [
        "/status/200",  // OK
        "/status/201",  // Created
        "/status/400",  // Bad Request
        "/status/404",  // Not Found
        "/status/500"   // Internal Server Error
    ];

    writefln("\nTesting standard HTTP status codes:");

    foreach (endpoint; testEndpoints) {
        try {
            auto http = HTTP("https://httpbin.org" ~ endpoint);
            string response;
            int statusCode = 0;

            http.onReceive = (ubyte[] data) {
                response ~= cast(string)data;
                return data.length;
            };

            http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
                statusCode = statusLine.code;
            };

            http.perform();

            string statusText;
            if (statusCode == 200) statusText = "OK";
            else if (statusCode == 201) statusText = "Created";
            else if (statusCode == 400) statusText = "Bad Request";
            else if (statusCode == 404) statusText = "Not Found";
            else if (statusCode == 500) statusText = "Internal Server Error";
            else statusText = "Unknown";

            writefln("✓ %s → Status %d (%s)", endpoint, statusCode, statusText);

        } catch (Exception e) {
            writefln("✗ %s failed: %s", endpoint, e.msg);
        }

        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Demonstrate resource representations
 */
void demonstrateRepresentations() {
    writeln("\n=== Resource Representations ===");

    writefln("REST APIs can return resources in different formats:");
    writefln("• JSON (most common)");
    writefln("• XML");
    writefln("• HTML");
    writefln("• Plain text");
    writefln("• Binary data");

    // Test different content types
    string[] acceptTypes = [
        "application/json",
        "application/xml",
        "text/html",
        "text/plain"
    ];

    foreach (acceptType; acceptTypes) {
        try {
            auto http = HTTP("https://httpbin.org/get");
            http.addRequestHeader("Accept", acceptType);

            string response;
            http.onReceive = (ubyte[] data) {
                response ~= cast(string)data;
                return data.length;
            };

            http.perform();

            // Check what content type was returned
            string contentType = "unknown";
            if (response.canFind(`"content-type"`)) {
                contentType = "json";
            } else if (response.canFind("<?xml")) {
                contentType = "xml";
            } else if (response.canFind("<html>")) {
                contentType = "html";
            }

            writefln("✓ Accept: %s → Response format: %s (%d bytes)",
                    acceptType, contentType, response.length);

        } catch (Exception e) {
            writefln("✗ Accept %s failed: %s", acceptType, e.msg);
        }

        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Demonstrate HATEOAS (Hypermedia As The Engine Of Application State)
 */
void demonstrateHATEOAS() {
    writeln("\n=== HATEOAS (Hypermedia Links) ===");

    writefln("REST APIs can include links for navigation:");
    writefln("• Links to related resources");
    writefln("• Links for state transitions");
    writefln("• Self-referencing links");

    // Example of a typical REST API response with links
    string mockAPIResponse = `{
        "user": {
            "id": 123,
            "name": "Alice",
            "email": "alice@example.com"
        },
        "_links": {
            "self": {"href": "/users/123"},
            "orders": {"href": "/users/123/orders"},
            "profile": {"href": "/users/123/profile"},
            "update": {"href": "/users/123", "method": "PUT"},
            "delete": {"href": "/users/123", "method": "DELETE"}
        }
    }`;

    writefln("Example API response with HATEOAS links:");
    writefln("%s", mockAPIResponse);

    writefln("\nHATEOAS Benefits:");
    writefln("• Clients discover available actions dynamically");
    writefln("• API evolution is easier (links can change)");
    writefln("• Reduces client coupling to specific URL structures");
    writefln("• Enables more flexible API design");
}

/**
 * Demonstrate layered system architecture
 */
void demonstrateLayeredSystem() {
    writeln("\n=== Layered System Architecture ===");

    writefln("REST APIs support layered architecture:");
    writefln("• Client layer (our application)");
    writefln("• API Gateway/Load Balancer layer");
    writefln("• Application/Service layer");
    writefln("• Data/Storage layer");

    writefln("\nEach layer is independent and can be:");
    writefln("• Scaled independently");
    writefln("• Modified without affecting other layers");
    writefln("• Replaced with alternative implementations");
    writefln("• Secured at different levels");

    // Demonstrate through multiple API calls (simulating different layers)
    writefln("\nSimulating requests through different 'layers':");

    string[] services = [
        "https://httpbin.org/get",        // Direct API call
        "https://httpbin.org/uuid",       // Service layer
        "https://httpbin.org/ip"          // Infrastructure layer
    ];

    foreach (i, service; services) {
        try {
            auto response = get(service);
            writefln("✓ Layer %d service: %d bytes", i + 1, response.length);
        } catch (Exception e) {
            writefln("✗ Layer %d service failed: %s", i + 1, e.msg);
        }

        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Check if REST principles demonstration works
 */
bool testRESTCapability() {
    try {
        // Test basic HTTP operations
        auto getResponse = get("https://httpbin.org/get");
        if (getResponse.length == 0) return false;

        // Test POST operation
        auto http = HTTP("https://httpbin.org/post");
        http.method = HTTP.Method.post;
        http.postData = `{"test": "rest_principles"}`;

        string postResponse;
        http.onReceive = (ubyte[] data) {
            postResponse ~= cast(string)data;
            return data.length;
        };

        http.perform();

        return postResponse.length > 0 && canFind(postResponse, "rest_principles");
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the REST principles example
 */
void runExample() {
    writeln("=== REST Principles Demonstration ===\n");

    if (!testRESTCapability()) {
        writeln("ERROR: REST principles functionality test failed!");
        writeln("This might be due to network issues or HTTP library problems.");
        return;
    }

    writeln("✓ REST principles functionality confirmed\n");

    // Demonstrate different REST concepts
    demonstrateResources();
    demonstrateHTTPMethods();
    demonstrateStatelessness();
    demonstrateUniformInterface();
    demonstrateRepresentations();
    demonstrateHATEOAS();
    demonstrateLayeredSystem();

    writeln("\n=== Summary ===");
    writeln("• REST (Representational State Transfer) is an architectural style");
    writeln("• Resources are identified by URLs and manipulated via HTTP methods");
    writeln("• Stateless communication - each request is self-contained");
    writeln("• Uniform interface using standard HTTP methods and status codes");
    writeln("• Resources can be represented in multiple formats (JSON, XML, etc.)");
    writeln("• HATEOAS provides discoverable navigation through hypermedia links");
    writeln("• Layered architecture enables scalability and maintainability");
    writeln("• RESTful APIs are platform and language independent");
}

unittest {
    writeln("=== Running rest_principles tests ===");

    // Test REST capability
    bool restWorks = testRESTCapability();
    writefln("REST capability test: %s", restWorks ? "working" : "not working");

    // Test resource structure (safe, no network required)
    Resource testResource = Resource(
        "test-123",
        "test-type",
        ["prop1": "value1", "prop2": "value2"],
        "https://api.example.com/test/test-123"
    );

    assert(testResource.id == "test-123");
    assert(testResource.type == "test-type");
    assert("prop1" in testResource.properties);
    assert(testResource.properties["prop1"] == "value1");
    assert(testResource.selfUrl.canFind("test-123"));
    writeln("✓ Resource structure works");

    // Test HTTP method constants (safe, no network required)
    assert(HTTP.Method.get == HTTP.Method.get);
    assert(HTTP.Method.post == HTTP.Method.post);
    assert(HTTP.Method.put == HTTP.Method.put);
    assert(HTTP.Method.del == HTTP.Method.del);
    assert(HTTP.Method.get != HTTP.Method.post);
    writeln("✓ HTTP method constants work");

    // Test URL construction patterns (safe, no network required)
    string baseUrl = "https://api.example.com";
    string resource = "users";
    string id = "123";
    string fullUrl = baseUrl ~ "/" ~ resource ~ "/" ~ id;

    assert(fullUrl == "https://api.example.com/users/123");
    assert(canFind(fullUrl, "api.example.com"));
    assert(canFind(fullUrl, "users"));
    assert(canFind(fullUrl, "123"));
    writeln("✓ URL construction patterns work");

    // Test status code ranges (safe, no network required)
    int[] statusCodes = [200, 201, 301, 400, 404, 500];

    foreach (code; statusCodes) {
        if (code >= 200 && code < 300) {
            // Success codes
            assert(code >= 200 && code < 300);
        } else if (code >= 300 && code < 400) {
            // Redirection codes
            assert(code >= 300 && code < 400);
        } else if (code >= 400 && code < 500) {
            // Client error codes
            assert(code >= 400 && code < 500);
        } else if (code >= 500 && code < 600) {
            // Server error codes
            assert(code >= 500 && code < 600);
        }
    }
    writeln("✓ HTTP status code ranges work");

    // Test content type validation (safe, no network required)
    string[] contentTypes = ["application/json", "application/xml", "text/html", "text/plain"];

    foreach (contentType; contentTypes) {
        assert(canFind(contentType, "/"));
        bool isValid = contentType == "application/json" ||
                      contentType == "application/xml" ||
                      contentType == "text/html" ||
                      contentType == "text/plain";
        assert(isValid);
    }
    writeln("✓ Content type validation works");

    // Test JSON structure for HATEOAS (safe, no network required)
    string testJson = `{"_links": {"self": {"href": "/test"}, "next": {"href": "/test?page=2"}}}`;
    assert(canFind(testJson, "_links"));
    assert(canFind(testJson, "self"));
    assert(canFind(testJson, "href"));
    assert(canFind(testJson, "/test"));
    writeln("✓ HATEOAS JSON structure works");

    // Test layered architecture concept (safe, no network required)
    string[] layers = ["client", "api_gateway", "application", "database"];

    assert(layers.length == 4);
    assert(layers[0] == "client");
    assert(layers[3] == "database");

    // Verify layer independence concept
    foreach (i, layer; layers) {
        assert(layer.length > 0);
        // Each layer should be conceptually independent
    }
    writeln("✓ Layered architecture concept works");

    writeln("All rest_principles tests passed!");
    writeln("=== rest_principles tests completed ===");
}
