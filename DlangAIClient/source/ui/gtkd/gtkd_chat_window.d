module ui.gtkd.gtkd_chat_window;

import std.stdio;
import std.conv : to;
import std.string;

import gtk.MainWindow;
import gtk.Main;
import gtk.Widget;
import gtk.Box;
import gtk.Button;
import gtk.Entry;
import gtk.TextView;
import gtk.TextBuffer;
import gtk.TextIter;
import gtk.ScrolledWindow;
import gtk.Label;
import gdk.Event;
import gdk.Keysyms;
import pango.PgFontDescription;

import llm.chat_context;
import llm.llm_client;
import llm.message : MessageRole, ChatMessage;
import ui.chat_ui;
import ui.gtkd.gtkd_settings_dialog;

/**
 * GTK-D implementation of the chat window.
 * Uses GTK+ widgets for the user interface.
 */
class GtkDChatWindow : IChatUI
{
    private MainWindow _window;
    private TextView _chatView;
    private TextBuffer _chatBuffer;
    private Entry _promptEntry;
    private Button _sendBtn;
    private Button _clearBtn;
    private Button _settingsBtn;
    private Label _modelLabel;
    private Label _serverLabel;
    private ChatContext _chatContext;
    private LLMClient _client;
    private bool _initialized = false;

    // Font constants for consistent sizing
    private static PgFontDescription CHAT_FONT_DESC;
    private static PgFontDescription UI_FONT_DESC;

    // Static constructor to initialize font descriptions
    static this()
    {
        CHAT_FONT_DESC = PgFontDescription.fromString("Monospace 14");
        UI_FONT_DESC = PgFontDescription.fromString("Sans 14");
    }

    this(ChatContext chatContext, LLMClient client)
    {
        _chatContext = chatContext;
        _client = client;

        // Initialize GTK if not already done
        if (!_initialized)
        {
            string[] args;
            Main.init(args);
            _initialized = true;
        }

        createWindow();
        populateChatFromContext();
    }

    private void createWindow()
    {
        _window = new MainWindow("Dlang AI Client");
        _window.setDefaultSize(1200, 900);
        _window.addOnDelete(&onWindowDelete);

        // Main vertical box
        auto mainBox = new Box(GtkOrientation.VERTICAL, 5);
        mainBox.setMarginTop(5);
        mainBox.setMarginBottom(5);
        mainBox.setMarginStart(5);
        mainBox.setMarginEnd(5);

        // Chat display area (scrolled)
        auto scrolledWindow = new ScrolledWindow();
        scrolledWindow.setVexpand(true);
        import gtk.TextTagTable;

        _chatBuffer = new TextBuffer(cast(TextTagTable) null);
        _chatView = new TextView(_chatBuffer);
        _chatView.setEditable(false);
        _chatView.setWrapMode(GtkWrapMode.WORD);

        // Set font size to be 2 points larger than default
        _chatView.overrideFont(CHAT_FONT_DESC);
        scrolledWindow.add(_chatView);
        mainBox.packStart(scrolledWindow, true, true, 0);

        // Input row
        auto inputBox = new Box(GtkOrientation.HORIZONTAL, 5);
        _promptEntry = new Entry();
        _promptEntry.setHexpand(true);
        _promptEntry.addOnActivate(&onSendActivated);

        // Set font size for input field to match chat view
        _promptEntry.overrideFont(UI_FONT_DESC);

        inputBox.packStart(_promptEntry, true, true, 0);

        _sendBtn = new Button("Send");
        _sendBtn.addOnClicked(&onSendClicked);

        // Set font size for send button
        _sendBtn.overrideFont(UI_FONT_DESC);

        inputBox.packStart(_sendBtn, false, false, 0);

        _clearBtn = new Button("Clear");
        _clearBtn.addOnClicked(&onClearClicked);

        // Set font size for clear button
        _clearBtn.overrideFont(UI_FONT_DESC);

        inputBox.packStart(_clearBtn, false, false, 0);

        mainBox.packStart(inputBox, false, false, 0);

        // Bottom bar with model label, server label, and settings button
        auto bottomBox = new Box(GtkOrientation.HORIZONTAL, 5);
        _modelLabel = new Label("Model: " ~ _client.model);
        _modelLabel.setHexpand(false);
        _modelLabel.setXalign(0.0); // Left align

        // Set font size for model label
        _modelLabel.overrideFont(UI_FONT_DESC);

        bottomBox.packStart(_modelLabel, false, false, 0);

        string serverText = _chatContext.selectedServer.length > 0 ? _chatContext.selectedServer : "Not selected";
        _serverLabel = new Label(" at " ~ serverText);
        _serverLabel.setHexpand(true);
        _serverLabel.setXalign(0.0); // Left align

        // Set font size for server label
        _serverLabel.overrideFont(UI_FONT_DESC);

        bottomBox.packStart(_serverLabel, true, true, 0);

        _settingsBtn = new Button("Settings");
        _settingsBtn.addOnClicked(&onSettingsClicked);

        // Set font size for settings button
        _settingsBtn.overrideFont(UI_FONT_DESC);

        bottomBox.packStart(_settingsBtn, false, false, 0);

        mainBox.packStart(bottomBox, false, false, 0);

        _window.add(mainBox);
    }

