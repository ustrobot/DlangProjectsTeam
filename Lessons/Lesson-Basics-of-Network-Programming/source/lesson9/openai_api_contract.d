/**
 * Lesson 9: OpenAI API Contract - Understanding OpenAI-compatible API specifications
 *
 * This example demonstrates the structure and usage of OpenAI-compatible APIs,
 * including request/response formats, authentication, and error handling.
 */

module lesson9.openai_api_contract;

import std.stdio;
import std.net.curl;
import std.json;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

/**
 * OpenAI API request structure
 */
struct OpenAIRequest {
    string model;
    JSONValue[] messages;
    double temperature = 1.0;
    int maxTokens = 100;
    double topP = 1.0;
    int frequencyPenalty = 0;
    int presencePenalty = 0;
    string[] stop;

    /**
     * Convert to JSON
     */
    JSONValue toJSON() {
        JSONValue json = JSONValue([
            "model": JSONValue(model),
            "messages": JSONValue(messages),
            "temperature": JSONValue(temperature),
            "max_tokens": JSONValue(maxTokens),
            "top_p": JSONValue(topP),
            "frequency_penalty": JSONValue(frequencyPenalty),
            "presence_penalty": JSONValue(presencePenalty)
        ]);

        if (!stop.empty) {
            json["stop"] = JSONValue(stop);
        }

        return json;
    }
}

/**
 * OpenAI API response structure
 */
struct OpenAIResponse {
    string id;
    string object;
    long created;
    string model;
    Choice[] choices;
    Usage usage;

    static OpenAIResponse fromJSON(JSONValue json) {
        OpenAIResponse response;

        response.id = json["id"].str;
        response.object = json["object"].str;
        response.created = json["created"].integer;
        response.model = json["model"].str;

        // Parse choices
        foreach (choiceJson; json["choices"].array) {
            response.choices ~= Choice.fromJSON(choiceJson);
        }

        // Parse usage
        response.usage = Usage.fromJSON(json["usage"]);

        return response;
    }
}

/**
 * Choice structure for OpenAI responses
 */
struct Choice {
    int index;
    Message message;
    string finishReason;

    static Choice fromJSON(JSONValue json) {
        Choice choice;
        choice.index = cast(int)json["index"].integer;
        choice.message = Message.fromJSON(json["message"]);
        choice.finishReason = json["finish_reason"].str;
        return choice;
    }
}

/**
 * Message structure
 */
struct Message {
    string role;
    string content;

    static Message fromJSON(JSONValue json) {
        Message msg;
        msg.role = json["role"].str;
        msg.content = json["content"].str;
        return msg;
    }

    JSONValue toJSON() {
        return JSONValue([
            "role": JSONValue(role),
            "content": JSONValue(content)
        ]);
    }
}

/**
 * Usage statistics
 */
struct Usage {
    int promptTokens;
    int completionTokens;
    int totalTokens;

    static Usage fromJSON(JSONValue json) {
        Usage usage;
        usage.promptTokens = cast(int)json["prompt_tokens"].integer;
        usage.completionTokens = cast(int)json["completion_tokens"].integer;
        usage.totalTokens = cast(int)json["total_tokens"].integer;
        return usage;
    }
}

/**
 * Demonstrate OpenAI API request building
 */
void demonstrateAPIRequestBuilding() {
    writeln("=== OpenAI API Request Building ===");

    // Create a chat completion request
    OpenAIRequest request;
    request.model = "gpt-3.5-turbo";
    request.messages = [
        Message("system", "You are a helpful assistant.").toJSON(),
        Message("user", "What is the capital of France?").toJSON()
    ];
    request.temperature = 0.7;
    request.maxTokens = 150;

    // Convert to JSON
    JSONValue requestJson = request.toJSON();

    writefln("OpenAI API Request (Chat Completions):");
    writefln("%s", requestJson.toPrettyString());

    writefln("\nKey request components:");
    writefln("• model: Specifies which AI model to use");
    writefln("• messages: Array of conversation messages");
    writefln("• temperature: Controls randomness (0.0-2.0)");
    writefln("• max_tokens: Maximum response length");
    writefln("• Other parameters: top_p, frequency_penalty, etc.");
}

/**
 * Demonstrate OpenAI API response parsing
 */
