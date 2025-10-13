/**
 * Lesson 3: Dynamic Memory Allocation
 * Example: Dynamic Memory Allocation in D
 *
 * This example demonstrates how to allocate memory dynamically in D.
 */
module lesson3.dynamic_allocation;

import std.stdio;
import std.string;
import core.memory;

void runExample() {
    writeln("=== Dynamic Memory Allocation in D Example ===\n");
    
    // D provides several ways to allocate memory dynamically
    
    // 1. Using the 'new' operator (GC-managed)
    writeln("1. Using the 'new' operator (GC-managed):");
    
    // Allocate a single integer
    int* singleInt = new int;
    *singleInt = 42;
    writefln("  Allocated int: address=%s, value=%d", singleInt, *singleInt);
    
    // Allocate an array of integers
    int[] intArray = new int[10];
    foreach (i; 0..intArray.length) {
        intArray[i] = cast(int)(i * 10);
    }
    writefln("  Allocated int[]: address=%s, length=%d, values=%s", 
             intArray.ptr, intArray.length, intArray);
    
    // Allocate a string
    string dynamicString = "Hello, Dynamic Memory!".dup;
    writefln("  Allocated string: address=%s, value='%s'", &dynamicString, dynamicString);
    
    // 2. Using core.stdc.stdlib functions (manual memory management)
    writeln("\n2. Using core.stdc.stdlib functions (manual memory management):");
    import core.stdc.stdlib : malloc, calloc, realloc, free;
    
    // Allocate memory for a single integer using malloc
    int* mallocInt = cast(int*)malloc(int.sizeof);
    if (mallocInt is null) {
        writeln("  Failed to allocate memory with malloc");
    } else {
        *mallocInt = 100;
        writefln("  malloc'd int: address=%s, value=%d", mallocInt, *mallocInt);
    }
    
    // Allocate memory for an array of integers using calloc (initialized to 0)
    int* callocArray = cast(int*)calloc(5, int.sizeof);
    if (callocArray is null) {
        writeln("  Failed to allocate memory with calloc");
    } else {
        writeln("  calloc'd int array (initialized to 0):");
        for (int i = 0; i < 5; i++) {
            writefln("    callocArray[%d] = %d", i, callocArray[i]);
        }
        
        // Modify the values
        for (int i = 0; i < 5; i++) {
            callocArray[i] = i * 5;
        }
        
        writeln("  After modification:");
        for (int i = 0; i < 5; i++) {
            writefln("    callocArray[%d] = %d", i, callocArray[i]);
        }
    }
    
    // Resize memory using realloc
    if (callocArray !is null) {
        int* reallocArray = cast(int*)realloc(callocArray, 10 * int.sizeof);
        if (reallocArray is null) {
            writeln("  Failed to reallocate memory");
            // Original memory still valid if realloc fails
        } else {
            callocArray = reallocArray;  // Update pointer to new memory
            
            // Initialize the new elements
            for (int i = 5; i < 10; i++) {
                callocArray[i] = i * 5;
            }
            
            writeln("  After realloc (expanded to 10 elements):");
            for (int i = 0; i < 10; i++) {
                writefln("    callocArray[%d] = %d", i, callocArray[i]);
            }
        }
    }
    
    // 3. Using std.experimental.allocator (more advanced, not covered in detail)
    writeln("\n3. D also provides std.experimental.allocator for more control");
    writeln("  This is an advanced topic with custom allocators and memory pools");
    
    // Clean up manually allocated memory
    if (mallocInt !is null) {
        free(mallocInt);
        writeln("\nFreed malloc'd memory");
    }
    
    if (callocArray !is null) {
        free(callocArray);
        writeln("Freed calloc'd/realloc'd memory");
    }
    
    // Note: GC-allocated memory (new operator) is automatically managed
    
    // Force a garbage collection cycle (just for demonstration)
    writeln("\nForcing garbage collection to clean up GC-managed memory...");
    GC.collect();
    
    writeln("\nKey takeaways:");
    writeln("1. D provides multiple ways to allocate memory dynamically");
    writeln("2. The 'new' operator is the most common and is managed by the GC");
    writeln("3. Manual memory management (malloc/free) is available but rarely needed");
    writeln("4. Always check for allocation failures when using manual allocation");
    writeln("5. Remember to free manually allocated memory to prevent leaks");
}
