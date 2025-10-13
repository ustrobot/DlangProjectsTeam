# Assignment 4.1: Linked Chain (Pointer-Based Alternative)

## Objective

Implement a simple linked chain using pointers to structures instead of references to class objects. This alternative assignment will help you understand pointer-based memory management while learning the same concepts as the original assignment.

## Introduction

This is an alternative version of the Linked Chain assignment that uses pointers to structures instead of references to class objects. Just like a treasure hunt where each clue tells you where to find the next clue, this pointer-based approach gives you more direct control over memory and demonstrates how pointers work at a lower level.

## Requirements

### 1. Create a `Link` structure with pointer connections

Create a D program with a `Link` structure that:
- Stores a value (name, number, etc.)
- Uses pointers to connect to the next link in the chain

```d
// Example starter code
import std.stdio;
import std.string;
import core.stdc.stdlib : malloc, free;

/**
 * Link structure using pointers instead of references
 */
struct Link {
    string value;  // The data stored in this link
    Link* next;    // Pointer to the next link in the chain
}

/**
 * Linked chain implementation using pointers
 */
class LinkedChain {
    Link* first;   // Pointer to the first link in the chain
    Link* last;    // Pointer to the last link in the chain
    int length;    // Number of links in the chain

    /**
     * Constructor
     */
    this() {
        first = null;
        last = null;
        length = 0;
    }

    /**
     * Helper function to create a new link with manual memory allocation
     */
    Link* createLink(string value) {
        // TODO: Allocate memory for a new link
        // Initialize the link with the value
        // Return the pointer to the new link
    }

    /**
     * Helper function to free a link's memory
     */
    void freeLink(Link* link) {
        // TODO: Free the memory allocated for the link
    }

    // TODO: Implement method to add a link to the end
    void addLink(string value) {
        // Your code here
    }

    // TODO: Implement method to remove a link
    bool removeLink(string value) {
        // Your code here
    }

    // TODO: Implement method to find a link by value
    Link* findLink(string value) {
        // Your code here
    }

    // TODO: Implement method to print the entire chain
    void printChain() {
        // Your code here
    }

    /**
     * Destructor - clean up all allocated memory
     */
    ~this() {
        // TODO: Free all links in the chain
    }
}
```

### 2. Implement basic operations with pointer management

Add methods to your `LinkedChain` class that:
- Add a link to the end of the chain with proper memory allocation
- Remove a link from the chain with proper memory deallocation
- Find a link by its value
- Print the entire chain

### 3. Create a visual representation of the chain

Create a simple ASCII art visualization that shows the links in the chain:

```
[First] --> [Second] --> [Third] --> [Fourth] --> [End]
```

## Step-by-Step Guide

1. **Create the Link structure**
   - Define a struct that stores a value
   - Add a pointer to the next link in the chain
   - Note: No constructor needed for structs, but you'll need to manage memory manually

2. **Create the LinkedChain class**
   - Keep track of pointers to the first and last links in the chain
   - Track the length of the chain
   - Implement helper functions for memory allocation and deallocation

3. **Implement the createLink method**
   - Use `malloc` to allocate memory for a new link
   - Initialize the link's value and next pointer
   - Return the pointer to the new link

4. **Implement the addLink method**
   - Handle the case when the chain is empty
   - Allocate memory for the new link using createLink
   - Add the new link to the end of the chain
   - Update the last pointer and length

5. **Implement the removeLink method**
   - Handle the case when the link to remove is the first one
   - Handle the case when the link is in the middle or end
   - Free the memory of the removed link using freeLink
   - Update the chain connections and length

6. **Implement the findLink method**
   - Traverse the chain from the beginning using pointer arithmetic
   - Return the link pointer if found, or null if not found

7. **Implement the printChain method**
   - Traverse the chain using pointers and print each link's value
   - Add visual elements to show the connections

8. **Implement proper cleanup**
   - Add a destructor that frees all allocated memory
   - Ensure no memory leaks occur

## Example Output

Your program should produce output similar to this:

