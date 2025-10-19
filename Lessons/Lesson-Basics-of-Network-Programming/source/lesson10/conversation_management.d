/**
 * Lesson 10: Conversation Management - Managing chat conversations with LLMs
 *
 * This example demonstrates how to manage conversation state, maintain context,
 * handle conversation history, and implement conversation persistence.
 */

module lesson10.conversation_management;

import std.stdio;
import std.json;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.file;
import std.path;

/**
 * Message structure for conversations
 */
struct Message {
    string role;    // "system", "user", "assistant"
    string content;
    long timestamp; // Unix timestamp

    /**
     * Create a JSON representation
     */
    JSONValue toJSON() const {
        JSONValue json;
        json["role"] = role;
        json["content"] = content;
        json["timestamp"] = timestamp;
        return json;
    }

    /**
     * Create from JSON
     */
    static Message fromJSON(JSONValue json) {
        return Message(
            json["role"].str,
            json["content"].str,
            json["timestamp"].integer
        );
    }

    /**
     * Get formatted timestamp string
     */
    string getTimestampString() const {
        import std.datetime;
        auto dt = SysTime.fromUnixTime(timestamp);
        return dt.toSimpleString();
    }
}

/**
 * Conversation class
 */
class Conversation {
    private string id;
    private string title;
    private Message[] messages;
    private long created;
    private long lastModified;
    private string systemPrompt;
    private int maxMessages = 100; // Prevent unlimited growth

    this(string id = "", string title = "") {
        this.id = id.empty ? generateId() : id;
        this.title = title.empty ? "New Conversation" : title;
        this.created = getCurrentTimestamp();
        this.lastModified = this.created;
    }

    /**
     * Add a user message
     */
    void addUserMessage(string content) {
        addMessage("user", content);
    }

    /**
     * Add an assistant message
     */
    void addAssistantMessage(string content) {
        addMessage("assistant", content);
    }

    /**
     * Add a system message
     */
    void addSystemMessage(string content) {
        systemPrompt = content;
        // Don't add to messages array, system prompt is handled separately
    }

    /**
     * Add a message
     */
    private void addMessage(string role, string content) {
        auto message = Message(role, content, getCurrentTimestamp());
        messages ~= message;
        lastModified = getCurrentTimestamp();

        // Trim old messages if we exceed the limit
        if (messages.length > maxMessages) {
            // Keep system messages and most recent messages
            messages = messages[$ - maxMessages .. $];
        }
    }

    /**
     * Get all messages for API request (including system prompt)
     */
    Message[] getMessagesForAPI() {
        Message[] apiMessages;

        // Add system prompt first if it exists
        if (!systemPrompt.empty) {
            apiMessages ~= Message("system", systemPrompt, created);
        }

        // Add conversation messages
        apiMessages ~= messages;

        return apiMessages;
    }

    /**
     * Get conversation summary
     */
    string getSummary() {
        if (messages.empty) {
            return "Empty conversation";
        }

        string firstMessage = messages[0].content;
        if (firstMessage.length > 50) {
            firstMessage = firstMessage[0..47] ~ "...";
        }

        return format("%d messages, started: %s",
                     messages.length,
                     messages[0].getTimestampString());
    }

    /**
     * Get conversation info
     */
    string getInfo() {
        return format("ID: %s\nTitle: %s\nCreated: %s\nMessages: %d\nLast Modified: %s",
                     id, title, getTimestampString(created),
                     messages.length, getTimestampString(lastModified));
    }

    /**
     * Export conversation to JSON
     */
    JSONValue toJSON() {
        JSONValue json;
        json["id"] = id;
        json["title"] = title;
        json["created"] = created;
        json["lastModified"] = lastModified;
        json["systemPrompt"] = systemPrompt;
        json["maxMessages"] = maxMessages;

        JSONValue[] messageArray;
        foreach (msg; messages) {
            messageArray ~= msg.toJSON();
        }
        json["messages"] = messageArray;

        return json;
    }

