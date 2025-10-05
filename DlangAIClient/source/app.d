import std.stdio;
import std.process : environment;
import std.format;

import dlangui;

import models.user;
import llm.chat_context;
import llm.llm_client;
import llm.message;
import ui.chat_window;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args)
{
	// Prepare API key and chat context
	const string apiKey = environment.get("GROQ_API_KEY", "");
	if (apiKey.length == 0)
	{
		stderr.writeln("GROQ_API_KEY is not set; UI will open but Send will fail.");
	}
    auto chatContext = new ChatContext(apiKey, "You are a concise assistant.");

	// LLM client and ChatWindow
    auto client = new LLMClient("https://api.groq.com/openai/v1/", ModelIds.llama_3_1_8b_instant);
	auto window = new ChatWindow(chatContext, client);
	window.show();
	return Platform.instance.enterMessageLoop();
}