    private void populateChatFromContext()
    {
        foreach (message; _chatContext.messages)
        {
            string displayText;
            switch (message.role)
            {
            case MessageRole.USER:
                displayText = "You: " ~ message.content;
                break;
            case MessageRole.ASSISTANT:
                displayText = "Assistant: " ~ message.content;
                break;
            case MessageRole.SYSTEM:
                // Skip system messages - don't display them
                continue;
            default:
                displayText = message.role ~ ": " ~ message.content;
                break;
            }
            appendToChat(displayText);
        }
    }

    void show()
    {
        _window.showAll();
    }

    int run()
    {
        Main.run();
        return 0;
    }

    void appendUserMessage(string text)
    {
        appendToChat("You: " ~ text);
    }

    void appendAssistantMessage(string text)
    {
        appendToChat("Assistant: " ~ text);
    }

    void clearChat()
    {
        _chatBuffer.setText("");
        _chatContext.clear();
    }

    void updateModelLabel(string model)
    {
        _modelLabel.setText("Model: " ~ model);
    }

    void updateServerLabel(string server)
    {
        _serverLabel.setText("Server: " ~ (server.length > 0 ? server : "Not selected"));
    }

    private void appendToChat(string text)
    {
        TextIter iter;
        _chatBuffer.getEndIter(iter);

        // Add newline if buffer is not empty
        if (_chatBuffer.getCharCount() > 0)
        {
            _chatBuffer.insert(iter, "\n");
            _chatBuffer.getEndIter(iter);
        }

        _chatBuffer.insert(iter, text);

        // Auto-scroll to bottom
        _chatBuffer.getEndIter(iter);
        _chatView.scrollToIter(iter, 0.0, false, 0.0, 0.0);
    }

    private void onSendActivated(Entry entry)
    {
        sendMessage();
    }

    private void onSendClicked(Button button)
    {
        sendMessage();
    }

    private void sendMessage()
    {
        string text = _promptEntry.getText();
        if (text.strip().length == 0)
            return;

        appendUserMessage(text);
        _promptEntry.setText("");

        _chatContext.addMessage(ChatMessage(MessageRole.USER, text));
        if (_chatContext.apiKey.length == 0)
        {
            appendAssistantMessage("[Error] GROQ_API_KEY not set");
            return;
        }

        try
        {
            auto reply = _client.chatCompletion(_chatContext);
            appendAssistantMessage(reply);
            _chatContext.addMessage(ChatMessage(MessageRole.ASSISTANT, reply));
        }
        catch (Exception e)
        {
            appendAssistantMessage("[Error] " ~ e.msg);
        }
    }

    private void onClearClicked(Button button)
    {
        clearChat();
    }

    private void onSettingsClicked(Button button)
    {
        auto settingsDialog = new GtkDSettingsDialog(_chatContext, _client, _window, delegate() {
            updateModelLabel(_client.model);
            updateServerLabel(_chatContext.selectedServer);
        });
        settingsDialog.show();
    }

    private bool onWindowDelete(Event event, Widget widget)
    {
        Main.quit();
        return false;
    }
}
