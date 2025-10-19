/**
 * Lesson 10: Complete Chat Application - A full-featured chat application with LLM
 *
 * This example demonstrates a complete console-based chat application that integrates
 * all the concepts learned throughout the course: HTTP requests, JSON handling,
 * conversation management, logging, error handling, and more.
 */

module lesson10.chat_application;

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.json;
import std.net.curl;
import std.file;
import std.path;
import std.datetime;
import std.process;
import std.random;
import std.getopt;
import core.stdc.stdlib : exit;

/**
 * Import our custom modules
 */
import lesson10.request_builders;
import lesson10.response_parsers;
import lesson10.conversation_management;
import lesson10.logging;

/**
 * Chat application configuration
 */
struct ChatConfig {
    string apiKey;
    string apiBaseUrl = "https://api.openai.com/v1";
    string model = "gpt-3.5-turbo";
    double temperature = 0.7;
    int maxTokens = 1000;
    string systemPrompt = "You are a helpful AI assistant.";
    string conversationsDir = "conversations";
    LogLevel logLevel = LogLevel.INFO;
    bool verbose = false;
}

/**
 * Chat application main class
 */
class ChatApplication {
    private ChatConfig config;
    private ConversationManager convManager;
    private ChatLogger chatLogger;
    private ResponseParser responseParser;
    private Conversation currentConversation;
    private bool running = true;

    this(ChatConfig config) {
        this.config = config;

        // Initialize components
        convManager = new ConversationManager(config.conversationsDir);

        // Setup logging
        auto consoleLogger = new ConsoleLogger(config.logLevel);
        chatLogger = new ChatLogger(consoleLogger, "chat-app-" ~ getCurrentTimestamp().to!string);

        responseParser = new ResponseParser();

        // Load or create default conversation
        currentConversation = convManager.createConversation("Chat Session");
        currentConversation.addSystemMessage(config.systemPrompt);

        chatLogger.logConversationEvent(currentConversation.getId(), "started");
    }

    /**
     * Run the chat application
     */
    void run() {
        writefln("🤖 D LLM Chat Application");
        writefln("Type 'help' for commands, 'quit' to exit");
        writefln("Model: %s", config.model);
        writefln("System: %s", config.systemPrompt);
        writeln();

        while (running) {
            write("> ");
            string input = readln().strip();

            if (input.empty) continue;

            try {
                processCommand(input);
            } catch (Exception e) {
                writefln("❌ Error: %s", e.msg);
                chatLogger.logError(currentConversation.getId(), e.msg, "command_processing");
            }
        }

        // Save conversations on exit
        convManager.saveAll();
        chatLogger.logConversationEvent(currentConversation.getId(), "ended");
    }

    /**
     * Process user input commands
     */
    private void processCommand(string input) {
        auto parts = input.split();
        string command = parts[0].toLower();
        string[] args = parts[1..$];

        switch (command) {
            case "help", "h", "?":
                showHelp();
                break;

            case "quit", "q", "exit":
                running = false;
                break;

            case "send", "s":
                if (args.length == 0) {
                    writefln("❌ Usage: send <message>");
                } else {
                    sendMessage(args.join(" "));
                }
                break;

            case "list", "l":
                listConversations();
                break;

            case "switch", "sw":
                if (args.length == 0) {
                    writefln("❌ Usage: switch <conversation_id>");
                } else {
                    switchConversation(args[0]);
                }
                break;

            case "new", "n":
                string title = args.length > 0 ? args.join(" ") : "";
                newConversation(title);
                break;

            case "delete", "del", "d":
                if (args.length == 0) {
                    writefln("❌ Usage: delete <conversation_id>");
                } else {
                    deleteConversation(args[0]);
                }
                break;

            case "info", "i":
                showConversationInfo();
                break;

            case "clear", "c":
                clearConversation();
                break;

            case "history", "hist":
                showHistory(args.length > 0 ? to!int(args[0]) : 10);
                break;

            case "model", "m":
                if (args.length == 0) {
                    writefln("Current model: %s", config.model);
                } else {
                    config.model = args[0];
                    writefln("✅ Model set to: %s", config.model);
                }
                break;

            case "temp", "t":
                if (args.length == 0) {
                    writefln("Current temperature: %.1f", config.temperature);
                } else {
                    try {
                        config.temperature = to!double(args[0]);
                        writefln("✅ Temperature set to: %.1f", config.temperature);
                    } catch (Exception) {
                        writefln("❌ Invalid temperature value");
                    }
                }
                break;

            case "system", "sys":
                if (args.length == 0) {
                    writefln("Current system prompt: %s", config.systemPrompt);
                } else {
                    config.systemPrompt = args.join(" ");
                    currentConversation.addSystemMessage(config.systemPrompt);
                    writefln("✅ System prompt updated");
                }
                break;

            default:
                // If not a command, treat as a message to send
                if (!input.startsWith("/")) {
                    sendMessage(input);
                } else {
                    writefln("❌ Unknown command: %s", command);
                    writefln("Type 'help' for available commands");
                }
                break;
        }
    }

