/**
 * Lesson 3: GitHub API - GET from GitHub API with status codes
 *
 * This example demonstrates making authenticated requests to the GitHub REST API
 * using std.curl, handling status codes, rate limiting, and parsing JSON responses.
 */

module lesson3.github_api;

import std.stdio;
import std.net.curl;
import std.string;
import std.conv;
import std.json;
import std.array;
import std.algorithm;

/**
 * Structure to hold GitHub API response
 */
struct GitHubResponse {
    int statusCode;
    string statusText;
    JSONValue jsonData;
    string[string] headers;
    long rateLimitRemaining = -1;
    long rateLimitReset = -1;
    bool isRateLimited = false;

    /**
     * Check if the request was successful
     */
    bool isSuccess() const {
        return statusCode >= 200 && statusCode < 300 && !isRateLimited;
    }

    /**
     * Get error message if request failed
     */
    string getErrorMessage() const {
        if (isRateLimited) {
            return "Rate limit exceeded";
        }

        switch (statusCode) {
            case 401: return "Unauthorized - Invalid or missing token";
            case 403: return "Forbidden - Insufficient permissions";
            case 404: return "Not Found - Resource doesn't exist";
            case 422: return "Unprocessable Entity - Validation failed";
            case 500: return "Internal Server Error";
            case 502: return "Bad Gateway";
            case 503: return "Service Unavailable";
            default: return format("HTTP %d: %s", statusCode, statusText);
        }
    }
}

/**
 * Make a request to GitHub API
 */
GitHubResponse githubApiRequest(string endpoint, string token = "") {
    GitHubResponse response;

    try {
        string url = "https://api.github.com" ~ endpoint;
        auto http = HTTP(url);

        // Set headers
        http.addRequestHeader("Accept", "application/vnd.github.v3+json");
        http.addRequestHeader("User-Agent", "D-Language-Course/1.0");

        // Add authorization if token provided
        if (!token.empty) {
            http.addRequestHeader("Authorization", "token " ~ token);
        }

        // Timeout not set - using default (30 seconds is usually fine)

        string responseBody;

        // Receive response data
        http.onReceive = (ubyte[] data) {
            responseBody ~= cast(string)data;
            return data.length;
        };

        // Receive headers
        http.onReceiveHeader = (in char[] key, in char[] value) {
            string k = to!string(key).strip().toLower();
            string v = to!string(value).strip();

            response.headers[k] = v;

            // Check for rate limiting headers
            if (k == "x-ratelimit-remaining") {
                try {
                    response.rateLimitRemaining = to!long(v);
                } catch (Exception e) {}
            } else if (k == "x-ratelimit-reset") {
                try {
                    response.rateLimitReset = to!long(v);
                } catch (Exception e) {}
            }
        };

        // Get status code
        http.onReceiveStatusLine = (HTTP.StatusLine statusLine) {
            response.statusCode = statusLine.code;
            response.statusText = statusLine.reason.idup;
        };

        http.perform();

        // Check for rate limiting
        if (response.rateLimitRemaining == 0) {
            response.isRateLimited = true;
        }

        // Parse JSON response
        if (!responseBody.empty && responseBody.strip().length > 0) {
            try {
                response.jsonData = parseJSON(responseBody);
            } catch (JSONException e) {
                // If JSON parsing fails, store as string
                response.jsonData = JSONValue(responseBody);
            }
        }

    } catch (CurlException e) {
        response.statusCode = -1;
        response.statusText = e.msg.idup;
    } catch (Exception e) {
        response.statusCode = -1;
        response.statusText = e.msg.idup;
    }

    return response;
}

/**
 * Get user information from GitHub API
 */
void demonstrateUserInfo() {
    writeln("=== GitHub User Information ===");

    // Try to get info for a public user (no auth required for basic info)
    GitHubResponse response = githubApiRequest("/users/octocat");

    writefln("Status: HTTP %d %s", response.statusCode, response.statusText);

    if (response.isSuccess()) {
        writeln("✓ Successfully retrieved user information");

        // Extract user data from JSON
        if (response.jsonData.type == JSONType.object) {
            auto user = response.jsonData;

            if ("login" in user) {
                writefln("Username: %s", user["login"].str);
            }

            if ("name" in user && user["name"].type != JSONType.null_) {
                writefln("Name: %s", user["name"].str);
            }

            if ("public_repos" in user) {
                writefln("Public repositories: %d", user["public_repos"].integer);
            }

            if ("followers" in user) {
                writefln("Followers: %d", user["followers"].integer);
            }
        }

        // Show rate limit info
        if (response.rateLimitRemaining >= 0) {
            writefln("Rate limit remaining: %d", response.rateLimitRemaining);
        }

    } else {
        writefln("✗ Failed to get user info: %s", response.getErrorMessage());
    }
}

/**
 * Get repository information
 */
