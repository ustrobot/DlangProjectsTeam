/**
 * Lesson 10: Logging - Implementing logging for LLM chat applications
 *
 * This example demonstrates how to implement comprehensive logging for chat applications,
 * including request/response logging, error tracking, performance monitoring, and log analysis.
 */

module lesson10.logging;

import std.stdio;
import std.json;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.file;
import std.path;
import std.datetime;
import std.range;

/**
 * Log levels
 */
enum LogLevel {
    DEBUG,
    INFO,
    WARN,
    ERROR,
    FATAL
}

/**
 * Log entry structure
 */
struct LogEntry {
    LogLevel level;
    string message;
    string category;
    JSONValue data;
    long timestamp;
    string sessionId;
    string conversationId;

    /**
     * Create a log entry
     */
    static LogEntry create(LogLevel level, string message,
                          string category = "general",
                          JSONValue data = JSONValue(null),
                          string sessionId = "",
                          string conversationId = "") {
        return LogEntry(level, message, category, data,
                       Clock.currTime.toUnixTime(), sessionId, conversationId);
    }

    /**
     * Convert to JSON
     */
    JSONValue toJSON() const {
        JSONValue json;
        json["level"] = level.to!string;
        json["message"] = message;
        json["category"] = category;
        json["timestamp"] = timestamp;
        json["sessionId"] = sessionId;
        json["conversationId"] = conversationId;

        if (data.type != JSONType.null_) {
            json["data"] = data;
        }

        return json;
    }

    /**
     * Convert to readable string
     */
    string toString() const {
        auto dt = SysTime.fromUnixTime(timestamp);
        string timeStr = dt.toSimpleString();
        string levelStr = level.to!string;

        string result = format("[%s] %s %s: %s",
                              timeStr, levelStr, category, message);

        if (!sessionId.empty) {
            result ~= format(" (session: %s)", sessionId);
        }

        if (!conversationId.empty) {
            result ~= format(" (conv: %s)", conversationId);
        }

        return result;
    }
}

/**
 * Logger interface
 */
interface Logger {
    void log(LogEntry entry);
    LogEntry[] getEntries(string category = "", int limit = 100);
    void clear();
}

/**
 * Console logger
 */
class ConsoleLogger : Logger {
    private LogEntry[] entries;
    private LogLevel minLevel = LogLevel.INFO;

    this(LogLevel minLevel = LogLevel.INFO) {
        this.minLevel = minLevel;
    }

    override void log(LogEntry entry) {
        entries ~= entry;

        // Output to console if level is high enough
        if (entry.level >= minLevel) {
            writeln(entry.toString());

            // Pretty print data if present
            if (entry.data.type != JSONType.null_) {
                writefln("  Data: %s", entry.data.toPrettyString());
            }
        }
    }

    override LogEntry[] getEntries(string category = "", int limit = 100) {
        auto filtered = category.empty ?
            entries :
            entries.filter!(e => e.category == category).array;

        return filtered.take(limit).array;
    }

    override void clear() {
        entries = [];
    }
}

/**
 * File logger
 */
class FileLogger : Logger {
    private string logFile;
    private LogEntry[] buffer;
    private size_t bufferSize = 10; // Flush every 10 entries

    this(string logFile) {
        this.logFile = logFile;

        // Create directory if needed
        string dir = dirName(logFile);
        if (!dir.empty && !exists(dir)) {
            mkdirRecurse(dir);
        }
    }

    override void log(LogEntry entry) {
        buffer ~= entry;

        // Flush buffer when it gets full
        if (buffer.length >= bufferSize) {
            flush();
        }
    }

    override LogEntry[] getEntries(string category = "", int limit = 100) {
        // For file logger, we don't keep entries in memory
        // In a real implementation, you might want to read from file
        return [];
    }

    override void clear() {
        buffer = [];
        if (exists(logFile)) {
            try {
                remove(logFile);
            } catch (Exception e) {
                writefln("Warning: Could not clear log file: %s", e.msg);
            }
        }
    }

    /**
     * Flush buffer to file
     */
    void flush() {
        if (buffer.empty) return;

        try {
            auto file = File(logFile, "a");
            foreach (entry; buffer) {
                file.writeln(entry.toJSON().toString());
            }
            file.close();
        } catch (Exception e) {
            writefln("Error writing to log file: %s", e.msg);
        }

        buffer = [];
    }

    /**
     * Force flush remaining entries
     */
    void close() {
        flush();
    }
}

