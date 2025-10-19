# Programming Assignments for Network Programming Basics

This directory contains programming assignments for the "Network Programming Basics" course. These assignments are designed to help students practice and deepen their understanding of network programming concepts using the D programming language and curl.

## Assignment Levels

Assignments are organized into two difficulty levels:

- **Middle School**: Guided assignments with detailed instructions and starter code, focusing on fundamental concepts
- **High School**: Advanced assignments requiring deeper understanding, design decisions, and implementation of complex features

## Course Prerequisites

Before starting assignments, ensure you have:
- Completed the corresponding lesson examples
- D compiler (DMD/LDC) installed
- DUB package manager available
- libcurl library installed
- Basic understanding of D programming

## Assignment Structure

Each assignment includes:
- **Objective**: What you'll build
- **Requirements**: Specific features to implement
- **Starter Code**: Template code to begin with
- **Step-by-Step Guide**: Detailed implementation instructions
- **Example Output**: Expected program behavior
- **Learning Outcomes**: Concepts you'll master
- **Extension Activities**: Optional advanced features
- **Submission Guidelines**: How to submit your work
- **Grading Criteria**: How assignments are evaluated

## Lesson 1: Introduction to Network Programming

### Middle School Assignments

#### [Assignment 1.1: Network Basics Tool](middle/lesson1/assignment1_network_basics.md)
Build a simple network diagnostic tool that demonstrates basic networking concepts.

**Key concepts:**
- Network connectivity testing
- IP address validation
- Basic network troubleshooting

#### [Assignment 1.2: Protocol Simulator](middle/lesson1/assignment2_protocol_simulator.md)
Create a simulator that demonstrates TCP vs UDP protocol differences.

**Key concepts:**
- Protocol characteristics
- Connection-oriented vs connectionless communication
- Message reliability simulation

#### [Assignment 1.3: Address Analyzer](middle/lesson1/assignment3_address_analyzer.md)
Build a tool to analyze and classify IP addresses.

**Key concepts:**
- IP address structure
- Private vs public addresses
- Address class identification

### High School Assignments

#### [Assignment 1.1: Network Diagnostics Suite](high/lesson1/assignment1_network_diagnostics.md)
Implement a comprehensive network diagnostic suite with multiple testing capabilities.

**Key concepts:**
- Advanced network testing
- Performance measurement
- Comprehensive diagnostics

#### [Assignment 1.2: Protocol Analysis Tool](high/lesson1/assignment2_protocol_analysis.md)
Create an advanced protocol analyzer with performance metrics and detailed reporting.

**Key concepts:**
- Protocol performance analysis
- Statistical reporting
- Advanced simulation features

#### [Assignment 1.3: IP Network Calculator](high/lesson1/assignment3_ip_calculator.md)
Build a complete IP network calculator with subnetting capabilities.

**Key concepts:**
- Advanced subnet calculations
- Network planning
- CIDR manipulation

## Lesson 2: `curl` Fundamentals

### Middle School Assignments

#### [Assignment 2.1: HTTP Explorer](middle/lesson2/assignment1_http_explorer.md)
Create an interactive HTTP client using curl commands.

**Key concepts:**
- curl command-line usage
- HTTP method exploration
- Response analysis

#### [Assignment 2.2: API Data Collector](middle/lesson2/assignment2_api_collector.md)
Build a tool to collect data from multiple public APIs using curl.

**Key concepts:**
- Multiple API interaction
- Data aggregation
- curl scripting

### High School Assignments

#### [Assignment 2.1: HTTP Client Library](high/lesson2/assignment1_http_client.md)
Implement a comprehensive HTTP client library using curl.

**Key concepts:**
- HTTP client design
- Request/response handling
- Error management

#### [Assignment 2.2: Web Scraper Framework](high/lesson2/assignment2_web_scraper.md)
Create a web scraping framework with curl integration.

**Key concepts:**
- Automated data collection
- Content parsing
- Rate limiting

## Lesson 3: Using `curl` from D (`std.curl`)

### Middle School Assignments

#### [Assignment 3.1: Simple API Client](middle/lesson3/assignment1_api_client.md)
Build a simple API client using std.curl.

**Key concepts:**
- std.curl basic usage
- HTTP GET requests
- Response processing

#### [Assignment 3.2: HTTP Status Monitor](middle/lesson3/assignment2_status_monitor.md)
Create a website status monitoring tool.

**Key concepts:**
- HTTP status code handling
- Periodic monitoring
- Status reporting