void demonstrateAPIResponseParsing() {
    writeln("\n=== OpenAI API Response Parsing ===");

    // Sample OpenAI API response
    string sampleResponse = `{
        "id": "chatcmpl-1234567890",
        "object": "chat.completion",
        "created": 1677652288,
        "model": "gpt-3.5-turbo",
        "choices": [
            {
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": "The capital of France is Paris."
                },
                "finish_reason": "stop"
            }
        ],
        "usage": {
            "prompt_tokens": 23,
            "completion_tokens": 7,
            "total_tokens": 30
        }
    }`;

    writefln("Sample OpenAI API Response:");
    writefln("%s", sampleResponse);
    writeln();

    // Parse the response
    JSONValue responseJson = parseJSON(sampleResponse);
    OpenAIResponse response = OpenAIResponse.fromJSON(responseJson);

    writefln("Parsed Response:");
    writefln("• ID: %s", response.id);
    writefln("• Model: %s", response.model);
    writefln("• Created: %d", response.created);
    writefln("• Choices: %d", response.choices.length);

    if (!response.choices.empty) {
        Choice choice = response.choices[0];
        writefln("• Response: %s", choice.message.content);
        writefln("• Finish Reason: %s", choice.finishReason);
    }

    writefln("• Usage: %d prompt + %d completion = %d total tokens",
            response.usage.promptTokens,
            response.usage.completionTokens,
            response.usage.totalTokens);
}

/**
 * Demonstrate authentication headers
 */
void demonstrateAuthentication() {
    writeln("\n=== OpenAI API Authentication ===");

    writefln("OpenAI API authentication uses Bearer tokens:");
    writefln("```http");
    writefln("Authorization: Bearer sk-your-api-key-here");
    writefln("Content-Type: application/json");
    writefln("```");

    writefln("\nAuthentication best practices:");
    writefln("• Store API keys securely (environment variables, key vaults)");
    writefln("• Never commit API keys to version control");
    writefln("• Rotate keys regularly");
    writefln("• Use different keys for different environments");
    writefln("• Monitor API key usage");

    // Show how to make an authenticated request
    writefln("\nExample authenticated request setup:");
    writefln("```d");
    writefln("auto http = HTTP(\"https://api.openai.com/v1/chat/completions\");");
    writefln("http.addRequestHeader(\"Authorization\", \"Bearer \" ~ apiKey);");
    writefln("http.addRequestHeader(\"Content-Type\", \"application/json\");");
    writefln("http.postData = requestJson.toString();");
    writefln("```");
}

/**
 * Demonstrate different OpenAI API endpoints
 */
void demonstrateAPIEndpoints() {
    writeln("\n=== OpenAI API Endpoints ===");

    struct APIEndpoint {
        string path;
        string method;
        string description;
    }

    APIEndpoint[] endpoints = [
        {"/v1/chat/completions", "POST", "Generate chat completions"},
        {"/v1/completions", "POST", "Generate text completions"},
        {"/v1/edits", "POST", "Create edited version of text"},
        {"/v1/images/generations", "POST", "Generate images"},
        {"/v1/images/edits", "POST", "Edit images"},
        {"/v1/images/variations", "POST", "Create image variations"},
        {"/v1/embeddings", "POST", "Create embeddings"},
        {"/v1/audio/transcriptions", "POST", "Transcribe audio"},
        {"/v1/audio/translations", "POST", "Translate audio"},
        {"/v1/files", "GET", "List files"},
        {"/v1/files", "POST", "Upload file"},
        {"/v1/fine-tunes", "POST", "Create fine-tuning job"},
        {"/v1/models", "GET", "List available models"}
    ];

    writefln("OpenAI API endpoints:");
    foreach (endpoint; endpoints) {
        writefln("• %5s %s - %s", endpoint.method, endpoint.path, endpoint.description);
    }

    writefln("\nBase URL: https://api.openai.com");
    writefln("All endpoints require authentication");
    writefln("All POST endpoints accept/return JSON");
}

/**
 * Demonstrate error handling for OpenAI API
 */
void demonstrateAPIErrorHandling() {
    writeln("\n=== OpenAI API Error Handling ===");

    struct APIError {
        string type;
        string message;
        string description;
    }

    APIError[] commonErrors = [
        {
            "invalid_request_error",
            "Invalid request parameters",
            "Check your request format and parameters"
        },
        {
            "authentication_error",
            "Invalid API key",
            "Check your API key and authentication"
        },
        {
            "permission_error",
            "Insufficient permissions",
            "Your API key doesn't have access to this resource"
        },
        {
            "rate_limit_error",
            "Rate limit exceeded",
            "Wait before making more requests"
        },
        {
            "server_error",
            "Internal server error",
            "OpenAI service issue, retry later"
        },
        {
            "context_length_exceeded",
            "Context length exceeded",
            "Reduce the length of your prompt or messages"
        },
        {
            "content_policy_violation",
            "Content policy violation",
            "Your request violates OpenAI's content policy"
        }
    ];

    writefln("Common OpenAI API errors:");
    foreach (error; commonErrors) {
        writefln("• %s: %s", error.type, error.message);
        writefln("  → %s", error.description);
        writeln();
    }

    writefln("Error response format:");
    writefln("```json");
    writefln("{");
    writefln("  \"error\": {");
    writefln("    \"message\": \"Invalid API key\",");
    writefln("    \"type\": \"authentication_error\",");
    writefln("    \"param\": null,");
    writefln("    \"code\": null");
    writefln("  }");
    writefln("}");
    writefln("```");
}

