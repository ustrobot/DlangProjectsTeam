/**
 * Lesson 2: Pointer Arithmetic and Arrays
 * Example: Array Iteration Using Pointers
 *
 * This example demonstrates how to iterate through arrays using pointers.
 */
module lesson2.array_iteration;

import std.stdio;

void runExample() {
    writeln("=== Array Iteration Using Pointers Example ===\n");
    
    // Create an array to work with
    int[10] numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    
    // Print the array using standard iteration
    writeln("Standard array iteration:");
    write("  ");
    foreach (i, value; numbers) {
        write(value, " ");
    }
    writeln();
    
    // Print the array using pointer iteration
    writeln("\nPointer-based iteration (C style):");
    write("  ");
    
    // Get pointer to the first element
    int* ptr = &numbers[0];
    
    // Iterate using pointer arithmetic
    for (int i = 0; i < numbers.length; i++) {
        write(*(ptr + i), " ");
    }
    writeln();
    
    // Another way to iterate with pointers
    writeln("\nPointer-based iteration (incrementing pointer):");
    write("  ");
    
    // Reset pointer to the beginning
    ptr = &numbers[0];
    
    // Iterate by incrementing the pointer
    int* endPtr = ptr + numbers.length;  // Points just past the last element
    while (ptr < endPtr) {
        write(*ptr, " ");
        ptr++;
    }
    writeln();
    
    // Demonstrate iterating backwards
    writeln("\nPointer-based reverse iteration:");
    write("  ");
    
    // Start from the end (last element)
    ptr = &numbers[numbers.length - 1];
    
    // Iterate backwards
    for (int i = 0; i < numbers.length; i++) {
        write(*ptr, " ");
        ptr--;
    }
    writeln();
    
    // Demonstrate using pointers with dynamic arrays
    writeln("\nPointer-based iteration with dynamic arrays:");
    int[] dynamicArray = [10, 20, 30, 40, 50];
    
    write("  ");
    ptr = dynamicArray.ptr;
    for (int i = 0; i < dynamicArray.length; i++) {
        write(*(ptr + i), " ");
    }
    writeln();
    
    // Demonstrate a function that uses pointers for iteration
    writeln("\nUsing a function that takes a pointer and length:");
    printArrayUsingPointer(dynamicArray.ptr, dynamicArray.length);
    
    writeln("\nKey takeaways:");
    writeln("1. Pointers can be used to iterate through arrays in various ways");
    writeln("2. Pointer-based iteration is common in C but less common in D");
    writeln("3. D provides safer and more convenient ways to iterate (foreach)");
    writeln("4. Pointer iteration can be useful for low-level operations");
    writeln("5. Always be careful not to go beyond array bounds with pointers");
}

/**
 * Print an array using a pointer and length
 */
void printArrayUsingPointer(int* array, size_t length) {
    write("  ");
    for (size_t i = 0; i < length; i++) {
        write(array[i], " ");  // Equivalent to *(array + i)
    }
    writeln();
}
