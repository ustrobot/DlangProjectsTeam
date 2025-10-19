/**
 * Main application for "Network Programming Basics" course examples
 *
 * This application provides a menu-based interface to access all examples
 * from the ten lessons in the course.
 */

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import core.stdc.stdlib : exit;

// Import all lesson examples
import lesson1.client_server_model;
import lesson1.tcp_udp_basics;
import lesson1.osi_layers;
import lesson1.dns_lookup;
import lesson1.ip_addressing;

import lesson2.curl_basics;
import lesson2.http_methods;
import lesson2.headers_handling;
import lesson2.response_inspection;
import lesson2.file_operations;

import lesson3.stdcurl_intro;
import lesson3.http_get;
import lesson3.curl_easy;
import lesson3.callback_handlers;
import lesson3.github_api;

import lesson4.post_basics;
import lesson4.form_data;
import lesson4.json_payload;
import lesson4.httpbin_test;
import lesson4.custom_headers;

import lesson5.curl_multi_intro;
import lesson5.parallel_requests;
import lesson5.event_loop;
import lesson5.handle_management;
import lesson5.multi_api_fetch;

import lesson6.rest_principles;
import lesson6.status_codes;
import lesson6.bearer_auth;
import lesson6.api_key_auth;
import lesson6.openweather_api;

import lesson7.json_basics;
import lesson7.json_value;
import lesson7.json_extraction;
import lesson7.weather_struct;
import lesson7.advanced_json;

import lesson8.curl_errors;
import lesson8.retry_logic;
import lesson8.exponential_backoff;
import lesson8.rate_limit_handling;
import lesson8.robust_http_client;

import lesson9.tls_verification;
import lesson9.certificate_handling;
import lesson9.openai_api_contract;
import lesson9.secure_auth;
import lesson9.api_testing;

import lesson10.request_builders;
import lesson10.response_parsers;
import lesson10.conversation_management;
import lesson10.logging;
import lesson10.chat_application;

void main() {
    showMainMenu();
}

/**
 * Display the main menu with lesson options
 */