/**
 * Composite logger (logs to multiple destinations)
 */
class CompositeLogger : Logger {
    private Logger[] loggers;

    void addLogger(Logger logger) {
        loggers ~= logger;
    }

    override void log(LogEntry entry) {
        foreach (logger; loggers) {
            logger.log(entry);
        }
    }

    override LogEntry[] getEntries(string category = "", int limit = 100) {
        // Return entries from first logger (usually console)
        if (!loggers.empty) {
            return loggers[0].getEntries(category, limit);
        }
        return [];
    }

    override void clear() {
        foreach (logger; loggers) {
            logger.clear();
        }
    }
}

/**
 * Chat application logger with specialized methods
 */
class ChatLogger {
    private Logger logger;
    private string sessionId;

    this(Logger logger, string sessionId = "") {
        this.logger = logger;
        this.sessionId = sessionId;
    }

    /**
     * Log chat request
     */
    void logRequest(string conversationId, JSONValue request, string endpoint = "") {
        JSONValue data = JSONValue([
            "type": JSONValue("request"),
            "endpoint": JSONValue(endpoint),
            "request": request
        ]);

        logger.log(LogEntry.create(LogLevel.INFO, "Chat request sent",
                                  "chat", data, sessionId, conversationId));
    }

    /**
     * Log chat response
     */
    void logResponse(string conversationId, JSONValue response, Duration responseTime) {
        JSONValue data = JSONValue([
            "type": JSONValue("response"),
            "responseTime": JSONValue(responseTime.total!"msecs"),
            "response": response
        ]);

        logger.log(LogEntry.create(LogLevel.INFO, "Chat response received",
                                  "chat", data, sessionId, conversationId));
    }

    /**
     * Log error
     */
    void logError(string conversationId, string error, string context = "") {
        JSONValue data = JSONValue([
            "type": JSONValue("error"),
            "error": JSONValue(error),
            "context": JSONValue(context)
        ]);

        logger.log(LogEntry.create(LogLevel.ERROR, "Chat error occurred",
                                  "chat", data, sessionId, conversationId));
    }

    /**
     * Log rate limit
     */
    void logRateLimit(string conversationId, int retryAfter) {
        JSONValue data = JSONValue([
            "type": JSONValue("rate_limit"),
            "retryAfter": JSONValue(retryAfter)
        ]);

        logger.log(LogEntry.create(LogLevel.WARN, "Rate limit hit",
                                  "rate_limit", data, sessionId, conversationId));
    }

    /**
     * Log conversation event
     */
    void logConversationEvent(string conversationId, string event, JSONValue details = JSONValue(null)) {
        JSONValue data = JSONValue([
            "type": JSONValue("conversation"),
            "event": JSONValue(event)
        ]);

        if (details.type != JSONType.null_) {
            data["details"] = details;
        }

        logger.log(LogEntry.create(LogLevel.INFO, format("Conversation %s", event),
                                  "conversation", data, sessionId, conversationId));
    }

    /**
     * Log performance metrics
     */
    void logPerformance(string operation, Duration duration, JSONValue metrics = JSONValue(null)) {
        JSONValue data = JSONValue([
            "type": JSONValue("performance"),
            "operation": JSONValue(operation),
            "duration": JSONValue(duration.total!"msecs")
        ]);

        if (metrics.type != JSONType.null_) {
            data["metrics"] = metrics;
        }

        logger.log(LogEntry.create(LogLevel.DEBUG, format("%s completed in %s", operation, duration),
                                  "performance", data, sessionId));
    }

    /**
     * Get entries for a conversation
     */
    LogEntry[] getConversationLogs(string conversationId, int limit = 50) {
        return logger.getEntries("chat", limit)
                    .filter!(e => e.conversationId == conversationId)
                    .array;
    }

    /**
     * Get error logs
     */
    LogEntry[] getErrorLogs(int limit = 20) {
        return logger.getEntries()
                    .filter!(e => e.level >= LogLevel.ERROR)
                    .take(limit)
                    .array;
    }
}

/**
 * Log analyzer
 */
class LogAnalyzer {
    private LogEntry[] entries;

    this(LogEntry[] entries) {
        this.entries = entries;
    }

