import std.stdio;
import std.process : environment;
import std.format;
import std.conv : to;

import dlangui;

import models.user;
import llm.chat_context;
import llm.llm_client;
import llm.message;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args)
{
	// Prepare API key and chat context
	const string apiKey = environment.get("GROQ_API_KEY", "");
	if (apiKey.length == 0)
	{
		stderr.writeln("GROQ_API_KEY is not set; UI will open but Send will fail.");
	}
	auto chatContext = new ChatContext(apiKey);
	chatContext.addMessage(ChatMessage("system", "You are a concise assistant."));

	// Create main window
	auto window = Platform.instance.createWindow("Dlang AI Client", null);

	// Root vertical layout
	auto root = new VerticalLayout();
	root.layoutWidth = FILL_PARENT;
	root.layoutHeight = FILL_PARENT;
	window.mainWidget = root;

	// Chat area: simple growing text widget
	auto chatText = new EditBox("");
	chatText.readOnly = true;
	chatText.focusable = false;
	chatText.wordWrap = true;
	chatText.hscrollbarMode = ScrollBarMode.Invisible;
	chatText.layoutWidth = FILL_PARENT;
	chatText.layoutHeight = FILL_PARENT;
	root.addChild(chatText);

	// Input row: prompt + Send + Clear
	auto inputRow = new HorizontalLayout();
	inputRow.layoutWidth = FILL_PARENT;
	inputRow.layoutHeight = WRAP_CONTENT;
	root.addChild(inputRow);

	auto promptField = new EditLine();
	// Expand to take remaining space in the row
	promptField.layoutWidth = FILL_PARENT;
	promptField.layoutHeight = WRAP_CONTENT;
	//promptField.weight = 1.0f;
	inputRow.addChild(promptField);

	auto sendBtn = new Button();
	sendBtn.text = "Send";
	sendBtn.layoutWidth = WRAP_CONTENT;
	sendBtn.layoutHeight = WRAP_CONTENT;
	inputRow.addChild(sendBtn);

	auto clearBtn = new Button();
	clearBtn.text = "Clear";
	clearBtn.layoutWidth = WRAP_CONTENT;
	clearBtn.layoutHeight = WRAP_CONTENT;
	inputRow.addChild(clearBtn);

	// LLM client
	auto client = new LLMClient();

	// Helpers to append messages to the chat area
	auto appendUser = (string text) {
		chatText.text = chatText.text ~ to!dstring((chatText.text.length ? "\n" : "") ~ "You: " ~ text);
	};
	auto appendAssistant = (string text) {
		chatText.text = chatText.text ~ to!dstring((chatText.text.length ? "\n" : "") ~ "Assistant: " ~ text);
	};

	// Send action
	bool delegate(Widget) doSend = delegate bool(Widget) {
		auto text = to!string(promptField.text);
		if (text.length == 0)
			return true;

		appendUser(text);
		promptField.text = "";

		// push to context and query
		chatContext.addMessage(ChatMessage("user", text));
		if (chatContext.apiKey.length == 0)
		{
			appendAssistant("[Error] GROQ_API_KEY not set");
			return true;
		}

		// Blocking request; for simplicity. Consider threading for production.
		auto reply = client.chatCompletion(chatContext);
		appendAssistant(reply);
		chatContext.addMessage(ChatMessage("assistant", reply));
		return true;
	};

	sendBtn.click = doSend;
	// Hook Enter handling via overridden onKeyEvent
	promptField.keyEvent = (Widget source, KeyEvent event) {
		if (promptField.text.length > 0 && event.action == KeyAction.KeyDown && event.keyCode == 13) 
		{
			doSend(promptField);
			return true;
		}
		return false;
	};

	// Clear action
	clearBtn.click = (w) {
		chatText.text = "";
		chatContext.clear();
		return true;
	};

	window.show();
	return Platform.instance.enterMessageLoop();
}
