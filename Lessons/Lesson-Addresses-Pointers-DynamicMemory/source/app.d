/**
 * Main application for "Addresses, Pointers, and Dynamic Memory" course examples
 *
 * This application provides a menu-based interface to access all examples
 * from the four lessons in the course.
 */
module app;

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import core.stdc.stdlib : exit;

// Import all lesson examples
import lesson1.addresses;
import lesson1.pointers_basics;
import lesson1.pointer_types;
import lesson1.null_pointers;
import lesson1.swap_function;

import lesson2.pointer_arithmetic;
import lesson2.arrays_and_pointers;
import lesson2.array_iteration;
import lesson2.array_operations;
import lesson2.array_reversal;

import lesson3.stack_vs_heap;
import lesson3.dynamic_allocation;
import lesson3.memory_safety;
import lesson3.dynamic_arrays;
import lesson3.manual_resize;
import lesson3.nogc_memory;

import lesson4.node_structure;
import lesson4.linked_list;
import lesson4.list_operations;
import lesson4.stack_implementation;
import lesson4.memory_tracking;

void main() {
    showMainMenu();
}

/**
 * Display the main menu with lesson options
 */
void showMainMenu() {
    while (true) {
        clearScreen();
        writeln("=================================================");
        writeln("  ADDRESSES, POINTERS, AND DYNAMIC MEMORY COURSE");
        writeln("=================================================");
        writeln();
        writeln("Select a lesson:");
        writeln("  1. Addresses and Pointer Fundamentals");
        writeln("  2. Pointer Arithmetic and Arrays");
        writeln("  3. Dynamic Memory Allocation");
        writeln("  4. Dynamic Data Structures");
        writeln("  0. Exit");
        writeln();
        write("Enter your choice (0-4): ");
        
        string input = readln().strip();
        
        try {
            int choice = to!int(input);
            
            switch (choice) {
                case 1:
                    showLessonMenu("Addresses and Pointer Fundamentals", &showLesson1Menu);
                    break;
                case 2:
                    showLessonMenu("Pointer Arithmetic and Arrays", &showLesson2Menu);
                    break;
                case 3:
                    showLessonMenu("Dynamic Memory Allocation", &showLesson3Menu);
                    break;
                case 4:
                    showLessonMenu("Dynamic Data Structures", &showLesson4Menu);
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
        writeln("  LESSON 1: ADDRESSES AND POINTER FUNDAMENTALS");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. Memory Addresses");
        writeln("  2. Pointer Basics");
        writeln("  3. Pointer Types and Type Safety");
        writeln("  4. Null Pointers and Safety Checks");
        writeln("  5. Swap Function Using Pointers");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");
        
        string input = readln().strip();
        
        try {
            int choice = to!int(input);
            
            switch (choice) {
                case 1:
                    runExample("Memory Addresses", &lesson1.addresses.runExample);
                    break;
                case 2:
                    runExample("Pointer Basics", &lesson1.pointers_basics.runExample);
                    break;
                case 3:
                    runExample("Pointer Types and Type Safety", &lesson1.pointer_types.runExample);
                    break;
                case 4:
                    runExample("Null Pointers and Safety Checks", &lesson1.null_pointers.runExample);
                    break;
                case 5:
                    runExample("Swap Function Using Pointers", &lesson1.swap_function.runExample);
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
        writeln("  LESSON 2: POINTER ARITHMETIC AND ARRAYS");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. Pointer Arithmetic");
        writeln("  2. Arrays and Pointers");
        writeln("  3. Array Iteration Using Pointers");
        writeln("  4. Array Operations Using Pointers");
        writeln("  5. Array Reversal Using Pointers");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");
        
        string input = readln().strip();
        
        try {
            int choice = to!int(input);
            
            switch (choice) {
                case 1:
                    runExample("Pointer Arithmetic", &lesson2.pointer_arithmetic.runExample);
                    break;
                case 2:
                    runExample("Arrays and Pointers", &lesson2.arrays_and_pointers.runExample);
                    break;
                case 3:
                    runExample("Array Iteration Using Pointers", &lesson2.array_iteration.runExample);
                    break;
                case 4:
                    runExample("Array Operations Using Pointers", &lesson2.array_operations.runExample);
                    break;
                case 5:
                    runExample("Array Reversal Using Pointers", &lesson2.array_reversal.runExample);
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
        writeln("  LESSON 3: DYNAMIC MEMORY ALLOCATION");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. Stack vs Heap Memory");
        writeln("  2. Dynamic Memory Allocation in D");
        writeln("  3. Memory Safety Features in D");
        writeln("  4. Working with Dynamic Arrays");
        writeln("  5. Manually Resizing a Dynamic Array");
        writeln("  6. Memory Management with GC Disabled");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-6): ");
        
        string input = readln().strip();
        
        try {
            int choice = to!int(input);
            
            switch (choice) {
                case 1:
                    runExample("Stack vs Heap Memory", &lesson3.stack_vs_heap.runExample);
                    break;
                case 2:
                    runExample("Dynamic Memory Allocation in D", &lesson3.dynamic_allocation.runExample);
                    break;
                case 3:
                    runExample("Memory Safety Features in D", &lesson3.memory_safety.runExample);
                    break;
                case 4:
                    runExample("Working with Dynamic Arrays", &lesson3.dynamic_arrays.runExample);
                    break;
                case 5:
                    runExample("Manually Resizing a Dynamic Array", &lesson3.manual_resize.runExample);
                    break;
                case 6:
                    runExample("Memory Management with GC Disabled", &lesson3.nogc_memory.runExample);
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
        writeln("  LESSON 4: DYNAMIC DATA STRUCTURES");
        writeln("=================================================");
        writeln();
        writeln("Select an example:");
        writeln("  1. Node Structure for Linked Lists");
        writeln("  2. Linked List Implementation");
        writeln("  3. List Operations");
        writeln("  4. Stack Implementation Using Pointers");
        writeln("  5. Memory Tracking and Leak Detection");
        writeln("  0. Back to Main Menu");
        writeln();
        write("Enter your choice (0-5): ");
        
        string input = readln().strip();
        
        try {
            int choice = to!int(input);
            
            switch (choice) {
                case 1:
                    runExample("Node Structure for Linked Lists", &lesson4.node_structure.runExample);
                    break;
                case 2:
                    runExample("Linked List Implementation", &lesson4.linked_list.runExample);
                    break;
                case 3:
                    runExample("List Operations", &lesson4.list_operations.runExample);
                    break;
                case 4:
                    runExample("Stack Implementation Using Pointers", &lesson4.stack_implementation.runExample);
                    break;
                case 5:
                    runExample("Memory Tracking and Leak Detection", &lesson4.memory_tracking.runExample);
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