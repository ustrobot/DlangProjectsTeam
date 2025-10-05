module llm.message;

/**
 * Represents a single chat message.
 * Valid roles typically include: "system", "user", "assistant".
 */
struct ChatMessage
{
    string role;
    string content;
}