    /**
     * Get statistics
     */
    void getStatistics(out int totalLogs, out int errors, out int warnings,
                      out int info, out int debugLogs) {
        totalLogs = cast(int)entries.length;
        errors = cast(int)entries.count!(e => e.level == LogLevel.ERROR);
        warnings = cast(int)entries.count!(e => e.level == LogLevel.WARN);
        info = cast(int)entries.count!(e => e.level == LogLevel.INFO);
        debugLogs = cast(int)entries.count!(e => e.level == LogLevel.DEBUG);
    }

    /**
     * Get logs by category
     */
    LogEntry[][string] getLogsByCategory() {
        LogEntry[][string] categorized;

        foreach (entry; entries) {
            categorized[entry.category] ~= entry;
        }

        return categorized;
    }

    /**
     * Get recent errors
     */
    LogEntry[] getRecentErrors(int count = 5) {
        return entries.filter!(e => e.level >= LogLevel.ERROR)
                     .array
                     .sort!((a, b) => a.timestamp > b.timestamp)
                     .take(count)
                     .array;
    }

    /**
     * Get conversation summary
     */
    string[string] getConversationSummary() {
        string[string] summaries;

        auto chatEntries = entries.filter!(e => e.category == "chat");
        auto conversations = chatEntries.map!(e => e.conversationId)
                                       .filter!(id => !id.empty);

        foreach (convId; conversations) {
            auto convEntries = chatEntries.filter!(e => e.conversationId == convId);
            int requests = cast(int)convEntries.count!(e => e.data.type != JSONType.null_ &&
                                                       "type" in e.data &&
                                                       e.data["type"].str == "request");
            int responses = cast(int)convEntries.count!(e => e.data.type != JSONType.null_ &&
                                                        "type" in e.data &&
                                                        e.data["type"].str == "response");
            int errors = cast(int)convEntries.count!(e => e.level >= LogLevel.ERROR);

            summaries[convId] = format("Requests: %d, Responses: %d, Errors: %d",
                                     requests, responses, errors);
        }

        return summaries;
    }
}

/**
 * Demonstrate basic logging
 */
void demonstrateBasicLogging() {
    writeln("=== Basic Logging ===");

    auto logger = new ConsoleLogger(LogLevel.DEBUG);

    // Log different types of messages
    logger.log(LogEntry.create(LogLevel.INFO, "Application started"));
    logger.log(LogEntry.create(LogLevel.DEBUG, "Configuration loaded", "config"));
    logger.log(LogEntry.create(LogLevel.WARN, "Deprecated API usage detected", "api"));
    logger.log(LogEntry.create(LogLevel.ERROR, "Failed to connect to database", "database"));

    // Log with data
    JSONValue userData = JSONValue(["userId": JSONValue("12345"), "action": JSONValue("login")]);
    logger.log(LogEntry.create(LogLevel.INFO, "User action performed", "user", userData));
}

/**
 * Demonstrate chat application logging
 */
void demonstrateChatLogging() {
    writeln("\n=== Chat Application Logging ===");

    auto consoleLogger = new ConsoleLogger(LogLevel.INFO);
    auto chatLogger = new ChatLogger(consoleLogger, "session-123");

    string convId = "conv-456";

    // Simulate chat interactions
    JSONValue request = JSONValue([
        "model": JSONValue("gpt-3.5-turbo"),
        "messages": JSONValue([
            JSONValue(["role": JSONValue("user"), "content": JSONValue("Hello!")])
        ])
    ]);

    chatLogger.logRequest(convId, request, "https://api.openai.com/v1/chat/completions");

    // Simulate response
    JSONValue response = JSONValue([
        "id": JSONValue("chatcmpl-123"),
        "choices": JSONValue([
            JSONValue([
                "message": JSONValue(["content": JSONValue("Hi there!")])
            ])
        ]),
        "usage": JSONValue(["total_tokens": JSONValue(25)])
    ]);

    chatLogger.logResponse(convId, response, 1500.msecs);

    // Simulate error
    chatLogger.logError(convId, "Invalid API key", "authentication");

    // Simulate rate limit
    chatLogger.logRateLimit(convId, 60);

    // Simulate conversation events
    chatLogger.logConversationEvent(convId, "created");
    chatLogger.logConversationEvent(convId, "completed");

    // Log performance
    JSONValue perfData = JSONValue(["tokens": JSONValue(150), "model": JSONValue("gpt-3.5-turbo")]);
    chatLogger.logPerformance("chat_completion", 2.seconds, perfData);
}

/**
 * Demonstrate file logging
 */