    /**
     * Import conversation from JSON
     */
    static Conversation fromJSON(JSONValue json) {
        auto conv = new Conversation(json["id"].str, json["title"].str);
        conv.created = json["created"].integer;
        conv.lastModified = json["lastModified"].integer;
        conv.systemPrompt = json["systemPrompt"].str;
        conv.maxMessages = cast(int)json["maxMessages"].integer;

        foreach (msgJson; json["messages"].array) {
            conv.messages ~= Message.fromJSON(msgJson);
        }

        return conv;
    }

    // Getters
    string getId() { return id; }
    string getTitle() { return title; }
    int getMessageCount() { return cast(int)messages.length; }
    Message[] getMessages() { return messages.dup; }
    long getLastModified() { return lastModified; }

    // Setters
    void setTitle(string title) {
        this.title = title;
        lastModified = getCurrentTimestamp();
    }

    private long getCurrentTimestamp() {
        import std.datetime;
        return Clock.currTime.toUnixTime();
    }

    private string generateId() {
        import std.uuid;
        return randomUUID().toString();
    }

    private string getTimestampString(long timestamp) {
        import std.datetime;
        auto dt = SysTime.fromUnixTime(timestamp);
        return dt.toSimpleString();
    }
}

/**
 * Conversation manager
 */
class ConversationManager {
    private Conversation[string] conversations;
    private string storagePath = "conversations";

    this(string storagePath = "conversations") {
        this.storagePath = storagePath;

        // Create storage directory if it doesn't exist
        if (!exists(storagePath)) {
            try {
                mkdirRecurse(storagePath);
            } catch (Exception e) {
                writefln("Warning: Could not create storage directory: %s", e.msg);
            }
        }

        loadConversations();
    }

    /**
     * Create a new conversation
     */
    Conversation createConversation(string title = "") {
        auto conv = new Conversation("", title);
        conversations[conv.getId()] = conv;
        saveConversation(conv);
        return conv;
    }

    /**
     * Get a conversation by ID
     */
    Conversation getConversation(string id) {
        return conversations.get(id, null);
    }

    /**
     * List all conversation IDs
     */
    string[] listConversationIds() {
        return conversations.keys;
    }

    /**
     * List conversations with summaries
     */
    Conversation[] listConversations() {
        return conversations.values;
    }

    /**
     * Delete a conversation
     */
    bool deleteConversation(string id) {
        if (id in conversations) {
            conversations.remove(id);

            // Delete file
            string filename = buildPath(storagePath, id ~ ".json");
            if (exists(filename)) {
                try {
                    remove(filename);
                } catch (Exception e) {
                    writefln("Warning: Could not delete file %s: %s", filename, e.msg);
                }
            }

            return true;
        }
        return false;
    }

    /**
     * Save a conversation
     */
    private void saveConversation(Conversation conv) {
        try {
            string filename = buildPath(storagePath, conv.getId() ~ ".json");
            JSONValue json = conv.toJSON();
            std.file.write(filename, json.toPrettyString());
        } catch (Exception e) {
            writefln("Error saving conversation %s: %s", conv.getId(), e.msg);
        }
    }

    /**
     * Load conversations from disk
     */
    private void loadConversations() {
        try {
            if (!exists(storagePath) || !isDir(storagePath)) {
                return;
            }

            foreach (DirEntry entry; dirEntries(storagePath, "*.json", SpanMode.shallow)) {
                try {
                    string content = readText(entry.name);
                    JSONValue json = parseJSON(content);
                    auto conv = Conversation.fromJSON(json);
                    conversations[conv.getId()] = conv;
                } catch (Exception e) {
                    writefln("Warning: Could not load conversation from %s: %s", entry.name, e.msg);
                }
            }
        } catch (Exception e) {
            writefln("Error loading conversations: %s", e.msg);
        }
    }

    /**
     * Save all conversations
     */
    void saveAll() {
        foreach (conv; conversations) {
            saveConversation(conv);
        }
    }

