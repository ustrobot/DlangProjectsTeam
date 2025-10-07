module ui.ui_factory;

import ui.chat_ui;
import llm.chat_context;
import llm.llm_client;

/**
 * Supported UI frameworks
 */
enum UIFramework
{
    DlangUI,
    GtkD
}

/**
 * Factory for creating UI instances based on the selected framework
 */
class UIFactory
{
    /**
     * Create a chat UI instance for the specified framework
     */
    static IChatUI createChatUI(UIFramework framework, ChatContext chatContext, LLMClient client)
    {
        final switch (framework)
        {
        case UIFramework.DlangUI:
            import ui.dlangui.dlangui_chat_window;

            return new DlangUIChatWindow(chatContext, client);

        case UIFramework.GtkD:
            import ui.gtkd.gtkd_chat_window;

            return new GtkDChatWindow(chatContext, client);
        }
    }

    /**
     * Parse UI framework from string
     * Returns null if invalid
     */
    static UIFramework parseFramework(string name)
    {
        import std.uni : toLower;
        import std.string : strip;

        string normalized = name.strip().toLower();

        switch (normalized)
        {
        case "dlangui":
            return UIFramework.DlangUI;
        case "gtk-d":
        case "gtkd":
        case "gtk":
            return UIFramework.GtkD;
        default:
            throw new Exception("Unknown UI framework: " ~ name ~ ". Supported: dlangui, gtk-d");
        }
    }
}
