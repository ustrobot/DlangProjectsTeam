/**
 * Lesson 2: Pointer Arithmetic and Arrays
 * Example: Array Reversal Using Pointers
 *
 * This example demonstrates how to reverse an array using pointers.
 */
module lesson2.array_reversal;

import std.stdio;

void runExample() {
    writeln("=== Array Reversal Using Pointers Example ===\n");
    
    // Create an array to work with
    int[10] numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    
    writefln("Original array: %s", numbers);
    
    // Reverse the array using pointers
    reverseArrayWithPointers(numbers.ptr, numbers.length);
    
    writefln("Reversed array: %s", numbers);
    
    // Create a dynamic array for another example
    int[] dynamicArray = [10, 20, 30, 40, 50, 60, 70];
    
    writefln("\nOriginal dynamic array: %s", dynamicArray);
    
    // Reverse the dynamic array using pointers
    reverseArrayWithPointers(dynamicArray.ptr, dynamicArray.length);
    
    writefln("Reversed dynamic array: %s", dynamicArray);
    
    // Demonstrate reversing a string (character array)
    char[] text = "Hello, World!".dup;  // .dup to make it mutable
    
    writefln("\nOriginal string: %s", text);
    
    // Reverse the string using pointers
    reverseArrayWithPointers(text.ptr, text.length);
    
    writefln("Reversed string: %s", text);
    
    // Demonstrate reversing part of an array
    int[] partialArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    
    writefln("\nOriginal array: %s", partialArray);
    
    // Reverse just a portion of the array (elements 2 through 6)
    reverseArrayWithPointers(partialArray.ptr + 2, 5);  // Start at index 2, length 5
    
    writefln("Array with segment reversed: %s", partialArray);
    
    // Demonstrate the implementation
    writeln("\nImplementation of reverseArrayWithPointers:");
    writeln("void reverseArrayWithPointers(T)(T* array, size_t length) {");
    writeln("    T* start = array;");
    writeln("    T* end = array + length - 1;");
    writeln("    ");
    writeln("    while (start < end) {");
    writeln("        // Swap elements");
    writeln("        T temp = *start;");
    writeln("        *start = *end;");
    writeln("        *end = temp;");
    writeln("        ");
    writeln("        // Move pointers toward the middle");
    writeln("        start++;");
    writeln("        end--;");
    writeln("    }");
    writeln("}");
    
    writeln("\nKey takeaways:");
    writeln("1. Pointers allow direct manipulation of array elements");
    writeln("2. Reversing an array is a classic pointer algorithm");
    writeln("3. The technique works with any type of array");
    writeln("4. D's templates allow for generic implementations");
    writeln("5. Pointer arithmetic can target specific segments of an array");
}

/**
 * Reverse an array using pointers
 * 
 * This is a generic function that works with any type
 */
void reverseArrayWithPointers(T)(T* array, size_t length) {
    if (length <= 1) return;  // Nothing to reverse
    
    T* start = array;
    T* end = array + length - 1;
    
    while (start < end) {
        // Swap elements
        T temp = *start;
        *start = *end;
        *end = temp;
        
        // Move pointers toward the middle
        start++;
        end--;
    }
}
