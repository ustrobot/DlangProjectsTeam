# Assignment 3.3: Stack and Heap Analyzer

## Objective

Create a tool that analyzes and visualizes memory usage patterns in stack vs heap allocations. This assignment will help you understand memory layout, allocation patterns, and develop skills for memory analysis and visualization.

## Requirements

### 1. Implement a program that analyzes memory usage

Create a program that:
- Creates various objects on both stack and heap
- Tracks memory addresses and sizes
- Visualizes the memory layout using text-based visualization

### 2. Include examples of different allocation types

Your program should demonstrate and analyze:
- Local variables of different sizes
- Dynamic allocations of different sizes
- Arrays (both stack and heap)
- Structs and classes with different memory layouts

### 3. Create a memory usage report

Generate a comprehensive report showing:
- Address ranges for stack and heap
- Memory fragmentation patterns
- Size comparisons between different allocation types
- Memory alignment patterns

### 4. Implement memory leak detection

Add a feature to track memory leaks:
- Track allocations and deallocations
- Identify memory that was allocated but not freed
- Report leak information (address, size, allocation point)

## Starter Code

```d
module memory_analyzer;

import std.stdio;
import std.format;
import std.conv;
import std.algorithm;
import std.range;
import std.string;
import core.memory;

/**
 * Structure to track an allocation
 */
struct AllocationInfo {
    void* address;      // Memory address
    size_t size;        // Size in bytes
    string description; // Description of the allocation
    bool isStack;       // Whether it's on the stack or heap
}

/**
 * Memory analyzer class
 */
class MemoryAnalyzer {
private:
    AllocationInfo[] allocations;
    
public:
    /**
     * Track a stack allocation
     */
    void trackStack(T)(T* ptr, string description) {
        allocations ~= AllocationInfo(cast(void*)ptr, T.sizeof, description, true);
    }
    
    /**
     * Track a heap allocation
     */
    void trackHeap(void* ptr, size_t size, string description) {
        allocations ~= AllocationInfo(ptr, size, description, false);
    }
    
    /**
     * Remove a tracked allocation
     */
    void untrack(void* ptr) {
        import std.algorithm : remove;
        
        foreach (i, ref allocation; allocations) {
            if (allocation.address == ptr) {
                allocations = allocations.remove(i);
                return;
            }
        }
        
        writefln("Warning: Attempted to untrack unknown pointer %s", ptr);
    }
    
    /**
     * Generate a report of memory usage
     */
    void generateReport() {
        writeln("\n=== Memory Usage Report ===\n");
        
        // Sort allocations by address
        import std.algorithm : sort;
        sort!((a, b) => a.address < b.address)(allocations);
        
        // Calculate statistics
        size_t totalStack = 0;
        size_t totalHeap = 0;
        void* minStackAddr = cast(void*)size_t.max;
        void* maxStackAddr = null;
        void* minHeapAddr = cast(void*)size_t.max;
        void* maxHeapAddr = null;
        
        foreach (ref allocation; allocations) {
            if (allocation.isStack) {
                totalStack += allocation.size;
                if (allocation.address < minStackAddr) minStackAddr = allocation.address;
                if (allocation.address > maxStackAddr) maxStackAddr = allocation.address;
            } else {
                totalHeap += allocation.size;
                if (allocation.address < minHeapAddr) minHeapAddr = allocation.address;
                if (allocation.address > maxHeapAddr) maxHeapAddr = allocation.address;
            }
        }
        
        // Print summary
        writeln("Memory Summary:");
        writefln("  Stack: %d bytes total", totalStack);
        writefln("  Heap: %d bytes total", totalHeap);
        writefln("  Stack address range: %s - %s", minStackAddr, maxStackAddr);
        writefln("  Heap address range: %s - %s", minHeapAddr, maxHeapAddr);
        
        // Print allocations
        writeln("\nAllocations:");
        foreach (ref allocation; allocations) {
            writefln("  %s: %s at %s (%d bytes)",
                allocation.isStack ? "Stack" : "Heap",
                allocation.description,
                allocation.address,
                allocation.size);
        }
        
        // TODO: Add memory fragmentation analysis
        
        // TODO: Add memory visualization
    }
    
    /**
     * Visualize memory layout
     */
    void visualizeMemory() {
        writeln("\n=== Memory Visualization ===\n");
        
        // TODO: Implement text-based visualization of memory layout
    }
    
    /**
     * Check for memory leaks
     */
    void checkLeaks() {
        writeln("\n=== Memory Leak Check ===\n");
        
        bool leaksFound = false;
        foreach (ref allocation; allocations) {
            if (!allocation.isStack) {
                writefln("Possible leak: %s at %s (%d bytes)",
                    allocation.description,
                    allocation.address,
                    allocation.size);
                leaksFound = true;
            }
        }
        
        if (!leaksFound) {
            writeln("No memory leaks detected!");
        }
    }
}

/**
 * A test struct with different types of members
 */
struct TestStruct {
    int a;
    double b;
    bool c;
    int[10] arr;
}

/**
 * A test class with different types of members
 */
class TestClass {
    int x;
    double y;
    string name;
    int[] dynamicArray;
    
    this(string name) {
        this.name = name;
        this.x = 42;
        this.y = 3.14;
        this.dynamicArray = new int[5];
    }
}

void main() {
    // Create an analyzer
    auto analyzer = new MemoryAnalyzer();
    
    writeln("=== Stack and Heap Memory Analyzer ===\n");
    
    // Track stack allocations
    int stackInt = 42;
    analyzer.trackStack(&stackInt, "stackInt");
    
    double stackDouble = 3.14;
    analyzer.trackStack(&stackDouble, "stackDouble");
    
    char[20] stackCharArray = "Hello, World!";
    analyzer.trackStack(&stackCharArray, "stackCharArray");
    
    TestStruct stackStruct;
    analyzer.trackStack(&stackStruct, "stackStruct");
    
    // Track heap allocations
    int* heapInt = new int(100);
    analyzer.trackHeap(heapInt, int.sizeof, "heapInt");
    
    double* heapDouble = new double(2.71);
    analyzer.trackHeap(heapDouble, double.sizeof, "heapDouble");
    
    int[] heapArray = new int[10];
    analyzer.trackHeap(heapArray.ptr, int.sizeof * heapArray.length, "heapArray");
    
    TestClass heapClass = new TestClass("Test");
    analyzer.trackHeap(cast(void*)heapClass, __traits(classInstanceSize, TestClass), "heapClass");
    
    // Generate report
    analyzer.generateReport();
    
    // Visualize memory
    analyzer.visualizeMemory();
    
    // Clean up some allocations
    delete heapInt;
    analyzer.untrack(heapInt);
    
    delete heapDouble;
    analyzer.untrack(heapDouble);
    
    // Check for leaks
    analyzer.checkLeaks();
    
    // Clean up remaining allocations to avoid actual leaks
    delete heapClass;
    // Note: heapArray will be cleaned up by the GC
}
```

