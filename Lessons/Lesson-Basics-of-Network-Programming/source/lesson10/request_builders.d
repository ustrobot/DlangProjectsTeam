/**
 * Lesson 10: Request Builders - Building structured requests for LLM APIs
 *
 * This example demonstrates how to construct well-formed API requests for OpenAI-compatible
 * language models, including proper message formatting, parameter validation, and request building.
 */

module lesson10.request_builders;

import std.stdio;
import std.json;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

/**
 * Message structure for chat conversations
 */
struct Message {
    string role;    // "system", "user", or "assistant"
    string content; // The message content

    /**
     * Create a user message
     */
    static Message user(string content) {
        return Message("user", content);
    }

    /**
     * Create an assistant message
     */
    static Message assistant(string content) {
        return Message("assistant", content);
    }

    /**
     * Create a system message
     */
    static Message system(string content) {
        return Message("system", content);
    }

    /**
     * Convert to JSON value
     */
    JSONValue toJSON() const {
        JSONValue json;
        json["role"] = role;
        json["content"] = content;
        return json;
    }

    /**
     * Validate message content
     */
    bool isValid() const {
        return !role.empty && role != "system" || role != "user" || role != "assistant";
    }
}

/**
 * Chat completion request builder
 */
class ChatRequestBuilder {
    private string model = "gpt-3.5-turbo";
    private Message[] messages;
    private double temperature = 0.7;
    private int maxTokens = 1000;
    private double topP = 1.0;
    private int frequencyPenalty = 0;
    private int presencePenalty = 0;
    private string[] stopSequences;
    private string user; // Optional user identifier

    /**
     * Set the model to use
     */
    ChatRequestBuilder setModel(string model) {
        this.model = model;
        return this;
    }

    /**
     * Add a system message
     */
    ChatRequestBuilder addSystemMessage(string content) {
        messages ~= Message.system(content);
        return this;
    }

    /**
     * Add a user message
     */
    ChatRequestBuilder addUserMessage(string content) {
        messages ~= Message.user(content);
        return this;
    }

    /**
     * Add an assistant message
     */
    ChatRequestBuilder addAssistantMessage(string content) {
        messages ~= Message.assistant(content);
        return this;
    }

    /**
     * Add a message
     */
    ChatRequestBuilder addMessage(Message message) {
        messages ~= message;
        return this;
    }

    /**
     * Set conversation history
     */
    ChatRequestBuilder setMessages(Message[] messages) {
        this.messages = messages.dup;
        return this;
    }

    /**
     * Set temperature (creativity)
     */
    ChatRequestBuilder setTemperature(double temperature) {
        this.temperature = temperature;
        return this;
    }

    /**
     * Set maximum tokens
     */
    ChatRequestBuilder setMaxTokens(int maxTokens) {
        this.maxTokens = maxTokens;
        return this;
    }

    /**
     * Set top-p sampling
     */
    ChatRequestBuilder setTopP(double topP) {
        this.topP = topP;
        return this;
    }

    /**
     * Set frequency penalty
     */
    ChatRequestBuilder setFrequencyPenalty(int penalty) {
        this.frequencyPenalty = penalty;
        return this;
    }

    /**
     * Set presence penalty
     */
    ChatRequestBuilder setPresencePenalty(int penalty) {
        this.presencePenalty = penalty;
        return this;
    }

    /**
     * Set stop sequences
     */
    ChatRequestBuilder setStopSequences(string[] stops) {
        this.stopSequences = stops.dup;
        return this;
    }

    /**
     * Set user identifier
     */
    ChatRequestBuilder setUser(string user) {
        this.user = user;
        return this;
    }

    /**
     * Build the request JSON
     */
    JSONValue build() {
        JSONValue request;

        // Required fields
        request["model"] = model;
        request["messages"] = messages.map!(msg => msg.toJSON()).array;

        // Optional fields (only include if different from defaults)
        if (temperature != 0.7) request["temperature"] = temperature;
        if (maxTokens != 1000) request["max_tokens"] = maxTokens;
        if (topP != 1.0) request["top_p"] = topP;
        if (frequencyPenalty != 0) request["frequency_penalty"] = frequencyPenalty;
        if (presencePenalty != 0) request["presence_penalty"] = presencePenalty;
        if (!stopSequences.empty) request["stop"] = stopSequences;
        if (!user.empty) request["user"] = user;

        return request;
    }