    /**
     * Send a message to the LLM
     */
    private void sendMessage(string message) {
        if (config.apiKey.empty) {
            writefln("❌ No API key configured. Please set OPENAI_API_KEY environment variable.");
            return;
        }

        writefln("🤔 Thinking...");
        auto startTime = MonoTime.currTime;

        try {
            // Build request
            auto builder = new ChatRequestBuilder();
            builder.setModel(config.model);
            builder.setTemperature(config.temperature);
            builder.setMaxTokens(config.maxTokens);

            // Add conversation history
            foreach (msg; currentConversation.getMessages()) {
                if (msg.role == "user") {
                    builder.addUserMessage(msg.content);
                } else if (msg.role == "assistant") {
                    builder.addAssistantMessage(msg.content);
                }
            }

            // Add current message
            builder.addUserMessage(message);

            JSONValue requestJson = builder.build();

            // Log request
            chatLogger.logRequest(currentConversation.getId(), requestJson);

            // Make API call
            auto http = HTTP(config.apiBaseUrl ~ "/chat/completions");
            http.addRequestHeader("Authorization", "Bearer " ~ config.apiKey);
            http.addRequestHeader("Content-Type", "application/json");

            string responseBody;
            http.onReceive = (ubyte[] data) {
                responseBody ~= cast(string)data;
                return data.length;
            };

            http.perform();

            auto endTime = MonoTime.currTime;
            auto responseTime = endTime - startTime;

            // Parse response
            ChatResponse response = responseParser.parseResponse(responseBody);

            if (response.hasError()) {
                writefln("❌ API Error: %s", response.error);
                chatLogger.logError(currentConversation.getId(), response.error, "api_call");
                return;
            }

            // Log response
            JSONValue responseJson = parseJSON(responseBody);
            chatLogger.logResponse(currentConversation.getId(), responseJson, responseTime);

            // Display response
            string assistantMessage = response.getText();
            writefln("🤖 %s", assistantMessage);

            // Add to conversation
            currentConversation.addUserMessage(message);
            currentConversation.addAssistantMessage(assistantMessage);

            // Log performance
            JSONValue perfData = JSONValue([
                "model": JSONValue(config.model),
                "tokens": JSONValue(response.usage.totalTokens),
                "responseTime": JSONValue(responseTime.total!"msecs")
            ]);
            chatLogger.logPerformance("chat_completion", responseTime, perfData);

        } catch (CurlException e) {
            auto endTime = MonoTime.currTime;
            auto responseTime = endTime - startTime;

            writefln("❌ Network error: %s", e.msg);
            chatLogger.logError(currentConversation.getId(), e.msg, "network");

        } catch (Exception e) {
            auto endTime = MonoTime.currTime;
            auto responseTime = endTime - startTime;

            writefln("❌ Unexpected error: %s", e.msg);
            chatLogger.logError(currentConversation.getId(), e.msg, "unexpected");
        }
    }