    /**
     * Get statistics
     */
    void getStats(out int totalConversations, out int totalMessages) {
        totalConversations = cast(int)conversations.length;
        totalMessages = 0;
        foreach (conv; conversations) {
            totalMessages += conv.getMessageCount();
        }
    }
}

/**
 * Demonstrate basic conversation management
 */
void demonstrateBasicConversation() {
    writeln("=== Basic Conversation Management ===");

    auto conv = new Conversation("", "Test Conversation");

    writefln("Created conversation:");
    writefln("ID: %s", conv.getId());
    writefln("Title: %s", conv.getTitle());
    writefln("Messages: %d", conv.getMessageCount());

    // Add messages
    conv.addSystemMessage("You are a helpful assistant.");
    conv.addUserMessage("What is the capital of France?");
    conv.addAssistantMessage("The capital of France is Paris.");
    conv.addUserMessage("Tell me more about it.");

    writefln("\nAfter adding messages:");
    writefln("Messages: %d", conv.getMessageCount());
    writefln("Summary: %s", conv.getSummary());

    // Show messages for API
    Message[] apiMessages = conv.getMessagesForAPI();
    writefln("\nMessages for API (%d total):", apiMessages.length);
    foreach (i, msg; apiMessages) {
        writefln("%d. %s: %s", i + 1, msg.role, msg.content);
    }
}

/**
 * Demonstrate conversation persistence
 */
void demonstrateConversationPersistence() {
    writeln("\n=== Conversation Persistence ===");

    // Create conversation manager
    string tempDir = "temp_conversations";
    auto manager = new ConversationManager(tempDir);

    // Create a conversation
    auto conv1 = manager.createConversation("Persistent Test");
    conv1.addSystemMessage("You are a helpful coding assistant.");
    conv1.addUserMessage("How do I declare a variable in D?");
    conv1.addAssistantMessage("In D, you declare variables with: 'type variableName;'");

    writefln("Created conversation: %s", conv1.getId());

    // Save manually (normally happens automatically)
    manager.saveAll();

    // Create another conversation
    auto conv2 = manager.createConversation("Another Test");
    conv2.addUserMessage("Hello!");

    writefln("Created second conversation: %s", conv2.getId());

    // List all conversations
    writefln("\nAll conversations:");
    foreach (conv; manager.listConversations()) {
        writefln("• %s: %s (%d messages)",
                conv.getId(), conv.getTitle(), conv.getMessageCount());
    }

    // Simulate loading from disk (create new manager)
    auto manager2 = new ConversationManager(tempDir);
    writefln("\nLoaded conversations from disk:");
    foreach (conv; manager2.listConversations()) {
        writefln("• %s: %s (%d messages)",
                conv.getId(), conv.getTitle(), conv.getMessageCount());
    }

    // Cleanup
    try {
        if (exists(tempDir)) {
            rmdirRecurse(tempDir);
        }
    } catch (Exception e) {
        writefln("Warning: Could not clean up temp directory: %s", e.msg);
    }
}

/**
 * Demonstrate conversation history management
 */
void demonstrateConversationHistory() {
    writeln("\n=== Conversation History Management ===");

    auto conv = new Conversation("", "History Test");

    // Add many messages
    conv.addSystemMessage("You are a helpful assistant.");
    for (int i = 1; i <= 15; i++) {
        conv.addUserMessage(format("Question %d: What is %d + %d?", i, i, i + 1));
        conv.addAssistantMessage(format("Answer %d: %d + %d = %d", i, i, i + 1, i + (i + 1)));
    }

    writefln("Conversation with %d messages", conv.getMessageCount());

    // Get messages for API (should include system message)
    Message[] apiMessages = conv.getMessagesForAPI();
    writefln("API message count: %d", apiMessages.length);
    writefln("First message: %s", apiMessages[0].content);
    writefln("Last message: %s", apiMessages[$-1].content);

    // Show conversation turns
    writefln("\nConversation turns:");
    Message[] convMessages = conv.getMessages();
    for (int i = 0; i < convMessages.length; i += 2) {
        if (i < convMessages.length) {
            writefln("Turn %d:", (i / 2) + 1);
            writefln("  User: %s", convMessages[i].content);

            if (i + 1 < convMessages.length) {
                writefln("  Assistant: %s", convMessages[i + 1].content);
            }
        }
    }
}

