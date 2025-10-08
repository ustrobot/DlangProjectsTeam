/**
 * Lesson 1: Addresses and Pointer Fundamentals
 * Example: Swap Function Using Pointers
 *
 * This example demonstrates how to implement a swap function using pointers.
 */
module lesson1.swap_function;

import std.stdio;

void runExample() {
    writeln("=== Swap Function Using Pointers Example ===\n");
    
    // Initialize two variables
    int a = 5;
    int b = 10;
    
    // Print original values
    writefln("Original values: a = %d, b = %d", a, b);
    
    // Call swap function
    swap(&a, &b);
    
    // Print swapped values
    writefln("After swap: a = %d, b = %d", a, b);
    
    // Demonstrate swap with different data types
    double x = 3.14;
    double y = 2.71;
    
    writefln("\nOriginal values: x = %f, y = %f", x, y);
    swapGeneric(&x, &y);
    writefln("After swap: x = %f, y = %f", x, y);
    
    // Demonstrate swap with strings
    string str1 = "Hello";
    string str2 = "World";
    
    writefln("\nOriginal values: str1 = '%s', str2 = '%s'", str1, str2);
    swapGeneric(&str1, &str2);
    writefln("After swap: str1 = '%s', str2 = '%s'", str1, str2);
    
    // Demonstrate swap with arrays
    int[] arr1 = [1, 2, 3];
    int[] arr2 = [4, 5, 6];
    
    writefln("\nOriginal arrays: arr1 = %s, arr2 = %s", arr1, arr2);
    swapGeneric(&arr1, &arr2);
    writefln("After swap: arr1 = %s, arr2 = %s", arr1, arr2);
    
    writeln("\nImplementation of swap function:");
    writeln("void swap(int* a, int* b) {");
    writeln("    int temp = *a;");
    writeln("    *a = *b;");
    writeln("    *b = temp;");
    writeln("}");
    
    writeln("\nKey takeaways:");
    writeln("1. Pointers allow functions to modify variables from the caller's scope");
    writeln("2. Swap is a classic example of using pointers to modify multiple values");
    writeln("3. In D, we can use generic functions with type parameters for more flexibility");
    writeln("4. The & operator gets the address of a variable to pass to a function");
}

/**
 * Swap the values of two integers using pointers
 */
void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

/**
 * Generic swap function that works with any type
 */
void swapGeneric(T)(T* a, T* b) {
    T temp = *a;
    *a = *b;
    *b = temp;
}
