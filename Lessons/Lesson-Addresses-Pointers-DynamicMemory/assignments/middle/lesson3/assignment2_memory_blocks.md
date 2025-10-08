# Assignment 3.2: Memory Blocks Explorer

## Objective

Visualize memory allocation with a simple block-based memory system. This assignment will help you understand how computers manage memory when programs need to store data.

## Introduction

Think of computer memory like a big row of boxes where you can store things. When a program needs space, it asks for some of these boxes. When it's done, it gives them back so other programs can use them. In this assignment, you'll create a simple simulation of how this works!

## Requirements

### 1. Create a memory block simulation

Create a D program that simulates memory blocks:
- Represent memory as an array of "blocks" (you can use a character array)
- Each block can be either free or used
- Implement functions to allocate and free blocks

```d
// Example starter code
import std.stdio;

// Our memory is represented as an array of blocks
struct MemorySystem {
    char[] blocks;      // 'F' for free, 'U' for used
    int blockSize = 1;  // Each block is 1 unit in size
    
    // Create a new memory system with the given number of blocks
    this(int numBlocks) {
        blocks = new char[numBlocks];
        // Initialize all blocks as free
        foreach (ref block; blocks) {
            block = 'F';
        }
    }
    
    // TODO: Implement allocate function
    // Should mark blocks as used and return the starting position
    int allocate(int size) {
        // Your code here
    }
    
    // TODO: Implement free function
    // Should mark blocks as free
    void free(int startPos, int size) {
        // Your code here
    }
    
    // TODO: Implement defragment function
    // Should move used blocks to eliminate gaps
    void defragment() {
        // Your code here
    }
}
```

### 2. Create a visual representation of memory

Implement a function to display the memory blocks visually:
- Show blocks as ASCII characters (e.g., [X] for used, [ ] for free)
- Display memory status before and after operations

```d
// Example visualization function
void visualizeMemory(MemorySystem memory) {
    writeln("Memory Status:");
    write("|");
    foreach (block; memory.blocks) {
        if (block == 'U')
            write("[X]");  // Used block
        else
            write("[ ]");  // Free block
    }
    writeln("|");
    
    // Add a position indicator
    write(" ");
    for (int i = 0; i < memory.blocks.length; i++) {
        write(i % 10);
        write("  ");
    }
    writeln();
}
```

### 3. Implement memory operations

Add functions to:
- Allocate a block of specific size
- Free a block
- Defragment memory (move blocks to eliminate gaps)

## Step-by-Step Guide

1. **Create the memory simulation**
   - Define a structure to represent your memory system
   - Initialize it with all blocks free
   - Implement basic allocation and freeing functions

2. **Implement memory visualization**
   - Create a function to display the current state of memory
   - Use different symbols for used and free blocks
   - Add position markers to help identify block positions

3. **Implement memory operations**
   - Allocation: Find enough consecutive free blocks and mark them as used
   - Free: Mark blocks as free starting from a position
   - Defragmentation: Move used blocks to eliminate gaps between them

4. **Test your memory system**
   - Allocate blocks of different sizes
   - Free some blocks to create fragmentation
   - Run defragmentation and observe the results

## Example Output

Your program should produce output similar to this:

```
Initial memory status:
|[ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]|
 0  1  2  3  4  5  6  7  8  9

After allocating 3 blocks:
|[X][X][X][ ][ ][ ][ ][ ][ ][ ]|
 0  1  2  3  4  5  6  7  8  9

After allocating 2 blocks:
|[X][X][X][X][X][ ][ ][ ][ ][ ]|
 0  1  2  3  4  5  6  7  8  9

After freeing blocks at position 1:
|[X][ ][ ][X][X][ ][ ][ ][ ][ ]|
 0  1  2  3  4  5  6  7  8  9

After allocating 2 blocks:
|[X][ ][ ][X][X][X][X][ ][ ][ ]|
 0  1  2  3  4  5  6  7  8  9

After defragmentation:
|[X][X][X][X][X][ ][ ][ ][ ][ ]|
 0  1  2  3  4  5  6  7  8  9
```

## Learning Outcomes

After completing this assignment, you will understand:
- Basic concepts of memory allocation
- How fragmentation occurs in memory
- How defragmentation helps optimize memory usage
- How to visualize memory operations

## Extension Activities

If you finish early, try these additional challenges:

1. Add a "memory usage" report that shows how much memory is used and free
2. Implement different allocation strategies (first-fit, best-fit, worst-fit)
3. Create a simulation where multiple programs compete for memory
4. Add a graphical representation of memory usage over time

## Submission Guidelines

Submit your D source code file with:
- Well-commented code explaining what each part does
- All required functionality implemented
- Output showing the results of your memory operations

## Grading Criteria

- **Correctness**: Does your code correctly implement all required functionality?
- **Understanding**: Do you demonstrate understanding of memory allocation concepts?
- **Visualization**: Is your memory visualization clear and helpful?
- **Code Quality**: Is your code well-organized and properly commented?
