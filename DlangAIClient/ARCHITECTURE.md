# Architecture Notes

## Entry Point and Initialization

### DlangUI Requirements

DlangUI has specific initialization requirements that affect the application architecture:

1. **APP_ENTRY_POINT Mixin**: DlangUI requires the `mixin APP_ENTRY_POINT` which creates the platform-specific main function
2. **UIAppMain**: The actual application logic must be in `extern (C) int UIAppMain(string[] args)`
3. **Platform Initialization**: `Platform.instance` must be initialized before creating windows
4. **Message Loop**: `Platform.instance.enterMessageLoop()` must be called to run the UI

### Current Implementation

The application uses **UIAppMain as the primary entry point** for both frameworks:

```d
import dlangui;
mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args)
{
    // Parse arguments
    // Create context and client
    // Select framework
    // Create UI
    // Run message loop
}
```

### Framework-Specific Handling

#### DlangUI
- Runs natively within UIAppMain
- Platform is already initialized by APP_ENTRY_POINT
- Window creation and message loop work as expected
- **This is the intended and correct usage**

#### GTK-D
- Also runs from UIAppMain (after dlangui initialization)
- GTK-D calls `gtk.Main.init()` in its constructor
- GTK-D's `Main.run()` manages its own event loop
- **Note**: Some dlangui initialization has occurred, but GTK-D uses its own toolkit

### Why This Architecture?

**Option 1: Separate Binaries** ❌
- Could build separate binaries for each framework
- Requires conditional compilation
- Users must choose at compile time
- More complex build process

**Option 2: Dynamic Entry Point Selection** ❌
- Can't easily switch between main() and UIAppMain at runtime
- C requires single entry point
- Would need complex launcher logic

**Option 3: Use UIAppMain for Both** ✅ (Current)
- Single binary supports both frameworks
- DlangUI works correctly (proper initialization)
- GTK-D works but with dlangui pre-initialized
- Users choose framework at runtime via --UI flag
- Simpler build process

### Limitations

1. **GTK-D with DlangUI Initialized**: When using GTK-D, dlangui's Platform has been initialized (but not used). *This is generally harmless but worth noting*.

2. **Platform Dependencies**: Both dlangui and GTK-D libraries are always linked, *increasing binary size*.

3. **Initialization Order**: GTK-D initialization happens after dlangui's platform initialization.

### Future Improvements

If the current approach causes issues, alternatives include:

1. **Launcher Wrapper**: Small launcher binary that execs the appropriate binary
   ```
   dlang-ai-client (launcher) -> dlang-ai-client-dlangui
                               -> dlang-ai-client-gtkd
   ```

2. **Configuration-Based Build**: Use dub configurations to build different binaries
   ```bash
   dub build --config=dlangui
   dub build --config=gtkd
   ```

3. **Plugin Architecture**: Load UI frameworks dynamically via shared libraries

For now, the current approach provides the best balance of flexibility and simplicity.

## Code Organization

### Interface Layer
```
ui/chat_ui.d           - IChatUI interface
ui/settings_ui.d       - ISettingsDialog interface
ui/ui_factory.d        - Factory for creating UI instances
```

### Implementation Layer
```
ui/dlangui/            - DlangUI implementation
  dlangui_chat_window.d
  dlangui_settings_dialog.d

ui/gtkd/               - GTK-D implementation
  gtkd_chat_window.d
  gtkd_settings_dialog.d
```

### Business Logic
```
llm/                   - LLM client and chat logic
models/                - Data models
```

### Entry Point
```
app.d                  - UIAppMain, argument parsing, framework selection
```

## Message Flow

### Startup
1. Platform initializes (dlangui's APP_ENTRY_POINT)
2. UIAppMain is called
3. Arguments are parsed
4. Framework is selected
5. ChatContext and LLMClient are created
6. UIFactory creates appropriate UI instance
7. UI.show() is called
8. UI.run() enters the message loop

### Chat Interaction
1. User types message and presses Send/Enter
2. UI calls appendUserMessage()
3. UI creates ChatMessage and adds to ChatContext
4. UI calls LLMClient.chatCompletion()
5. LLMClient sends HTTP request to API
6. Response is received and parsed
7. UI calls appendAssistantMessage()
8. ChatContext stores assistant response

### Settings Change
1. User clicks Settings button
2. Settings dialog is created and shown
3. User selects new model or edits system message
4. On OK: Changes are applied to LLMClient and ChatContext
5. Callback updates model label in main window
6. Dialog closes

## Dependencies

```
dlangui (Required for entry point)
  └─ bindbc-sdl, bindbc-opengl, etc.

gtk-d (Required for GTK-D UI)
  └─ GTK+ 3 system libraries

vibe-d (Required for HTTP requests)
  └─ Used by LLMClient for API calls
```

## Testing Strategy

### Unit Tests
- LLMClient: Mock HTTP responses
- ChatContext: Test message management
- UIFactory: Test framework selection logic

### Integration Tests
- Test each UI with actual API calls
- Verify settings persistence
- Test error handling

### Manual Testing
- Test on different platforms (Linux, Windows, macOS)
- Test both UI frameworks
- Verify keyboard shortcuts
- Test with/without API key

## Platform Support

| Platform | DlangUI | GTK-D | Notes |
|----------|---------|-------|-------|
| Linux    | ✅      | ✅    | Both work well |
| Windows  | ✅      | ⚠️    | GTK-D requires GTK+ runtime |
| macOS    | ✅      | ⚠️    | GTK-D requires GTK+ via Homebrew |

For best cross-platform support, **DlangUI is recommended** as the default.