    /**
     * Show help information
     */
    private void showHelp() {
        writefln("📚 Available Commands:");
        writefln("  help, h, ?          Show this help");
        writefln("  quit, q, exit       Exit the application");
        writefln("  send <msg>, s <msg> Send a message to the LLM");
        writefln("  list, l             List all conversations");
        writefln("  switch <id>, sw <id> Switch to conversation");
        writefln("  new [title], n [title] Create new conversation");
        writefln("  delete <id>, del <id>, d <id> Delete conversation");
        writefln("  info, i             Show current conversation info");
        writefln("  clear, c            Clear current conversation");
        writefln("  history [n], hist [n] Show last n messages");
        writefln("  model [m], m [m]    Get/set model");
        writefln("  temp [t], t [t]     Get/set temperature");
        writefln("  system [prompt], sys [prompt] Get/set system prompt");
        writefln("Simply type a message to chat with the LLM!");
    }

    /**
     * List all conversations
     */
    private void listConversations() {
        auto conversations = convManager.listConversations();

        if (conversations.empty) {
            writefln("📭 No conversations found");
            return;
        }

        writefln("📁 Conversations (%d total):", conversations.length);
        foreach (conv; conversations) {
            string indicator = (conv.getId() == currentConversation.getId()) ? "→" : " ";
            writefln("  %s %s: %s (%d messages)",
                    indicator, conv.getId(), conv.getTitle(), conv.getMessageCount());
        }
    }

    /**
     * Switch to a different conversation
     */
    private void switchConversation(string convId) {
        auto conv = convManager.getConversation(convId);
        if (conv is null) {
            writefln("❌ Conversation not found: %s", convId);
            return;
        }

        currentConversation = conv;
        writefln("✅ Switched to conversation: %s", conv.getTitle());
        chatLogger.logConversationEvent(convId, "switched_to");
    }

    /**
     * Create a new conversation
     */
    private void newConversation(string title = "") {
        if (title.empty) {
            title = format("Conversation %d", convManager.listConversations().length + 1);
        }

        auto newConv = convManager.createConversation(title);
        newConv.addSystemMessage(config.systemPrompt);
        currentConversation = newConv;

        writefln("✅ Created new conversation: %s", title);
        chatLogger.logConversationEvent(newConv.getId(), "created");
    }

    /**
     * Delete a conversation
     */
    private void deleteConversation(string convId) {
        if (convId == currentConversation.getId()) {
            writefln("❌ Cannot delete current conversation");
            return;
        }

        if (convManager.deleteConversation(convId)) {
            writefln("✅ Deleted conversation: %s", convId);
        } else {
            writefln("❌ Conversation not found: %s", convId);
        }
    }

    /**
     * Show current conversation info
     */
    private void showConversationInfo() {
        writefln("📋 Current Conversation:");
        writefln("%s", currentConversation.getInfo());
    }

    /**
     * Clear current conversation
     */
    private void clearConversation() {
        auto convId = currentConversation.getId();
        auto title = currentConversation.getTitle();

        // Create new conversation with same title
        auto newConv = convManager.createConversation(title);
        newConv.addSystemMessage(config.systemPrompt);

        // Remove old conversation
        convManager.deleteConversation(convId);

        currentConversation = newConv;
        writefln("✅ Cleared conversation history");
        chatLogger.logConversationEvent(newConv.getId(), "cleared");
    }

    /**
     * Show conversation history
     */
    private void showHistory(int count) {
        auto messages = currentConversation.getMessages();

        if (messages.empty) {
            writefln("📭 No messages in conversation");
            return;
        }

        writefln("📜 Last %d messages:", min(count, messages.length));

        auto start = max(0, cast(int)messages.length - count);
        for (int i = start; i < messages.length; i++) {
            auto msg = messages[i];
            string roleIcon = msg.role == "user" ? "👤" : "🤖";
            writefln("%s %s: %s", roleIcon, msg.role.capitalize(), msg.content);
        }
    }

