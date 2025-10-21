/**
 * Lesson 10: Response Parsers - Parsing and processing LLM API responses
 *
 * This example demonstrates how to parse JSON responses from OpenAI-compatible APIs,
 * extract relevant information, handle errors, and process streaming responses.
 */

module lesson10.response_parsers;

import std.stdio;
import std.json;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.exception;

/**
 * Parsed chat completion response
 */
struct ChatResponse {
    string id;
    string object;
    long created;
    string model;
    Choice[] choices;
    Usage usage;
    string error; // For error responses

    /**
     * Get the main response text
     */
    string getText() {
        if (choices.length > 0 && choices[0].message.content) {
            return choices[0].message.content;
        }
        return "";
    }

    /**
     * Check if response is valid
     */
    bool isValid() {
        return !id.empty && choices.length > 0;
    }

    /**
     * Check if response indicates an error
     */
    bool hasError() {
        return !error.empty;
    }
}

/**
 * Choice from response
 */
struct Choice {
    int index;
    Message message;
    string finishReason;
}

/**
 * Message in response
 */
struct Message {
    string role;
    string content;
}

/**
 * Usage statistics
 */
struct Usage {
    int promptTokens;
    int completionTokens;
    int totalTokens;
}

/**
 * Response parser for OpenAI API
 */
class ResponseParser {
    /**
     * Parse a complete JSON response
     */
    ChatResponse parseResponse(string jsonText) {
        ChatResponse response;

        try {
            JSONValue json = parseJSON(jsonText);

            // Check for error response
            if ("error" in json) {
                JSONValue errorObj = json["error"];
                response.error = errorObj["message"].str;
                return response;
            }

            // Parse successful response
            response.id = json["id"].str;
            response.object = json["object"].str;
            response.created = json["created"].integer;
            response.model = json["model"].str;

            // Parse choices
            if ("choices" in json) {
                foreach (choiceJson; json["choices"].array) {
                    response.choices ~= parseChoice(choiceJson);
                }
            }

            // Parse usage
            if ("usage" in json) {
                response.usage = parseUsage(json["usage"]);
            }

        } catch (JSONException e) {
            response.error = "JSON parsing error: " ~ e.msg;
        } catch (Exception e) {
            response.error = "Unexpected error: " ~ e.msg;
        }

        return response;
    }

    /**
     * Parse a choice object
     */
    private Choice parseChoice(JSONValue json) {
        Choice choice;

        choice.index = cast(int)json["index"].integer;

        if ("message" in json) {
            choice.message = parseMessage(json["message"]);
        }

        if ("finish_reason" in json && json["finish_reason"].type != JSONType.null_) {
            choice.finishReason = json["finish_reason"].str;
        }

        return choice;
    }

    /**
     * Parse a message object
     */
    private Message parseMessage(JSONValue json) {
        Message message;

        if ("role" in json) {
            message.role = json["role"].str;
        }

        if ("content" in json) {
            message.content = json["content"].str;
        }

        return message;
    }

    /**
     * Parse usage statistics
     */
    private Usage parseUsage(JSONValue json) {
        Usage usage;

        if ("prompt_tokens" in json) {
            usage.promptTokens = cast(int)json["prompt_tokens"].integer;
        }

        if ("completion_tokens" in json) {
            usage.completionTokens = cast(int)json["completion_tokens"].integer;
        }

        if ("total_tokens" in json) {
            usage.totalTokens = cast(int)json["total_tokens"].integer;
        }

        return usage;
    }
}

/**
 * Streaming response parser
 */
class StreamingResponseParser {
    private string currentContent;
    private bool isComplete;

    /**
     * Parse a streaming chunk
     * Returns: true if this completes the response
     */
    bool parseChunk(string chunkData) {
        try {
            // Remove "data: " prefix if present
            string jsonText = chunkData;
            if (jsonText.startsWith("data: ")) {
                jsonText = jsonText[6..$];
            }

            // Check for end marker
            if (jsonText.strip() == "[DONE]") {
                isComplete = true;
                return true;
            }

            JSONValue json = parseJSON(jsonText);

            // Parse the chunk
            if ("choices" in json && json["choices"].array.length > 0) {
                JSONValue choice = json["choices"][0];

                // Check finish reason
                if ("finish_reason" in choice && choice["finish_reason"].type != JSONType.null_) {
                    string finishReason = choice["finish_reason"].str;
                    if (finishReason != "null" && !finishReason.empty) {
                        isComplete = true;
                        return true;
                    }
                }

                // Extract content delta
                if ("delta" in choice && "content" in choice["delta"]) {
                    string content = choice["delta"]["content"].str;
                    currentContent ~= content;
                }
            }

        } catch (JSONException e) {
            // Skip malformed chunks in streaming
            writefln("Warning: Skipping malformed chunk: %s", e.msg);
        }

        return false;
    }