### High School Assignments

#### [Assignment 3.1: REST API Wrapper](high/lesson3/assignment1_rest_wrapper.md)
Implement a generic REST API wrapper class.

**Key concepts:**
- API abstraction
- Generic design
- Connection management

#### [Assignment 3.2: Download Manager](high/lesson3/assignment2_download_manager.md)
Build a multi-threaded download manager.

**Key concepts:**
- Concurrent downloads
- Progress tracking
- Error recovery

## Lesson 4: POST Requests & Payloads

### Middle School Assignments

#### [Assignment 4.1: Form Data Poster](middle/lesson4/assignment1_form_poster.md)
Create a tool to submit form data to web services.

**Key concepts:**
- POST request creation
- Form data encoding
- Response handling

#### [Assignment 4.2: JSON API Client](middle/lesson4/assignment2_json_client.md)
Build a JSON-based API client.

**Key concepts:**
- JSON payload creation
- Content-Type headers
- JSON response parsing

### High School Assignments

#### [Assignment 4.1: Multi-Format HTTP Client](high/lesson4/assignment1_multi_format_client.md)
Implement an HTTP client supporting multiple payload formats.

**Key concepts:**
- Multiple content types
- Format detection
- Flexible request building

#### [Assignment 4.2: API Testing Framework](high/lesson4/assignment2_api_testing.md)
Create an API testing framework with request/response validation.

**Key concepts:**
- Automated testing
- Response validation
- Test reporting

## Lesson 5: Asynchronous Requests with `CurlMulti`

### Middle School Assignments

#### [Assignment 5.1: Parallel API Fetcher](middle/lesson5/assignment1_parallel_fetcher.md)
Build a tool to fetch data from multiple APIs simultaneously.

**Key concepts:**
- Concurrent requests
- Performance comparison
- Result aggregation

#### [Assignment 5.2: Load Balancer Simulator](middle/lesson5/assignment2_load_balancer.md)
Create a load balancer simulation using CurlMulti.

**Key concepts:**
- Request distribution
- Load balancing algorithms
- Performance monitoring

### High School Assignments

#### [Assignment 5.1: Concurrent Web Crawler](high/lesson5/assignment1_web_crawler.md)
Implement a concurrent web crawler with CurlMulti.

**Key concepts:**
- Web crawling algorithms
- URL management
- Concurrent processing

#### [Assignment 5.2: Distributed API Client](high/lesson5/assignment2_distributed_client.md)
Build a distributed API client with load balancing.

**Key concepts:**
- Distributed systems
- Load distribution
- Fault tolerance

## Lesson 6: REST APIs & Authentication

### Middle School Assignments

#### [Assignment 6.1: Weather App](middle/lesson6/assignment1_weather_app.md)
Create a weather application using a REST API.

**Key concepts:**
- REST API consumption
- API key authentication
- Data presentation

#### [Assignment 6.2: REST API Explorer](middle/lesson6/assignment2_rest_explorer.md)
Build a tool to explore REST API endpoints.

**Key concepts:**
- API discovery
- Endpoint testing
- Response analysis

### High School Assignments

#### [Assignment 6.1: API Aggregator Service](high/lesson6/assignment1_api_aggregator.md)
Implement an API aggregation service with multiple authentication methods.

**Key concepts:**
- Multiple API integration
- Authentication handling
- Data correlation

#### [Assignment 6.2: REST API Framework](high/lesson6/assignment2_rest_framework.md)
Create a REST API framework with built-in authentication.

**Key concepts:**
- Framework design
- Authentication middleware
- API abstraction

## Lesson 7: JSON Handling in D

### Middle School Assignments

#### [Assignment 7.1: JSON Parser Tool](middle/lesson7/assignment1_json_parser.md)
Build a JSON parsing and formatting tool.

**Key concepts:**
- JSON parsing
- Data extraction
- Pretty printing

#### [Assignment 7.2: Configuration Manager](middle/lesson7/assignment2_config_manager.md)
Create a configuration management system using JSON.

**Key concepts:**
- Configuration files
- JSON serialization
- Data validation

### High School Assignments

#### [Assignment 7.1: JSON Transformation Engine](high/lesson7/assignment1_json_transformer.md)
Implement a JSON data transformation engine.

**Key concepts:**
- Data transformation
- Schema mapping
- Complex JSON handling

#### [Assignment 7.2: JSON Database](high/lesson7/assignment2_json_database.md)
Build a simple JSON-based database system.

