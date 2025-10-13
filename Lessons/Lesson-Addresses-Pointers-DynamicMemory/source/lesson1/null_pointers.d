/**
 * Lesson 1: Addresses and Pointer Fundamentals
 * Example: Null Pointers and Safety Checks
 *
 * This example demonstrates null pointers, uninitialized pointers, and safety checks.
 */
module lesson1.null_pointers;

import std.stdio;

void runExample() {
    writeln("=== Null Pointers and Safety Checks Example ===\n");
    
    // Declare a null pointer
    int* nullPtr = null;
    writefln("nullPtr = %s", nullPtr);
    
    // Check if pointer is null before dereferencing
    if (nullPtr is null) {
        writeln("nullPtr is null - safe to check, unsafe to dereference");
    }
    
    // Attempting to dereference a null pointer would cause a segmentation fault
    // Uncomment the following line to see the error (program will crash)
    // writeln("Value: ", *nullPtr);  // Segmentation fault!
    
    // Safe way to work with potentially null pointers
    writeln("\nSafe pointer handling:");
    int* safePtr = null;
    
    // Initialize a regular variable
    int number = 42;
    
    // Demonstrate safe pointer usage
    writeln("1. Check if pointer is null before using it");
    if (safePtr !is null) {
        writefln("  safePtr points to: %d", *safePtr);
    } else {
        writeln("  safePtr is null, cannot dereference");
    }
    
    // Assign an address to the pointer
    writeln("\n2. Assign an address to the pointer");
    safePtr = &number;
    if (safePtr !is null) {
        writefln("  safePtr now points to: %d", *safePtr);
    }
    
    // Demonstrate resetting a pointer to null
    writeln("\n3. Reset pointer to null when no longer needed");
    safePtr = null;
    if (safePtr is null) {
        writeln("  safePtr is null again");
    }
    
    // Uninitialized pointers
    writeln("\nUninitialized pointers:");
    writeln("In D, uninitialized pointers in global or static storage are set to null");
    writeln("However, uninitialized pointers in local scope contain garbage values");
    
    // Demonstrate an uninitialized pointer (commented out for safety)
    // int* uninitPtr;  // Contains a random address!
    // if (uninitPtr !is null) {  // This check might pass!
    //     writeln(*uninitPtr);   // Dangerous! Could crash or read random memory
    // }
    
    // Best practice is to always initialize pointers
    int* goodPtr = null;  // Initialize to null if not pointing to anything yet
    
    writeln("\nKey takeaways:");
    writeln("1. Always initialize pointers, preferably to null if not pointing to anything");
    writeln("2. Always check if a pointer is null before dereferencing it");
    writeln("3. Set pointers to null when you're done with them");
    writeln("4. In D, use 'is null' or '!is null' to check pointer nullity");
}
