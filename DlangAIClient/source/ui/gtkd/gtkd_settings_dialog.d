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
import llm.server_preset;
import ui.settings_ui;

/**
 * GTK-D implementation of the settings dialog.
 * Allows users to change the LLM model and system message.
 */
class GtkDSettingsDialog : ISettingsDialog
{
    private Dialog _dialog;
    private ComboBoxText _serverCombo;
    private ComboBoxText _modelCombo;
    private TextView _systemView;
    private TextBuffer _systemBuffer;
    private ChatContext _chatContext;
    private LLMClient _client;
    private ServerPresetManager _presetManager;
    private ModelInfo[] _availableModels;
    private void delegate() _onModelChanged;

    this(ChatContext chatContext, LLMClient client, Window parentWindow, void delegate() onModelChanged = null)
    {
        _chatContext = chatContext;
        _client = client;
        _onModelChanged = onModelChanged;

        // Initialize server preset manager
        _presetManager = new ServerPresetManager();

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

        // Server selector
        auto serverLabel = new Label("Server:");
        serverLabel.setXalign(0.0);
        contentBox.packStart(serverLabel, false, false, 0);

        _serverCombo = new ComboBoxText();
        _serverCombo.addOnChanged(&onServerChanged);
        contentBox.packStart(_serverCombo, false, false, 0);

        // Model selector
        auto modelLabel = new Label("Model:");
        modelLabel.setXalign(0.0);
        contentBox.packStart(modelLabel, false, false, 0);

        _modelCombo = new ComboBoxText();
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

        populateServerComboBox();
        populateModelComboBox();
    }

    private void populateServerComboBox()
    {
        auto presets = _presetManager.getAllPresets();
        string currentServer = _chatContext.selectedServer;
        int selectedIndex = 0;

        foreach (i, preset; presets)
        {
            _serverCombo.appendText(preset.name);
            if (preset.server == currentServer)
            {
                selectedIndex = cast(int) i;
            }
        }

        _serverCombo.setActive(selectedIndex);

        // Load models for the initially selected server
        loadModelsForSelectedServer(selectedIndex);
    }

    private void populateModelComboBox()
    {
        // Clear existing items
        _modelCombo.removeAll();

        if (_availableModels.length > 0)
        {
            string currentModel = _client.model;
            int selectedIndex = 0;

            foreach (i, model; _availableModels)
            {
                _modelCombo.appendText(model.id);
                if (model.id == currentModel)
                {
                    selectedIndex = cast(int) i;
                }
            }

            _modelCombo.setActive(selectedIndex);
        }
        else
        {
            // No models available, show a placeholder
            _modelCombo.appendText("No models available");
            _modelCombo.setActive(0);
        }
    }

    private void loadModelsForSelectedServer(int itemIndex)
    {
        if (itemIndex < 0)
        {
            _availableModels = [];
            populateModelComboBox();
            return;
        }

        string serverName = _serverCombo.getActiveText();

        // Load preset and get models
        try
        {
            auto preset = _presetManager.getPreset(p => p.name == serverName);

            // Update the main client's configuration
            _client.baseUrl = preset.server;
            _client.apiKey = preset.token;
            _chatContext.selectedServer = preset.server;

            // Load models using the main client (now configured with the preset)
            _availableModels = _client.getAvailableModels();

            populateModelComboBox();

            // Select first model if available and no current model is set
            if (_availableModels.length > 0 && _client.model.length == 0)
            {
                _modelCombo.setActive(0);
            }
        }
        catch (Exception e)
        {
            writeln("Warning: Failed to load models for server ", serverName, ": ", e.msg);
            _availableModels = [];
            populateModelComboBox();
        }
    }

    private void onServerChanged(ComboBoxText combo)
    {
        int activeIndex = combo.getActive();
        loadModelsForSelectedServer(activeIndex);
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
        _chatContext.selectedModel = newModel;

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
