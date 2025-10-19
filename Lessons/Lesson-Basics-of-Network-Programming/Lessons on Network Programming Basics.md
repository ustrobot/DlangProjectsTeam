# Lessons on Network Programming Basics

## Course Goal

By the end of the course students can write D programs that use **curl** to make HTTP requests, parse JSON, handle errors, and **communicate with an OpenAI‑compatible LLM** (e.g., `POST /v1/chat/completions`).

## Course Structure

| Lesson | Topic | Theory (40 min) | Practice (40 min) | Key Skills |
|--------|-------|-----------------|-------------------|------------|
| 1 | Introduction to network programming | • Client‑server model, TCP/IP, UDP<br>• OSI vs. TCP/IP stack<br>• DNS & IP addressing | • Install DMD (or LDC) and `curl`<br>• Verify connectivity with `ping` / `traceroute` | Basic networking concepts |
| 2 | `curl` fundamentals | • CLI syntax, main options (`-X`, `-d`, `-H`, `-o`)<br>• HTTP methods, headers, body<br>• Debug output (`-v`) | • GET `https://example.com`, save to file<br>• Inspect response headers | Formulate HTTP requests from the shell |
| 3 | Using `curl` from D (`std.curl`) | • `std.curl` overview, `CurlEasy` object<br>• Setting options with `setopt`<br>• Callback functions for body & headers | • D program that GETs `https://api.github.com` and prints status + body | Call `curl` inside D code |
| 4 | POST requests & payloads | • Form‑data vs. JSON payloads<br>• `CURLOPT_POST`, `CURLOPT_POSTFIELDS`, custom headers | • POST JSON to `https://httpbin.org/post` and display returned JSON | Send data in HTTP requests |
| 5 | Asynchronous requests with `CurlMulti` | • Multi‑handle concept, event loop inside `CurlMulti`<br>• Adding/removing easy handles | • Parallel GETs to three public APIs (GitHub, ipify, httpbin) and collect all responses | Perform concurrent network calls |
| 6 | REST APIs & authentication | • REST principles, status codes<br>• Bearer token authentication (`Authorization: Bearer …`) | • Query current weather from OpenWeather (`/data/2.5/weather`) using an API key<br>• Parse JSON (see Lesson 7) | Interact with typical web services |
| 7 | JSON handling in D | • `std.json` parsing/serialization<br>• Working with `JsonValue`, extracting fields | • Convert weather response into a D struct and print temperature, description, humidity | Process JSON data |
| 8 | Error handling, retries & rate limits | • `curl` error codes (`CURLE_*`), checking return values<br>• Exponential back‑off strategy in D<br>• Recognising 429, 401, 500 responses | • Implement `httpGetWithRetry(url, retries)` that retries on timeout or 429<br>• Test against a deliberately throttled endpoint | Build resilient network clients |
| 9 | Secure HTTPS & OpenAI API specifics | • TLS verification (`CURLOPT_SSL_VERIFYPEER`, `CURLOPT_CAINFO`)<br>• OpenAI‑compatible API contract: endpoint, required headers, JSON schema<br>• Rate‑limit handling for LLM services | • Send a test request to a sandbox OpenAI‑compatible server (`POST /v1/models`)<br>• Verify certificate and handle possible 401/429 responses | Securely call LLM endpoints |
| 10 | Capstone project – Chat with an LLM | • Designing a small console chat client<br>• Separating modules: request builder, response parser, UI loop<br>• Logging & optional caching of conversations | • Build a D program that:<br>  • Reads user input<br>  • Sends `POST /v1/chat/completions` (model, messages, temperature, max_tokens) via `curl`<br>  • Parses `choices[0].message.content` and displays it<br>  • Handles errors, retries, and respects rate limits<br>  • (Optional) Saves conversation history to a JSON file | Full‑stack ability to communicate with an OpenAI‑compatible LLM |

## Prerequisites

- Basic D programming knowledge (variables, functions, structs, classes)
- Understanding of command-line interfaces
- Basic knowledge of web concepts (URLs, HTTP)

## Tools Required

- D compiler (DMD or LDC)
- DUB package manager
- curl command-line tool
- libcurl library (usually installed with curl)

## Learning Outcomes

After completing this course, learners will:

1. Understand fundamental networking concepts (client-server, TCP/IP, DNS)
2. Master curl command-line usage for HTTP requests
3. Use std.curl library to make HTTP requests from D programs
4. Handle different HTTP methods (GET, POST) with various payload types
5. Implement concurrent HTTP requests using CurlMulti
6. Work with REST APIs and authentication mechanisms
7. Parse and generate JSON data using std.json
8. Implement robust error handling and retry logic
9. Securely connect to HTTPS endpoints with certificate verification
10. Build a complete chat client that communicates with OpenAI-compatible LLM APIs

## Assessment

Students will be evaluated based on:

- Completion of practical exercises (40% of grade)
- Implementation of assignments at appropriate difficulty levels (40% of grade)
- Capstone project functionality and code quality (20% of grade)

## Course Materials

- Example code for each lesson (in `source/` directory)
- Assignment specifications (in `assignments/` directory)
- Documentation and setup guides
- Unit tests demonstrating expected functionality

---

*This course builds progressively, with each lesson building on concepts from previous lessons. Students should complete lessons in order and practice regularly with the provided examples and assignments.*