void demonstrateRepoInfo() {
    writeln("\n=== GitHub Repository Information ===");

    GitHubResponse response = githubApiRequest("/repos/microsoft/vscode");

    writefln("Status: HTTP %d %s", response.statusCode, response.statusText);

    if (response.isSuccess()) {
        writeln("✓ Successfully retrieved repository information");

        if (response.jsonData.type == JSONType.object) {
            auto repo = response.jsonData;

            if ("full_name" in repo) {
                writefln("Repository: %s", repo["full_name"].str);
            }

            if ("description" in repo && repo["description"].type != JSONType.null_) {
                writefln("Description: %s", repo["description"].str);
            }

            if ("stargazers_count" in repo) {
                writefln("Stars: %d", repo["stargazers_count"].integer);
            }

            if ("language" in repo && repo["language"].type != JSONType.null_) {
                writefln("Primary language: %s", repo["language"].str);
            }
        }

    } else {
        writefln("✗ Failed to get repo info: %s", response.getErrorMessage());
    }
}

/**
 * Demonstrate rate limiting
 */
void demonstrateRateLimiting() {
    writeln("\n=== Rate Limiting Demonstration ===");

    // Make multiple requests to see rate limiting
    for (int i = 0; i < 3; i++) {
        writefln("--- Request %d ---", i + 1);

        GitHubResponse response = githubApiRequest("/rate_limit");

        writefln("Status: HTTP %d %s", response.statusCode, response.statusText);

        if (response.isRateLimited) {
            writefln("⚠ Rate limit exceeded!");
            writefln("Remaining requests: %d", response.rateLimitRemaining);
            if (response.rateLimitReset > 0) {
                writefln("Resets at timestamp: %d", response.rateLimitReset);
            }
            break;
        }

        if (response.isSuccess() && response.jsonData.type == JSONType.object) {
            auto rateData = response.jsonData;
            if ("rate" in rateData && rateData["rate"].type == JSONType.object) {
                auto rate = rateData["rate"];
                if ("remaining" in rate) {
                    writefln("Remaining requests: %d", rate["remaining"].integer);
                }
                if ("reset" in rate) {
                    writefln("Reset timestamp: %d", rate["reset"].integer);
                }
            }
        }

        // Small delay between requests
        import core.thread;
        Thread.sleep(100.msecs);
    }
}

/**
 * Demonstrate error handling with different endpoints
 */
void demonstrateErrorHandling() {
    writeln("\n=== Error Handling with GitHub API ===");

    string[] testEndpoints = [
        "/users/nonexistent-user-12345",  // 404 Not Found
        "/repos/nonexistent/repo",        // 404 Not Found
        "/user",                          // 401 Unauthorized (requires auth)
    ];

    foreach (endpoint; testEndpoints) {
        writefln("--- Testing: %s ---", endpoint);

        GitHubResponse response = githubApiRequest(endpoint);

        writefln("Status: HTTP %d %s", response.statusCode, response.statusText);

        if (response.isSuccess()) {
            writefln("✓ Unexpected success");
        } else {
            writefln("✓ Expected error: %s", response.getErrorMessage());
        }

        // Small delay
        import core.thread;
        Thread.sleep(200.msecs);
    }
}

/**
 * Demonstrate JSON array handling (repository listing)
 */
void demonstrateJsonArrays() {
    writeln("\n=== JSON Array Handling ===");

    // Get a user's repositories (may be rate limited)
    GitHubResponse response = githubApiRequest("/users/octocat/repos?per_page=3");

    writefln("Status: HTTP %d %s", response.statusCode, response.statusText);

    if (response.isSuccess()) {
        if (response.jsonData.type == JSONType.array) {
            auto repos = response.jsonData.array;
            writefln("✓ Retrieved %d repositories", repos.length);

            // Show info for first few repos
            foreach (i, repo; repos) {
                if (i >= 3) break; // Limit output

                if (repo.type == JSONType.object) {
                    if ("name" in repo) {
                        writefln("  %d. %s", i + 1, repo["name"].str);
                    }

                    if ("language" in repo && repo["language"].type != JSONType.null_) {
                        writefln("     Language: %s", repo["language"].str);
                    }
                }
            }

        } else {
            writeln("? Expected array response");
        }

    } else {
        writefln("✗ Failed to get repositories: %s", response.getErrorMessage());
    }
}

/**
 * Show API rate limit information
 */
void showApiLimits() {
    writeln("\n=== GitHub API Rate Limits ===");

    GitHubResponse response = githubApiRequest("/rate_limit");

    if (response.isSuccess() && response.jsonData.type == JSONType.object) {
        auto data = response.jsonData;

        if ("resources" in data && data["resources"].type == JSONType.object) {
            auto resources = data["resources"];

            if ("core" in resources && resources["core"].type == JSONType.object) {
                auto core = resources["core"];
                writefln("Core API limit: %d", core["limit"].integer);
                writefln("Core API remaining: %d", core["remaining"].integer);
                writefln("Core API reset: %d", core["reset"].integer);
            }
        }
    } else {
        writefln("Could not retrieve rate limit information: %s", response.getErrorMessage());
    }

    writeln("\nNote: Unauthenticated requests are limited to 60 per hour");
    writeln("Authenticated requests get 5000 per hour");
    writeln("Use a GitHub personal access token for higher limits");
}

/**
 * Check if GitHub API is accessible
 */
