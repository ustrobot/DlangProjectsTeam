# Assignment 3.1: Custom Dynamic Array Implementation

## Objective

Implement a custom dynamic array that manages its own memory without using D's built-in dynamic arrays. This assignment will help you understand how dynamic arrays work under the hood and practice manual memory management in D.

## Requirements

### 1. Create a `DynamicArray(T)` struct/class that uses manual memory allocation

Implement a template class or struct that can work with any data type and manages its own memory using manual allocation.

```d
struct DynamicArray(T) {
    // Your implementation here
}
```

### 2. Core Functionality

Implement the following methods:

- **Constructor with initial capacity**
  ```d
  this(size_t initialCapacity);
  ```

- **Add an element to the end**
  ```d
  void add(T element);
  ```

- **Insert at a specific position**
  ```d
  void insert(size_t index, T element);
  ```

- **Remove element at index**
  ```d
  T remove(size_t index);
  ```

- **Get element at index**
  ```d
  T get(size_t index);
  ```

- **Current number of elements**
  ```d
  size_t size();
  ```

- **Current capacity**
  ```d
  size_t capacity();
  ```

- **Reduce capacity to match size**
  ```d
  void shrink();
  ```

- **Proper cleanup method**
  ```d
  void dispose();
  ```

### 3. Automatic Resizing

Implement a strategy to automatically resize the array when it reaches capacity. Common strategies include:
- Double the capacity when full
- Increase by a fixed amount or percentage
- Use a growth factor (e.g., multiply by 1.5)

### 4. Bounds Checking

Include proper bounds checking with appropriate error handling:
- Check for valid indices in `get()`, `insert()`, and `remove()`
- Handle out-of-bounds errors with exceptions or error codes
- Validate inputs for all methods

### 5. Test Cases

Write comprehensive test cases demonstrating all functionality:
- Basic operations (add, get, remove)
- Edge cases (empty array, single element)
- Resizing behavior
- Error handling

## Starter Code

```d
module dynamicarray;

import std.stdio;
import core.stdc.stdlib : malloc, realloc, free;
import std.exception : enforce;

/**
 * A manually managed dynamic array implementation
 */
struct DynamicArray(T) {
private:
    T* data;           // Pointer to the array data
    size_t _size;      // Current number of elements
    size_t _capacity;  // Current capacity
    
public:
    /**
     * Constructor with initial capacity
     */
    this(size_t initialCapacity) {
        // TODO: Allocate memory for initialCapacity elements
        // Initialize _size and _capacity
    }
    
    /**
     * Add an element to the end of the array
     */
    void add(T element) {
        // TODO: Check if resize needed
        // Add the element at the end
        // Update _size
    }
    
    /**
     * Insert an element at the specified index
     */
    void insert(size_t index, T element) {
        // TODO: Check bounds
        // Check if resize needed
        // Shift elements to make room
        // Insert the element
        // Update _size
    }
    
    /**
     * Remove and return the element at the specified index
     */
    T remove(size_t index) {
        // TODO: Check bounds
        // Get the element
        // Shift elements to fill the gap
        // Update _size
        // Return the removed element
    }
    
    /**
     * Get the element at the specified index
     */
    T get(size_t index) {
        // TODO: Check bounds
        // Return the element
    }
    
    /**
     * Get the current number of elements
     */
    size_t size() {
        return _size;
    }
    
    /**
     * Get the current capacity
     */
    size_t capacity() {
        return _capacity;
    }
    
    /**
     * Reduce capacity to match size
     */
    void shrink() {
        // TODO: Resize the array to match the current size
    }
    
    /**
     * Clean up allocated memory
     */
    void dispose() {
        // TODO: Free the allocated memory
        // Reset _size and _capacity
    }
    
private:
    /**
     * Resize the array to the new capacity
     */
    void resize(size_t newCapacity) {
        // TODO: Allocate new memory
        // Copy existing elements
        // Update data pointer and _capacity
    }
}

/**
 * Test function for DynamicArray
 */
void testDynamicArray() {
    // TODO: Implement tests for all functionality
}

void main() {
    testDynamicArray();
}
```

## Evaluation Criteria

Your implementation will be evaluated based on:

1. **Correctness**: All operations work as expected
2. **Memory Management**: Proper allocation and deallocation
3. **Error Handling**: Appropriate bounds checking and error handling
4. **Efficiency**: Reasonable resizing strategy and performance
5. **Code Quality**: Clear, well-organized, and documented code

## Memory Management Tips

When implementing custom dynamic arrays in D:

**Manual Memory Allocation:**
- Use `malloc(T.sizeof * capacity)` to allocate memory for array elements
- Cast properly: `T* data = cast(T*)malloc(T.sizeof * capacity);`
- Always check allocation success: `if (data is null) throw new Exception("Allocation failed");`

**Memory Deallocation:**
- Always call `free(data)` in destructor or dispose method
- Never access memory after freeing it (use-after-free)
- Implement proper cleanup in all code paths

**Resizing Strategy:**
- Choose appropriate growth factors (1.5x or 2x are common)
- Consider amortized analysis - frequent small allocations vs occasional large ones
- Minimize copying during resize operations

**Error Handling:**
- Check bounds in all access methods
- Handle allocation failures gracefully
- Validate input parameters

## Advanced Extensions

If you complete the basic requirements, try these extensions:

1. Implement a `foreach` iterator for your array
2. Add methods like `indexOf()`, `contains()`, and `clear()`
3. Make your implementation work with `@nogc` attribute
4. Implement a thread-safe version with synchronization
5. Add a custom allocator option to control memory allocation strategy

## Submission

Submit your implementation as a single D file with:
- Complete `DynamicArray(T)` implementation
- Test cases demonstrating all functionality
- Comments explaining your design choices

## Learning Outcomes

After completing this assignment, you should understand:
- Manual memory allocation and deallocation in D
- Dynamic array resizing strategies
- Memory management best practices
- Error handling for memory operations