void demonstrateFileLogging() {
    writeln("\n=== File Logging ===");

    string logFile = "demo_chat.log";
    auto fileLogger = new FileLogger(logFile);
    auto chatLogger = new ChatLogger(fileLogger, "demo-session");

    // Log some entries
    chatLogger.logRequest("demo-conv", JSONValue(["messages": JSONValue(["user": "test"])]));
    chatLogger.logResponse("demo-conv", JSONValue(["content": JSONValue("response")]), 500.msecs);
    chatLogger.logError("demo-conv", "Demo error");

    // Force flush to disk
    fileLogger.close();

    // Show file contents
    if (exists(logFile)) {
        writefln("Log file contents:");
        try {
            auto content = readText(logFile);
            writefln("%s", content);
        } catch (Exception e) {
            writefln("Error reading log file: %s", e.msg);
        }

        // Cleanup
        try {
            remove(logFile);
        } catch (Exception) {}
    }
}

/**
 * Demonstrate log analysis
 */
void demonstrateLogAnalysis() {
    writeln("\n=== Log Analysis ===");

    // Create some sample log entries
    LogEntry[] sampleEntries = [
        LogEntry.create(LogLevel.INFO, "Request sent", "chat", JSONValue(["type": "request"])),
        LogEntry.create(LogLevel.INFO, "Response received", "chat", JSONValue(["type": "response"])),
        LogEntry.create(LogLevel.ERROR, "API error", "chat"),
        LogEntry.create(LogLevel.WARN, "Rate limit hit", "rate_limit"),
        LogEntry.create(LogLevel.INFO, "Conversation created", "conversation"),
        LogEntry.create(LogLevel.DEBUG, "Token count: 150", "performance")
    ];

    auto analyzer = new LogAnalyzer(sampleEntries);

    // Get statistics
    int total, errors, warnings, info, debugLogs;
    analyzer.getStatistics(total, errors, warnings, info, debugLogs);

    writefln("Log Statistics:");
    writefln("Total entries: %d", total);
    writefln("Errors: %d", errors);
    writefln("Warnings: %d", warnings);
    writefln("Info: %d", info);
    writefln("Debug: %d", debugLogs);

    // Get logs by category
    auto categorized = analyzer.getLogsByCategory();
    writefln("\nLogs by category:");
    foreach (category, entries; categorized) {
        writefln("%s: %d entries", category, entries.length);
    }

    // Get recent errors
    auto recentErrors = analyzer.getRecentErrors(3);
    writefln("\nRecent errors (%d):", recentErrors.length);
    foreach (error; recentErrors) {
        writefln("• %s", error.message);
    }

    // Get conversation summaries
    auto convSummaries = analyzer.getConversationSummary();
    writefln("\nConversation summaries:");
    foreach (convId, summary; convSummaries) {
        writefln("%s: %s", convId, summary);
    }
}

/**
 * Demonstrate composite logging
 */
void demonstrateCompositeLogging() {
    writeln("\n=== Composite Logging ===");

    auto compositeLogger = new CompositeLogger();

    // Add console logger
    compositeLogger.addLogger(new ConsoleLogger(LogLevel.WARN));

    // Add file logger
    string tempLog = "temp_composite.log";
    auto fileLogger = new FileLogger(tempLog);
    compositeLogger.addLogger(fileLogger);

    auto chatLogger = new ChatLogger(compositeLogger, "composite-session");

    // Log messages (only warnings and above will show in console)
    chatLogger.logRequest("test-conv", JSONValue(["test": "request"]));
    chatLogger.logError("test-conv", "Test error message");
    chatLogger.logRateLimit("test-conv", 30);

    // Flush file logger
    fileLogger.close();

    // Show what was logged to file
    if (exists(tempLog)) {
        try {
            auto lines = readText(tempLog).split("\n").filter!(l => !l.empty).array;
            writefln("File logger captured %d entries", lines.length);
        } catch (Exception) {}

        // Cleanup
        try {
            remove(tempLog);
        } catch (Exception) {}
    }
}

/**
 * Check if logging functionality works
 */
