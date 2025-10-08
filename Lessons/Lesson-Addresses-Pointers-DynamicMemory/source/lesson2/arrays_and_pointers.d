/**
 * Lesson 2: Pointer Arithmetic and Arrays
 * Example: Arrays and Pointers
 *
 * This example demonstrates the relationship between arrays and pointers in D.
 */
module lesson2.arrays_and_pointers;

import std.stdio;

void runExample() {
    writeln("=== Arrays and Pointers Example ===\n");
    
    // Declare a fixed-size array
    int[5] numbers = [10, 20, 30, 40, 50];
    
    // In D, arrays and pointers are not exactly the same as in C/C++
    // But we can still demonstrate the relationship
    
    // Get a pointer to the first element
    int* ptr = &numbers[0];
    
    // Alternative way to get a pointer to the first element
    int* ptr2 = numbers.ptr;
    
    writeln("Array and pointer basics:");
    writefln("  numbers: %s", numbers);
    writefln("  &numbers[0]: %s", &numbers[0]);
    writefln("  numbers.ptr: %s", numbers.ptr);
    writefln("  ptr: %s", ptr);
    writefln("  ptr2: %s", ptr2);
    
    // Access array elements using pointer arithmetic
    writeln("\nAccessing array elements:");
    writefln("  numbers[0] = %d, *ptr = %d", numbers[0], *ptr);
    writefln("  numbers[1] = %d, *(ptr + 1) = %d", numbers[1], *(ptr + 1));
    writefln("  numbers[2] = %d, *(ptr + 2) = %d", numbers[2], *(ptr + 2));
    writefln("  numbers[3] = %d, ptr[3] = %d", numbers[3], ptr[3]);  // Array notation with pointer
    
    // Modify array elements using pointers
    writeln("\nModifying array elements using pointers:");
    *ptr = 100;
    *(ptr + 2) = 300;
    ptr[4] = 500;
    
    writefln("  After modifications: %s", numbers);
    
    // Demonstrate that arrays in D know their length
    writeln("\nArray properties in D:");
    writefln("  numbers.length = %d", numbers.length);
    
    // D arrays vs C arrays
    writeln("\nD arrays vs C-style arrays:");
    writeln("  In D, arrays are more than just pointers:");
    writeln("  - They know their own length");
    writeln("  - They have bounds checking in safe mode");
    writeln("  - They have properties like .ptr, .length, .dup");
    
    // Dynamic arrays in D
    writeln("\nDynamic arrays in D:");
    int[] dynamicArray = [1, 2, 3, 4, 5];
    writefln("  dynamicArray: %s", dynamicArray);
    writefln("  dynamicArray.ptr: %s", dynamicArray.ptr);
    writefln("  dynamicArray.length: %d", dynamicArray.length);
    
    // Slicing - a powerful feature in D
    writeln("\nArray slicing in D:");
    int[] slice = dynamicArray[1..4];  // Elements 1, 2, 3 (not 4)
    writefln("  dynamicArray[1..4]: %s", slice);
    
    // Demonstrate that slices share memory with original array
    slice[0] = 200;  // This changes dynamicArray[1]
    writefln("  After slice[0] = 200:");
    writefln("  slice: %s", slice);
    writefln("  dynamicArray: %s", dynamicArray);
    
    writeln("\nKey takeaways:");
    writeln("1. In D, you can access the underlying pointer of an array with .ptr");
    writeln("2. You can use pointer arithmetic with array pointers");
    writeln("3. D arrays have additional features like length and bounds checking");
    writeln("4. Array slices provide a view into a portion of an array");
    writeln("5. Slices share memory with the original array");
}
