module llm.chat_context;

import llm.message : MessageRole, ChatMessage;

/**
 * Holds chat history and related configuration like the API key.
 */
class ChatContext
{
    private ChatMessage[] _messages;
    private string _apiKey;
    private string _systemMessage;
    private string _selectedServer;
    private string _selectedModel;

    this(string apiKey, string systemMessage = "", string selectedServer = "", string selectedModel = "")
    {
        _apiKey = apiKey;
        _systemMessage = systemMessage;
        _selectedServer = selectedServer;
        _selectedModel = selectedModel;
    }

    @property string apiKey() const
    {
        return _apiKey;
    }

    void addMessage(ChatMessage message)
    {
        _messages ~= message;
    }

    @property ChatMessage[] messages() const
    {
        return _messages.dup;
    }

    void clear()
    {
        _messages.length = 0;
    }

    @property string systemMessage() const
    {
        return _systemMessage;
    }

    @property void systemMessage(string value)
    {
        _systemMessage = value;
        // ensure the first message in the history reflects the system prompt
        // if empty, remove any existing system message; else set/update it at index 0
        bool hasSystemAtZero = _messages.length > 0 && _messages[0].role == MessageRole.SYSTEM;
        if (value.length == 0)
        {
            if (hasSystemAtZero)
            {
                // drop the first element
                _messages = _messages[1 .. $].dup;
            }
            return;
        }
        auto sysMsg = ChatMessage(MessageRole.SYSTEM, value);
        if (hasSystemAtZero)
        {
            _messages[0] = sysMsg;
        }
        else
        {
            _messages = [sysMsg] ~ _messages;
        }
    }

    @property string selectedServer() const
    {
        return _selectedServer;
    }

    @property void selectedServer(string value)
    {
        _selectedServer = value;
    }

    @property string selectedModel() const
    {
        return _selectedModel;
    }

    @property void selectedModel(string value)
    {
        _selectedModel = value;
    }

    /**
     * Get messages array for serialization purposes.
     * Note: This returns a copy to maintain encapsulation.
     */
    ChatMessage[] getMessagesForSerialization()
    {
        return _messages.dup;
    }

    /**
     * Set messages array from deserialization.
     * This bypasses the normal addMessage logic for efficiency.
     */
    void setMessagesFromDeserialization(ChatMessage[] messages)
    {
        _messages = messages.dup;
    }

    /**
     * Get current state as a serializable struct for persistence.
     */
    ChatContextData getSerializableData()
    {
        return ChatContextData(_messages.dup, _systemMessage, _selectedServer, _selectedModel);
    }

    /**
     * Restore state from serializable data.
     */
    void restoreFromSerializableData(ChatContextData data, string apiKey)
    {
        _apiKey = apiKey;
        _systemMessage = data.systemMessage;
        _selectedServer = data.selectedServer;
        _selectedModel = data.selectedModel;
        _messages = data.messages.dup;
    }
}

/**
 * Serializable data structure for ChatContext.
 */
struct ChatContextData
{
    ChatMessage[] messages;
    string systemMessage;
    string selectedServer;
    string selectedModel;
}
