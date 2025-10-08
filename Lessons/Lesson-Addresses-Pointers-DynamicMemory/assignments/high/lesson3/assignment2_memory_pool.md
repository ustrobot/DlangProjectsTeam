# Assignment 3.2: Memory Pool Allocator

## Objective

Create a memory pool allocator to efficiently manage memory for objects of fixed size. This assignment will help you understand advanced memory management techniques and performance optimization strategies.

## Requirements

### 1. Implement a `MemoryPool(T)` class that pre-allocates memory for objects of type T

Create a template class that can pre-allocate and manage memory for objects of a specific type.

```d
class MemoryPool(T) {
    // Your implementation here
}
```

### 2. Core Functionality

Implement the following methods:

- **Constructor that pre-allocates memory for N objects**
  ```d
  this(size_t numObjects);
  ```

- **Allocate an object from the pool**
  ```d
  T* allocate();
  ```

- **Return an object to the pool**
  ```d
  void deallocate(T* obj);
  ```

- **Get number of available slots**
  ```d
  size_t available();
  ```

- **Get total capacity**
  ```d
  size_t capacity();
  ```

### 3. Free-List Implementation

Implement a free-list to track available memory blocks:
- Use a linked list structure to track free blocks
- Efficiently reuse deallocated memory
- Handle the case when the pool is full

### 4. Performance Comparison

Create a performance test that compares your memory pool with standard allocation:
- Measure time for multiple allocations and deallocations
- Compare with standard `new`/`delete` or `malloc`/`free`
- Create a report showing the performance difference

### 5. @nogc Implementation

Create a version of your memory pool that can be used with `@nogc`:
- Ensure no GC allocations occur in your implementation
- Mark appropriate methods with `@nogc` attribute
- Demonstrate usage in a `@nogc` context

## Starter Code

```d
module memorypool;

import std.stdio;
import std.datetime.stopwatch;
import core.stdc.stdlib : malloc, free;

/**
 * A memory pool allocator for fixed-size objects
 */
class MemoryPool(T) {
private:
    void* memory;          // The pre-allocated memory block
    size_t blockSize;      // Size of each block (may be larger than T.sizeof)
    size_t _capacity;      // Total number of objects that can be stored
    size_t _available;     // Number of available slots
    void* freeList;        // Pointer to the first free block
    
public:
    /**
     * Constructor that pre-allocates memory for numObjects objects
     */
    this(size_t numObjects) {
        // TODO: Calculate blockSize (consider alignment)
        // Allocate memory for numObjects blocks
        // Initialize the free list
        // Set _capacity and _available
    }
    
    /**
     * Destructor to clean up memory
     */
    ~this() {
        // TODO: Free the allocated memory
    }
    
    /**
     * Allocate an object from the pool
     * Returns: Pointer to memory for a new object, or null if pool is full
     */
    T* allocate() {
        // TODO: Check if pool is empty
        // Remove a block from the free list
        // Update _available
        // Return the block cast to T*
    }
    
    /**
     * Return an object to the pool
     * Params:
     *   obj = Pointer to the object to return to the pool
     */
    void deallocate(T* obj) {
        // TODO: Validate that obj belongs to this pool
        // Add the block to the free list
        // Update _available
    }
    
    /**
     * Get number of available slots
     */
    size_t available() {
        return _available;
    }
    
    /**
     * Get total capacity
     */
    size_t capacity() {
        return _capacity;
    }
}

/**
 * A simple struct to use with the memory pool
 */
struct TestObject {
    int id;
    double value;
    char[32] name;
    
    void initialize(int i) {
        id = i;
        value = i * 3.14;
        // Fill name with something
        foreach (j; 0..8) {
            name[j] = cast(char)('A' + (i + j) % 26);
        }
        name[8] = '\0';
    }
}

/**
 * Performance test comparing memory pool vs standard allocation
 */
void performanceTest(size_t numObjects, size_t iterations) {
    writefln("Performance test: %d objects, %d iterations", numObjects, iterations);
    
    // Create a memory pool
    auto pool = new MemoryPool!TestObject(numObjects);
    
    // Array to store pointers for both tests
    TestObject*[] poolObjects;
    TestObject*[] standardObjects;
    poolObjects.length = numObjects;
    standardObjects.length = numObjects;
    
    // Test memory pool allocation
    auto poolTimer = StopWatch(AutoStart.yes);
    for (size_t iter = 0; iter < iterations; iter++) {
        // Allocate all objects
        for (size_t i = 0; i < numObjects; i++) {
            poolObjects[i] = pool.allocate();
            if (poolObjects[i]) {
                poolObjects[i].initialize(cast(int)i);
            }
        }
        
        // Deallocate all objects
        for (size_t i = 0; i < numObjects; i++) {
            if (poolObjects[i]) {
                pool.deallocate(poolObjects[i]);
            }
        }
    }
    poolTimer.stop();
    
    // Test standard allocation
    auto standardTimer = StopWatch(AutoStart.yes);
    for (size_t iter = 0; iter < iterations; iter++) {
        // Allocate all objects
        for (size_t i = 0; i < numObjects; i++) {
            standardObjects[i] = cast(TestObject*)malloc(TestObject.sizeof);
            if (standardObjects[i]) {
                standardObjects[i].initialize(cast(int)i);
            }
        }
        
        // Deallocate all objects
        for (size_t i = 0; i < numObjects; i++) {
            if (standardObjects[i]) {
                free(standardObjects[i]);
            }
        }
    }
    standardTimer.stop();
    
    // Report results
    writefln("Memory Pool:     %s", poolTimer.peek());
    writefln("Standard Alloc:  %s", standardTimer.peek());
    double speedup = cast(double)standardTimer.peek().total!"usecs" / 
                    cast(double)poolTimer.peek().total!"usecs";
    writefln("Speedup factor:  %.2fx", speedup);
}

/**
 * Test the memory pool implementation
 */
void testMemoryPool() {
    // TODO: Implement basic functionality tests
}

/**
 * Demonstrate @nogc usage of the memory pool
 */
@nogc void nogcTest() {
    // TODO: Implement a test that uses the memory pool in a @nogc context
}

void main() {
    testMemoryPool();
    performanceTest(1000, 100);
    nogcTest();
}
```

## Evaluation Criteria

Your implementation will be evaluated based on:

1. **Correctness**: All operations work as expected
2. **Memory Management**: Proper allocation and deallocation
3. **Performance**: Significant improvement over standard allocation
4. **@nogc Compliance**: Proper implementation of @nogc version
5. **Code Quality**: Clear, well-organized, and documented code

## Advanced Extensions

If you complete the basic requirements, try these extensions:

1. Make the memory pool thread-safe
2. Implement a version that can allocate variable-sized objects
3. Add support for automatic pool expansion when full
4. Implement a memory pool hierarchy for different object sizes
5. Add memory usage statistics and reporting

## Submission

Submit your implementation as a single D file with:
- Complete `MemoryPool(T)` implementation
- Test cases demonstrating all functionality
- Performance comparison results
- @nogc demonstration
- Comments explaining your design choices

## Learning Outcomes

After completing this assignment, you should understand:
- Advanced memory management techniques
- Performance optimization for memory allocation
- Free-list implementation strategies
- Memory fragmentation issues and solutions
- @nogc programming in D