/**
 * Demonstrate rate limiting for OpenAI API
 */
void demonstrateAPIRateLimiting() {
    writeln("\n=== OpenAI API Rate Limiting ===");

    writefln("OpenAI implements rate limits to ensure fair usage:");
    writefln("• RPM (Requests Per Minute)");
    writefln("• TPM (Tokens Per Minute)");
    writefln("• RPD (Requests Per Day, for some endpoints)");

    writefln("\nRate limits vary by model and account tier:");
    writefln("• GPT-4: Lower limits than GPT-3.5");
    writefln("• Paid accounts: Higher limits than free");
    writefln("• Fine-tuned models: Different limits");

    writefln("\nRate limit headers in responses:");
    writefln("• x-ratelimit-limit-requests: Request limit");
    writefln("• x-ratelimit-remaining-requests: Remaining requests");
    writefln("• x-ratelimit-reset-requests: Reset time for requests");
    writefln("• x-ratelimit-limit-tokens: Token limit");
    writefln("• x-ratelimit-remaining-tokens: Remaining tokens");
    writefln("• x-ratelimit-reset-tokens: Reset time for tokens");

    writefln("\nHandling rate limits:");
    writefln("• Check remaining requests before making calls");
    writefln("• Implement exponential backoff on 429 errors");
    writefln("• Respect Retry-After headers");
    writefln("• Monitor usage patterns");
}

/**
 * Demonstrate making a mock OpenAI API call
 */
void demonstrateMockAPICall() {
    writeln("\n=== Mock OpenAI API Call ===");

    // Create a request
    OpenAIRequest request;
    request.model = "gpt-3.5-turbo";
    request.messages = [
        Message("system", "You are a helpful assistant.").toJSON(),
        Message("user", "Hello, how are you?").toJSON()
    ];
    request.temperature = 0.7;
    request.maxTokens = 50;

    JSONValue requestJson = request.toJSON();

    writefln("Request that would be sent to OpenAI API:");
    writefln("%s", requestJson.toPrettyString());

    writefln("\nUsing httpbin.org to simulate API call:");

    try {
        auto http = HTTP("https://httpbin.org/post");
        http.addRequestHeader("Content-Type", "application/json");
        http.addRequestHeader("Authorization", "Bearer mock-api-key");
        http.postData = requestJson.toString();

        string response;
        http.onReceive = (ubyte[] data) {
            response ~= cast(string)data;
            return data.length;
        };

        http.perform();

        writefln("✓ Mock API call successful");
        writefln("Response length: %d bytes", response.length);

        // Parse the httpbin response to show what was sent
        JSONValue httpbinResponse = parseJSON(response);
        if ("json" in httpbinResponse) {
            writefln("Request data that was sent:");
            writefln("%s", httpbinResponse["json"].toPrettyString());
        }

    } catch (Exception e) {
        writefln("✗ Mock API call failed: %s", e.msg);
    }
}

/**
 * Demonstrate streaming responses (conceptually)
 */
void demonstrateStreaming() {
    writeln("\n=== Streaming Responses ===");

    writefln("OpenAI supports streaming responses for real-time output:");
    writefln("• Set 'stream': true in request");
    writefln("• Responses come as Server-Sent Events (SSE)");
    writefln("• Each chunk contains partial response");
    writefln("• Final chunk has 'finish_reason'");

    writefln("\nStreaming response format:");
    writefln("```");
    writefln("data: {\"id\": \"chatcmpl-123\", \"object\": \"chat.completion.chunk\", ...}");
    writefln("data: {\"id\": \"chatcmpl-123\", \"object\": \"chat.completion.chunk\", ...}");
    writefln("data: [DONE]");
    writefln("```");

    writefln("\nStreaming benefits:");
    writefln("• Faster apparent response time");
    writefln("• Better user experience for long responses");
    writefln("• Ability to handle very long responses");
    writefln("• Real-time display of generated text");
}

