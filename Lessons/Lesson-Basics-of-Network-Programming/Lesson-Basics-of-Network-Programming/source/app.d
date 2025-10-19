module app;

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

// Future lesson imports will be added here as they are implemented

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
                    showLessonMenu("`curl` Fundamentals", &showLesson2Menu);
                    break;
                case 3:
                    showLessonMenu("Using `curl` from D (`std.curl`)", &showLesson3Menu);
                    break;
                case 4:
                    showLessonMenu("POST Requests & Payloads", &showLesson4Menu);
                    break;
                case 5:
                    showLessonMenu("Asynchronous Requests with `CurlMulti`", &showLesson5Menu);
                    break;
                case 6:
                    showLessonMenu("REST APIs & Authentication", &showLesson6Menu);
                    break;
                case 7:
                    showLessonMenu("JSON Handling in D", &showLesson7Menu);
                    break;
                case 8:
                    showLessonMenu("Error Handling, Retries & Rate Limits", &showLesson8Menu);
                    break;
                case 9:
                    showLessonMenu("Secure HTTPS & OpenAI API Specifics", &showLesson9Menu);
                    break;
                case 10:
                    showLessonMenu("Capstone Project - Chat with an LLM", &showLesson10Menu);
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
 * Display menu for Lesson 2 (placeholder for now)
 */
void showLesson2Menu() {
    clearScreen();
    writeln("=================================================");
    writeln("  LESSON 2: `curl` FUNDAMENTALS");
    writeln("=================================================");
    writeln();
    writeln("Lesson 2 examples are not yet implemented.");
    writeln("Press Enter to return to main menu...");
    readln();
}

/**
 * Display menu for Lesson 3 (placeholder for now)
 */
void showLesson3Menu() {
    clearScreen();
    writeln("=================================================");
    writeln("  LESSON 3: USING `curl` FROM D (`std.curl`)");
    writeln("=================================================");
    writeln();
    writeln("Lesson 3 examples are not yet implemented.");
    writeln("Press Enter to return to main menu...");
    readln();
}

/**
 * Display menu for Lesson 4 (placeholder for now)
 */
void showLesson4Menu() {
    clearScreen();
    writeln("=================================================");
    writeln("  LESSON 4: POST REQUESTS & PAYLOADS");
    writeln("=================================================");
    writeln();
    writeln("Lesson 4 examples are not yet implemented.");
    writeln("Press Enter to return to main menu...");
    readln();
}

/**
 * Display menu for Lesson 5 (placeholder for now)
 */
void showLesson5Menu() {
    clearScreen();
    writeln("=================================================");
    writeln("  LESSON 5: ASYNCHRONOUS REQUESTS WITH `CurlMulti`");
    writeln("=================================================");
    writeln();
    writeln("Lesson 5 examples are not yet implemented.");
    writeln("Press Enter to return to main menu...");
    readln();
}

/**
 * Display menu for Lesson 6 (placeholder for now)
 */
void showLesson6Menu() {
    clearScreen();
    writeln("=================================================");
    writeln("  LESSON 6: REST APIs & AUTHENTICATION");
    writeln("=================================================");
    writeln();
    writeln("Lesson 6 examples are not yet implemented.");
    writeln("Press Enter to return to main menu...");
    readln();
}

/**
 * Display menu for Lesson 7 (placeholder for now)
 */
void showLesson7Menu() {
    clearScreen();
    writeln("=================================================");
    writeln("  LESSON 7: JSON HANDLING IN D");
    writeln("=================================================");
    writeln();
    writeln("Lesson 7 examples are not yet implemented.");
    writeln("Press Enter to return to main menu...");
    readln();
}

/**
 * Display menu for Lesson 8 (placeholder for now)
 */
void showLesson8Menu() {
    clearScreen();
    writeln("=================================================");
    writeln("  LESSON 8: ERROR HANDLING, RETRIES & RATE LIMITS");
    writeln("=================================================");
    writeln();
    writeln("Lesson 8 examples are not yet implemented.");
    writeln("Press Enter to return to main menu...");
    readln();
}

/**
 * Display menu for Lesson 9 (placeholder for now)
 */
void showLesson9Menu() {
    clearScreen();
    writeln("=================================================");
    writeln("  LESSON 9: SECURE HTTPS & OPENAI API SPECIFICS");
    writeln("=================================================");
    writeln();
    writeln("Lesson 9 examples are not yet implemented.");
    writeln("Press Enter to return to main menu...");
    readln();
}

/**
 * Display menu for Lesson 10 (placeholder for now)
 */
void showLesson10Menu() {
    clearScreen();
    writeln("=================================================");
    writeln("  LESSON 10: CAPSTONE PROJECT - CHAT WITH AN LLM");
    writeln("=================================================");
    writeln();
    writeln("Lesson 10 examples are not yet implemented.");
    writeln("Press Enter to return to main menu...");
    readln();
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
