<!-- 5f1d1c8f-9929-428c-bf40-ed5d9c23a89f 90cc4368-6819-4e57-b629-468e0b709d14 -->
# Network Programming Basics Course - Implementation Plan

## Overview

Create a complete course structure mirroring EXAMPLE-Lesson-Addresses-Pointers-DynamicMemory but focused on network programming with D and CURL. Each lesson includes theory (40 min), practice (40 min), examples with unit tests, and assignments at middle/high school levels.

## Course Structure

### Phase 1: Project Setup and Core Structure

- Create main directory: `Lesson-Basics-of-Network-Programming/`
- Copy and adapt project configuration files:
- `dub.json` - configure dependencies (curl support)
- `.gitignore` - based on example course
- `.vscode/launch.json` and `.vscode/tasks.json` - debug configuration

### Phase 2: Main Lesson Plan Document

Create `Lessons on Network Programming Basics.md` covering:

- Course overview and learning objectives
- 10 lesson breakdown (each with theory 40min + practice 40min)
- Learning outcomes summary
- Prerequisites and tools needed

### Phase 3: Source Code Implementation

#### Lesson 1: Introduction to Network Programming

**Directory:** `source/lesson1/`

**Theory Topics (40 min):**

- Client-server model concepts
- TCP/IP and UDP protocols
- OSI vs TCP/IP stack
- DNS and IP addressing basics

**Example Files:**

1. `client_server_model.d` - Demonstration of client-server concepts
2. `tcp_udp_basics.d` - Protocol comparison examples
3. `osi_layers.d` - Visual representation of network layers
4. `dns_lookup.d` - Simple DNS resolution examples
5. `ip_addressing.d` - IP address manipulation and validation

**Practice (40 min):**

- Install DMD/LDC compiler and curl
- Verify connectivity with system commands
- Write simple network diagnostic tool

**Unit Tests:** Each file includes unittest blocks testing core functionality

#### Lesson 2: curl Fundamentals

**Directory:** `source/lesson2/`

**Theory Topics:**

- curl CLI syntax and options (-X, -d, -H, -o)
- HTTP methods (GET, POST, PUT, DELETE)
- Request/response headers
- Debug output with -v flag

**Example Files:**

1. `curl_basics.d` - Execute curl from D using std.process
2. `http_methods.d` - Demonstrate different HTTP methods
3. `headers_handling.d` - Work with custom headers
4. `response_inspection.d` - Parse curl verbose output
5. `file_operations.d` - Save responses to files

**Practice:**

- GET requests to example.com
- Inspect response headers
- Save responses to files

#### Lesson 3: Using curl from D (std.curl)

**Directory:** `source/lesson3/`

**Theory Topics:**

- std.curl module overview
- HTTP and CurlEasy objects
- Setting options with setopt
- Callback functions for body & headers

**Example Files:**

1. `stdcurl_intro.d` - Basic std.curl usage
2. `http_get.d` - Simple GET requests
3. `curl_easy.d` - Working with CurlEasy objects
4. `callback_handlers.d` - Custom callbacks for data processing
5. `github_api.d` - GET from GitHub API with status codes

**Practice:**

- Fetch data from api.github.com
- Print status code and response body
- Handle different response types

#### Lesson 4: POST Requests & Payloads

**Directory:** `source/lesson4/`

**Theory Topics:**

- Form-data vs JSON payloads
- CURLOPT_POST and CURLOPT_POSTFIELDS
- Custom headers for content type
- Request body formatting

**Example Files:**

1. `post_basics.d` - Simple POST requests
2. `form_data.d` - Sending form-encoded data
3. `json_payload.d` - POST JSON data
4. `httpbin_test.d` - Test with httpbin.org endpoints
5. `custom_headers.d` - Set Content-Type and other headers

**Practice:**

- POST JSON to httpbin.org/post
- Display returned JSON response
- Handle different payload formats

#### Lesson 5: Asynchronous Requests with CurlMulti

**Directory:** `source/lesson5/`

**Theory Topics:**

- Multi-handle concept
- Event loop in CurlMulti
- Adding/removing easy handles
- Concurrent request management

**Example Files:**

1. `curl_multi_intro.d` - Basic CurlMulti usage
2. `parallel_requests.d` - Multiple concurrent GETs
3. `event_loop.d` - Managing the multi-handle event loop
4. `handle_management.d` - Add/remove handles dynamically
5. `multi_api_fetch.d` - Fetch from GitHub, ipify, httpbin in parallel

**Practice:**

- Parallel GET to 3 public APIs
- Collect and display all responses
- Measure performance vs sequential

#### Lesson 6: REST APIs & Authentication

**Directory:** `source/lesson6/`

**Theory Topics:**

- REST principles (resources, methods, statelessness)
- HTTP status codes (2xx, 3xx, 4xx, 5xx)
- Bearer token authentication
- API key authentication