    private long getCurrentTimestamp() {
        return Clock.currTime.toUnixTime();
    }
}

/**
 * Parse command line arguments
 */
ChatConfig parseArguments(string[] args) {
    ChatConfig config;

    // Get API key from environment
    config.apiKey = environment.get("OPENAI_API_KEY", "");

    // Parse command line options
    auto helpInfo = getopt(
        args,
        "model|m", "Model to use", &config.model,
        "temperature|t", "Temperature setting", &config.temperature,
        "max-tokens", "Maximum tokens", &config.maxTokens,
        "system-prompt", "System prompt", &config.systemPrompt,
        "conversations-dir", "Conversations directory", &config.conversationsDir,
        "verbose|v", "Verbose logging", &config.verbose,
        "api-url", "API base URL", &config.apiBaseUrl
    );

    if (helpInfo.helpWanted) {
        defaultGetoptPrinter("D LLM Chat Application", helpInfo.options);
        exit(0);
    }

    // Set log level based on verbose flag
    config.logLevel = config.verbose ? LogLevel.DEBUG : LogLevel.INFO;

    return config;
}

/**
 * Main application entry point
 */
void runChatApplication(string[] args) {
    auto config = parseArguments(args);

    if (config.apiKey.empty) {
        writefln("❌ Error: OPENAI_API_KEY environment variable not set");
        writefln("Please set your OpenAI API key:");
        writefln("  export OPENAI_API_KEY=your-api-key-here");
        return;
    }

    try {
        auto app = new ChatApplication(config);
        app.run();
    } catch (Exception e) {
        writefln("❌ Fatal error: %s", e.msg);
    }
}

/**
 * Demonstrate the chat application (limited demo)
 */
void demonstrateChatApplication() {
    writeln("=== Chat Application Demonstration ===");

    // Create config for demo (without real API key)
    ChatConfig config;
    config.apiKey = "demo-key"; // Won't work for real API calls
    config.model = "gpt-3.5-turbo";
    config.systemPrompt = "You are a helpful AI assistant for demonstrations.";

    writefln("Chat Application Configuration:");
    writefln("• Model: %s", config.model);
    writefln("• Temperature: %.1f", config.temperature);
    writefln("• Max Tokens: %d", config.maxTokens);
    writefln("• System Prompt: %s", config.systemPrompt);
    writefln("• Conversations Directory: %s", config.conversationsDir);

    writefln("\nThis is a demonstration. To run the full application:");
    writefln("1. Set your OPENAI_API_KEY environment variable");
    writefln("2. Run: dub run -- lesson10.chat_application");
    writefln("3. Type messages or use commands (help for list)");
    writefln("4. Type 'quit' to exit");

    writefln("\nExample commands:");
    writefln("• Hello, how are you?");
    writefln("• /model gpt-4");
    writefln("• /temp 0.5");
    writefln("• /new My New Chat");
    writefln("• /list");
    writefln("• /quit");
}

/**
 * Check if chat application components work
 */