/**
 * Demonstrate conversation search and filtering
 */
void demonstrateConversationSearch() {
    writeln("\n=== Conversation Search and Filtering ===");

    // Create several conversations
    Conversation[] convs;
    convs ~= new Conversation("", "D Language Discussion");
    convs ~= new Conversation("", "Weather API Help");
    convs ~= new Conversation("", "General Questions");

    // Add content
    convs[0].addUserMessage("How do I use ranges in D?");
    convs[0].addAssistantMessage("D has powerful range-based operations...");

    convs[1].addUserMessage("How do I call the OpenWeather API?");
    convs[1].addAssistantMessage("You'll need an API key from openweathermap.org...");

    convs[2].addUserMessage("What is the meaning of life?");
    convs[2].addAssistantMessage("That's a philosophical question...");

    // Search functions
    Conversation[] findByKeyword(Conversation[] conversations, string keyword) {
        return conversations.filter!(c =>
            c.getMessages().any!(m =>
                m.content.toLower().canFind(keyword.toLower())
            )
        ).array;
    }

    Conversation[] findByTitle(Conversation[] conversations, string titlePart) {
        return conversations.filter!(c =>
            c.getTitle().toLower().canFind(titlePart.toLower())
        ).array;
    }

    // Search examples
    writefln("Search for 'API':");
    auto apiResults = findByKeyword(convs, "API");
    foreach (conv; apiResults) {
        writefln("  Found: %s", conv.getTitle());
    }

    writefln("\nSearch for 'weather':");
    auto weatherResults = findByKeyword(convs, "weather");
    foreach (conv; weatherResults) {
        writefln("  Found: %s", conv.getTitle());
    }

    writefln("\nSearch titles containing 'Language':");
    auto langResults = findByTitle(convs, "Language");
    foreach (conv; langResults) {
        writefln("  Found: %s", conv.getTitle());
    }
}

/**
 * Demonstrate conversation export/import
 */
void demonstrateConversationExport() {
    writeln("\n=== Conversation Export/Import ===");

    // Create a conversation
    auto conv = new Conversation("", "Export Test");
    conv.addSystemMessage("You are a helpful assistant.");
    conv.addUserMessage("Hello!");
    conv.addAssistantMessage("Hi there! How can I help you?");
    conv.addUserMessage("Tell me about D programming.");
    conv.addAssistantMessage("D is a systems programming language...");

    // Export to JSON
    JSONValue exported = conv.toJSON();
    writefln("Exported conversation JSON:");
    writefln("%s", exported.toPrettyString());

    // Import from JSON
    auto imported = Conversation.fromJSON(exported);
    writefln("\nImported conversation:");
    writefln("ID: %s", imported.getId());
    writefln("Title: %s", imported.getTitle());
    writefln("Messages: %d", imported.getMessageCount());

    writefln("\nImported messages:");
    foreach (i, msg; imported.getMessages()) {
        writefln("%d. %s: %s", i + 1, msg.role, msg.content);
    }

    // Verify they match
    assert(conv.getId() == imported.getId());
    assert(conv.getTitle() == imported.getTitle());
    assert(conv.getMessageCount() == imported.getMessageCount());
    writefln("\n✓ Export/import successful");
}

/**
 * Check if conversation management functionality works
 */