**Example Files:**

1. `rest_principles.d` - Demonstrate REST concepts
2. `status_codes.d` - Handle different status codes
3. `bearer_auth.d` - Bearer token authentication
4. `api_key_auth.d` - API key in headers/query params
5. `openweather_api.d` - Query OpenWeather API with key

**Practice:**

- Query OpenWeather API for current weather
- Use API key authentication
- Parse basic JSON response (preparation for Lesson 7)

#### Lesson 7: JSON Handling in D

**Directory:** `source/lesson7/`

**Theory Topics:**

- std.json module overview
- Parsing JSON with parseJSON
- Working with JSONValue
- Extracting fields and nested data
- Serializing D structs to JSON

**Example Files:**

1. `json_parsing.d` - Parse JSON strings
2. `json_value.d` - Navigate JSONValue objects
3. `field_extraction.d` - Extract specific fields
4. `nested_json.d` - Handle nested objects/arrays
5. `weather_struct.d` - Convert weather JSON to D struct

**Practice:**

- Parse OpenWeather JSON response
- Extract temperature, description, humidity
- Create D struct with weather data

#### Lesson 8: Error Handling, Retries & Rate Limits

**Directory:** `source/lesson8/`

**Theory Topics:**

- CURL error codes (CURLE_*)
- Checking return values
- Exponential back-off strategy
- Recognizing 429, 401, 500 responses
- Timeout handling

**Example Files:**

1. `error_codes.d` - Handle curl error codes
2. `retry_logic.d` - Implement retry with backoff
3. `rate_limiting.d` - Detect and handle 429 responses
4. `timeout_handling.d` - Set and handle timeouts
5. `httpget_with_retry.d` - Complete retry implementation

**Practice:**

- Implement httpGetWithRetry(url, retries)
- Test against throttled endpoint
- Log retry attempts and delays

#### Lesson 9: Secure HTTPS & OpenAI API Specifics

**Directory:** `source/lesson9/`

**Theory Topics:**

- TLS/SSL verification (CURLOPT_SSL_VERIFYPEER)
- Certificate authority bundles (CURLOPT_CAINFO)
- OpenAI-compatible API contract
- Required headers and JSON schema
- Rate-limit handling for LLM services

**Example Files:**

1. `tls_verification.d` - SSL/TLS certificate handling
2. `ca_certificates.d` - Work with CA bundles
3. `openai_contract.d` - OpenAI API structure
4. `api_headers.d` - Required headers for LLM APIs
5. `models_endpoint.d` - Test POST /v1/models

**Practice:**

- Send test request to OpenAI-compatible server
- Verify certificates properly
- Handle 401/429 responses

#### Lesson 10: Capstone Project - Chat with an LLM

**Directory:** `source/lesson10/`

**Theory Topics:**

- Console chat client design
- Module separation (request builder, response parser, UI loop)
- Conversation history management
- Logging and optional caching

**Example Files:**

1. `request_builder.d` - Build chat completion requests
2. `response_parser.d` - Parse chat API responses
3. `ui_loop.d` - Interactive console interface
4. `conversation_manager.d` - Manage message history
5. `chat_client.d` - Complete working chat client

**Practice:**

- Build complete D chat program
- Read user input, send to LLM API
- Parse and display AI responses
- Implement error handling and retries
- Optional: Save conversation to JSON file

### Phase 4: Main Application Menu

Create `source/app.d` - Menu-driven interface to run all examples (similar to example course structure):

- Main menu with 10 lesson options
- Sub-menus for each lesson's examples
- Clear screen functionality
- User-friendly navigation

### Phase 5: Assignments Structure

#### Create `assignments/README.md`

Overview of all assignments, difficulty levels, and submission guidelines

#### Middle School Assignments (assignments/middle/)

**Lesson 1:** `lesson1/assignment1_network_basics.md`

- Simple network diagnostic tool
- Ping simulation with output
- Basic IP address validator

**Lesson 2:** `lesson2/assignment1_curl_explorer.md`

- Interactive curl command builder
- Execute and display results
- Save responses to files

**Lesson 3:** `lesson3/assignment1_api_fetcher.md`

- Fetch data from public API
- Display formatted results
- Simple error handling

**Lesson 4:** `lesson4/assignment1_form_poster.md`

- Submit form data to test endpoint
- Display server response
- Test different content types

**Lesson 5:** `lesson5/assignment1_multi_fetch.md`

- Fetch from 3 APIs simultaneously
- Compare performance with sequential
- Display all results

**Lesson 6:** `lesson6/assignment1_weather_app.md`

- Simple weather lookup tool
- Use API key authentication
- Display current conditions

**Lesson 7:** `lesson7/assignment1_json_parser.md`