bool testChatApplicationCapability() {
    try {
        // Test configuration parsing
        ChatConfig config;
        config.apiKey = "test-key";
        assert(config.apiKey == "test-key");

        // Test conversation manager (in memory)
        auto convManager = new ConversationManager("nonexistent_dir");
        auto conv = convManager.createConversation("Test");
        assert(conv !is null);
        assert(conv.getTitle() == "Test");

        // Test request builder
        auto builder = new ChatRequestBuilder();
        builder.addUserMessage("Test message");
        JSONValue request = builder.build();
        assert(request["messages"].array.length == 1);

        // Test response parser
        auto parser = new ResponseParser();
        string testResponse = `{"id": "test", "choices": [{"message": {"content": "OK"}}]}`;
        auto response = parser.parseResponse(testResponse);
        assert(response.getText() == "OK");

        // Test logging
        auto logger = new ConsoleLogger(LogLevel.ERROR); // Only errors
        auto chatLogger = new ChatLogger(logger);
        chatLogger.logError("test-conv", "Test error");

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the chat application example
 */
void runExample() {
    writeln("=== Complete Chat Application Demonstration ===\n");

    if (!testChatApplicationCapability()) {
        writeln("ERROR: Chat application functionality test failed!");
        return;
    }

    writeln("✓ Chat application functionality confirmed\n");

    // Run demonstration instead of full application
    // (since it requires API key and user interaction)
    demonstrateChatApplication();

    writeln("\n=== Summary ===");
    writeln("• Complete chat application integrating all course concepts");
    writeln("• Command-line interface with rich commands");
    writeln("• Conversation management with persistence");
    writeln("• Comprehensive logging and error handling");
    writeln("• Configurable model parameters and settings");
    writeln("• Request building and response parsing");
    writeln("• Real-time chat with OpenAI-compatible APIs");
    writeln("• History management and conversation switching");
}

unittest {
    writeln("=== Running chat_application tests ===");

    // Test configuration
    ChatConfig config;
    config.apiKey = "test-key-123";
    config.model = "gpt-4";
    config.temperature = 0.8;
    assert(config.apiKey == "test-key-123");
    assert(config.model == "gpt-4");
    assert(config.temperature == 0.8);
    writeln("✓ Configuration structure works");

    // Test conversation manager
    auto convManager = new ConversationManager("test_convs");
    auto conv = convManager.createConversation("Test Conversation");
    assert(conv !is null);
    assert(conv.getTitle() == "Test Conversation");
    assert(convManager.getConversation(conv.getId()) !is null);
    assert(convManager.listConversationIds().canFind(conv.getId()));
    writeln("✓ Conversation manager works");

    // Test request builder integration
    auto builder = new ChatRequestBuilder();
    builder.setModel("test-model");
    builder.addSystemMessage("Test system");
    builder.addUserMessage("Test user");
    builder.addAssistantMessage("Test assistant");

    JSONValue request = builder.build();
    assert(request["model"].str == "test-model");
    assert(request["messages"].array.length == 3);
    writeln("✓ Request builder integration works");

    // Test response parser integration
    auto parser = new ResponseParser();
    string mockResponse = `{
        "id": "test-123",
        "object": "chat.completion",
        "created": 1640995200,
        "model": "test-model",
        "choices": [{
            "index": 0,
            "message": {"role": "assistant", "content": "Parsed successfully"},
            "finish_reason": "stop"
        }],
        "usage": {"prompt_tokens": 10, "completion_tokens": 5, "total_tokens": 15}
    }`;

    auto response = parser.parseResponse(mockResponse);
    assert(response.id == "test-123");
    assert(response.getText() == "Parsed successfully");
    assert(response.usage.totalTokens == 15);
    assert(!response.hasError());
    writeln("✓ Response parser integration works");

    // Test logging integration
    auto logger = new ConsoleLogger(LogLevel.ERROR);
    auto chatLogger = new ChatLogger(logger, "test-session");
    chatLogger.logError("test-conv", "Test error message");
    assert(logger.getEntries().length == 1);
    writeln("✓ Logging integration works");

    // Test conversation operations
    conv.addUserMessage("Hello");
    conv.addAssistantMessage("Hi there");
    assert(conv.getMessageCount() == 2);

    auto apiMessages = conv.getMessagesForAPI();
    assert(apiMessages.length == 2); // 2 messages (no system prompt)
    assert(apiMessages[0].role == "user");
    assert(apiMessages[1].role == "assistant");
    writeln("✓ Conversation operations work");

    // Cleanup
    try {
        if (exists("test_convs")) {
            rmdirRecurse("test_convs");
        }
    } catch (Exception) {}

    writeln("All chat_application tests passed!");
    writeln("=== chat_application tests completed ===");
}