    /**
     * Get accumulated content
     */
    string getContent() {
        return currentContent;
    }

    /**
     * Check if response is complete
     */
    bool isResponseComplete() {
        return isComplete;
    }

    /**
     * Reset parser for new response
     */
    void reset() {
        currentContent = "";
        isComplete = false;
    }
}

/**
 * Response validator
 */
class ResponseValidator {
    /**
     * Validate a chat response
     */
    ValidationResult validate(ChatResponse response) {
        ValidationResult result;

        if (response.hasError()) {
            result.isValid = false;
            result.errors ~= "Response contains error: " ~ response.error;
            return result;
        }

        // Check required fields
        if (response.id.empty) {
            result.errors ~= "Missing response ID";
        }

        if (response.object != "chat.completion") {
            result.errors ~= "Invalid object type: " ~ response.object;
        }

        if (response.choices.empty) {
            result.errors ~= "No choices in response";
        } else {
            // Validate first choice
            Choice choice = response.choices[0];
            if (choice.message.content.empty) {
                result.errors ~= "Empty content in response";
            }
        }

        // Check usage statistics
        if (response.usage.totalTokens == 0) {
            result.warnings ~= "Missing usage statistics";
        }

        result.isValid = result.errors.empty;
        return result;
    }
}

/**
 * Validation result
 */
struct ValidationResult {
    bool isValid;
    string[] errors;
    string[] warnings;
}

/**
 * Demonstrate basic response parsing
 */
void demonstrateBasicResponseParsing() {
    writeln("=== Basic Response Parsing ===");

    // Sample successful response
    string sampleResponse = `{
        "id": "chatcmpl-123456",
        "object": "chat.completion",
        "created": 1640995200,
        "model": "gpt-3.5-turbo",
        "choices": [
            {
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": "Hello! How can I help you today?"
                },
                "finish_reason": "stop"
            }
        ],
        "usage": {
            "prompt_tokens": 9,
            "completion_tokens": 8,
            "total_tokens": 17
        }
    }`;

    auto parser = new ResponseParser();
    ChatResponse response = parser.parseResponse(sampleResponse);

    writefln("Parsed response:");
    writefln("• ID: %s", response.id);
    writefln("• Model: %s", response.model);
    writefln("• Content: %s", response.getText());
    writefln("• Finish Reason: %s", response.choices[0].finishReason);
    writefln("• Tokens Used: %d", response.usage.totalTokens);

    writefln("\n✓ Response parsed successfully");
}

/**
 * Demonstrate error response parsing
 */
void demonstrateErrorResponseParsing() {
    writeln("\n=== Error Response Parsing ===");

    // Sample error response
    string errorResponse = `{
        "error": {
            "message": "Invalid API key provided",
            "type": "authentication_error",
            "param": null,
            "code": null
        }
    }`;

    auto parser = new ResponseParser();
    ChatResponse response = parser.parseResponse(errorResponse);

    writefln("Parsed error response:");
    writefln("• Has Error: %s", response.hasError());
    writefln("• Error Message: %s", response.error);
    writefln("• Is Valid Response: %s", response.isValid());

    // Another error example
    string rateLimitError = `{
        "error": {
            "message": "Rate limit exceeded",
            "type": "rate_limit_error",
            "param": null,
            "code": null
        }
    }`;

    response = parser.parseResponse(rateLimitError);
    writefln("\nRate limit error:");
    writefln("• Error: %s", response.error);
}

/**
 * Demonstrate streaming response parsing
 */
void demonstrateStreamingResponseParsing() {
    writeln("\n=== Streaming Response Parsing ===");

    // Simulate streaming chunks
    string[] streamingChunks = [
        `data: {"id": "chatcmpl-stream", "object": "chat.completion.chunk", "created": 1640995200, "model": "gpt-3.5-turbo", "choices": [{"index": 0, "delta": {"role": "assistant"}, "finish_reason": null}]}

`,
        `data: {"id": "chatcmpl-stream", "object": "chat.completion.chunk", "created": 1640995200, "model": "gpt-3.5-turbo", "choices": [{"index": 0, "delta": {"content": "Hello"}, "finish_reason": null}]}

`,
        `data: {"id": "chatcmpl-stream", "object": "chat.completion.chunk", "created": 1640995200, "model": "gpt-3.5-turbo", "choices": [{"index": 0, "delta": {"content": " there"}, "finish_reason": null}]}

`,
        `data: {"id": "chatcmpl-stream", "object": "chat.completion.chunk", "created": 1640995200, "model": "gpt-3.5-turbo", "choices": [{"index": 0, "delta": {"content": "!"}, "finish_reason": "stop"}]}

`,
        `data: [DONE]

`
    ];

    auto streamingParser = new StreamingResponseParser();

    writefln("Processing streaming chunks:");
    foreach (i, chunk; streamingChunks) {
        writefln("Chunk %d: %s", i + 1, chunk.replace("\n", "\\n").strip());

        bool isComplete = streamingParser.parseChunk(chunk);
        writefln("  Accumulated content: '%s'", streamingParser.getContent());
        writefln("  Is complete: %s", isComplete);

        if (isComplete) {
            writefln("  ✓ Streaming response complete!");
            break;
        }
    }

    writefln("\nFinal content: '%s'", streamingParser.getContent());
}