bool testConversationManagementCapability() {
    try {
        // Test conversation creation
        auto conv = new Conversation("", "Test");
        assert(!conv.getId().empty);
        assert(conv.getTitle() == "Test");
        assert(conv.getMessageCount() == 0);

        // Test message adding
        conv.addUserMessage("Hello");
        conv.addAssistantMessage("Hi");
        assert(conv.getMessageCount() == 2);

        // Test API messages
        auto apiMessages = conv.getMessagesForAPI();
        assert(apiMessages.length == 2);

        // Test JSON export/import
        JSONValue exported = conv.toJSON();
        auto imported = Conversation.fromJSON(exported);
        assert(imported.getId() == conv.getId());
        assert(imported.getMessageCount() == conv.getMessageCount());

        // Test conversation manager
        string testDir = "test_conversations";
        auto manager = new ConversationManager(testDir);
        auto conv2 = manager.createConversation("Manager Test");
        assert(manager.getConversation(conv2.getId()) !is null);
        assert(manager.listConversationIds().length >= 1);

        // Cleanup
        try {
            if (exists(testDir)) {
                rmdirRecurse(testDir);
            }
        } catch (Exception) {}

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the conversation management example
 */
void runExample() {
    writeln("=== Conversation Management Demonstration ===\n");

    if (!testConversationManagementCapability()) {
        writeln("ERROR: Conversation management functionality test failed!");
        return;
    }

    writeln("✓ Conversation management functionality confirmed\n");

    demonstrateBasicConversation();
    demonstrateConversationPersistence();
    demonstrateConversationHistory();
    demonstrateConversationSearch();
    demonstrateConversationExport();

    writeln("\n=== Summary ===");
    writeln("• Use Conversation class to manage chat state");
    writeln("• Implement proper message history with size limits");
    writeln("• Persist conversations to disk for continuity");
    writeln("• Export/import conversations for backup/sharing");
    writeln("• Search and filter conversations by content");
    writeln("• Handle system prompts separately from conversation");
    writeln("• Track conversation metadata (timestamps, titles)");
    writeln("• Implement conversation management with ConversationManager");
}

unittest {
    writeln("=== Running conversation_management tests ===");

    // Test message structure
    auto msg = Message("user", "Hello world", 1234567890);
    assert(msg.role == "user");
    assert(msg.content == "Hello world");
    assert(msg.timestamp == 1234567890);

    JSONValue msgJson = msg.toJSON();
    assert(msgJson["role"].str == "user");
    assert(msgJson["content"].str == "Hello world");

    auto restoredMsg = Message.fromJSON(msgJson);
    assert(restoredMsg.role == msg.role);
    assert(restoredMsg.content == msg.content);
    writeln("✓ Message structure works");

    // Test conversation
    auto conv = new Conversation("test-id", "Test Conversation");
    assert(conv.getId() == "test-id");
    assert(conv.getTitle() == "Test Conversation");
    assert(conv.getMessageCount() == 0);

    conv.addUserMessage("Hello");
    conv.addAssistantMessage("Hi there");
    assert(conv.getMessageCount() == 2);

    auto apiMessages = conv.getMessagesForAPI();
    assert(apiMessages.length == 2);
    assert(apiMessages[0].role == "user");
    assert(apiMessages[1].role == "assistant");
    writeln("✓ Conversation management works");

    // Test system prompt
    conv.addSystemMessage("You are helpful");
    apiMessages = conv.getMessagesForAPI();
    assert(apiMessages.length == 3); // system + 2 messages
    assert(apiMessages[0].role == "system");
    writeln("✓ System prompt handling works");

    // Test JSON export/import
    JSONValue exported = conv.toJSON();
    auto imported = Conversation.fromJSON(exported);
    assert(imported.getId() == conv.getId());
    assert(imported.getTitle() == conv.getTitle());
    assert(imported.getMessageCount() == conv.getMessageCount());
    writeln("✓ JSON export/import works");

    // Test conversation manager (in memory only)
    auto manager = new ConversationManager("nonexistent_dir");
    auto conv2 = manager.createConversation("Manager Test");
    assert(manager.getConversation(conv2.getId()) !is null);
    assert(manager.listConversationIds().canFind(conv2.getId()));
    assert(manager.listConversations().length >= 1);
    writeln("✓ Conversation manager works");

    writeln("All conversation_management tests passed!");
    writeln("=== conversation_management tests completed ===");
}
