/**
 * Lesson 3: Dynamic Memory Allocation
 * Example: Memory Management with GC Disabled
 *
 * This example demonstrates how to allocate and manage memory in D
 * when garbage collection is disabled.
 */
module lesson3.nogc_memory;

import std.stdio;
import core.memory : GC;
import core.stdc.stdlib : malloc, calloc, realloc, free;
import core.stdc.string : memcpy, memset;

void runExample() {
    writeln("=== Memory Management with GC Disabled Example ===\n");
    
    // 1. Introduction to @nogc
    writeln("1. Introduction to @nogc Attribute:");
    writeln("  The @nogc attribute ensures that a function doesn't allocate GC memory");
    writeln("  This is checked at compile time and will cause errors if GC allocations are used");
    writeln("  Functions marked with @nogc can only call other @nogc functions");
    
    // Demonstrate a simple @nogc function
    int result = nogcAdd(5, 10);
    writefln("  Result of nogcAdd(5, 10): %d", result);
    
    // Demonstrate what's not allowed in @nogc functions
    writeln("\n  In @nogc functions, you CANNOT use:");
    writeln("  - new expressions (e.g., new int, new int[10])");
    writeln("  - Array concatenation (e.g., arr ~= value)");
    writeln("  - Array literals (e.g., [1, 2, 3])");
    writeln("  - Associative array literals");
    writeln("  - Closures that allocate memory");
    writeln("  - Any library function that uses GC");
    
    // 2. Manual Memory Management
    writeln("\n2. Manual Memory Management:");
    
    // Allocate memory for an integer
    int* intPtr = cast(int*)malloc(int.sizeof);
    if (intPtr is null) {
        writeln("  Failed to allocate memory");
        return;
    }
    
    // Initialize the memory
    *intPtr = 42;
    writefln("  Allocated memory for an int: address=%s, value=%d", intPtr, *intPtr);
    
    // Create a manual array
    int arraySize = 5;
    int* arrayPtr = cast(int*)malloc(int.sizeof * arraySize);
    if (arrayPtr is null) {
        writeln("  Failed to allocate array memory");
        free(intPtr);
        return;
    }
    
    // Initialize the array
    for (int i = 0; i < arraySize; i++) {
        arrayPtr[i] = i * 10;
    }
    
    // Print the array
    write("  Manual array: [");
    for (int i = 0; i < arraySize; i++) {
        write(arrayPtr[i]);
        if (i < arraySize - 1) write(", ");
    }
    writeln("]");
    
    // Demonstrate manual array resizing
    int newSize = 8;
    int* newArrayPtr = cast(int*)realloc(arrayPtr, int.sizeof * newSize);
    if (newArrayPtr is null) {
        writeln("  Failed to reallocate memory");
        free(arrayPtr);
        free(intPtr);
        return;
    }
    
    // Update the pointer
    arrayPtr = newArrayPtr;
    
    // Initialize new elements
    for (int i = arraySize; i < newSize; i++) {
        arrayPtr[i] = i * 10;
    }
    
    // Print the resized array
    write("  Resized array: [");
    for (int i = 0; i < newSize; i++) {
        write(arrayPtr[i]);
        if (i < newSize - 1) write(", ");
    }
    writeln("]");
    
    // Free the memory
    free(intPtr);
    free(arrayPtr);
    writeln("  Manually freed memory");
    
    // 3. Temporarily Disabling GC
    writeln("\n3. Temporarily Disabling GC:");
    
    writeln("  For performance-critical sections, you can temporarily disable the GC");
    writeln("  This prevents collection cycles but doesn't prevent GC allocations");
    
    // Demonstrate disabling/enabling the GC
    {
        writeln("  Disabling GC...");
        GC.disable();
        
        // Do some work without GC interruptions
        performCriticalWork();
        
        writeln("  Re-enabling GC...");
        GC.enable();
    }
    
    // 4. Custom Memory Allocators
    writeln("\n4. Custom Memory Allocators:");
    
    // Create a simple memory pool
    MemoryPool pool = MemoryPool(1024);  // 1KB pool
    
    // Allocate from the pool
    void* block1 = pool.allocate(100);
    void* block2 = pool.allocate(200);
    void* block3 = pool.allocate(300);
    
    writefln("  Allocated blocks from pool:");
    writefln("    Block 1: %s (100 bytes)", block1);
    writefln("    Block 2: %s (200 bytes)", block2);
    writefln("    Block 3: %s (300 bytes)", block3);
    writefln("  Pool usage: %d/%d bytes", pool.used, pool.capacity);
    
    // Try to allocate more than available
    void* block4 = pool.allocate(500);
    if (block4 is null) {
        writeln("  Failed to allocate block4 (out of memory in pool)");
    }
    
    // Free the pool (all memory at once)
    pool.reset();
    writeln("  Pool reset, all memory freed");
    writefln("  Pool usage: %d/%d bytes", pool.used, pool.capacity);
    
    // 5. Structs with Custom Allocators
    writeln("\n5. Structs with Custom Allocators:");
    
    // Create a custom vector using manual memory management
    auto vector = ManualVector!int(5);
    
    // Add elements
    vector.add(10);
    vector.add(20);
    vector.add(30);
    vector.add(40);
    vector.add(50);
    
    // Print the vector
    writefln("  Vector contents: %s", vector.toString());
    
    // Try adding more elements (should resize)
    vector.add(60);
    vector.add(70);
    
    writefln("  Vector after adding more elements: %s", vector.toString());
    writefln("  Vector capacity: %d, size: %d", vector.capacity, vector.size);
    
    // Clean up
    vector.dispose();
    writeln("  Vector disposed");
    
    // 6. Best Practices
    writeln("\n6. Best Practices for @nogc Code:");
    writeln("  - Use @nogc for performance-critical code paths");
    writeln("  - Consider the trade-off between safety and performance");
    writeln("  - Remember to free all manually allocated memory");
    writeln("  - Use scope(exit) for cleanup to handle exceptions");
    writeln("  - Consider using betterC for even stricter no-runtime code");
    writeln("  - Use custom allocators for specific allocation patterns");
    writeln("  - Profile your code to ensure @nogc actually improves performance");
    
    writeln("\nKey takeaways:");
    writeln("1. D allows fine-grained control over memory management");
    writeln("2. @nogc ensures no garbage collection allocations occur");
    writeln("3. Manual memory management requires careful tracking of allocations");
    writeln("4. Custom allocators can improve performance for specific use cases");
    writeln("5. D offers a spectrum from fully automatic to fully manual memory management");
}

