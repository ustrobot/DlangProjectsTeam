# Quick Start Guide - Multi-UI Framework Support

## Basic Usage

### 1. Run with Default UI (DlangUI)
```bash
./dlang-ai-client
```

### 2. Run with GTK-D UI
```bash
./dlang-ai-client --UI=gtk-d
```

### 3. Get Help
```bash
./dlang-ai-client --help
```

## Command-Line Options

| Option | Values | Default | Description |
|--------|--------|---------|-------------|
| `--UI` | `dlangui`, `gtk-d`, `gtkd`, `gtk` | `dlangui` | Select UI framework |
| `--help` or `-h` | - | - | Show help message |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GROQ_API_KEY` | Yes* | Your Groq API key for LLM access |

\* The application will start without the API key, but sending messages will fail with an error.

## Examples

### Example 1: Using DlangUI (OpenGL-based)
```bash
export GROQ_API_KEY="your-api-key-here"
./dlang-ai-client
```

### Example 2: Using GTK-D (Native GTK+ widgets)
```bash
export GROQ_API_KEY="your-api-key-here"
./dlang-ai-client --UI=gtk-d
```

### Example 3: Different ways to specify GTK-D
All of these work:
```bash
./dlang-ai-client --UI=gtk-d
./dlang-ai-client --UI=gtkd
./dlang-ai-client --UI=gtk
```

## Building from Source

```bash
# Install dependencies
dub fetch

# Build
dub build

# Run
./dlang-ai-client --UI=dlangui
```

## Troubleshooting

### "Unknown UI framework" error
Make sure you're using one of the supported values: `dlangui`, `gtk-d`, `gtkd`, or `gtk`.

### GTK+ not found
Install GTK+ 3 development libraries:
```bash
# Ubuntu/Debian
sudo apt-get install libgtk-3-dev

# Fedora
sudo dnf install gtk3-devel

# macOS
brew install gtk+3
```

### SDL/OpenGL errors with DlangUI
Install SDL2 and OpenGL libraries:
```bash
# Ubuntu/Debian
sudo apt-get install libsdl2-dev libglew-dev

# Fedora
sudo dnf install SDL2-devel glew-devel
```

### "GROQ_API_KEY not set" error
This is just a warning. The UI will open, but you need to set the API key to send messages:
```bash
export GROQ_API_KEY="your-api-key-here"
./dlang-ai-client
```

## UI Features

Both UI implementations support:

- ✅ Chat message history with auto-scroll
- ✅ Input field (press Enter to send)
- ✅ Send button
- ✅ Clear button (resets conversation)
- ✅ Settings dialog
  - Model selection
  - System message customization
- ✅ Status bar showing current model
- ✅ Error messages

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Enter` | Send message (when in input field) |

## Choosing the Right UI

**Use DlangUI when:**
- You want consistent look across all platforms
- You prefer OpenGL-based rendering
- You're on Windows or macOS

**Use GTK-D when:**
- You're on Linux and want native look and feel
- You prefer traditional GTK+ widgets
- You have GTK+ already installed

Both UIs have identical functionality - it's just a matter of preference!

## Next Steps

- Read [UI_FRAMEWORKS.md](UI_FRAMEWORKS.md) for detailed architecture information
- Read [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) for implementation details
- See the source code in `source/ui/` for examples of how to extend the UI

## Getting Help

If you encounter issues:
1. Check the error message
2. Review the troubleshooting section above
3. Check that all dependencies are installed
4. Try the alternative UI framework
5. Review the logs (application prints debug info to console)

Enjoy your multi-UI AI client! 🚀

