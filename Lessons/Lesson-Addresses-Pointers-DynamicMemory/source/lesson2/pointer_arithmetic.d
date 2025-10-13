/**
 * Lesson 2: Pointer Arithmetic and Arrays
 * Example: Pointer Arithmetic
 *
 * This example demonstrates basic pointer arithmetic operations.
 */
module lesson2.pointer_arithmetic;

import std.stdio;

void runExample() {
    writeln("=== Pointer Arithmetic Example ===\n");
    
    // Create an array to work with
    int[5] numbers = [10, 20, 30, 40, 50];
    
    // Get a pointer to the first element
    int* ptr = &numbers[0];
    
    // Basic pointer arithmetic
    writeln("Basic pointer arithmetic:");
    writefln("  Address of numbers[0]: %s, Value: %d", ptr, *ptr);
    
    // Move to the next element (ptr + 1)
    ptr = ptr + 1;  // This adds sizeof(int) bytes to the address
    writefln("  After ptr + 1: Address: %s, Value: %d", ptr, *ptr);
    
    // Move to the next element using increment
    ptr++;  // Same as ptr = ptr + 1
    writefln("  After ptr++: Address: %s, Value: %d", ptr, *ptr);
    
    // Move back one element
    ptr--;  // Same as ptr = ptr - 1
    writefln("  After ptr--: Address: %s, Value: %d", ptr, *ptr);
    
    // Jump multiple elements
    ptr = ptr + 2;  // Move forward 2 elements
    writefln("  After ptr + 2: Address: %s, Value: %d", ptr, *ptr);
    
    // Reset pointer to beginning of array
    ptr = &numbers[0];
    
    // Demonstrate how pointer arithmetic adjusts by the size of the type
    writeln("\nPointer arithmetic adjusts by the size of the type:");
    writefln("  Size of int: %d bytes", int.sizeof);
    
    writefln("  ptr:      %s (points to numbers[0] = %d)", ptr, *ptr);
    writefln("  ptr + 1:  %s (points to numbers[1] = %d)", ptr + 1, *(ptr + 1));
    writefln("  ptr + 2:  %s (points to numbers[2] = %d)", ptr + 2, *(ptr + 2));
    
    // Calculate the difference between pointers
    int* start = &numbers[0];
    int* end = &numbers[4];
    
    writeln("\nPointer subtraction:");
    writefln("  start: %s (points to numbers[0] = %d)", start, *start);
    writefln("  end:   %s (points to numbers[4] = %d)", end, *end);
    writefln("  end - start = %d elements", end - start);
    
    // Demonstrate pointer comparison
    writeln("\nPointer comparison:");
    writefln("  start < end: %s", start < end ? "true" : "false");
    writefln("  start > end: %s", start > end ? "true" : "false");
    writefln("  start == end: %s", start == end ? "true" : "false");
    
    // Demonstrate out-of-bounds issues (commented out for safety)
    writeln("\nOut-of-bounds issues (dangerous in real code):");
    writeln("  Accessing memory outside array bounds can cause undefined behavior");
    writeln("  ptr + 10 would point outside our array and could cause a crash");
    
    // Uncomment to demonstrate (may crash or show garbage values)
    // int* dangerous = ptr + 10;  // Points way outside our array
    // writefln("  Value at dangerous location: %d", *dangerous);  // Undefined behavior!
    
    writeln("\nKey takeaways:");
    writeln("1. Pointer arithmetic adds/subtracts in units of the pointed type's size");
    writeln("2. ptr + 1 moves to the next element, not just the next byte");
    writeln("3. Pointer subtraction gives the number of elements between pointers");
    writeln("4. Pointers can be compared with <, >, ==");
    writeln("5. Accessing memory outside array bounds is dangerous and should be avoided");
}