**Key concepts:**
- Data persistence
- Query capabilities
- JSON indexing

## Lesson 8: Error Handling, Retries & Rate Limits

### Middle School Assignments

#### [Assignment 8.1: Retry Client](middle/lesson8/assignment1_retry_client.md)
Create an HTTP client with automatic retry functionality.

**Key concepts:**
- Error detection
- Retry logic
- Exponential backoff

#### [Assignment 8.2: Rate Limit Handler](middle/lesson8/assignment2_rate_limit_handler.md)
Build a tool to handle API rate limits gracefully.

**Key concepts:**
- Rate limit detection
- Backoff strategies
- Queue management

### High School Assignments

#### [Assignment 8.1: Resilient HTTP Client](high/lesson8/assignment1_resilient_client.md)
Implement a production-ready HTTP client with comprehensive error handling.

**Key concepts:**
- Circuit breaker pattern
- Advanced retry strategies
- Monitoring and metrics

#### [Assignment 8.2: Load Testing Framework](high/lesson8/assignment2_load_testing.md)
Create a load testing framework with rate limiting and error analysis.

**Key concepts:**
- Load testing
- Performance analysis
- Error statistics

## Lesson 9: Secure HTTPS & OpenAI API Specifics

### Middle School Assignments

#### [Assignment 9.1: Secure HTTP Client](middle/lesson9/assignment1_secure_client.md)
Build an HTTPS client with proper certificate verification.

**Key concepts:**
- SSL/TLS configuration
- Certificate validation
- Secure connections

#### [Assignment 9.2: OpenAI API Client](middle/lesson9/assignment2_openai_client.md)
Create a basic client for OpenAI-compatible APIs.

**Key concepts:**
- API authentication
- Request formatting
- Response parsing

### High School Assignments

#### [Assignment 9.1: LLM API Framework](high/lesson9/assignment1_llm_framework.md)
Implement a comprehensive framework for LLM API interactions.

**Key concepts:**
- Multiple LLM providers
- Streaming responses
- Advanced error handling

#### [Assignment 9.2: Secure API Gateway](high/lesson9/assignment2_api_gateway.md)
Build a secure API gateway with authentication and rate limiting.

**Key concepts:**
- API gateway design
- Security middleware
- Traffic management

## Lesson 10: Capstone Project - Chat with an LLM

### Middle School Assignments

#### [Assignment 10.1: Simple Chat Bot](middle/lesson10/assignment1_simple_chatbot.md)
Create a basic chatbot that interacts with an LLM.

**Key concepts:**
- Single-turn conversations
- Basic request/response handling
- Simple UI

#### [Assignment 10.2: Conversation Logger](middle/lesson10/assignment2_conversation_logger.md)
Build a chat application with conversation logging capabilities.

**Key concepts:**
- Message history
- File I/O for conversations
- Session management

### High School Assignments

#### [Assignment 10.1: Advanced Chatbot](high/lesson10/assignment1_advanced_chatbot.md)
Implement a multi-turn conversation chatbot with advanced features.

**Key concepts:**
- Context management
- Conversation flow
- Multiple personas

#### [Assignment 10.2: LLM Application Framework](high/lesson10/assignment2_llm_framework.md)
Create a comprehensive framework for LLM-powered applications.

**Key concepts:**
- Plugin architecture
- Multi-modal interactions
- Advanced conversation management

## Submission Guidelines

For each assignment:

1. **Create a single D source file** with your implementation
2. **Include comprehensive unit tests** demonstrating all features
3. **Add detailed comments** explaining your design choices
4. **Ensure code compiles and runs** without errors
5. **Follow D language best practices** and coding standards
6. **Include example output** showing your program in action

## Evaluation Criteria

Your assignments will be evaluated based on:

1. **Correctness**: All required functionality works as specified
2. **Code Quality**: Clean, well-organized, and properly documented code
3. **Testing**: Comprehensive unit tests covering all features
4. **Understanding**: Demonstration of concept mastery
5. **Creativity**: Innovative solutions and additional features
6. **Documentation**: Clear explanations and usage examples

## Getting Help

- Review the lesson examples for reference implementations
- Check the course documentation for API details
- Test your code incrementally as you build features
- Use unit tests to verify functionality

## Assignment Completion

Complete assignments in order with the lessons. Each assignment builds on concepts from previous lessons. Focus on understanding the core concepts rather than just completing the code.

The final capstone assignments integrate all course concepts into complete applications that demonstrate real-world network programming skills.
