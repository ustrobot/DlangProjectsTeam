/**
 * Lesson 1: Addresses and Pointer Fundamentals
 * Example: Pointer Basics
 *
 * This example demonstrates basic pointer declaration, initialization, and dereferencing.
 */
module lesson1.pointers_basics;

import std.stdio;

void runExample() {
    writeln("=== Pointer Basics Example ===\n");
    
    // Declare and initialize a regular variable
    int number = 42;
    writefln("Original variable: number = %d", number);
    
    // Declare a pointer to an integer
    int* pNumber;  // Uninitialized pointer (dangerous!)
    
    // Initialize the pointer with the address of our integer variable
    pNumber = &number;
    
    // Print the pointer value (which is an address) and what it points to
    writefln("\nPointer basics:");
    writefln("  &number = %s (address of number variable)", &number);
    writefln("  pNumber = %s (value stored in pointer)", pNumber);
    writefln("  *pNumber = %d (dereferenced value)", *pNumber);
    
    // Modify the original variable through the pointer
    *pNumber = 100;
    writefln("\nAfter *pNumber = 100:");
    writefln("  number = %d (original variable changed)", number);
    writefln("  *pNumber = %d (dereferenced value)", *pNumber);
    
    // Modify the original variable directly
    number = 200;
    writefln("\nAfter number = 200:");
    writefln("  number = %d (original variable)", number);
    writefln("  *pNumber = %d (dereferenced value also changed)", *pNumber);
    
    // Demonstrate multiple indirection (pointer to pointer)
    int** ppNumber = &pNumber;
    writefln("\nPointer to pointer (double indirection):");
    writefln("  ppNumber = %s (address of pNumber)", ppNumber);
    writefln("  *ppNumber = %s (value of pNumber)", *ppNumber);
    writefln("  **ppNumber = %d (value of number)", **ppNumber);
    
    // Change value through double indirection
    **ppNumber = 300;
    writefln("\nAfter **ppNumber = 300:");
    writefln("  number = %d", number);
    writefln("  *pNumber = %d", *pNumber);
    writefln("  **ppNumber = %d", **ppNumber);
    
    writeln("\nKey takeaways:");
    writeln("1. A pointer stores the memory address of another variable");
    writeln("2. The * operator dereferences a pointer (accesses the value it points to)");
    writeln("3. Changes made through a pointer affect the original variable");
    writeln("4. You can have pointers to pointers (multiple levels of indirection)");
}