/**
 * Demonstrate response validation
 */
void demonstrateResponseValidation() {
    writeln("\n=== Response Validation ===");

    auto validator = new ResponseValidator();
    auto parser = new ResponseParser();

    struct ValidationTest {
        string description;
        string jsonResponse;
    }

    ValidationTest[] tests = [
        {
            "Valid response",
            `{
                "id": "chatcmpl-valid",
                "object": "chat.completion",
                "created": 1640995200,
                "model": "gpt-3.5-turbo",
                "choices": [{
                    "index": 0,
                    "message": {"role": "assistant", "content": "Valid response"},
                    "finish_reason": "stop"
                }],
                "usage": {"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15}
            }`
        },
        {
            "Missing content",
            `{
                "id": "chatcmpl-invalid",
                "object": "chat.completion",
                "created": 1640995200,
                "model": "gpt-3.5-turbo",
                "choices": [{
                    "index": 0,
                    "message": {"role": "assistant"},
                    "finish_reason": "stop"
                }]
            }`
        },
        {
            "Wrong object type",
            `{
                "id": "chatcmpl-wrong",
                "object": "text.completion",
                "created": 1640995200,
                "model": "gpt-3.5-turbo",
                "choices": [{
                    "index": 0,
                    "message": {"role": "assistant", "content": "Wrong type"},
                    "finish_reason": "stop"
                }]
            }`
        },
        {
            "Error response",
            `{
                "error": {
                    "message": "Invalid request",
                    "type": "invalid_request_error"
                }
            }`
        }
    ];

    foreach (test; tests) {
        writefln("Testing: %s", test.description);

        ChatResponse response = parser.parseResponse(test.jsonResponse);
        ValidationResult validation = validator.validate(response);

        writefln("  Valid: %s", validation.isValid);

        if (!validation.errors.empty) {
            writefln("  Errors:");
            foreach (error; validation.errors) {
                writefln("    • %s", error);
            }
        }

        if (!validation.warnings.empty) {
            writefln("  Warnings:");
            foreach (warning; validation.warnings) {
                writefln("    • %s", warning);
            }
        }

        writeln();
    }
}

/**
 * Demonstrate response processing pipeline
 */
void demonstrateResponseProcessingPipeline() {
    writeln("\n=== Response Processing Pipeline ===");

    writefln("Complete response processing workflow:");

    // 1. Raw response
    string rawResponse = `{
        "id": "chatcmpl-pipeline",
        "object": "chat.completion",
        "created": 1640995200,
        "model": "gpt-3.5-turbo",
        "choices": [{
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "The capital of France is Paris. This is a well-known fact that has been true for centuries. Paris serves as the political, economic, and cultural center of France."
            },
            "finish_reason": "stop"
        }],
        "usage": {
            "prompt_tokens": 15,
            "completion_tokens": 45,
            "total_tokens": 60
        }
    }`;

    // 2. Parse
    auto parser = new ResponseParser();
    ChatResponse response = parser.parseResponse(rawResponse);

    // 3. Validate
    auto validator = new ResponseValidator();
    ValidationResult validation = validator.validate(response);

    // 4. Extract information
    string content = response.getText();
    int tokensUsed = response.usage.totalTokens;
    string finishReason = response.choices[0].finishReason;

    // 5. Process content (e.g., clean up, format)
    string processedContent = content.strip();

    writefln("1. Raw JSON received");
    writefln("2. ✓ Parsed successfully");
    writefln("3. ✓ Validation passed");
    writefln("4. Extracted content: '%s...'", processedContent[0..50]);
    writefln("5. Processed content length: %d characters", processedContent.length);
    writefln("6. Tokens used: %d", tokensUsed);
    writefln("7. Finish reason: %s", finishReason);

    // 6. Handle based on finish reason
    final switch (finishReason) {
        case "stop":
            writefln("8. ✓ Response completed normally");
            break;
        case "length":
            writefln("8. ⚠️ Response truncated due to length limit");
            break;
        case "content_filter":
            writefln("8. ⚠️ Response filtered by content policy");
            break;
    }
}

/**
 * Check if response parser functionality works
 */
