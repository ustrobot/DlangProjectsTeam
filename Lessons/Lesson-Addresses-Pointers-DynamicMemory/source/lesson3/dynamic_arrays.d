/**
 * Lesson 3: Dynamic Memory Allocation
 * Example: Working with Dynamic Arrays
 *
 * This example demonstrates how to work with dynamic arrays in D.
 */
module lesson3.dynamic_arrays;

import std.stdio;
import std.algorithm;
import std.range;

void runExample() {
    writeln("=== Working with Dynamic Arrays Example ===\n");
    
    // 1. Creating dynamic arrays
    writeln("1. Creating Dynamic Arrays:");
    
    // Create an empty dynamic array
    int[] emptyArray;
    writefln("  emptyArray: %s, length: %d", emptyArray, emptyArray.length);
    
    // Create a dynamic array with initial size
    int[] sizedArray = new int[5];
    writefln("  sizedArray: %s, length: %d", sizedArray, sizedArray.length);
    
    // Create a dynamic array with initial values
    int[] initializedArray = [1, 2, 3, 4, 5];
    writefln("  initializedArray: %s, length: %d", initializedArray, initializedArray.length);
    
    // 2. Resizing dynamic arrays
    writeln("\n2. Resizing Dynamic Arrays:");
    
    writefln("  Before resize: %s, length: %d  %x", sizedArray, sizedArray.length, sizedArray.ptr);
    // Resize by assignment
    sizedArray.length = 10;
    writefln("  After resize to 10: %s, length: %d  %x", sizedArray, sizedArray.length, sizedArray.ptr);
    
    // Fill with values
    foreach (i; 0..sizedArray.length) {
        sizedArray[i] = cast(int)(i * 10);
    }
    writefln("  After filling: %s", sizedArray);
    
    // Shrink the array
    sizedArray.length = 5;
    writefln("  After shrinking to 5: %s, length: %d   %x", sizedArray, sizedArray.length, sizedArray.ptr);
    writefln("  Element 0: %d", sizedArray.ptr[0]);
    writefln("  Element 1: %d", sizedArray.ptr[1]);
    writefln("  Element 2: %d", sizedArray.ptr[2]);
    writefln("  Element 3: %d", sizedArray.ptr[3]);
    writefln("  Element 4: %d", sizedArray.ptr[4]);
    writefln("  Element 5: %d", sizedArray.ptr[5]);
    writefln("  Element 6: %d", sizedArray.ptr[6]);
    writefln("  Element 7: %d", sizedArray.ptr[7]);
    writefln("  Element 8: %d", sizedArray.ptr[8]);
    writefln("  Element 9: %d", sizedArray.ptr[9]);
    
    sizedArray.length = 10;
    writefln("  After shrinking to 10: %s, length: %d  %x", sizedArray, sizedArray.length, sizedArray.ptr);


    // 3. Adding elements to dynamic arrays
    writeln("\n3. Adding Elements to Dynamic Arrays:");
    
    // Using ~= operator (append)
    int[] growingArray = [1, 2, 3];
    writefln("  Initial array: %s", growingArray);
    
    growingArray ~= 4;  // Append a single element
    writefln("  After appending 4: %s", growingArray);
    
    growingArray ~= [5, 6, 7];  // Append multiple elements
    writefln("  After appending [5, 6, 7]: %s", growingArray);
    
    // 4. Memory allocation patterns
    writeln("\n4. Memory Allocation Patterns:");
    
    writeln("  When a dynamic array grows beyond its capacity:");
    writeln("  - D allocates a new, larger block of memory");
    writeln("  - Copies the existing elements to the new block");
    writeln("  - Frees the old block (via garbage collection)");
    writeln("  - This can be inefficient for many small appends");
    
    // Demonstrate capacity growth
    int[] capacityDemo;
    writeln("\n  Growing an array one element at a time:");
    
    int* oldPtr;
    foreach (i; 0..100) {
        size_t oldLength = capacityDemo.length;
        oldPtr = capacityDemo.ptr;
        capacityDemo ~= i;
        writefln("    Added element %d, length: %d", i, capacityDemo.length);
        
        // Check if address changed (reallocation occurred)
        if (oldLength > 0 && capacityDemo.ptr != oldPtr) {
            writeln("    Reallocation occurred!");
            writefln("    Old pointer: %x", oldPtr);
            writefln("    New pointer: %x", capacityDemo.ptr);
        }
    }

    writeln("The end");
    writefln("    Old pointer: %x", oldPtr);
    writefln("    New pointer: %x", capacityDemo.ptr);
    
    // 5. Reserve capacity in advance
    writeln("\n5. Reserve Capacity in Advance:");
    
    // Pre-allocate space for efficiency
    int[] reservedArray;
    reservedArray.reserve(20);  // Reserve space for 20 elements
    
    writeln("  Reserved space for 20 elements");
    writeln("  This reduces reallocations when growing the array");
    
    // 6. Slicing dynamic arrays
    writeln("\n6. Slicing Dynamic Arrays:");
    
    int[] fullArray = [10, 20, 30, 40, 50, 60, 70, 80, 90];
    
    int[] firstHalf = fullArray[0..5];
    int[] secondHalf = fullArray[5..$];  // $ means the length of the array
    
    writefln("  Full array: %s", fullArray);
    writefln("  First half: %s", firstHalf);
    writefln("  Second half: %s", secondHalf);
    
    // Demonstrate that slices share memory
    firstHalf[0] = 1000;
    writefln("\n  After modifying firstHalf[0]:");
    writefln("  Full array: %s", fullArray);
    writefln("  First half: %s", firstHalf);
    
    // 7. Creating independent copies
    writeln("\n7. Creating Independent Copies:");
    
    int[] originalArray = [1, 2, 3, 4, 5];
    int[] shallowCopy = originalArray;  // Just copies the reference
    int[] deepCopy = originalArray.dup;  // Creates a new array with copied values
    
    // Modify the original
    originalArray[0] = 999;
    
    writefln("  Original array: %s", originalArray);
    writefln("  Shallow copy (affected by change): %s", shallowCopy);
    writefln("  Deep copy (independent): %s", deepCopy);
    
    writeln("\nKey takeaways:");
    writeln("1. Dynamic arrays in D automatically manage their memory");
    writeln("2. Arrays can be resized with the .length property");
    writeln("3. Use ~= to append elements or other arrays");
    writeln("4. Use .reserve() to pre-allocate space for better performance");
    writeln("5. Slices provide views into arrays without copying data");
    writeln("6. Use .dup to create independent copies of arrays");
}
