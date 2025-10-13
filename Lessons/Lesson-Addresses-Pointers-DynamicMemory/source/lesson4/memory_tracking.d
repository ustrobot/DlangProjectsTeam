/**
 * Lesson 4: Dynamic Data Structures
 * Example: Memory Tracking and Leak Detection
 *
 * This example demonstrates a simple memory leak detector.
 */
module lesson4.memory_tracking;

import std.stdio;
import std.format;
import std.datetime;
import std.conv;
import std.algorithm;

void runExample() {
    writeln("=== Memory Tracking and Leak Detection Example ===\n");
    
    // 1. Initialize the memory tracker
    writeln("1. Initializing Memory Tracker:");
    
    MemoryTracker tracker = new MemoryTracker();
    writefln("  Memory tracker initialized");
    
    // 2. Allocate and track memory
    writeln("\n2. Allocating and Tracking Memory:");
    
    // Allocate some objects and track them
    void* ptr1 = tracker.allocate(100, "Integer Array");
    writefln("  Allocated 100 bytes for 'Integer Array' at %s", ptr1);
    
    void* ptr2 = tracker.allocate(200, "String Buffer");
    writefln("  Allocated 200 bytes for 'String Buffer' at %s", ptr2);
    
    void* ptr3 = tracker.allocate(50, "Temporary Data");
    writefln("  Allocated 50 bytes for 'Temporary Data' at %s", ptr3);
    
    // 3. Check current memory usage
    writeln("\n3. Current Memory Usage:");
    tracker.printStatus();
    
    // 4. Free some memory
    writeln("\n4. Freeing Memory:");
    
    tracker.deallocate(ptr2);
    writefln("  Freed 'String Buffer' at %s", ptr2);
    
    tracker.printStatus();
    
    // 5. Detect memory leaks
    writeln("\n5. Detecting Memory Leaks:");
    
    tracker.checkLeaks();
    
    // Free remaining memory to clean up
    tracker.deallocate(ptr1);
    tracker.deallocate(ptr3);
    
    writefln("  All memory freed");
    tracker.printStatus();
    
    // 6. Demonstrate a more realistic scenario
    writeln("\n6. Realistic Scenario - Creating a Linked List:");
    
    // Create a new tracker for this example
    MemoryTracker listTracker = new MemoryTracker();
    
    // Create a linked list with tracking
    TrackedNode!int head = null;
    
    // Add nodes
    for (int i = 0; i < 5; i++) {
        TrackedNode!int newNode = cast(TrackedNode!int)listTracker.allocate(
            TrackedNode!int.sizeof, 
            format("Node %d", i)
        );
        
        // Initialize the node
        newNode.value = i * 10;
        newNode.next = head;
        head = newNode;
    }
    
    // Print the list
    writeln("  Created linked list:");
    TrackedNode!int current = head;
    write("    ");
    while (current !is null) {
        write(current.value);
        if (current.next !is null) {
            write(" -> ");
        }
        current = current.next;
    }
    writeln();
    
    // Check for leaks (should show all nodes)
    writeln("\n  Memory status before cleanup:");
    listTracker.printStatus();
    
    // Clean up properly
    writeln("\n  Cleaning up linked list...");
    while (head !is null) {
        TrackedNode!int temp = head;
        head = head.next;
        listTracker.deallocate(cast(void*)temp);
    }
    
    // Check for leaks again (should be empty)
    writeln("\n  Memory status after cleanup:");
    listTracker.printStatus();
    
    writeln("\nKey takeaways:");
    writeln("1. Memory tracking helps identify and prevent memory leaks");
    writeln("2. Each allocation should have a corresponding deallocation");
    writeln("3. Memory leaks can occur when pointers to allocated memory are lost");
    writeln("4. In real applications, memory leaks can cause performance issues");
    writeln("5. D's garbage collector handles most memory management automatically");
    writeln("6. Custom memory tracking is useful for manual memory management");
}

/**
 * Structure to track memory allocations
 */
struct MemoryAllocation {
    void* address;      // Memory address
    size_t size;        // Size in bytes
    string description; // Description of the allocation
    SysTime timestamp;  // When the allocation occurred
}

/**
 * Simple memory tracker to detect leaks
 */
class MemoryTracker {
private:
    MemoryAllocation[] allocations;
    size_t totalAllocated;
    size_t totalFreed;
    size_t allocationCount;
    size_t deallocationCount;
    
public:
    /**
     * Constructor
     */
    this() {
        allocations = [];
        totalAllocated = 0;
        totalFreed = 0;
        allocationCount = 0;
        deallocationCount = 0;
    }
    
    /**
     * Allocate memory and track it
     */
    void* allocate(size_t size, string description) {
        // Allocate memory
        void* ptr = new ubyte[size].ptr;
        
        // Track the allocation
        MemoryAllocation allocation;
        allocation.address = ptr;
        allocation.size = size;
        allocation.description = description;
        allocation.timestamp = Clock.currTime();
        
        allocations ~= allocation;
        
        // Update statistics
        totalAllocated += size;
        allocationCount++;
        
        return ptr;
    }
    
    /**
     * Deallocate memory and remove from tracking
     */
    void deallocate(void* ptr) {
        // Find the allocation
        foreach (i, ref allocation; allocations) {
            if (allocation.address == ptr) {
                // Update statistics
                totalFreed += allocation.size;
                deallocationCount++;
                
                // Remove from tracking
                allocations = allocations[0..i] ~ allocations[i+1..$];
                return;
            }
        }
        
        // If we get here, the pointer wasn't found
        writefln("Warning: Attempt to free untracked pointer %s", ptr);
    }
    
    /**
     * Check for memory leaks
     */
    void checkLeaks() {
        if (allocations.length == 0) {
            writeln("  No memory leaks detected");
            return;
        }
        
        writefln("  WARNING: %d memory leaks detected!", allocations.length);
        writeln("  Leaked allocations:");
        
        foreach (ref allocation; allocations) {
            writefln("    Address: %s, Size: %d bytes, Description: '%s', Allocated at: %s",
                     allocation.address,
                     allocation.size,
                     allocation.description,
                     allocation.timestamp);
        }
    }
    
    /**
     * Print current memory status
     */
    void printStatus() {
        writefln("  Memory Status:");
        writefln("    Total allocated: %d bytes", totalAllocated);
        writefln("    Total freed: %d bytes", totalFreed);
        writefln("    Current usage: %d bytes", totalAllocated - totalFreed);
        writefln("    Allocation count: %d", allocationCount);
        writefln("    Deallocation count: %d", deallocationCount);
        writefln("    Active allocations: %d", allocations.length);
    }
}

/**
 * Node structure for a tracked linked list
 */
class TrackedNode(T) {
    T value;                // The data stored in this node
    TrackedNode!T next;     // Reference to the next node
}
