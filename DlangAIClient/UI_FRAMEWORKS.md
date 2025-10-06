# Multi-UI Framework Support

This application supports multiple UI frameworks, allowing you to choose your preferred UI toolkit.

## Supported Frameworks

### 1. DlangUI (Default)
- **Description**: Cross-platform UI library written in D
- **Platform**: Linux, Windows, macOS
- **Rendering**: OpenGL-based

### 2. GTK-D
- **Description**: D bindings for GTK+ 3
- **Platform**: Primarily Linux, also Windows and macOS
- **Rendering**: Native GTK+ widgets

## Usage

### Running with DlangUI (Default)

```bash
./dlang-ai-client
```

or explicitly:

```bash
./dlang-ai-client --UI=dlangui
```

### Running with GTK-D

```bash
./dlang-ai-client --UI=gtk-d
```

Alternative names also work:
```bash
./dlang-ai-client --UI=gtkd
./dlang-ai-client --UI=gtk
```

### Help

```bash
./dlang-ai-client --help
```

## Architecture

The application uses a **Factory Pattern** to support multiple UI frameworks:

### Key Components

1. **UI Interfaces** (`source/ui/`)
   - `chat_ui.d` - Interface for chat window implementations
   - `settings_ui.d` - Interface for settings dialog implementations

2. **Factory** (`source/ui/ui_factory.d`)
   - Creates appropriate UI instances based on selected framework
   - Parses command-line arguments

3. **Framework Implementations**
   - **DlangUI**: `source/ui/dlangui/`
     - `dlangui_chat_window.d`
     - `dlangui_settings_dialog.d`
   
   - **GTK-D**: `source/ui/gtkd/`
     - `gtkd_chat_window.d`
     - `gtkd_settings_dialog.d`

### Architecture Diagram

```
┌─────────────┐
│   app.d     │
└──────┬──────┘
       │
       v
┌─────────────────┐      ┌──────────────┐
│  UIFactory      │─────>│  IChatUI     │ (interface)
│  .createChatUI()│      └──────┬───────┘
└─────────────────┘             │
                                │
                    ┌───────────┴───────────┐
                    │                       │
          ┌─────────v─────────┐   ┌────────v────────┐
          │ DlangUIChatWindow │   │ GtkDChatWindow  │
          └───────────────────┘   └─────────────────┘
```

## Features

Both UI implementations provide identical functionality:

- **Chat Interface**
  - Message history display
  - Input field with Enter key support
  - Send button
  - Clear button to reset conversation

- **Settings Dialog**
  - Model selection dropdown
  - System message editor
  - OK/Cancel buttons

- **Status Bar**
  - Current model display
  - Settings button

## Adding New UI Frameworks

To add support for a new UI framework:

1. Create a new directory: `source/ui/yourframework/`

2. Implement the interfaces:
   - Create a class implementing `IChatUI`
   - Create a class implementing `ISettingsDialog`

3. Update the factory (`source/ui/ui_factory.d`):
   - Add new enum value to `UIFramework`
   - Add case in `createChatUI()`
   - Add parsing in `parseFramework()`

4. Update `dub.json` to add the framework dependency

5. Test thoroughly!

## Dependencies

### DlangUI
- dlangui ~>0.10.8
- bindbc-sdl, bindbc-opengl (transitive)

### GTK-D
- gtk-d ~>3.10.0
- GTK+ 3 runtime libraries (system dependency)

## Building

```bash
# Build with all UI frameworks
dub build

# Clean build
dub clean
dub build
```

## Troubleshooting

### GTK-D Issues

If you get errors about missing GTK+ libraries:

**Ubuntu/Debian:**
```bash
sudo apt-get install libgtk-3-dev
```

**Fedora:**
```bash
sudo dnf install gtk3-devel
```

**macOS:**
```bash
brew install gtk+3
```

### DlangUI Issues

If you get OpenGL/SDL errors:

**Ubuntu/Debian:**
```bash
sudo apt-get install libsdl2-dev libglew-dev
```

## Performance Considerations

- **DlangUI**: May have faster startup on systems with good OpenGL support
- **GTK-D**: Better integration with native desktop environments (especially on Linux)

Both frameworks offer good performance for chat applications. Choose based on:
- Platform native look and feel (GTK-D)
- Cross-platform consistency (DlangUI)
- Personal preference

