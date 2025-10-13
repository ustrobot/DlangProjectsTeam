# Assignment 3.4: Custom Reference Counting System

## Objective

Implement a simple reference counting system for memory management. This assignment will help you understand reference counting as a memory management strategy and how to implement proper object lifetime management.

## Requirements

### 1. Create a `RefCounted(T)` template class

Implement a template class that:
- Keeps track of references to an object
- Automatically frees memory when reference count reaches zero
- Handles copying and assignment correctly

```d
struct RefCounted(T) {
    // Your implementation here
}
```

### 2. Core Functionality

Implement the following methods:

- **Constructor and destructor**
  ```d
  this();
  this(T value);
  ~this();
  ```

- **Copy constructor and assignment operator**
  ```d
  this(this);
  RefCounted!T opAssign(RefCounted!T other);
  ```

- **Reference management methods**
  ```d
  void addRef();
  void release();
  size_t refCount();
  ```

- **Access to the underlying object**
  ```d
  ref T get();
  ```

### 3. Test Cases

Create comprehensive test cases demonstrating:
- Basic reference counting
- Object lifetime management
- Copy semantics
- Assignment behavior
- Proper cleanup

### 4. Handle Circular References (Advanced)

Implement a strategy to detect and handle circular references:
- Weak reference support
- Cycle detection algorithm
- Breaking cycles automatically

### 5. @nogc Implementation (Advanced)

Create a version that works with `@nogc`:
- Ensure no GC allocations occur
- Mark appropriate methods with `@nogc`
- Demonstrate usage in a `@nogc` context

## Starter Code

```d
module refcounted;

import std.stdio;
import core.memory;
import core.stdc.stdlib : malloc, free;

/**
 * A reference-counted wrapper for any type
 */
struct RefCounted(T) {
private:
    static struct RefCountedStore {
        T value;           // The actual value
        size_t refCount;   // Reference count
    }
    
    RefCountedStore* store;  // Pointer to the store
    
public:
    /**
     * Default constructor
     */
    this() {
        // TODO: Initialize with null store
    }
    
    /**
     * Constructor with initial value
     */
    this(T value) {
        // TODO: Allocate store
        // Initialize value
        // Set refCount to 1
    }
    
    /**
     * Copy constructor
     */
    this(this) {
        // TODO: Increment reference count if store is not null
    }
    
    /**
     * Destructor
     */
    ~this() {
        // TODO: Release the reference
    }
    
    /**
     * Assignment operator
     */
    RefCounted!T opAssign(RefCounted!T other) {
        // TODO: Handle self-assignment
        // Release current reference
        // Copy the other's store
        // Increment reference count
        // Return this
    }
    
    /**
     * Add a reference
     */
    void addRef() {
        // TODO: Increment reference count if store is not null
    }
    
    /**
     * Release a reference
     */
    void release() {
        // TODO: Decrement reference count
        // If count reaches zero, free the store
    }
    
    /**
     * Get current reference count
     */
    size_t refCount() {
        // TODO: Return current reference count or 0 if store is null
    }
    
    /**
     * Check if the object is valid (has a store)
     */
    bool isValid() {
        return store !is null;
    }
    
    /**
     * Get reference to the value
     */
    ref T get() {
        // TODO: Check if store is valid
        // Return reference to the value
    }
}

/**
 * A test class to demonstrate reference counting
 */
class TestObject {
    int id;
    string name;
    
    this(int id, string name) {
        this.id = id;
        this.name = name;
        writefln("TestObject %d created: %s", id, name);
    }
    
    ~this() {
        writefln("TestObject %d destroyed: %s", id, name);
    }
    
    void doSomething() {
        writefln("TestObject %d doing something: %s", id, name);
    }
}

/**
 * Test basic reference counting
 */
void testBasicRefCounting() {
    writeln("\n=== Basic Reference Counting Test ===\n");
    
    {
        writeln("Creating first reference:");
        auto ref1 = RefCounted!TestObject(new TestObject(1, "First"));
        writefln("  ref1 count: %d", ref1.refCount());
        
        {
            writeln("\nCreating second reference (copy of first):");
            auto ref2 = ref1;
            writefln("  ref1 count: %d", ref1.refCount());
            writefln("  ref2 count: %d", ref2.refCount());
            
            writeln("\nCreating third reference:");
            auto ref3 = RefCounted!TestObject(new TestObject(2, "Second"));
            writefln("  ref3 count: %d", ref3.refCount());
            
            writeln("\nAssigning third to second:");
            ref2 = ref3;
            writefln("  ref1 count: %d", ref1.refCount());
            writefln("  ref2 count: %d", ref2.refCount());
            writefln("  ref3 count: %d", ref3.refCount());
            
            writeln("\nCalling methods on objects:");
            ref1.get().doSomething();
            ref2.get().doSomething();
            
            writeln("\nSecond and third references going out of scope...");
        }
        
        writefln("\nAfter inner scope:");
        writefln("  ref1 count: %d", ref1.refCount());
        ref1.get().doSomething();
        
        writeln("\nFirst reference going out of scope...");
    }
    
    writeln("\nAll references gone, objects should be destroyed.");
}

/**
 * Test circular references
 */
void testCircularReferences() {
    // TODO: Implement circular reference test
}

/**
 * Test @nogc implementation
 */
@nogc void testNogc() {
    // TODO: Implement @nogc test
}

void main() {
    testBasicRefCounting();
    // Uncomment when implemented:
    // testCircularReferences();
    // testNogc();
}
```

## Implementation Details

### Reference Counting Mechanism

The core of your implementation should:
1. Track the number of references to an object
2. Increment the count when a new reference is created
3. Decrement the count when a reference is destroyed
4. Free the object when the count reaches zero

### Copy Semantics

Ensure proper behavior when:
- A RefCounted object is copied
- A RefCounted object is assigned to another
- A RefCounted object is passed to or returned from a function

### Handling Circular References

For the advanced requirement, implement one of these strategies:
1. Weak references that don't increment the count
2. Cycle detection algorithm
3. Manual breaking of cycles

### @nogc Implementation

For the @nogc version:
1. Use `malloc`/`free` instead of `new`/`delete`
2. Avoid any GC allocations in your methods
3. Handle object construction/destruction manually

## Evaluation Criteria

Your implementation will be evaluated based on:

1. **Correctness**: Proper reference counting and memory management
2. **Safety**: No memory leaks or use-after-free issues
3. **Copy Semantics**: Correct behavior with copying and assignment
4. **Advanced Features**: Handling of circular references and @nogc support
5. **Code Quality**: Clear, well-organized, and documented code

## Advanced Extensions

If you complete the basic requirements, try these extensions:

1. Implement thread-safe reference counting with atomic operations
2. Add move semantics for more efficient transfers
3. Create a weak reference companion class
4. Implement a debug mode that tracks allocation sites
5. Add support for custom deleters

## Submission

Submit your implementation as a single D file with:
- Complete `RefCounted(T)` implementation
- Test cases demonstrating all functionality
- Advanced features (circular references, @nogc)
- Comments explaining your design choices

## Learning Outcomes

After completing this assignment, you should understand:
- Reference counting as a memory management strategy
- Copy and assignment semantics
- Object lifetime management
- Circular reference problems and solutions
- @nogc programming in D
