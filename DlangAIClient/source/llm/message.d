module llm.message;

/**
 * Constants for message roles.
 */
enum MessageRole
{
    SYSTEM = "system",
    USER = "user",
    ASSISTANT = "assistant"
}

/**
 * Represents a single chat message.
 * Valid roles typically include: "system", "user", "assistant".
 */
struct ChatMessage
{
    MessageRole role;
    string content;
}
