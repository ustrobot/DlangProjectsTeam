/**
 * Lesson 3: Dynamic Memory Allocation
 * Example: Memory Safety Features in D
 *
 * This example demonstrates D's memory safety features and how to prevent common memory errors.
 */
module lesson3.memory_safety;

import std.stdio;
import std.string;
import core.exception;

void runExample() {
    writeln("=== Memory Safety Features in D Example ===\n");
    
    // D provides several memory safety features to prevent common errors
    
    // 1. Null pointer detection
    writeln("1. Null Pointer Detection:");
    
    int* nullPtr = null;
    
    try {
        // This would cause a segmentation fault in C/C++
        // In D with safety enabled, it throws an Error
        // *nullPtr = 10;  // Uncomment to see the error
        
        writeln("  D detects null pointer dereferences at runtime (in safe mode)");
        writeln("  This prevents one of the most common causes of crashes");
    } catch (Error e) {
        writeln("  Caught error: ", e.msg);
    }
    
    // 2. Array bounds checking
    writeln("\n2. Array Bounds Checking:");
    
    int[] arr = [1, 2, 3, 4, 5];
    
    try {
        // This would cause undefined behavior in C/C++
        // In D with safety enabled, it throws a RangeError
        // int value = arr[10];  // Uncomment to see the error
        
        writeln("  D checks array bounds at runtime (in safe mode)");
        writeln("  This prevents buffer overflows and underflows");
    } catch (RangeError e) {
        writeln("  Caught range error: ", e.msg);
    }
    
    // 3. Memory initialization
    writeln("\n3. Memory Initialization:");
    
    // In D, memory from the GC is initialized
    int[] newArray = new int[5];
    writefln("  New array (automatically initialized to 0): %s", newArray);
    
    // Even class members are initialized
    class TestClass {
        int x;        // Initialized to 0
        bool flag;    // Initialized to false
        string text;  // Initialized to null
    }
    
    auto obj = new TestClass();
    writefln("  New class instance members: x=%d, flag=%s, text=%s", 
             obj.x, obj.flag, obj.text is null ? "null" : obj.text);
    
    // 4. Slices provide safe views into arrays
    writeln("\n4. Safe Array Slices:");
    
    int[] fullArray = [10, 20, 30, 40, 50, 60, 70, 80, 90];
    int[] slice = fullArray[2..5];  // Elements 2, 3, 4
    
    writefln("  Full array: %s", fullArray);
    writefln("  Slice (elements 2-4): %s", slice);
    
    // Modifying the slice modifies the original array
    slice[0] = 300;
    writefln("  After modifying slice[0], full array: %s", fullArray);
    
    // 5. Garbage collection prevents memory leaks
    writeln("\n5. Garbage Collection:");
    
    writeln("  D's garbage collector automatically reclaims memory");
    writeln("  when objects are no longer referenced");
    
    // Create objects without worrying about cleanup
    class LargeObject {
        int[1000] data;
    }
    
    void createObjects() {
        for (int i = 0; i < 10; i++) {
            auto obj = new LargeObject();
            // No need to free - GC will handle it when obj goes out of scope
        }
    }
    
    createObjects();
    writeln("  Objects created and automatically managed by GC");
    
    // 6. @safe, @trusted, and @system function attributes
    writeln("\n6. Code Safety Attributes:");
    
    writeln("  @safe - Cannot perform unsafe operations");
    writeln("  @trusted - Marked safe but can use unsafe code");
    writeln("  @system - Can perform any operation (potentially unsafe)");
    
    // Example of @safe function
    @safe int add(int a, int b) {
        return a + b;
    }
    
    // Example of @system function (allows unsafe operations)
    @system void unsafeOperation() {
        import core.stdc.stdlib : malloc, free;
        int* ptr = cast(int*)malloc(int.sizeof);
        *ptr = 42;
        free(ptr);
    }
    
    writeln("\nKey takeaways:");
    writeln("1. D provides runtime safety checks for null pointers and array bounds");
    writeln("2. Memory is automatically initialized to prevent garbage values");
    writeln("3. Slices provide safe views into arrays");
    writeln("4. Garbage collection prevents most memory leaks");
    writeln("5. Safety attributes allow controlling the safety level of code");
    writeln("6. D allows both safe and unsafe code, with safety by default");
}