void showMainMenu() {
    while (true) {
        clearScreen();
        writeln("===============================================");
        writeln("      NETWORK PROGRAMMING BASICS COURSE");
        writeln("===============================================");
        writeln();
        writeln("Select a lesson:");
        writeln("  1. Introduction to Network Programming");
        writeln("  2. `curl` Fundamentals");
        writeln("  3. Using `curl` from D (`std.curl`)");
        writeln("  4. POST Requests & Payloads");
        writeln("  5. Asynchronous Requests with `CurlMulti`");
        writeln("  6. REST APIs & Authentication");
        writeln("  7. JSON Handling in D");
        writeln("  8. Error Handling, Retries & Rate Limits");
        writeln("  9. Secure HTTPS & OpenAI API Specifics");
        writeln(" 10. Capstone Project - Chat with an LLM");
        writeln("  0. Exit");
        writeln();
        write("Enter your choice (0-10): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    showLessonMenu("Introduction to Network Programming", &showLesson1Menu);
                    break;
                case 2:
                    showLesson2Menu();
                    break;
                case 3:
                    showLesson3Menu();
                    break;
                case 4:
                    showLesson4Menu();
                    break;
                case 5:
                    showLesson5Menu();
                    break;
                case 6:
                    showLesson6Menu();
                    break;
                case 7:
                    showLesson7Menu();
                    break;
                case 8:
                    showLesson8Menu();
                    break;
                case 9:
                    showLesson9Menu();
                    break;
                case 10:
                    showLesson10Menu();
                    break;
                case 0:
                    writeln("Exiting program. Goodbye!");
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display menu for Lesson 1
 */
void showLesson1Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 1: INTRODUCTION TO NETWORK PROGRAMMING");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. Client-Server Model");
        writeln("  2. TCP vs UDP Protocols");
        writeln("  3. OSI Network Layers");
        writeln("  4. DNS Lookup and Resolution");
        writeln("  5. IP Address Manipulation and Validation");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("Client-Server Model", &lesson1.client_server_model.runExample);
                    break;
                case 2:
                    runExample("TCP vs UDP Protocols", &lesson1.tcp_udp_basics.runExample);
                    break;
                case 3:
                    runExample("OSI Network Layers", &lesson1.osi_layers.runExample);
                    break;
                case 4:
                    runExample("DNS Lookup and Resolution", &lesson1.dns_lookup.runExample);
                    break;
                case 5:
                    runExample("IP Address Manipulation and Validation", &lesson1.ip_addressing.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display menu for Lesson 2
 */
void showLesson2Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 2: `curl` FUNDAMENTALS");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. curl Basics");
        writeln("  2. HTTP Methods");
        writeln("  3. Headers Handling");
        writeln("  4. Response Inspection");
        writeln("  5. File Operations");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("curl Basics", &lesson2.curl_basics.runExample);
                    break;
                case 2:
                    runExample("HTTP Methods", &lesson2.http_methods.runExample);
                    break;
                case 3:
                    runExample("Headers Handling", &lesson2.headers_handling.runExample);
                    break;
                case 4:
                    runExample("Response Inspection", &lesson2.response_inspection.runExample);
                    break;
                case 5:
                    runExample("File Operations", &lesson2.file_operations.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display menu for Lesson 3
 */
void showLesson3Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 3: USING `curl` FROM D (`std.curl`)");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. std.curl Introduction");
        writeln("  2. HTTP GET Requests");
        writeln("  3. CurlEasy Objects");
        writeln("  4. Callback Handlers");
        writeln("  5. GitHub API");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("std.curl Introduction", &lesson3.stdcurl_intro.runExample);
                    break;
                case 2:
                    runExample("HTTP GET Requests", &lesson3.http_get.runExample);
                    break;
                case 3:
                    runExample("CurlEasy Objects", &lesson3.curl_easy.runExample);
                    break;
                case 4:
                    runExample("Callback Handlers", &lesson3.callback_handlers.runExample);
                    break;
                case 5:
                    runExample("GitHub API", &lesson3.github_api.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display menu for Lesson 4
 */
void showLesson4Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 4: POST REQUESTS & PAYLOADS");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. POST Basics");
        writeln("  2. Form Data");
        writeln("  3. JSON Payload");
        writeln("  4. HttpBin Test");
        writeln("  5. Custom Headers");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("POST Basics", &lesson4.post_basics.runExample);
                    break;
                case 2:
                    runExample("Form Data", &lesson4.form_data.runExample);
                    break;
                case 3:
                    runExample("JSON Payload", &lesson4.json_payload.runExample);
                    break;
                case 4:
                    runExample("HttpBin Test", &lesson4.httpbin_test.runExample);
                    break;
                case 5:
                    runExample("Custom Headers", &lesson4.custom_headers.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display menu for Lesson 5
 */
void showLesson5Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 5: ASYNCHRONOUS REQUESTS WITH `CurlMulti`");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. CurlMulti Introduction");
        writeln("  2. Parallel Requests");
        writeln("  3. Event Loop");
        writeln("  4. Handle Management (disabled - CurlMulti not available)");
        writeln("  5. Multi API Fetch");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("CurlMulti Introduction", &lesson5.curl_multi_intro.runExample);
                    break;
                case 2:
                    runExample("Parallel Requests", &lesson5.parallel_requests.runExample);
                    break;
                case 3:
                    runExample("Event Loop", &lesson5.event_loop.runExample);
                    break;
                case 4:
                    writeln("Handle Management example is disabled (CurlMulti not available in std.net.curl).");
                    writeln("Press Enter to continue...");
                    readln();
                    break;
                case 5:
                    runExample("Multi API Fetch", &lesson5.multi_api_fetch.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display menu for Lesson 6
 */
void showLesson6Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 6: REST APIs & AUTHENTICATION");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. REST Principles");
        writeln("  2. Status Codes");
        writeln("  3. Bearer Authentication");
        writeln("  4. API Key Authentication");
        writeln("  5. OpenWeather API");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("REST Principles", &lesson6.rest_principles.runExample);
                    break;
                case 2:
                    runExample("Status Codes", &lesson6.status_codes.runExample);
                    break;
                case 3:
                    runExample("Bearer Authentication", &lesson6.bearer_auth.runExample);
                    break;
                case 4:
                    runExample("API Key Authentication", &lesson6.api_key_auth.runExample);
                    break;
                case 5:
                    runExample("OpenWeather API", &lesson6.openweather_api.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}


/**
 * Display menu for Lesson 7
 */
void showLesson7Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 7: JSON HANDLING IN D");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. JSON Basics");
        writeln("  2. Working with JsonValue");
        writeln("  3. JSON Field Extraction");
        writeln("  4. Weather API JSON to Struct");
        writeln("  5. Advanced JSON Handling");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("JSON Basics", &lesson7.json_basics.runExample);
                    break;
                case 2:
                    runExample("Working with JsonValue", &lesson7.json_value.runExample);
                    break;
                case 3:
                    runExample("JSON Field Extraction", &lesson7.json_extraction.runExample);
                    break;
                case 4:
                    runExample("Weather API JSON to Struct", &lesson7.weather_struct.runExample);
                    break;
                case 5:
                    runExample("Advanced JSON Handling", &lesson7.advanced_json.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display menu for Lesson 8
 */
void showLesson8Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 8: ERROR HANDLING, RETRIES & RATE LIMITS");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. curl Error Codes");
        writeln("  2. Retry Logic");
        writeln("  3. Exponential Backoff");
        writeln("  4. Rate Limit Handling");
        writeln("  5. Robust HTTP Client");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("curl Error Codes", &lesson8.curl_errors.runExample);
                    break;
                case 2:
                    runExample("Retry Logic", &lesson8.retry_logic.runExample);
                    break;
                case 3:
                    runExample("Exponential Backoff", &lesson8.exponential_backoff.runExample);
                    break;
                case 4:
                    runExample("Rate Limit Handling", &lesson8.rate_limit_handling.runExample);
                    break;
                case 5:
                    runExample("Robust HTTP Client", &lesson8.robust_http_client.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display menu for Lesson 9
 */
void showLesson9Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 9: SECURE HTTPS & OPENAI API SPECIFICS");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. TLS Verification");
        writeln("  2. Certificate Handling");
        writeln("  3. OpenAI API Contract");
        writeln("  4. Secure Authentication");
        writeln("  5. API Testing");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("TLS Verification", &lesson9.tls_verification.runExample);
                    break;
                case 2:
                    runExample("Certificate Handling", &lesson9.certificate_handling.runExample);
                    break;
                case 3:
                    runExample("OpenAI API Contract", &lesson9.openai_api_contract.runExample);
                    break;
                case 4:
                    runExample("Secure Authentication", &lesson9.secure_auth.runExample);
                    break;
                case 5:
                    runExample("API Testing", &lesson9.api_testing.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display menu for Lesson 10
 */
void showLesson10Menu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  LESSON 10: CAPSTONE PROJECT - CHAT WITH AN LLM");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. Request Builders");
        writeln("  2. Response Parsers");
        writeln("  3. Conversation Management");
        writeln("  4. Logging");
        writeln("  5. Complete Chat Application");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");

        string input = readln().strip();

        // Handle empty input
        if (input.empty) {
            continue;
        }

        try {
            int choice = to!int(input);

            switch (choice) {
                case 1:
                    runExample("Request Builders", &lesson10.request_builders.runExample);
                    break;
                case 2:
                    runExample("Response Parsers", &lesson10.response_parsers.runExample);
                    break;
                case 3:
                    runExample("Conversation Management", &lesson10.conversation_management.runExample);
                    break;
                case 4:
                    runExample("Logging", &lesson10.logging.runExample);
                    break;
                case 5:
                    runExample("Complete Chat Application", &lesson10.chat_application.runExample);
                    break;
                case 0:
                    return;
                default:
                    writeln("Invalid choice. Press Enter to continue...");
                    readln();
                    break;
            }
        } catch (Exception e) {
            writeln("Invalid input. Press Enter to continue...");
            readln();
        }
    }
}