/**
 * A simple @nogc function that adds two integers
 * This function cannot allocate memory from the GC
 */
@nogc int nogcAdd(int a, int b) {
    return a + b;
}

/**
 * A function that performs some "critical" work
 * This is just a simulation for demonstration purposes
 */
void performCriticalWork() {
    // In a real application, this would be performance-critical code
    // that shouldn't be interrupted by GC collections
    
    writeln("  Performing critical work without GC interruptions...");
    
    // Simulate some work
    long sum = 0;
    for (int i = 0; i < 1_000_000; i++) {
        sum += i;
    }
    
    writefln("  Critical work completed (sum: %d)", sum);
}

/**
 * A simple memory pool allocator
 */
struct MemoryPool {
    private void* memory;
    private size_t capacity;
    private size_t used;
    
    /**
     * Create a memory pool with the given capacity
     */
    this(size_t capacity) {
        this.capacity = capacity;
        this.memory = malloc(capacity);
        this.used = 0;
    }
    
    /**
     * Allocate memory from the pool
     * Returns null if not enough memory is available
     */
    void* allocate(size_t size) {
        // Check if we have enough space
        if (used + size > capacity) {
            return null;
        }
        
        // Get the current position
        void* ptr = cast(void*)(cast(ubyte*)memory + used);
        
        // Update used count
        used += size;
        
        return ptr;
    }
    
    /**
     * Reset the pool (doesn't free memory, just resets the counter)
     */
    void reset() {
        used = 0;
    }
    
    /**
     * Free the entire pool
     */
    void dispose() {
        if (memory !is null) {
            free(memory);
            memory = null;
            capacity = 0;
            used = 0;
        }
    }
}

/**
 * A vector implementation that uses manual memory management
 */
struct ManualVector(T) {
    private T* data;
    private size_t _capacity;
    private size_t _size;
    
    /**
     * Create a vector with initial capacity
     */
    @nogc this(size_t initialCapacity) {
        _capacity = initialCapacity;
        data = cast(T*)malloc(T.sizeof * initialCapacity);
        _size = 0;
    }
    
    /**
     * Add an element to the vector
     */
    @nogc void add(T value) {
        // Check if we need to resize
        if (_size >= _capacity) {
            // Double the capacity
            size_t newCapacity = _capacity * 2;
            T* newData = cast(T*)realloc(data, T.sizeof * newCapacity);
            
            // Check if reallocation succeeded
            if (newData is null) {
                // Handle out of memory (in a real app, you'd want better error handling)
                return;
            }
            
            data = newData;
            _capacity = newCapacity;
        }
        
        // Add the element
        data[_size++] = value;
    }
    
    /**
     * Get an element at the specified index
     */
    @nogc T get(size_t index) {
        // In a real implementation, you'd want bounds checking
        return data[index];
    }
    
    /**
     * Get the current size
     */
    @nogc size_t size() const {
        return _size;
    }
    
    /**
     * Get the current capacity
     */
    @nogc size_t capacity() const {
        return _capacity;
    }
    
    /**
     * Free the memory
     */
    @nogc void dispose() {
        if (data !is null) {
            free(data);
            data = null;
            _capacity = 0;
            _size = 0;
        }
    }
    
    /**
     * Convert to string representation
     * Note: This is NOT @nogc because it allocates a string
     */
    string toString() {
        import std.conv : to;
        
        string result = "[";
        for (size_t i = 0; i < _size; i++) {
            result ~= to!string(data[i]);
            if (i < _size - 1) {
                result ~= ", ";
            }
        }
        result ~= "]";
        return result;
    }
}