    /**
     * Validate the request
     */
    bool validate(out string error) {
        if (model.empty) {
            error = "Model is required";
            return false;
        }

        if (messages.empty) {
            error = "At least one message is required";
            return false;
        }

        if (messages[0].role != "system" && messages[0].role != "user") {
            error = "First message should be from system or user";
            return false;
        }

        if (temperature < 0.0 || temperature > 2.0) {
            error = "Temperature must be between 0.0 and 2.0";
            return false;
        }

        if (maxTokens < 1 || maxTokens > 4096) {
            error = "Max tokens must be between 1 and 4096";
            return false;
        }

        if (topP < 0.0 || topP > 1.0) {
            error = "Top-p must be between 0.0 and 1.0";
            return false;
        }

        error = "";
        return true;
    }

    /**
     * Reset the builder
     */
    void reset() {
        model = "gpt-3.5-turbo";
        messages = [];
        temperature = 0.7;
        maxTokens = 1000;
        topP = 1.0;
        frequencyPenalty = 0;
        presencePenalty = 0;
        stopSequences = [];
        user = "";
    }
}

/**
 * Request template system
 */
class RequestTemplate {
    private string name;
    private string description;
    private ChatRequestBuilder function(ChatRequestBuilder) templateFunc;

    this(string name, string description,
         ChatRequestBuilder function(ChatRequestBuilder) templateFunc) {
        this.name = name;
        this.description = description;
        this.templateFunc = templateFunc;
    }

    /**
     * Apply template to a builder
     */
    ChatRequestBuilder apply(ChatRequestBuilder builder) {
        return templateFunc(builder);
    }

    /**
     * Get template info
     */
    string getName() { return name; }
    string getDescription() { return description; }
}

/**
 * Template registry
 */
class TemplateRegistry {
    private RequestTemplate[string] templates;

    /**
     * Register a template
     */
    void register(RequestTemplate template_) {
        templates[template_.getName()] = template_;
    }

    /**
     * Get a template by name
     */
    RequestTemplate getTemplate(string name) {
        return templates.get(name, null);
    }

    /**
     * List all templates
     */
    string[] listTemplates() {
        return templates.keys;
    }

    /**
     * Apply a template by name
     */
    ChatRequestBuilder applyTemplate(string name, ChatRequestBuilder builder) {
        auto template_ = getTemplate(name);
        if (template_ is null) {
            throw new Exception("Template not found: " ~ name);
        }
        return template_.apply(builder);
    }
}

/**
 * Demonstrate basic request building
 */
void demonstrateBasicRequestBuilding() {
    writeln("=== Basic Request Building ===");

    auto builder = new ChatRequestBuilder();

    // Build a simple request
    JSONValue request = builder
        .addSystemMessage("You are a helpful assistant.")
        .addUserMessage("What is the capital of France?")
        .setTemperature(0.5)
        .setMaxTokens(100)
        .build();

    writefln("Simple chat request:");
    writefln("%s", request.toPrettyString());

    // Validate the request
    string error;
    if (builder.validate(error)) {
        writefln("✓ Request is valid");
    } else {
        writefln("✗ Request validation failed: %s", error);
    }
}

/**
 * Demonstrate conversation building
 */
void demonstrateConversationBuilding() {
    writeln("\n=== Conversation Building ===");

    auto builder = new ChatRequestBuilder();

    // Build a conversation
    JSONValue conversationRequest = builder
        .addSystemMessage("You are a helpful programming assistant.")
        .addUserMessage("How do I declare a variable in D?")
        .addAssistantMessage("In D, you can declare a variable using the syntax: 'type variableName;' for example: 'int x;'")
        .addUserMessage("How about arrays?")
        .setModel("gpt-4")
        .setTemperature(0.3)
        .build();

    writefln("Conversation request:");
    writefln("%s", conversationRequest.toPrettyString());

    writefln("Conversation flow:");
    JSONValue[] messages = conversationRequest["messages"].array;
    foreach (i, msg; messages) {
        writefln("%d. %s: %s", i + 1, msg["role"].str, msg["content"].str);
    }
}

/**
 * Demonstrate request templates
 */