/**
 * Display a lesson menu with the given title and menu function
 */
void showLessonMenu(string title, void function() menuFunc) {
    menuFunc();
}

/**
 * Run an example with the given title and function
 */
void runExample(string title, void function() exampleFunc) {
    clearScreen();
    writeln("=================================================");
    writeln("  EXAMPLE: " ~ title.toUpper());
    writeln("=================================================");
    writeln();

    // Run the example
    exampleFunc();

    writeln();
    writeln("=================================================");
    writeln("Example complete. Press Enter to return to menu...");
    readln();
}

/**
 * Clear the screen (platform independent)
 */
void clearScreen() {
    version (Windows) {
        import core.sys.windows.windows;
        HANDLE hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
        CONSOLE_SCREEN_BUFFER_INFO csbi;
        DWORD count;
        DWORD cellCount;
        COORD homeCoords = { 0, 0 };

        if (hStdOut == INVALID_HANDLE_VALUE) return;

        if (!GetConsoleScreenBufferInfo(hStdOut, &csbi)) return;
        cellCount = csbi.dwSize.X * csbi.dwSize.Y;

        if (!FillConsoleOutputCharacter(hStdOut, ' ', cellCount, homeCoords, &count)) return;

        if (!FillConsoleOutputAttribute(hStdOut, csbi.wAttributes, cellCount, homeCoords, &count)) return;

        SetConsoleCursorPosition(hStdOut, homeCoords);
    } else {
        write("\033[2J\033[H");  // ANSI escape sequence to clear screen
    }
}
