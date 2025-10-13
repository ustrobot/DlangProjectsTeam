# Dlang AI Client

An AI chat client written in **D language** to experiment with Large Language Models (LLMs) and demonstrate D's capabilities in building GUI applications.

## 🎯 Project Purpose

This project serves as an **experiment** for:

- **LLM Integration in D**: Exploring how to integrate LLM APIs using D's native HTTP libraries with dynamic server configuration
- **Multi-Framework UI**: Demonstrating D's flexibility by supporting multiple UI toolkits (DlangUI and GTK-D)
- **Chat Persistence**: Implementing automatic saving and loading of conversation history with server/model preferences
- **Server Configuration Management**: Supporting multiple LLM servers through JSON-based configuration presets
- **Dynamic Model Loading**: Loading available models from servers at runtime instead of hardcoded lists
- **Modern D Practices**: Showcasing interface-based design, factory patterns, and clean architecture in D
- **Cross-Platform Development**: Building applications that work across Linux, Windows, and macOS using D

## 🚀 Quick Start

### Prerequisites

```bash
# Install D compiler (DMD)
# Ubuntu/Debian:
sudo apt-get install dmd dub

# Or download from: https://dlang.org/download.html

# Install GTK+ 3 (for GTK-D UI option)
sudo apt-get install libgtk-3-dev

# Install SDL2 (for DlangUI)
sudo apt-get install libsdl2-dev
```

### Get Your API Key

Sign up at [Groq](https://console.groq.com/) and get your API key.

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GROQ_API_KEY` | No* | Your Groq API key for LLM access |

*API key can be provided via server presets (see below) or environment variable.

### Data Persistence

The application automatically saves your chat conversations and settings:

- **Location**: `~/.dlang-ai-client/chat_context.json`
- **Auto-save**: Conversations are saved when you exit the application
- **Auto-load**: Previous conversations are restored when you restart
- **Backup**: Create backups of this file if you want to preserve specific conversations

To reset your conversation history, simply delete the `chat_context.json` file in your home directory.

### Server Configuration

The application supports multiple LLM servers through configuration presets. Server presets are stored as `.llm-server` JSON files in a `presets/` directory next to the application binary.

#### Server Preset Format

Create `.llm-server` files with the following JSON structure:

```json
{
    "name": "My Server",
    "description": "Description of the server",
    "server": "https://api.example.com/v1/",
    "token": "your-api-key-here"
}
```

#### Example Preset

An example Groq server preset is included: `groq-server.llm-server`. Copy this file and update the token with your actual API key.

#### Setting Up Your API Key

```bash
# Method 1: Environment variable (legacy support)
export GROQ_API_KEY="your-api-key-here"

# Method 2: Server preset (recommended)
# 1. Copy groq-server.llm-server to presets/ directory
# 2. Edit the token field with your actual API key
# 3. Select "Groq" from the server dropdown in settings
```

### Build & Run

```bash
# Clone the repository
git clone <repository-url>
cd DlangAIClient

# Build
dub build

# Set up server presets (optional)
mkdir -p presets/
cp groq-server.llm-server presets/

# Run with DlangUI (default)
./dlang-ai-client

# Or run with GTK-D
./dlang-ai-client --UI=gtk-d
```

## 📖 Documentation

### Quick References

- **[QUICKSTART.md](QUICKSTART.md)** - Get up and running in minutes
  - Basic usage examples
  - Command-line options
  - Troubleshooting common issues

- **[UI_FRAMEWORKS.md](UI_FRAMEWORKS.md)** - Complete UI framework guide
  - Choosing between DlangUI and GTK-D
  - Platform-specific considerations
  - Adding new UI frameworks

### Architecture & Design

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture overview
  - Entry point and initialization patterns
  - Message flow diagrams
  - Code organization
  - Testing strategy

- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Detailed implementation notes
  - What was implemented and why
  - Design decisions and trade-offs
  - File structure breakdown
  - Lines of code metrics

- **[DLANGUI_REFACTOR.md](DLANGUI_REFACTOR.md)** - DlangUI integration specifics
  - Why UIAppMain is used
  - Platform initialization requirements
  - Framework coexistence details

## 🏗️ Project Structure

```
DlangAIClient/
├── source/
│   ├── app.d                    # Main entry point (UIAppMain)
│   ├── llm/                     # LLM client and chat logic
│   │   ├── chat_context.d       # Conversation state management
│   │   ├── chat_persistence.d   # Chat history persistence
│   │   ├── llm_client.d         # HTTP API client
│   │   └── message.d            # Message data structures
│   ├── models/                  # Data models
│   │   └── user.d
│   └── ui/                      # User interface layer
│       ├── chat_ui.d            # IChatUI interface
│       ├── settings_ui.d        # ISettingsDialog interface
│       ├── ui_factory.d         # Factory pattern implementation
│       ├── dlangui/             # DlangUI implementation
│       │   ├── dlangui_chat_window.d
│       │   └── dlangui_settings_dialog.d
│       └── gtkd/                # GTK-D implementation
│           ├── gtkd_chat_window.d
│           └── gtkd_settings_dialog.d
├── dub.json                     # Build configuration
├── README.md                    # This file
└── *.md                         # Documentation files
```

## 🧪 Experiments & Learning

This project is starting point for experimenting with:

### D Language Features
- Interface-based design patterns
- Factory pattern implementation
- Foreign Function Interface (FFI) with C libraries
- String handling (UTF-8, UTF-16, UTF-32)
- HTTP client libraries (vibe-d)
- Error handling and exceptions

### GUI Programming in D
- DlangUI: Immediate mode GUI with OpenGL
- GTK-D: Traditional widget-based GUI
- Event handling patterns
- Layout management
- Multi-window applications

### LLM Integration
- REST API communication
- JSON serialization/deserialization
- Dynamic server configuration with presets
- Runtime model loading from servers
- Context window management
- Model parameter configuration
- Server validation and error handling

## 🌟 Key Technologies

- **[D Language](https://dlang.org/)** - Fast, modern systems programming language
- **[DlangUI](https://github.com/buggins/dlangui)** - Cross-platform GUI library for D
- **[GTK-D](https://gtkd.org/)** - D bindings for GTK+ 3
- **[vibe-d](https://vibed.org/)** - HTTP client library for D
- **[Groq API](https://groq.com/)** - Fast LLM inference API

## 🎓 Learning Resources

If you're new to D language:
- [D Language Tour](https://tour.dlang.org/)
- [D Programming Language Book](https://www.amazon.com/D-Programming-Language-Andrei-Alexandrescu/dp/0321635361)
- [DlangUI Wiki](https://github.com/buggins/dlangui/wiki)
- [GTK-D Documentation](https://gtkd.org/documentation.html)

## 🤝 Contributing

This is an experimental project, but contributions are welcome!

Areas for potential enhancement:
- Additional UI frameworks (Qt, Terminal UI, Web UI)
- More LLM providers (OpenAI, Anthropic, local models)
- Streaming response support
- Conversation history persistence
- Multi-turn conversation improvements

## 🙏 Acknowledgments

- **D Language Community** - For the excellent language and tools
- **DlangUI** - For the cross-platform GUI framework
- **GTK-D** - For GTK+ bindings in D
- **Groq** - For fast LLM inference API
- **vibe-d** - For HTTP client functionality

## 📧 Contact

For questions, suggestions, or discussions about D language and LLM integration, feel free to open an issue.

---

**Built with D** 🚀 | **Powered by Groq** ⚡ | **Experimenting with the Future** 🔬

