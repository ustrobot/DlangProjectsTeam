module ui.chat_window;
import std.array;
import std.algorithm;
import std.stdio;
import std.conv : to;
import dlangui;

import llm.chat_context;
import llm.llm_client;
import llm.message;
import ui.settings_dialog;

/**
 * ChatWindow encapsulates the entire chat UI and interactions.
 * Uses composition: owns a platform Window instance.
 */
class ChatWindow
{
    private Window _window;
    private EditBox _chatText;
    private EditLine _promptField;
    private Button _sendBtn;
    private Button _clearBtn;
    private Button _settingsBtn;
    private TextWidget _modelLabel;
    private ChatContext _chatContext;
    private LLMClient _client;

    this(ChatContext chatContext, LLMClient client)
    {
        _chatContext = chatContext;
        _client = client;

        _window = Platform.instance.createWindow("Dlang AI Client", null,  WindowFlag.Resizable, 1200, 900);

        auto root = new VerticalLayout();
        root.layoutWidth = FILL_PARENT;
        root.layoutHeight = FILL_PARENT;
        _window.mainWidget = root;


        _chatText = new EditBox("");
        _chatText.readOnly = true;
        _chatText.focusable = false;
        _chatText.wordWrap = true;
        _chatText.hscrollbarMode = ScrollBarMode.Invisible;
        _chatText.layoutWidth = FILL_PARENT;
        _chatText.layoutHeight = FILL_PARENT;
        root.addChild(_chatText);

        auto inputRow = new HorizontalLayout();
        inputRow.layoutWidth = FILL_PARENT;
        inputRow.layoutHeight = WRAP_CONTENT;
        root.addChild(inputRow);

        _promptField = new EditLine();
        _promptField.layoutWidth = FILL_PARENT;
        _promptField.layoutHeight = WRAP_CONTENT;
        inputRow.addChild(_promptField);

        _sendBtn = new Button();
        _sendBtn.text = "Send";
        _sendBtn.layoutWidth = WRAP_CONTENT;
        _sendBtn.layoutHeight = WRAP_CONTENT;
        inputRow.addChild(_sendBtn);

        _clearBtn = new Button();
        _clearBtn.text = "Clear";
        _clearBtn.layoutWidth = WRAP_CONTENT;
        _clearBtn.layoutHeight = WRAP_CONTENT;
        inputRow.addChild(_clearBtn);

        // Bottom bar with model name and settings button
        auto bottomBar = new HorizontalLayout();
        bottomBar.layoutWidth = FILL_PARENT;
        bottomBar.layoutHeight = WRAP_CONTENT;
        root.addChild(bottomBar);

        // Model name label (left side)
        _modelLabel = new TextWidget("", to!dstring("Model: " ~ _client.model));
        _modelLabel.layoutWidth = FILL_PARENT;
        _modelLabel.layoutHeight = WRAP_CONTENT;
        bottomBar.addChild(_modelLabel);

        // Settings button (right side)
        _settingsBtn = new Button();
        _settingsBtn.text = "Settings";
        _settingsBtn.layoutWidth = WRAP_CONTENT;
        _settingsBtn.layoutHeight = WRAP_CONTENT;
        bottomBar.addChild(_settingsBtn);

        // Wire events
        _sendBtn.click = &onSendClicked;
        _promptField.keyEvent = &onPromptKeyEvent;
        _clearBtn.click = &onClearClicked;
        _settingsBtn.click = &onSettingsClicked;
    }

    void show()
    {
        _window.show();
    }

    @property Window window()
    {
        return _window;
    }

    private void appendUser(string text)
    {
        _chatText.text = _chatText.text ~ to!dstring((_chatText.text.length ? "\n" : "") ~ "You: " ~ text);
    }

    private void appendAssistant(string text)
    {
        _chatText.text = _chatText.text ~ to!dstring((_chatText.text.length ? "\n" : "") ~ "Assistant: " ~ text);
    }

    private bool onSendClicked(Widget w)
    {
        auto text = to!string(_promptField.text);
        if (text.length == 0)
            return true;

        appendUser(text);
        _promptField.text = "";

        _chatContext.addMessage(ChatMessage("user", text));
        if (_chatContext.apiKey.length == 0)
        {
            appendAssistant("[Error] GROQ_API_KEY not set");
            return true;
        }

        auto reply = _client.chatCompletion(_chatContext);
        appendAssistant(reply);
        _chatContext.addMessage(ChatMessage("assistant", reply));
        return true;
    }

    private bool onPromptKeyEvent(Widget source, KeyEvent event)
    {
        if (_promptField.text.length > 0 && event.action == KeyAction.KeyDown && event.keyCode == 13)
        {
            onSendClicked(_promptField);
            return true;
        }
        return false;
    }

    private bool onClearClicked(Widget w)
    {
        _chatText.text = "";
        _chatContext.clear();
        return true;
    }

    private void showSettingsDialog()
    {
        auto settingsDialog = new SettingsDialog(_chatContext, _client, _window, delegate ()
        {
            _modelLabel.text = to!dstring("Model: " ~ _client.model);
        });
        settingsDialog.show();
    }

    private bool onSettingsClicked(Widget w)
    {
        showSettingsDialog();
        return true;
    }
}