bool testLoggingCapability() {
    try {
        // Test console logger
        auto consoleLogger = new ConsoleLogger(LogLevel.DEBUG);
        auto entry = LogEntry.create(LogLevel.INFO, "Test message", "test");
        consoleLogger.log(entry);
        assert(consoleLogger.getEntries().length == 1);

        // Test chat logger
        auto chatLogger = new ChatLogger(consoleLogger, "test-session");
        JSONValue testRequest = JSONValue(["model": "test"]);
        chatLogger.logRequest("test-conv", testRequest);
        assert(consoleLogger.getEntries().length == 2);

        // Test file logger (basic)
        string testFile = "test_logging.tmp";
        auto fileLogger = new FileLogger(testFile);
        fileLogger.log(entry);
        fileLogger.close();

        // Cleanup
        if (exists(testFile)) {
            remove(testFile);
        }

        // Test log analyzer
        LogEntry[] testEntries = [
            LogEntry.create(LogLevel.INFO, "info", "test"),
            LogEntry.create(LogLevel.ERROR, "error", "test")
        ];
        auto analyzer = new LogAnalyzer(testEntries);

        int total, errors, warnings, info, debugLogs;
        analyzer.getStatistics(total, errors, warnings, info, debugLogs);
        assert(total == 2);
        assert(errors == 1);
        assert(info == 1);

        return true;
    } catch (Exception e) {
        return false;
    }
}

/**
 * Run the logging example
 */
void runExample() {
    writeln("=== Logging Demonstration ===\n");

    if (!testLoggingCapability()) {
        writeln("ERROR: Logging functionality test failed!");
        return;
    }

    writeln("✓ Logging functionality confirmed\n");

    demonstrateBasicLogging();
    demonstrateChatLogging();
    demonstrateFileLogging();
    demonstrateLogAnalysis();
    demonstrateCompositeLogging();

    writeln("\n=== Summary ===");
    writeln("• Implement structured logging with LogEntry and Logger interfaces");
    writeln("• Use ChatLogger for specialized chat application logging");
    writeln("• Combine multiple loggers with CompositeLogger");
    writeln("• Persist logs to files with FileLogger");
    writeln("• Analyze logs with LogAnalyzer for insights");
    writeln("• Include session and conversation IDs for tracking");
    writeln("• Log requests, responses, errors, and performance metrics");
    writeln("• Use appropriate log levels (DEBUG, INFO, WARN, ERROR)");
    writeln("• Structure log data as JSON for easy parsing");
}

unittest {
    writeln("=== Running logging tests ===");

    // Test log entry
    auto entry = LogEntry.create(LogLevel.INFO, "Test message", "test",
                               JSONValue(["key": "value"]), "session-1", "conv-1");
    assert(entry.level == LogLevel.INFO);
    assert(entry.message == "Test message");
    assert(entry.category == "test");
    assert(entry.sessionId == "session-1");
    assert(entry.conversationId == "conv-1");

    JSONValue json = entry.toJSON();
    assert(json["level"].str == "INFO");
    assert(json["message"].str == "Test message");
    assert(json["data"]["key"].str == "value");
    writeln("✓ Log entry structure works");

    // Test console logger
    auto logger = new ConsoleLogger(LogLevel.DEBUG);
    logger.log(entry);
    auto entries = logger.getEntries();
    assert(entries.length == 1);
    assert(entries[0].message == "Test message");

    auto categoryEntries = logger.getEntries("test");
    assert(categoryEntries.length == 1);
    writeln("✓ Console logger works");

    // Test chat logger
    auto chatLogger = new ChatLogger(logger, "session-1");
    JSONValue request = JSONValue(["model": "test"]);
    chatLogger.logRequest("conv-1", request);

    auto allEntries = logger.getEntries();
    assert(allEntries.length == 2); // Original + request log
    writeln("✓ Chat logger works");

    // Test log analyzer
    LogEntry[] testEntries = [
        LogEntry.create(LogLevel.INFO, "info 1", "chat"),
        LogEntry.create(LogLevel.ERROR, "error 1", "chat"),
        LogEntry.create(LogLevel.WARN, "warn 1", "rate_limit"),
        LogEntry.create(LogLevel.INFO, "info 2", "chat")
    ];

    auto analyzer = new LogAnalyzer(testEntries);

    int total, errors, warnings, info, debugLogs;
    analyzer.getStatistics(total, errors, warnings, info, debugLogs);
    assert(total == 4);
    assert(errors == 1);
    assert(warnings == 1);
    assert(info == 2);
    assert(debugLogs == 0);
    writeln("✓ Log analyzer works");

    // Test categorized logs
    auto categorized = analyzer.getLogsByCategory();
    assert("chat" in categorized);
    assert("rate_limit" in categorized);
    assert(categorized["chat"].length == 3);
    assert(categorized["rate_limit"].length == 1);
    writeln("✓ Log categorization works");

    writeln("All logging tests passed!");
    writeln("=== logging tests completed ===");
}