void demonstrateRequestTemplates() {
    writeln("\n=== Request Templates ===");

    auto registry = new TemplateRegistry();

    // Register some templates
    registry.register(new RequestTemplate(
        "coding-assistant",
        "Template for coding assistance",
        (ChatRequestBuilder builder) {
            return builder
                .setModel("gpt-4")
                .addSystemMessage("You are an expert D programming language assistant. Provide clear, correct, and well-documented code examples.")
                .setTemperature(0.2)
                .setMaxTokens(2000);
        }
    ));

    registry.register(new RequestTemplate(
        "creative-writing",
        "Template for creative writing assistance",
        (ChatRequestBuilder builder) {
            return builder
                .setModel("gpt-3.5-turbo")
                .addSystemMessage("You are a creative writing assistant. Help with stories, poems, and literary analysis.")
                .setTemperature(0.9)
                .setMaxTokens(1500);
        }
    ));

    registry.register(new RequestTemplate(
        "concise-qa",
        "Template for concise question answering",
        (ChatRequestBuilder builder) {
            return builder
                .setModel("gpt-3.5-turbo")
                .addSystemMessage("You are a helpful assistant. Provide clear, concise answers to questions.")
                .setTemperature(0.1)
                .setMaxTokens(500);
        }
    ));

    writefln("Available templates:");
    foreach (templateName; registry.listTemplates()) {
        auto template_ = registry.getTemplate(templateName);
        writefln("• %s: %s", template_.getName(), template_.getDescription());
    }

    // Apply a template
    writefln("\nApplying 'coding-assistant' template:");
    auto builder = new ChatRequestBuilder();
    builder = registry.applyTemplate("coding-assistant", builder);
    builder.addUserMessage("How do I implement a binary search in D?");

    JSONValue templatedRequest = builder.build();
    writefln("%s", templatedRequest.toPrettyString());
}

/**
 * Demonstrate parameter validation
 */
void demonstrateParameterValidation() {
    writeln("\n=== Parameter Validation ===");

    struct ValidationTest {
        string description;
        ChatRequestBuilder function(ChatRequestBuilder) setup;
        bool shouldBeValid;
    }

    ValidationTest[] tests = [
        {
            "Valid request",
            (ChatRequestBuilder b) => b.addUserMessage("Hello").setTemperature(0.5),
            true
        },
        {
            "Missing messages",
            (ChatRequestBuilder b) => b,
            false
        },
        {
            "Invalid temperature (too high)",
            (ChatRequestBuilder b) => b.addUserMessage("Hello").setTemperature(2.5),
            false
        },
        {
            "Invalid temperature (negative)",
            (ChatRequestBuilder b) => b.addUserMessage("Hello").setTemperature(-0.5),
            false
        },
        {
            "Invalid max tokens (too high)",
            (ChatRequestBuilder b) => b.addUserMessage("Hello").setMaxTokens(5000),
            false
        },
        {
            "Invalid max tokens (zero)",
            (ChatRequestBuilder b) => b.addUserMessage("Hello").setMaxTokens(0),
            false
        }
    ];

    foreach (test; tests) {
        auto builder = new ChatRequestBuilder();
        builder = test.setup(builder);

        string error;
        bool isValid = builder.validate(error);

        string status = (isValid == test.shouldBeValid) ? "✓" : "✗";
        writefln("%s %s: %s", status, test.description,
                isValid ? "Valid" : "Invalid (" ~ error ~ ")");
    }
}

/**
 * Demonstrate advanced request features
 */
void demonstrateAdvancedFeatures() {
    writeln("\n=== Advanced Request Features ===");

    auto builder = new ChatRequestBuilder();

    // Build a complex request with all features
    JSONValue advancedRequest = builder
        .setModel("gpt-4")
        .addSystemMessage("You are a technical documentation writer.")
        .addUserMessage("Explain how neural networks work.")
        .setTemperature(0.3)      // More focused
        .setMaxTokens(2000)       // Longer response
        .setTopP(0.9)            // Some diversity
        .setFrequencyPenalty(1)   // Reduce repetition
        .setPresencePenalty(1)    // Encourage new topics
        .setStopSequences(["##", "---"])  // Custom stop sequences
        .setUser("doc-writer-123")  // User identifier
        .build();

    writefln("Advanced request with all parameters:");
    writefln("%s", advancedRequest.toPrettyString());

    writefln("Parameter explanations:");
    writefln("• temperature: 0.3 - Lower values make output more focused");
    writefln("• max_tokens: 2000 - Allow longer responses");
    writefln("• top_p: 0.9 - Nucleus sampling for quality");
    writefln("• frequency_penalty: 1 - Reduce repetitive text");
    writefln("• presence_penalty: 1 - Encourage topic diversity");
    writefln("• stop: Custom sequences to end generation");
    writefln("• user: Identifier for tracking/rate limiting");
}