/**
 * Check if OpenAI API contract functionality works
 */
bool testOpenAIAPIContractCapability() {
    try {
        // Test request building
        OpenAIRequest request;
        request.model = "test-model";
        request.messages = [Message("user", "test").toJSON()];
        JSONValue json = request.toJSON();

        assert(json["model"].str == "test-model");
        assert(json["messages"].array.length == 1);

        // Test response parsing
        string mockResponse = `{
            "id": "test-123",
            "object": "chat.completion",
            "created": 1234567890,
            "model": "test-model",
            "choices": [{
                "index": 0,
                "message": {"role": "assistant", "content": "test response"},
                "finish_reason": "stop"
            }],
            "usage": {
                "prompt_tokens": 10,
                "completion_tokens": 5,
                "total_tokens": 15
            }
        }`;

        JSONValue responseJson = parseJSON(mockResponse);
        OpenAIResponse response = OpenAIResponse.fromJSON(responseJson);

        assert(response.id == "test-123");
        assert(response.choices.length == 1);
        assert(response.choices[0].message.content == "test response");
        assert(response.usage.totalTokens == 15);

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the OpenAI API contract example
 */
void runExample() {
    writeln("=== OpenAI API Contract Demonstration ===\n");

    if (!testOpenAIAPIContractCapability()) {
        writeln("ERROR: OpenAI API contract functionality test failed!");
        return;
    }

    writeln("✓ OpenAI API contract functionality confirmed\n");

    demonstrateAPIRequestBuilding();
    demonstrateAPIResponseParsing();
    demonstrateAuthentication();
    demonstrateAPIEndpoints();
    demonstrateAPIErrorHandling();
    demonstrateAPIRateLimiting();
    demonstrateMockAPICall();
    demonstrateStreaming();

    writeln("\n=== Summary ===");
    writeln("• OpenAI API uses JSON for requests and responses");
    writeln("• Authentication via Bearer tokens in Authorization header");
    writeln("• Chat completions use messages array with roles");
    writeln("• Handle rate limits with exponential backoff");
    writeln("• Parse structured error responses");
    writeln("• Monitor token usage for cost control");
    writeln("• Consider streaming for real-time responses");
    writeln("• Always validate API responses before use");
}

unittest {
    writeln("=== Running openai_api_contract tests ===");

    // Test request building
    OpenAIRequest request;
    request.model = "gpt-3.5-turbo";
    request.messages = [Message("user", "Hello").toJSON()];
    request.temperature = 0.5;
    request.maxTokens = 100;

    JSONValue json = request.toJSON();
    assert(json["model"].str == "gpt-3.5-turbo");
    assert(json["messages"].array.length == 1);
    assert(json["temperature"].floating == 0.5);
    assert(json["max_tokens"].integer == 100);
    writeln("✓ Request building works");

    // Test message structure
    Message msg = Message("assistant", "Hello there!");
    JSONValue msgJson = msg.toJSON();
    assert(msgJson["role"].str == "assistant");
    assert(msgJson["content"].str == "Hello there!");
    writeln("✓ Message structure works");

    // Test response parsing
    string testResponse = `{
        "id": "test-id",
        "object": "chat.completion",
        "created": 123456789,
        "model": "test-model",
        "choices": [{
            "index": 0,
            "message": {"role": "assistant", "content": "Test response"},
            "finish_reason": "stop"
        }],
        "usage": {
            "prompt_tokens": 5,
            "completion_tokens": 3,
            "total_tokens": 8
        }
    }`;

    JSONValue responseJson = parseJSON(testResponse);
    OpenAIResponse response = OpenAIResponse.fromJSON(responseJson);

    assert(response.id == "test-id");
    assert(response.model == "test-model");
    assert(response.choices.length == 1);
    assert(response.choices[0].message.content == "Test response");
    assert(response.usage.promptTokens == 5);
    assert(response.usage.completionTokens == 3);
    assert(response.usage.totalTokens == 8);
    writeln("✓ Response parsing works");

    // Test usage structure
    Usage usage = Usage(10, 20, 30);
    assert(usage.promptTokens == 10);
    assert(usage.completionTokens == 20);
    assert(usage.totalTokens == 30);
    writeln("✓ Usage structure works");

    // Test choice structure
    Choice choice;
    choice.index = 1;
    choice.message = Message("user", "test");
    choice.finishReason = "length";
    assert(choice.index == 1);
    assert(choice.finishReason == "length");
    writeln("✓ Choice structure works");

    writeln("All openai_api_contract tests passed!");
    writeln("=== openai_api_contract tests completed ===");
}
