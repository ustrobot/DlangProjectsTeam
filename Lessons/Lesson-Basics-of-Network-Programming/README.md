# Network Programming Basics Course

A comprehensive course teaching network programming concepts using the D programming language and libcurl. Learn to build HTTP clients, handle JSON data, implement retry logic, and communicate with REST APIs including OpenAI-compatible LLM services.

## Course Overview

This course consists of 10 lessons that progressively build your network programming skills:

1. **Introduction to Network Programming** - Client-server model, TCP/IP, OSI layers, DNS, IP addressing
2. **`curl` Fundamentals** - Command-line HTTP client usage
3. **Using `curl` from D (`std.curl`)** - D's built-in HTTP library
4. **POST Requests & Payloads** - Sending data via HTTP
5. **Asynchronous Requests with `CurlMulti`** - Concurrent HTTP requests
6. **REST APIs & Authentication** - Web service communication
7. **JSON Handling in D** - Parsing and generating JSON data
8. **Error Handling, Retries & Rate Limits** - Robust network clients
9. **Secure HTTPS & OpenAI API Specifics** - SSL/TLS and LLM APIs
10. **Capstone Project - Chat with an LLM** - Complete chat application

## Prerequisites

- Basic D programming knowledge (variables, functions, structs, classes)
- Understanding of command-line interfaces
- Familiarity with web concepts (URLs, HTTP)

## Required Tools

### D Compiler
Install DMD (Digital Mars D) or LDC (LLVM-based D compiler):

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install dmd
```

**macOS (with Homebrew):**
```bash
brew install dmd
```

**Windows:**
Download from [dlang.org](https://dlang.org/download.html)

### DUB Package Manager
DUB comes with DMD, or install separately:

```bash
# Should be available after DMD installation
dub --version
```

### libcurl
Most systems have curl installed. Verify:

```bash
curl --version
```

**Ubuntu/Debian:**
```bash
sudo apt-get install libcurl4-openssl-dev
```

**macOS:**
```bash
# Usually pre-installed, or:
brew install curl
```

## Getting Started

1. **Clone or download** this course repository
2. **Navigate** to the course directory:
   ```bash
   cd Lesson-Basics-of-Network-Programming
   ```
3. **Build and run** the course application:
   ```bash
   dub run
   ```

## Course Structure

```
Lesson-Basics-of-Network-Programming/
├── source/                    # D source code
│   ├── app.d                 # Main menu application
│   └── lesson1/              # Lesson 1 examples
│       ├── client_server_model.d
│       ├── tcp_udp_basics.d
│       ├── osi_layers.d
│       ├── dns_lookup.d
│       └── ip_addressing.d
├── assignments/              # Programming assignments
│   ├── README.md            # Assignment overview
│   ├── middle/              # Middle school level assignments
│   └── high/                # High school level assignments
├── dub.json                 # DUB project configuration
├── .gitignore              # Git ignore rules
├── .vscode/                # VSCode configuration
│   ├── launch.json
│   └── tasks.json
└── README.md               # This file
```

## Running Examples

The course includes an interactive menu application. Run:

```bash
dub run
```

Navigate through lessons and examples using the numbered menus.

## Running Tests

Each example includes comprehensive unit tests. Run all tests:

```bash
dub test
```

Or run tests for a specific configuration:

```bash
dub test --build=unittest
```

## Assignments

The course includes assignments at two difficulty levels:

- **Middle School Level**: Guided assignments with detailed instructions
- **High School Level**: Advanced assignments requiring deeper understanding

Assignments are located in the `assignments/` directory. Each assignment includes:
- Detailed problem description
- Starter code (where appropriate)
- Learning objectives
- Evaluation criteria

## API Keys Setup

Some lessons require API keys. Create a `api_keys.d` file in the project root:

```d
module api_keys;