```
=== Pointer-Based Linked Chain Demo ===

Adding links to the chain:
Allocated memory for "Apple" at address 0x7FFF1234
Allocated memory for "Banana" at address 0x7FFF1240
Allocated memory for "Cherry" at address 0x7FFF124C
Allocated memory for "Date" at address 0x7FFF1258

Current chain:
[Apple] --> [Banana] --> [Cherry] --> [Date] --> [End]
Chain length: 4

Finding links:
Found "Cherry" at address 0x7FFF124C
"Grape" not found in the chain

Removing links:
Found and removed "Banana" at address 0x7FFF1240
Freed memory at address 0x7FFF1240

Updated chain:
[Apple] --> [Cherry] --> [Date] --> [End]
Chain length: 3

Adding more links:
Allocated memory for "Elderberry" at address 0x7FFF1264
Allocated memory for "Fig" at address 0x7FFF1270

Final chain:
[Apple] --> [Cherry] --> [Date] --> [Elderberry] --> [Fig] --> [End]
Chain length: 5

Cleaning up:
Freed memory at address 0x7FFF1234 (Apple)
Freed memory at address 0x7FFF124C (Cherry)
Freed memory at address 0x7FFF1258 (Date)
Freed memory at address 0x7FFF1264 (Elderberry)
Freed memory at address 0x7FFF1270 (Fig)
All memory freed successfully
```

## Key Differences from Reference-Based Version

| Aspect | Reference-Based | Pointer-Based |
|--------|----------------|---------------|
| **Link Type** | `class Link` | `struct Link` |
| **Connections** | `Link next` | `Link* next` |
| **Memory** | GC-managed | Manual allocation |
| **Performance** | Slightly slower | Potentially faster |
| **Control** | Automatic cleanup | Explicit control |

## Learning Outcomes

After completing this assignment, you will understand:
- How pointer-based structures work in programming
- Manual memory allocation and deallocation in D
- The differences between references and pointers
- How to manage memory explicitly to avoid leaks
- Advanced concepts in memory management

## Extension Activities

If you finish early, try these additional challenges:

1. **Add position-based operations**: Implement methods to insert/remove links at specific positions
2. **Implement a doubly-linked chain**: Each link points to both next and previous links
3. **Add memory tracking**: Track memory usage and report statistics
4. **Create a circular chain**: The last link points back to the first link
5. **Performance comparison**: Compare the performance of pointer-based vs reference-based implementations

## Memory Management Tips

When working with pointers, remember:
- **Always allocate memory before using it**
- **Always free memory when you're done with it**
- **Check for null pointers before dereferencing**
- **Keep track of allocated memory to avoid leaks**
- **Use RAII (Resource Acquisition Is Initialization) patterns when possible**

## Submission Guidelines

Submit your D source code file with:
- Well-commented code explaining what each part does
- All required operations implemented with proper memory management
- A clear visualization of the chain with memory addresses
- Proper cleanup to prevent memory leaks

## Memory Management Tips

When working with pointer-based linked chains in D:

**Node Allocation:**
- Use `malloc(Node.sizeof)` to allocate memory for struct nodes
- Cast properly: `Node* node = cast(Node*)malloc(Node.sizeof);`
- Always check allocation success: `if (node is null) { /* handle error */ }`
- Initialize all fields: `node.value = value; node.next = null;`

**Node Deallocation:**
- Always call `free(node)` when removing nodes from the chain
- Never access a node after freeing it (use-after-free bug)
- Never free the same node twice (double-free bug)
- Use destructors to ensure cleanup: `~this() { clear(); }`

**Memory Safety Best Practices:**
- Keep track of all allocated nodes to prevent leaks
- Use `scope(exit)` for cleanup that must happen even if exceptions occur
- Validate pointers before dereferencing: `if (node !is null) { ... }`
- Consider using smart pointers or RAII patterns for complex scenarios

**Performance Considerations:**
- Manual memory management can be faster than GC-managed allocation
- But incorrect manual management leads to crashes and memory leaks
- Profile your code to ensure manual management actually improves performance

## Grading Criteria

- **Correctness**: Does your code correctly implement all required operations?
- **Memory Management**: Do you properly allocate and free memory?
- **Understanding**: Do you demonstrate understanding of pointer-based structures?
- **Visualization**: Is your chain visualization clear and shows memory addresses?
- **Code Quality**: Is your code well-organized and properly commented?

## Why Pointer-Based?

This pointer-based approach:
1. **Gives you direct control** over memory allocation and deallocation
2. **Demonstrates low-level programming concepts** that are important for systems programming
3. **Shows the relationship** between high-level D code and low-level memory management
4. **Prepares you for** working with C libraries or performance-critical code

While D's garbage collector handles memory automatically in most cases, understanding manual memory management is valuable for writing efficient, low-level code.
