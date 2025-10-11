import std.stdio;
import std.process : environment;
import std.format;
import std.algorithm;
import std.string;
import std.getopt;

import models.user;
import llm.chat_context;
import llm.chat_persistence;
import llm.llm_client;
import llm.server_preset;
import llm.message;
import ui.ui_factory;
import ui.chat_ui;

// We need to handle two different frameworks with different initialization requirements
// DlangUI: requires UIAppMain and Platform initialization
// GTK-D: uses standard main() with gtk.Main.init()

// Strategy: Use dlangui's entry point, but detect framework choice and handle accordingly

import dlangui;
mixin APP_ENTRY_POINT;

// Global persistence manager
private __gshared ChatPersistence _persistence;

/**
 * Validate that the selected server and model are still available.
 * Returns true if settings dialog needs to be shown.
 */
private bool validateServerAndModelConfiguration(ChatContext chatContext, LLMClient client)
{
    string selectedServer = chatContext.selectedServer;
    string selectedModel = chatContext.selectedModel;

    // If no server is selected, need settings dialog
    if (selectedServer.length == 0)
    {
        return true;
    }

    // Try to load the server preset
    auto presetManager = new ServerPresetManager();
    try
    {
        auto preset = presetManager.getPreset(p => p.server == selectedServer);

        // Configure client with the preset
        client.baseUrl = preset.server;
        client.apiKey = preset.token;

        // Try to load models from the server
        auto models = client.getAvailableModels();

        // Check if the selected model is available
        foreach (model; models)
        {
            if (model.id == selectedModel)
            {
                // Model is available, configuration is valid
                client.model = selectedModel;
                return false;
            }
        }

        // Model not found in the available models
        writeln("Warning: Selected model '", selectedModel, "' not found on server '", selectedServer, "'");
        return true;
    }
    catch (Exception e)
    {
        writeln("Warning: Failed to validate server configuration: ", e.msg);
        return true;
    }
}

/**
 * DlangUI entry point - this is called by dlangui's platform initialization.
 * We use this as our main entry point and handle both frameworks from here.
 */
extern (C) int UIAppMain(string[] args)
{
    // Initialize persistence manager
    _persistence = new ChatPersistence();

    // Parse command-line arguments
    string uiFramework = "dlangui"; // Default to dlangui
    bool showHelp = false;

    try
    {
        auto helpInformation = getopt(
            args,
            "UI", "UI framework to use (dlangui or gtk-d). Default: dlangui", &uiFramework,
            "help|h", "Show this help message", &showHelp
        );

        if (showHelp || helpInformation.helpWanted)
        {
            defaultGetoptPrinter(
                "Dlang AI Client - A multi-framework AI chat application\n\n" ~
                "Usage: dlang-ai-client [options]\n\n" ~
                "Options:",
                helpInformation.options
            );
            return 0;
        }
    }
    catch (Exception e)
    {
        stderr.writefln("Error parsing arguments: %s", e.msg);
        stderr.writeln("Use --help for usage information");
        return 1;
    }

    // Determine UI framework
    UIFramework framework;
    try
    {
        framework = UIFactory.parseFramework(uiFramework);
        writefln("Starting with %s UI framework...", uiFramework);
    }
    catch (Exception e)
    {
        stderr.writeln(e.msg);
        stderr.writeln("Use --help for usage information");
        return 1;
    }

    // Prepare API key and chat context
    const string apiKey = environment.get("GROQ_API_KEY", "");
    if (apiKey.length == 0)
    {
        stderr.writeln("GROQ_API_KEY is not set; UI will open but Send will fail.");
    }

    // Load saved chat context or create new one
    auto chatContext = _persistence.loadContext(apiKey, "You are a concise assistant.", "", "");
    writeln("Loaded chat context with ", chatContext.messages.length, " messages");

    // LLM client (will be configured based on server selection)
    auto client = new LLMClient("https://api.groq.com/openai/v1/", "llama-3.1-8b-instant", apiKey);

    // Validate server and model configuration
    bool needsSettingsDialog = validateServerAndModelConfiguration(chatContext, client);
    // If the server and model are valid, set the client to the selected server and model
    if (!needsSettingsDialog)
    {
        client.baseUrl = chatContext.selectedServer;
        client.model = chatContext.selectedModel;
    }

    // Set up cleanup to save context on exit
    scope(exit)
    {
        writeln("Saving chat context...");
        _persistence.saveContext(chatContext);
        writeln("Chat context saved to ", _persistence.dataDir);
    }

    // Handle framework-specific initialization
    final switch (framework)
    {
        case UIFramework.DlangUI:
            // We're already inside UIAppMain, so Platform is initialized
            // Create and run DlangUI window
            IChatUI ui = UIFactory.createChatUI(framework, chatContext, client);

            // Show settings dialog if needed before showing main window
            if (needsSettingsDialog)
            {
                writeln("Showing settings dialog for configuration...");
                // The UI should handle showing the settings dialog
                // For now, we'll just show the main window and let it handle the settings
            }

            ui.show();
            return ui.run();

        case UIFramework.GtkD:
            // GTK-D needs to run outside of dlangui's Platform
            // We need to clean up dlangui's platform first
            stderr.writeln("Warning: Running GTK-D from dlangui entry point.");
            stderr.writeln("Note: Some dlangui initialization has already occurred.");

            // Create and run GTK-D window
            // The GtkD implementation will call gtk.Main.init()
            IChatUI gtkUI = UIFactory.createChatUI(framework, chatContext, client);

            // Show settings dialog if needed before showing main window
            if (needsSettingsDialog)
            {
                writeln("Showing settings dialog for configuration...");
                // The UI should handle showing the settings dialog
            }

            gtkUI.show();
            return gtkUI.run();
    }
}