/**
 * Check if request builder functionality works
 */
bool testRequestBuilderCapability() {
    try {
        // Test basic building
        auto builder = new ChatRequestBuilder();
        builder.addUserMessage("Test message");
        JSONValue request = builder.build();

        assert(request["model"].str == "gpt-3.5-turbo");
        assert(request["messages"].array.length == 1);
        assert(request["messages"][0]["role"].str == "user");
        assert(request["messages"][0]["content"].str == "Test message");

        // Test validation
        string error;
        assert(builder.validate(error));

        // Test template system
        auto registry = new TemplateRegistry();
        registry.register(new RequestTemplate(
            "test",
            "Test template",
            (ChatRequestBuilder b) => b.setModel("gpt-4")
        ));

        auto templated = registry.applyTemplate("test", new ChatRequestBuilder());
        JSONValue templatedRequest = templated.build();
        assert(templatedRequest["model"].str == "gpt-4");

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the request builders example
 */
void runExample() {
    writeln("=== Request Builders Demonstration ===\n");

    if (!testRequestBuilderCapability()) {
        writeln("ERROR: Request builder functionality test failed!");
        return;
    }

    writeln("✓ Request builder functionality confirmed\n");

    demonstrateBasicRequestBuilding();
    demonstrateConversationBuilding();
    demonstrateRequestTemplates();
    demonstrateParameterValidation();
    demonstrateAdvancedFeatures();

    writeln("\n=== Summary ===");
    writeln("• Use ChatRequestBuilder for structured API requests");
    writeln("• Add system, user, and assistant messages appropriately");
    writeln("• Set model and parameters based on use case");
    writeln("• Use templates for common request patterns");
    writeln("• Always validate requests before sending");
    writeln("• Balance temperature and other parameters for desired output");
    writeln("• Include user identifiers for tracking when appropriate");
}

unittest {
    writeln("=== Running request_builders tests ===");

    // Test message structure
    auto userMsg = Message.user("Hello");
    assert(userMsg.role == "user");
    assert(userMsg.content == "Hello");

    auto systemMsg = Message.system("You are helpful");
    assert(systemMsg.role == "system");

    auto assistantMsg = Message.assistant("Hi there");
    assert(assistantMsg.role == "assistant");

    // Test JSON conversion
    JSONValue jsonMsg = userMsg.toJSON();
    assert(jsonMsg["role"].str == "user");
    assert(jsonMsg["content"].str == "Hello");
    writeln("✓ Message structure works");

    // Test request builder
    auto builder = new ChatRequestBuilder();
    builder.addSystemMessage("System prompt")
           .addUserMessage("User question")
           .setTemperature(0.5)
           .setMaxTokens(100);

    JSONValue request = builder.build();
    assert(request["model"].str == "gpt-3.5-turbo");
    assert(request["messages"].array.length == 2);
    assert(request["temperature"].floating == 0.5);
    assert(request["max_tokens"].integer == 100);
    writeln("✓ Request builder works");

    // Test validation
    string error;
    assert(builder.validate(error));

    // Test invalid request
    auto invalidBuilder = new ChatRequestBuilder();
    assert(!invalidBuilder.validate(error));
    assert(error.canFind("message"));
    writeln("✓ Validation works");

    // Test template system
    auto registry = new TemplateRegistry();
    auto template_ = new RequestTemplate(
        "test-template",
        "Test description",
        (ChatRequestBuilder b) => b.setModel("gpt-4").setTemperature(0.1)
    );

    registry.register(template_);
    assert(registry.getTemplate("test-template") !is null);
    assert(registry.listTemplates().length == 1);

    auto applied = registry.applyTemplate("test-template", new ChatRequestBuilder());
    JSONValue templatedRequest = applied.build();
    assert(templatedRequest["model"].str == "gpt-4");
    assert(templatedRequest["temperature"].floating == 0.1);
    writeln("✓ Template system works");

    writeln("All request_builders tests passed!");
    writeln("=== request_builders tests completed ===");
}
