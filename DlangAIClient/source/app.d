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
    auto chatContext = _persistence.loadContext(apiKey, "You are a concise assistant.");
    writeln("Loaded chat context with ", chatContext.messages.length, " messages");

    // LLM client
    auto client = new LLMClient("https://api.groq.com/openai/v1/", ModelIds.llama_3_1_8b_instant);

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
            gtkUI.show();
            return gtkUI.run();
    }
}
