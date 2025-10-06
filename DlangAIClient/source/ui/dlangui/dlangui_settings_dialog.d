module ui.dlangui.dlangui_settings_dialog;

import std.array;
import std.algorithm;
import std.conv : to;
import dlangui;
import dlangui.dialogs.dialog;

import llm.chat_context;
import llm.llm_client;
import ui.settings_ui;

/**
 * DlangUI implementation of the settings dialog.
 * Allows users to change the LLM model and system message.
 */
class DlangUISettingsDialog : ISettingsDialog
{
    private Dialog _dialog;
    private ComboBox _modelCombo;
    private EditBox _systemBox;
    private ChatContext _chatContext;
    private LLMClient _client;
    private void delegate() _onModelChanged;

    // Constants for settings dialog
    private enum
    {
        LABEL_MIN_HEIGHT = 30,
        SYSTEM_BOX_MIN_HEIGHT = 600,
        SYSTEM_BOX_MIN_WIDTH = 600,
        BUTTON_ROW_HEIGHT = 40
    }

    this(ChatContext chatContext, LLMClient client, Window parentWindow, void delegate() onModelChanged = null)
    {
        _chatContext = chatContext;
        _client = client;
        _onModelChanged = onModelChanged;

        _dialog = new Dialog(UIString.fromRaw("Settings"d), parentWindow);
        setupDialogContent();
        setupModelSelector();
        setupSystemPromptEditor();
        setupDialogButtons();
    }

    void show()
    {
        _dialog.show();
    }

    private void setupDialogContent()
    {
        auto content = _dialog;
        content.backgroundColor = Color.light_gray;
        content.layoutWidth = WRAP_CONTENT;
        content.layoutHeight = WRAP_CONTENT;
        content.minHeight = 1;
    }

    private void setupModelSelector()
    {
        auto content = _dialog;

        // Model label
        auto modelLabel = new TextWidget("", "Model"d);
        modelLabel.minHeight = LABEL_MIN_HEIGHT;
        content.addChild(modelLabel);

        // Model combo box
        _modelCombo = new ComboBox();
        populateModelComboBox();
        content.addChild(_modelCombo);
    }

    private void populateModelComboBox()
    {
        string[] models = LLMClient.supportedModels();
        _modelCombo.items = models.map!(m => to!dstring(m)).array;

        // Select current model if available
        string currentModel = _client.model;
        foreach (i; 0 .. _modelCombo.items.length)
        {
            if (equal(_modelCombo.items[i].value, currentModel))
            {
                _modelCombo.selectedItemIndex = i;
                break;
            }
        }
    }

    private void setupSystemPromptEditor()
    {
        auto content = _dialog;

        // System prompt label
        auto systemLabel = new TextWidget("", "System Message"d);
        systemLabel.minHeight = LABEL_MIN_HEIGHT;
        content.addChild(systemLabel);

        // System prompt edit box
        _systemBox = new EditBox("");
        configureSystemPromptBox();
        content.addChild(_systemBox);
    }

    private void configureSystemPromptBox()
    {
        _systemBox.layoutWidth = FILL_PARENT;
        _systemBox.layoutHeight = WRAP_CONTENT;
        _systemBox.minHeight = SYSTEM_BOX_MIN_HEIGHT;
        _systemBox.minWidth = SYSTEM_BOX_MIN_WIDTH;
        _systemBox.wordWrap = true;
        _systemBox.focusable = true;
        _systemBox.readOnly = false;
        _systemBox.text = to!dstring(_chatContext.systemMessage);
    }

    private void setupDialogButtons()
    {
        auto content = _dialog;

        // Button row
        auto buttonRow = new HorizontalLayout();
        buttonRow.layoutWidth = FILL_PARENT;
        buttonRow.minHeight = BUTTON_ROW_HEIGHT;
        buttonRow.maxHeight = BUTTON_ROW_HEIGHT;

        auto okButton = new Button();
        okButton.text = "OK";
        auto cancelButton = new Button();
        cancelButton.text = "Cancel";

        buttonRow.addChild(okButton);
        buttonRow.addChild(cancelButton);
        content.addChild(buttonRow);

        // Wire button events
        okButton.click = &onSettingsOkClicked;
        cancelButton.click = &onSettingsCancelClicked;
    }

    private bool onSettingsOkClicked(Widget w)
    {
        // Apply selected model
        UIString selectedModel = _modelCombo.items[_modelCombo.selectedItemIndex];
        string newModel = to!string(selectedModel.value);
        bool modelChanged = (_client.model != newModel);
        _client.model = newModel;

        // Apply system message
        _chatContext.systemMessage = to!string(_systemBox.text);

        // Notify if model changed
        if (modelChanged && _onModelChanged !is null)
        {
            _onModelChanged();
        }

        _dialog.close(null);
        return true;
    }

    private bool onSettingsCancelClicked(Widget w)
    {
        _dialog.close(null);
        return true;
    }
}

