module ui.gtkd.gtkd_settings_dialog;

import std.stdio;
import std.conv : to;
import std.algorithm;

import gtk.Dialog;
import gtk.Window;
import gtk.Box;
import gtk.Button;
import gtk.Label;
import gtk.ComboBoxText;
import gtk.TextView;
import gtk.TextBuffer;
import gtk.TextIter;
import gtk.ScrolledWindow;

import llm.chat_context;
import llm.llm_client;
import ui.settings_ui;

/**
 * GTK-D implementation of the settings dialog.
 * Allows users to change the LLM model and system message.
 */
class GtkDSettingsDialog : ISettingsDialog
{
    private Dialog _dialog;
    private ComboBoxText _modelCombo;
    private TextView _systemView;
    private TextBuffer _systemBuffer;
    private ChatContext _chatContext;
    private LLMClient _client;
    private void delegate() _onModelChanged;

    this(ChatContext chatContext, LLMClient client, Window parentWindow, void delegate() onModelChanged = null)
    {
        _chatContext = chatContext;
        _client = client;
        _onModelChanged = onModelChanged;

        _dialog = new Dialog();
        _dialog.setTitle("Settings");
        _dialog.setTransientFor(parentWindow);
        _dialog.setModal(true);
        _dialog.setDefaultSize(600, 400);

        setupDialogContent();
        setupButtons();
    }

    void show()
    {
        _dialog.showAll();
        _dialog.run();
        _dialog.destroy();
    }

    private void setupDialogContent()
    {
        auto contentBox = _dialog.getContentArea();
        contentBox.setMarginTop(10);
        contentBox.setMarginBottom(10);
        contentBox.setMarginStart(10);
        contentBox.setMarginEnd(10);
        contentBox.setSpacing(10);

        // Model selector
        auto modelLabel = new Label("Model:");
        modelLabel.setXalign(0.0);
        contentBox.packStart(modelLabel, false, false, 0);

        _modelCombo = new ComboBoxText();
        populateModelComboBox();
        contentBox.packStart(_modelCombo, false, false, 0);

        // System message editor
        auto systemLabel = new Label("System Message:");
        systemLabel.setXalign(0.0);
        contentBox.packStart(systemLabel, false, false, 0);

        auto scrolledWindow = new ScrolledWindow();
        scrolledWindow.setVexpand(true);
        import gtk.TextTagTable;

        _systemBuffer = new TextBuffer(cast(TextTagTable) null);
        _systemBuffer.setText(_chatContext.systemMessage);
        _systemView = new TextView(_systemBuffer);
        _systemView.setWrapMode(GtkWrapMode.WORD);
        scrolledWindow.add(_systemView);
        contentBox.packStart(scrolledWindow, true, true, 0);
    }

    private void populateModelComboBox()
    {
        string[] models = LLMClient.supportedModels();
        string currentModel = _client.model;
        int selectedIndex = 0;

        foreach (i, model; models)
        {
            _modelCombo.appendText(model);
            if (model == currentModel)
            {
                selectedIndex = cast(int) i;
            }
        }

        _modelCombo.setActive(selectedIndex);
    }

    private void setupButtons()
    {
        auto okButton = _dialog.addButton("OK", GtkResponseType.OK);
        auto cancelButton = _dialog.addButton("Cancel", GtkResponseType.CANCEL);

        _dialog.addOnResponse(&onDialogResponse);
    }

    private void onDialogResponse(int response, Dialog dialog)
    {
        if (response == GtkResponseType.OK)
        {
            applySettings();
        }
    }

    private void applySettings()
    {
        // Apply selected model
        string newModel = _modelCombo.getActiveText();
        bool modelChanged = (_client.model != newModel);
        _client.model = newModel;

        // Apply system message
        TextIter startIter, endIter;
        _systemBuffer.getStartIter(startIter);
        _systemBuffer.getEndIter(endIter);
        string newSystemMessage = _systemBuffer.getText(startIter, endIter, false);
        _chatContext.systemMessage = newSystemMessage;

        // Notify if model changed
        if (modelChanged && _onModelChanged !is null)
        {
            _onModelChanged();
        }
    }
}
