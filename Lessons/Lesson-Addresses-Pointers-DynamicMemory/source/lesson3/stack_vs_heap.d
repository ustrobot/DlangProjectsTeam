/**
 * Lesson 3: Dynamic Memory Allocation
 * Example: Stack vs Heap Memory
 *
 * This example demonstrates the differences between stack and heap memory.
 */
module lesson3.stack_vs_heap;

import std.stdio;
import core.memory;

void runExample() {
    writeln("=== Stack vs Heap Memory Example ===\n");
    
    // Stack memory examples
    writeln("Stack Memory:");
    writeln("  - Automatically allocated/deallocated");
    writeln("  - Fast allocation (just moves stack pointer)");
    writeln("  - Limited size (typically a few MB)");
    writeln("  - LIFO (Last In, First Out) access pattern");
    writeln("  - Used for local variables, function parameters");
    
    // Demonstrate stack allocation
    int stackInt = 42;
    double stackDouble = 3.14;
    int[5] stackArray = [1, 2, 3, 4, 5];
    
    writefln("\nStack variables:");
    writefln("  stackInt address:    %s", &stackInt);
    writefln("  stackDouble address: %s", &stackDouble);
    writefln("  stackArray address:  %s", &stackArray);
    
    // Call a function to show how stack grows and shrinks
    demonstrateStackGrowth();
    
    // Heap memory examples
    writeln("\nHeap Memory:");
    writeln("  - Manually allocated/deallocated (or garbage collected)");
    writeln("  - Slower allocation than stack");
    writeln("  - Much larger size limit (up to available system memory)");
    writeln("  - Random access pattern");
    writeln("  - Used for dynamic data, large objects, long-lived data");
    
    // Demonstrate heap allocation in D
    // In D, the new operator allocates on the heap and is managed by the GC
    int* heapInt = new int;
    *heapInt = 100;
    
    double* heapDouble = new double;
    *heapDouble = 2.71;
    
    // Allocate an array on the heap
    int[] heapArray = new int[5];
    heapArray[0] = 10;
    heapArray[1] = 20;
    heapArray[2] = 30;
    heapArray[3] = 40;
    heapArray[4] = 50;
    
    writefln("\nHeap variables:");
    writefln("  heapInt address:    %s, value: %d", heapInt, *heapInt);
    writefln("  heapDouble address: %s, value: %f", heapDouble, *heapDouble);
    writefln("  heapArray address:  %s, values: %s", heapArray.ptr, heapArray);
    
    // Demonstrate manual memory management (less common in D)
    writeln("\nManual memory management in D:");
    import core.stdc.stdlib : malloc, free;
    
    // Allocate memory for an integer
    int* manualInt = cast(int*)malloc(int.sizeof);
    *manualInt = 999;
    writefln("  manualInt address: %s, value: %d", manualInt, *manualInt);
    
    // Free the memory
    free(manualInt);
    writeln("  Memory freed (manualInt)");
    
    // Note: In D, you typically don't need to manually free memory
    // because of the garbage collector
    writeln("\nIn D, the garbage collector handles most heap memory:");
    writeln("  - Objects with no references are automatically collected");
    writeln("  - GC.collect() can be called to force collection");
    writeln("  - Manual memory management is available but rarely needed");
    
    // Force a garbage collection (just for demonstration)
    writeln("\nForcing garbage collection...");
    GC.collect();
    
    writeln("\nKey takeaways:");
    writeln("1. Stack memory is fast but limited in size");
    writeln("2. Heap memory is larger but slower to allocate");
    writeln("3. In D, the 'new' operator allocates memory on the heap");
    writeln("4. D's garbage collector automatically manages heap memory");
    writeln("5. Understanding the difference helps with performance and memory usage");
}

void demonstrateStackGrowth() {
    // These variables are allocated on the stack
    int localVar1 = 10;
    int localVar2 = 20;
    
    writefln("\nInside function - stack variables:");
    writefln("  localVar1 address: %s", &localVar1);
    writefln("  localVar2 address: %s", &localVar2);
    
    // Call another function to show further stack growth
    nestedFunction();
    
    // When this function returns, localVar1 and localVar2 are automatically deallocated
}

void nestedFunction() {
    int nestedVar = 30;
    writefln("  nestedVar address: %s (deeper in the stack)", &nestedVar);
    // When this function returns, nestedVar is automatically deallocated
}
