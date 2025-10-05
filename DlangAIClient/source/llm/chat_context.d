module llm.chat_context;

import llm.message;

/**
 * Holds chat history and related configuration like the API key.
 */
class ChatContext
{
    private ChatMessage[] _messages;
    private string _apiKey;

    this(string apiKey)
    {
        _apiKey = apiKey;
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
}