// Add your API keys here
string OPENWEATHER_API_KEY = "your_openweather_key_here";
string OPENAI_API_KEY = "your_openai_key_here";
```

### Getting API Keys

- **OpenWeather API**: Sign up at [openweathermap.org](https://openweathermap.org/api)
- **OpenAI API**: Sign up at [platform.openai.com](https://platform.openai.com/)

## Lessons Overview

### Lesson 1: Introduction to Network Programming (40 min theory + 40 min practice)
- **Theory**: Client-server model, TCP/IP vs UDP, OSI layers, DNS resolution, IP addressing
- **Practice**: Install tools, verify connectivity, run network diagnostics
- **Examples**: Client-server simulation, protocol comparison, layer visualization

### Lesson 2: `curl` Fundamentals (40 min theory + 40 min practice)
- **Theory**: curl CLI syntax, HTTP methods, headers, response inspection
- **Practice**: GET requests, response analysis, file operations
- **Examples**: HTTP method demonstrations, header manipulation, verbose output parsing

### Lesson 3: Using `curl` from D (`std.curl`) (40 min theory + 40 min practice)
- **Theory**: std.curl module, CurlEasy objects, callback functions
- **Practice**: HTTP GET requests, status code handling, response processing
- **Examples**: Basic GET requests, callback handlers, GitHub API integration

### Lesson 4: POST Requests & Payloads (40 min theory + 40 min practice)
- **Theory**: Form-data vs JSON payloads, content types, request formatting
- **Practice**: POST to httpbin.org, JSON/form data handling
- **Examples**: POST request types, payload formatting, response validation

### Lesson 5: Asynchronous Requests with `CurlMulti` (40 min theory + 40 min practice)
- **Theory**: Multi-handle concepts, event loops, concurrent requests
- **Practice**: Parallel API calls, performance comparison
- **Examples**: Multi-request handling, event loop management, timing analysis

### Lesson 6: REST APIs & Authentication (40 min theory + 40 min practice)
- **Theory**: REST principles, HTTP status codes, authentication methods
- **Practice**: OpenWeather API queries, API key authentication
- **Examples**: RESTful operations, auth mechanisms, error code handling

### Lesson 7: JSON Handling in D (40 min theory + 40 min practice)
- **Theory**: std.json module, JSONValue, parsing/serialization
- **Practice**: Weather API JSON parsing, struct conversion
- **Examples**: JSON parsing, nested data access, struct serialization

### Lesson 8: Error Handling, Retries & Rate Limits (40 min theory + 40 min practice)
- **Theory**: curl error codes, backoff strategies, rate limit detection
- **Practice**: Retry implementation, throttled endpoint testing
- **Examples**: Error code handling, exponential backoff, rate limit management

### Lesson 9: Secure HTTPS & OpenAI API Specifics (40 min theory + 40 min practice)
- **Theory**: TLS verification, certificate handling, OpenAI API contracts
- **Practice**: Secure requests, certificate validation, OpenAI API testing
- **Examples**: SSL configuration, API contract implementation, secure authentication

### Lesson 10: Capstone Project - Chat with an LLM (40 min theory + 40 min practice)
- **Theory**: Chat client architecture, conversation management, logging
- **Practice**: Complete chat application, error handling, conversation persistence
- **Examples**: Request builders, response parsers, UI components, conversation managers

## Troubleshooting

### Build Errors
- Ensure DMD/DUB are properly installed: `dmd --version && dub --version`
- Check libcurl development headers are installed
- Try cleaning and rebuilding: `dub clean && dub build`

### Runtime Errors
- Verify internet connectivity for network-dependent examples
- Check API keys are properly configured in `api_keys.d`
- Ensure firewall allows outbound HTTP/HTTPS connections

### Test Failures
- Some tests may require internet connectivity
- API-dependent tests may fail without valid API keys
- Mock responses are used where possible to avoid external dependencies

## Contributing

This is an educational course. Suggestions for improvements are welcome!

## License

This course material is provided under the MIT License.

## Course Completion

Upon completing all lessons and assignments, you will be able to:

- Build robust HTTP clients in D using std.curl
- Handle JSON data parsing and generation
- Implement proper error handling and retry logic
- Work with REST APIs and authentication
- Create secure HTTPS connections
- Build applications that communicate with LLM APIs like OpenAI

The capstone project demonstrates a complete chat application that integrates all concepts learned throughout the course.