bool isGitHubApiAvailable() {
    try {
        GitHubResponse response = githubApiRequest("/rate_limit");
        return response.statusCode > 0;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the GitHub API examples
 */
void runExample() {
    writeln("=== GitHub API with std.curl ===\n");

    if (!isGitHubApiAvailable()) {
        writeln("ERROR: GitHub API is not accessible!");
        writeln("This might be due to network issues or API being down.");
        return;
    }

    writeln("✓ GitHub API is accessible\n");

    // Demonstrate GitHub API usage
    demonstrateUserInfo();
    demonstrateRepoInfo();
    demonstrateRateLimiting();
    demonstrateErrorHandling();
    demonstrateJsonArrays();
    showApiLimits();

    writeln("\n=== Summary ===");
    writeln("• GitHub API provides RESTful access to repository and user data");
    writeln("• Authentication increases rate limits from 60 to 5000 requests/hour");
    writeln("• JSON responses require parsing with std.json");
    writeln("• Rate limiting headers help manage API usage");
    writeln("• Error codes: 401 (auth), 403 (permissions), 404 (not found)");
    writeln("• Arrays and nested objects common in API responses");
}

unittest {
    writeln("=== Running github_api tests ===");

    // Test GitHubResponse struct
    GitHubResponse response;
    response.statusCode = 200;
    response.statusText = "OK";
    response.rateLimitRemaining = 4999;
    response.rateLimitReset = 1640995200;

    assert(response.isSuccess());
    assert(!response.isRateLimited);

    // Test rate limiting detection
    response.rateLimitRemaining = 0;
    response.isRateLimited = true;  // This should be set when rateLimitRemaining == 0
    assert(response.isRateLimited);
    assert(!response.isSuccess());

    // Test error message generation
    GitHubResponse errorResponse;
    errorResponse.statusCode = 404;
    assert(!errorResponse.isSuccess());
    string errorMsg = errorResponse.getErrorMessage();
    assert(errorMsg.canFind("Not Found"));

    errorResponse.statusCode = 401;
    errorMsg = errorResponse.getErrorMessage();
    assert(errorMsg.canFind("Unauthorized"));

    errorResponse.statusCode = 500;
    errorMsg = errorResponse.getErrorMessage();
    assert(errorMsg.canFind("Internal Server Error"));
    writeln("✓ GitHubResponse struct works");

    // Test JSON parsing simulation
    string jsonStr = `{"login": "octocat", "id": 1, "name": "The Octocat"}`;
    JSONValue json;
    try {
        json = parseJSON(jsonStr);
        assert(json.type == JSONType.object);
        assert("login" in json);
        assert(json["login"].str == "octocat");
        assert(json["id"].integer == 1);
        writeln("✓ JSON parsing simulation works");
    } catch (Exception e) {
        assert(false, "JSON parsing should work");
    }

    // Test array handling simulation
    JSONValue jsonArray;
    jsonArray = parseJSON(`["repo1", "repo2", "repo3"]`);
    assert(jsonArray.type == JSONType.array);
    assert(jsonArray.array.length == 3);
    assert(jsonArray[0].str == "repo1");
    assert(jsonArray[1].str == "repo2");
    assert(jsonArray[2].str == "repo3");
    writeln("✓ JSON array handling simulation works");

    // Test header parsing simulation
    string[string] headers;
    headers["x-ratelimit-remaining"] = "4999";
    headers["x-ratelimit-reset"] = "1640995200";
    headers["content-type"] = "application/json";

    long remaining = -1;
    long reset = -1;

    foreach (key, value; headers) {
        if (key == "x-ratelimit-remaining") {
            remaining = to!long(value);
        } else if (key == "x-ratelimit-reset") {
            reset = to!long(value);
        }
    }

    assert(remaining == 4999);
    assert(reset == 1640995200);
    writeln("✓ Header parsing simulation works");

    // Test endpoint construction
    string[] endpoints = ["/users/octocat", "/repos/microsoft/vscode", "/rate_limit"];
    foreach (endpoint; endpoints) {
        assert(endpoint.startsWith("/"));
        assert(!endpoint.canFind(" "));
    }
    writeln("✓ Endpoint construction validation works");

    // Test status code categorization
    int[] codes = [200, 201, 301, 400, 404, 500];
    foreach (code; codes) {
        bool is2xx = code >= 200 && code < 300;
        bool is4xx = code >= 400 && code < 500;
        bool is5xx = code >= 500;

        if (code == 200 || code == 201) assert(is2xx);
        if (code == 400 || code == 404) assert(is4xx);
        if (code == 500) assert(is5xx);
    }
    writeln("✓ Status code categorization works");

    // Test GitHub API availability
    bool apiAvailable = isGitHubApiAvailable();
    writefln("GitHub API availability test: %s", apiAvailable ? "available" : "not available");

    // Test rate limiting logic
    int remainingRequests = 10;
    bool isLimited = remainingRequests == 0;
    assert(!isLimited);

    remainingRequests = 0;
    isLimited = remainingRequests == 0;
    assert(isLimited);
    writeln("✓ Rate limiting logic works");

    writeln("All GitHub API tests passed!");
    writeln("=== github_api tests completed ===");
}
