/**
 * Lesson 2: Pointer Arithmetic and Arrays
 * Example: Array Operations Using Pointers
 *
 * This example demonstrates common array operations using pointers.
 */
module lesson2.array_operations;

import std.stdio;

void runExample() {
    writeln("=== Array Operations Using Pointers Example ===\n");
    
    // Create an array to work with
    int[10] numbers = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
    
    writefln("Original array: %s", numbers);
    
    // Calculate sum using standard approach
    int sum = 0;
    foreach (value; numbers) {
        sum += value;
    }
    writefln("\nSum using standard approach: %d", sum);
    
    // Calculate sum using pointers
    int sumUsingPointers = calculateSumWithPointers(numbers.ptr, numbers.length);
    writefln("Sum using pointers: %d", sumUsingPointers);
    
    // Calculate average using pointers
    double averageUsingPointers = calculateAverageWithPointers(numbers.ptr, numbers.length);
    writefln("Average using pointers: %.2f", averageUsingPointers);
    
    // Find maximum value using pointers
    int maxUsingPointers = findMaxWithPointers(numbers.ptr, numbers.length);
    writefln("Maximum value using pointers: %d", maxUsingPointers);
    
    // Find minimum value using pointers
    int minUsingPointers = findMinWithPointers(numbers.ptr, numbers.length);
    writefln("Minimum value using pointers: %d", minUsingPointers);
    
    // Create a copy of the array using pointers
    int[] arrayCopy = copyArrayWithPointers(numbers.ptr, numbers.length);
    writefln("\nCopied array: %s", arrayCopy);
    
    // Modify the copy to show it's independent
    arrayCopy[0] = 999;
    writefln("Original array after modifying copy: %s", numbers);
    writefln("Modified copy: %s", arrayCopy);
    
    // Demonstrate a filter operation using pointers
    // Create an array with even numbers only
    int[] evenNumbers = filterEvenNumbersWithPointers(numbers.ptr, numbers.length);
    writefln("\nEven numbers only: %s", evenNumbers);
    
    writeln("\nKey takeaways:");
    writeln("1. Pointers can be used for common array operations");
    writeln("2. Pointer-based operations can be efficient but require careful bounds checking");
    writeln("3. D provides safer alternatives through built-in array operations");
    writeln("4. Understanding pointer-based operations helps understand how arrays work");
}

/**
 * Calculate the sum of an array using pointers
 */
int calculateSumWithPointers(int* array, size_t length) {
    int sum = 0;
    int* end = array + length;
    
    while (array < end) {
        sum += *array;
        array++;
    }
    
    return sum;
}

/**
 * Calculate the average of an array using pointers
 */
double calculateAverageWithPointers(int* array, size_t length) {
    if (length == 0) return 0.0;
    
    int sum = calculateSumWithPointers(array, length);
    return cast(double)sum / length;
}

/**
 * Find the maximum value in an array using pointers
 */
int findMaxWithPointers(int* array, size_t length) {
    if (length == 0) return int.min;
    
    int max = *array;
    int* end = array + length;
    array++;  // Move to second element
    
    while (array < end) {
        if (*array > max) {
            max = *array;
        }
        array++;
    }
    
    return max;
}

/**
 * Find the minimum value in an array using pointers
 */
int findMinWithPointers(int* array, size_t length) {
    if (length == 0) return int.max;
    
    int min = *array;
    int* end = array + length;
    array++;  // Move to second element
    
    while (array < end) {
        if (*array < min) {
            min = *array;
        }
        array++;
    }
    
    return min;
}

/**
 * Create a copy of an array using pointers
 */
int[] copyArrayWithPointers(int* array, size_t length) {
    int[] result = new int[length];
    
    for (size_t i = 0; i < length; i++) {
        result[i] = *(array + i);
    }
    
    return result;
}

/**
 * Filter even numbers from an array using pointers
 */
int[] filterEvenNumbersWithPointers(int* array, size_t length) {
    // First count how many even numbers we have
    size_t count = 0;
    int* ptr = array;
    int* end = array + length;
    
    while (ptr < end) {
        if (*ptr % 2 == 0) {
            count++;
        }
        ptr++;
    }
    
    // Allocate result array
    int[] result = new int[count];
    
    // Fill the result array
    ptr = array;
    size_t resultIndex = 0;
    
    while (ptr < end) {
        if (*ptr % 2 == 0) {
            result[resultIndex++] = *ptr;
        }
        ptr++;
    }
    
    return result;
}
