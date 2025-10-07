module llm.chat_persistence;

import std.file;
import std.path;
import std.json;
import std.stdio;
import std.process : environment;
import llm.chat_context;
import llm.message;

/**
 * Handles persistence of chat context to/from user's home directory.
 */
class ChatPersistence
{
    private static const string APP_DIR = ".dlang-ai-client";
    private static const string CONTEXT_FILE = "chat_context.json";

    private string _dataDir;

    this()
    {
        // Create data directory in user's home
        _dataDir = buildPath(environment.get("HOME", "/tmp"), APP_DIR);
        ensureDataDir();
    }

    /**
     * Save chat context to JSON file.
     */
    void saveContext(ChatContext context)
    {
        try
        {
            auto jsonData = serializeContext(context);
            auto filePath = buildPath(_dataDir, CONTEXT_FILE);
            std.file.write(filePath, jsonData.toPrettyString(JSONOptions.doNotEscapeSlashes));
        }
        catch (Exception e)
        {
            stderr.writeln("Warning: Failed to save chat context: ", e.msg);
        }
    }

    /**
     * Load chat context from JSON file.
     * Returns null if no saved context exists or loading fails.
     */
    ChatContext loadContext(string apiKey, string defaultSystemMessage = "You are a concise assistant.")
    {
        auto filePath = buildPath(_dataDir, CONTEXT_FILE);

        if (!exists(filePath))
        {
            return new ChatContext(apiKey, defaultSystemMessage);
        }

        try
        {
            string content = readText(filePath);
            JSONValue jsonData = parseJSON(content);

            return deserializeContext(jsonData, apiKey, defaultSystemMessage);
        }
        catch (Exception e)
        {
            stderr.writeln("Warning: Failed to load chat context, using defaults: ", e.msg);
            return new ChatContext(apiKey, defaultSystemMessage);
        }
    }

    /**
     * Clear saved context by deleting the file.
     */
    void clearSavedContext()
    {
        auto filePath = buildPath(_dataDir, CONTEXT_FILE);

        if (exists(filePath))
        {
            try
            {
                remove(filePath);
            }
            catch (Exception e)
            {
                stderr.writeln("Warning: Failed to clear saved context: ", e.msg);
            }
        }
    }

    /**
     * Get the full path to the data directory.
     */
    @property string dataDir() const
    {
        return _dataDir;
    }

    /**
     * Ensure the data directory exists.
     */
    private void ensureDataDir()
    {
        if (!exists(_dataDir))
        {
            try
            {
                mkdirRecurse(_dataDir);
            }
            catch (Exception e)
            {
                stderr.writeln("Warning: Failed to create data directory: ", e.msg);
                // Fall back to /tmp if home directory is not writable
                _dataDir = buildPath("/tmp", APP_DIR);
                if (!exists(_dataDir))
                {
                    mkdirRecurse(_dataDir);
                }
            }
        }
    }

    /**
     * Serialize ChatContext to JSON.
     */
    private JSONValue serializeContext(ChatContext context)
    {
        JSONValue[string] json;

        // Serialize messages using the new method
        JSONValue[] messagesJson;
        foreach (message; context.getMessagesForSerialization())
        {
            JSONValue[string] msgJson;
            msgJson["role"] = message.role;
            msgJson["content"] = message.content;
            messagesJson ~= JSONValue(msgJson);
        }
        json["messages"] = messagesJson;

        // Serialize system message (separate from messages array)
        json["systemMessage"] = context.systemMessage;

        return JSONValue(json);
    }

    /**
     * Deserialize JSON to ChatContext.
     */
    private ChatContext deserializeContext(JSONValue jsonData, string apiKey, string defaultSystemMessage)
    {
        ChatContext context = new ChatContext(apiKey, defaultSystemMessage);

        // Deserialize messages
        if ("messages" in jsonData && jsonData["messages"].type == JSONType.array)
        {
            ChatMessage[] messages;
            foreach (msgJson; jsonData["messages"].array)
            {
                if (msgJson.type == JSONType.object &&
                    "role" in msgJson && "content" in msgJson)
                {
                    string role = msgJson["role"].str;
                    string content = msgJson["content"].str;
                    messages ~= ChatMessage(cast(MessageRole)role, content);
                }
            }

            if (messages.length > 0)
            {
                context.setMessagesFromDeserialization(messages);
            }
        }

        // Deserialize system message (override the default)
        if ("systemMessage" in jsonData && jsonData["systemMessage"].type == JSONType.string)
        {
            context.systemMessage = jsonData["systemMessage"].str;
        }

        return context;
    }
}