- Parse JSON from various sources
- Extract and display specific fields
- Handle nested structures

**Lesson 8:** `lesson8/assignment1_retry_fetcher.md`

- Implement automatic retry logic
- Handle different error types
- Log retry attempts

**Lesson 9:** `lesson9/assignment1_secure_fetch.md`

- Verify HTTPS certificates
- Test with different endpoints
- Handle SSL errors

**Lesson 10:** `lesson10/assignment1_simple_chatbot.md`

- Basic question-answer chatbot
- Single-turn conversations
- Save conversation log

#### High School Assignments (assignments/high/)

**Lesson 1:** `lesson1/assignment1_network_diagnostics.md`

- Complete network diagnostic suite
- Traceroute implementation
- Performance measurement tools

**Lesson 2:** `lesson2/assignment1_http_client.md`

- Full-featured HTTP client
- Support all HTTP methods
- Custom header management
- Response caching

**Lesson 3:** `lesson3/assignment1_api_wrapper.md`

- Generic API wrapper class
- Configurable base URL and headers
- Response type handling
- Connection pooling

**Lesson 4:** `lesson4/assignment1_rest_client.md`

- RESTful API client library
- Support JSON and form data
- Automatic serialization
- Request/response logging

**Lesson 5:** `lesson5/assignment1_concurrent_downloader.md`

- Multi-threaded download manager
- Progress tracking
- Bandwidth limiting
- Resume capability

**Lesson 6:** `lesson6/assignment1_api_aggregator.md`

- Query multiple APIs
- Aggregate and correlate data
- Handle different auth methods
- Rate limit coordination

**Lesson 7:** `lesson7/assignment1_json_processor.md`

- JSON transformation pipeline
- Schema validation
- Data mapping and conversion
- Performance optimization

**Lesson 8:** `lesson8/assignment1_resilient_client.md`

- Production-ready HTTP client
- Circuit breaker pattern
- Retry with jitter
- Comprehensive error handling
- Metrics and monitoring

**Lesson 9:** `lesson9/assignment1_llm_client.md`

- Complete OpenAI-compatible client
- Support multiple endpoints
- Streaming responses
- Token counting
- Cost tracking

**Lesson 10:** `lesson10/assignment1_advanced_chatbot.md`

- Multi-turn conversation system
- Context management
- Multiple persona support
- Conversation persistence
- Plugin system for commands

### Phase 6: Documentation Files

Create supporting documentation:

1. Main README.md - Course overview, setup instructions
2. SETUP.md - Detailed environment setup
3. API_KEYS.md - Guide for obtaining API keys
4. TESTING.md - How to run tests and examples

### Implementation Notes

**Unit Testing Strategy:**

- Each example file includes unittest blocks
- Tests verify core functionality
- Mock responses where appropriate
- Test both success and error cases

**Code Style:**

- Follow D best practices
- Comprehensive documentation comments
- Clear variable naming
- Modular, reusable code

**Dependencies:**

- D compiler (DMD or LDC)
- DUB package manager
- libcurl (system library)
- No external D packages initially (use Phobos)

**File Naming Conventions:**

- lowercase with underscores: `http_client.d`
- Descriptive names indicating purpose
- Assignment files: `assignmentN_description.md`

## Success Criteria

- All 10 lessons implemented with examples
- Every example file has passing unit tests
- 20 assignments total (10 middle + 10 high school)
- Complete menu-driven application works
- Documentation is comprehensive
- Code compiles and runs without errors

### To-dos

- [ ] Create project structure, dub.json, .gitignore, and VSCode config files
- [ ] Write main lesson plan document with all 10 lessons detailed
- [ ] Implement Lesson 1 examples (network programming intro) with unit tests
- [ ] Implement Lesson 2 examples (curl fundamentals) with unit tests
- [ ] Implement Lesson 3 examples (std.curl) with unit tests
- [ ] Implement Lesson 4 examples (POST requests) with unit tests
- [ ] Implement Lesson 5 examples (async CurlMulti) with unit tests
- [ ] Implement Lesson 6 examples (REST & auth) with unit tests
- [ ] Implement Lesson 7 examples (JSON handling) with unit tests
- [ ] Implement Lesson 8 examples (error handling) with unit tests
- [ ] Implement Lesson 9 examples (HTTPS & OpenAI) with unit tests
- [ ] Implement Lesson 10 examples (chat client capstone) with unit tests
- [ ] Create main app.d with menu system to access all lesson examples
- [ ] Write all 10 middle school assignments with starter code and instructions
- [ ] Write all 10 high school assignments with starter code and instructions
- [ ] Create assignments README with overview and submission guidelines
- [ ] Write main README, SETUP guide, API_KEYS guide, and TESTING documentation
- [ ] Run all unit tests and verify they pass
- [ ] Build complete project with dub and verify no errors