bool testResponseParserCapability() {
    try {
        // Test basic parsing
        auto parser = new ResponseParser();

        string testResponse = `{
            "id": "test-123",
            "object": "chat.completion",
            "created": 123456789,
            "model": "gpt-3.5-turbo",
            "choices": [{
                "index": 0,
                "message": {"role": "assistant", "content": "Test response"},
                "finish_reason": "stop"
            }],
            "usage": {"prompt_tokens": 5, "completion_tokens": 3, "total_tokens": 8}
        }`;

        ChatResponse response = parser.parseResponse(testResponse);
        assert(response.id == "test-123");
        assert(response.getText() == "Test response");
        assert(response.usage.totalTokens == 8);
        assert(response.isValid());

        // Test error parsing
        string errorResponse = `{"error": {"message": "Test error"}}`;
        ChatResponse errorResp = parser.parseResponse(errorResponse);
        assert(errorResp.hasError());
        assert(errorResp.error == "Test error");

        // Test streaming parser
        auto streamingParser = new StreamingResponseParser();
        bool complete = streamingParser.parseChunk(`data: {"choices": [{"delta": {"content": "Hello"}}]}`);
        assert(!complete);
        assert(streamingParser.getContent() == "Hello");

        complete = streamingParser.parseChunk(`data: [DONE]`);
        assert(complete);

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the response parsers example
 */
void runExample() {
    writeln("=== Response Parsers Demonstration ===\n");

    if (!testResponseParserCapability()) {
        writeln("ERROR: Response parser functionality test failed!");
        return;
    }

    writeln("✓ Response parser functionality confirmed\n");

    demonstrateBasicResponseParsing();
    demonstrateErrorResponseParsing();
    demonstrateStreamingResponseParsing();
    demonstrateResponseValidation();
    demonstrateResponseProcessingPipeline();

    writeln("\n=== Summary ===");
    writeln("• Use ResponseParser to parse JSON API responses");
    writeln("• Handle both successful and error responses");
    writeln("• Process streaming responses for real-time output");
    writeln("• Validate responses before using the content");
    writeln("• Extract usage statistics for monitoring");
    writeln("• Check finish_reason to handle different completion types");
    writeln("• Implement proper error handling for malformed responses");
}

unittest {
    writeln("=== Running response_parsers tests ===");

    // Test response parser
    auto parser = new ResponseParser();

    string testJson = `{
        "id": "test-id",
        "object": "chat.completion",
        "created": 1234567890,
        "model": "gpt-3.5-turbo",
        "choices": [{
            "index": 0,
            "message": {"role": "assistant", "content": "Hello world"},
            "finish_reason": "stop"
        }],
        "usage": {"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15}
    }`;

    ChatResponse response = parser.parseResponse(testJson);
    assert(response.id == "test-id");
    assert(response.object == "chat.completion");
    assert(response.model == "gpt-3.5-turbo");
    assert(response.choices.length == 1);
    assert(response.choices[0].message.content == "Hello world");
    assert(response.choices[0].finishReason == "stop");
    assert(response.usage.promptTokens == 10);
    assert(response.usage.completionTokens == 5);
    assert(response.usage.totalTokens == 15);
    assert(response.isValid());
    assert(!response.hasError());
    writeln("✓ Response parser works");

    // Test error response
    string errorJson = `{"error": {"message": "Authentication failed"}}`;
    ChatResponse errorResponse = parser.parseResponse(errorJson);
    assert(errorResponse.hasError());
    assert(errorResponse.error == "Authentication failed");
    assert(!errorResponse.isValid());
    writeln("✓ Error response parsing works");

    // Test streaming parser
    auto streamingParser = new StreamingResponseParser();

    bool complete1 = streamingParser.parseChunk(`data: {"choices": [{"delta": {"content": "Hi"}}]}`);
    assert(!complete1);
    assert(streamingParser.getContent() == "Hi");

    bool complete2 = streamingParser.parseChunk(`data: {"choices": [{"delta": {"content": " there"}}]}`);
    assert(!complete2);
    assert(streamingParser.getContent() == "Hi there");

    bool complete3 = streamingParser.parseChunk(`data: [DONE]`);
    assert(complete3);
    assert(streamingParser.getContent() == "Hi there");
    assert(streamingParser.isResponseComplete());
    writeln("✓ Streaming parser works");

    // Test validator
    auto validator = new ResponseValidator();
    ValidationResult validResult = validator.validate(response);
    assert(validResult.isValid);
    assert(validResult.errors.empty);

    ValidationResult errorResult = validator.validate(errorResponse);
    assert(!errorResult.isValid);
    assert(!errorResult.errors.empty);
    writeln("✓ Response validator works");

    // Test response structure
    ChatResponse testResp;
    testResp.id = "test";
    testResp.choices ~= Choice(0, Message("assistant", "content"), "stop");
    assert(testResp.getText() == "content");
    assert(testResp.isValid());
    writeln("✓ Response structure works");

    writeln("All response_parsers tests passed!");
    writeln("=== response_parsers tests completed ===");
}