## Implementation Tasks

### 1. Memory Tracking

Enhance the memory tracking system to:
- Record more detailed information about allocations
- Track memory alignment patterns
- Add call stack information for heap allocations (optional)

### 2. Memory Visualization

Implement a text-based visualization that shows:
- Relative positions of allocations
- Gaps between allocations (fragmentation)
- Different symbols or colors for different allocation types
- Scale indicators for size reference

Example visualization:
```
Stack Memory:
0x7FFF1000 +----------------+ 
           | stackInt       | 4 bytes
0x7FFF1004 +----------------+
           | padding        | 4 bytes
0x7FFF1008 +----------------+
           | stackDouble    | 8 bytes
0x7FFF1010 +----------------+
           | stackCharArray | 20 bytes
0x7FFF1024 +----------------+
           | stackStruct    | 96 bytes
0x7FFF1084 +----------------+

Heap Memory:
0x00A10000 +----------------+
           | heapInt        | 4 bytes
0x00A10004 +----------------+
           | padding        | 4 bytes
0x00A10008 +----------------+
           | heapDouble     | 8 bytes
0x00A10010 +----------------+
           |                |
           |    ~ gap ~     | 16 bytes
           |                |
0x00A10020 +----------------+
           | heapArray      | 40 bytes
0x00A10048 +----------------+
           | heapClass      | 32 bytes
0x00A10068 +----------------+
```

### 3. Fragmentation Analysis

Implement an analysis of memory fragmentation:
- Calculate total fragmentation (sum of gaps between allocations)
- Identify largest contiguous free block
- Calculate fragmentation percentage
- Suggest optimization strategies

### 4. Memory Leak Detection

Enhance the memory leak detection to:
- Track allocation source (file and line number if possible)
- Categorize leaks by size and type
- Provide suggestions for fixing leaks

## Evaluation Criteria

Your implementation will be evaluated based on:

1. **Accuracy**: Correct tracking and reporting of memory usage
2. **Visualization**: Clear and informative memory visualization
3. **Analysis**: Insightful fragmentation and usage analysis
4. **Leak Detection**: Effective identification of memory leaks
5. **Code Quality**: Clear, well-organized, and documented code

## Advanced Extensions

If you complete the basic requirements, try these extensions:

1. Add memory access pattern tracking (read/write frequency)
2. Create a graphical visualization (using a simple graphics library)
3. Add support for tracking system allocations (malloc/free)
4. Implement a memory defragmentation suggestion algorithm
5. Add support for tracking memory usage over time (with snapshots)

## Submission

Submit your implementation as a single D file with:
- Complete `MemoryAnalyzer` implementation
- Test cases demonstrating different memory patterns
- Sample output showing memory reports and visualizations
- Comments explaining your design choices

## Learning Outcomes

After completing this assignment, you should understand:
- Memory layout differences between stack and heap
- Memory alignment and padding patterns
- Memory fragmentation causes and effects
- Techniques for visualizing memory usage
- Strategies for detecting memory leaks
