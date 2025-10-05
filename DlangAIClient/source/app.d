import std.stdio;
import models.user;
import std.process : environment;
import llm.chat_context;
import llm.llm_client;
import llm.message;
import std.format;

void main()
{
	auto user = new User("Ada", "Lovelace");

	// Demo: LLM chat with API key from environment
	const string apiKey = environment.get("GROQ_API_KEY", "");
	if (apiKey.length == 0)
	{
		writeln("GROQ_API_KEY is not set; skipping LLM demo.");
		return;
	}

	auto ctx = new ChatContext(apiKey);
	ctx.addMessage(ChatMessage("system", "You are a concise assistant."));
	ctx.addMessage(ChatMessage("user", format("Say a short exciting greeting to %s.", user.fullName)));

	auto client = new LLMClient();
	auto reply = client.chatCompletion(ctx);
	writeln("LLM: " ~ reply);
}
