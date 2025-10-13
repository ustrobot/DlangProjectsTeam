module ui.chat_ui;

/**
 * Interface for chat UI implementations.
 * Allows different UI frameworks to be used interchangeably.
 */
interface IChatUI
{
    /**
     * Show the chat window
     */
    void show();

    /**
     * Append a user message to the chat display
     */
    void appendUserMessage(string text);

    /**
     * Append an assistant message to the chat display
     */
    void appendAssistantMessage(string text);

    /**
     * Clear the chat display and context
     */
    void clearChat();

    /**
     * Update the model label with the current model name
     */
    void updateModelLabel(string model);

    /**
     * Update the server label with the current server name
     */
    void updateServerLabel(string server);

    /**
     * Run the UI message loop
     * Returns exit code
     */
    int run();
}
