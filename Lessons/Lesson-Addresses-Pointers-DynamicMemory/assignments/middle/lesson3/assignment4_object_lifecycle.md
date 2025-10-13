# Assignment 3.4: Object Lifecycle Tracker

## Objective

Understand object creation, use, and cleanup through a simple tracking system. This assignment will help you understand how objects are created, used, and eventually cleaned up in a computer program.

## Introduction

Objects in a program have a "lifecycle" - they're created, used for a while, and then cleaned up when they're no longer needed. Understanding this lifecycle is important for writing efficient programs. In this assignment, you'll create a system to track and visualize the lifecycle of objects.

## Requirements

### 1. Create a `TrackedObject` class

Create a D program with a `TrackedObject` class that:
- Logs when it's created
- Logs when it's destroyed
- Tracks how many instances exist

```d
// Example starter code
import std.stdio;
import std.datetime;

class TrackedObject {
    // Static counter for all instances
    static int instanceCount = 0;
    
    // Object ID and creation time
    int id;
    SysTime creationTime;
    string name;
    
    // Constructor
    this(string name) {
        // Assign an ID and increment the counter
        this.id = ++instanceCount;
        this.name = name;
        this.creationTime = Clock.currTime();
        
        // Log creation
        writefln("Object %d ('%s') created at %s", 
                 id, name, creationTime.toSimpleString());
    }
    
    // Destructor
    ~this() {
        // Log destruction
        writefln("Object %d ('%s') destroyed after %s seconds", 
                 id, name, (Clock.currTime() - creationTime).total!"seconds");
        
        // Decrement the counter
        instanceCount--;
    }
    
    // Method to report status
    void reportStatus() {
        writefln("Object %d ('%s') is alive for %s seconds. Total objects: %d", 
                 id, name, (Clock.currTime() - creationTime).total!"seconds", instanceCount);
    }
}
```

### 2. Implement different scenarios

Create functions that demonstrate different object lifecycle scenarios:
- Creating objects in different scopes
- Passing objects to functions
- Storing objects in arrays

```d
// Example scenario functions

// Objects created in different scopes
void demonstrateScopes() {
    writeln("\n=== Demonstrating Object Scopes ===");
    
    // Object in the outer scope
    auto outerObject = new TrackedObject("Outer");
    
    // Create a block scope
    {
        // Object in the inner scope
        auto innerObject = new TrackedObject("Inner");
        
        // Report status of both objects
        outerObject.reportStatus();
        innerObject.reportStatus();
        
        writeln("End of inner scope - innerObject will be eligible for cleanup");
    }
    
    // Report status of remaining object
    outerObject.reportStatus();
    
    writeln("End of outer scope - outerObject will be eligible for cleanup");
}

// TODO: Implement function that demonstrates passing objects to functions

// TODO: Implement function that demonstrates storing objects in arrays
```

### 3. Create a visual timeline of object lifecycles

Create a simple visualization that shows when objects are created and destroyed:

```
Object Lifecycle Timeline:
|
|---> Object 1 ('Outer') created
|     |
|     |---> Object 2 ('Inner') created
|     |
|     |<--- Object 2 ('Inner') destroyed
|
|<--- Object 1 ('Outer') destroyed
|
```

## Step-by-Step Guide

1. **Create the TrackedObject class**
   - Implement the constructor to log creation and track instances
   - Implement the destructor to log destruction and update the counter
   - Add methods to report the object's status

2. **Implement lifecycle scenarios**
   - Create objects in different scopes to show how scope affects lifetime
   - Pass objects to functions to show how they're handled
   - Store objects in arrays to show how collections affect lifecycle

3. **Create the visualization**
   - Record the creation and destruction times of objects
   - Create a timeline visualization showing when objects are created and destroyed
   - Use simple ASCII art to make the timeline easy to understand

4. **Add analysis and explanation**
   - Add comments explaining what's happening at each stage
   - Explain how the garbage collector affects object lifecycle
   - Discuss best practices for managing object lifecycles

## Example Output

Your program should produce output similar to this:

```
=== Object Lifecycle Tracker ===

=== Demonstrating Object Scopes ===
Object 1 ('Outer') created at 2025-10-08 15:30:00
Object 2 ('Inner') created at 2025-10-08 15:30:00
Object 1 ('Outer') is alive for 0 seconds. Total objects: 2
Object 2 ('Inner') is alive for 0 seconds. Total objects: 2
End of inner scope - innerObject will be eligible for cleanup
Object 1 ('Outer') is alive for 1 seconds. Total objects: 1
End of outer scope - outerObject will be eligible for cleanup

=== Demonstrating Function Parameters ===
Object 3 ('Parameter') created at 2025-10-08 15:30:01
Inside function: Object 3 ('Parameter') is alive for 0 seconds. Total objects: 1
Object 3 ('Parameter') destroyed after 1 seconds

=== Demonstrating Object Arrays ===
Object 4 ('Array1') created at 2025-10-08 15:30:03
Object 5 ('Array2') created at 2025-10-08 15:30:03
Object 6 ('Array3') created at 2025-10-08 15:30:03
Array contains 3 objects
Removing middle object from array
Object 5 ('Array2') destroyed after 2 seconds
Array now contains 2 objects
End of program - remaining objects will be cleaned up
Object 4 ('Array1') destroyed after 4 seconds
Object 6 ('Array3') destroyed after 4 seconds

Object Lifecycle Timeline:
0s |
   |---> Object 1 ('Outer') created
   |     |
   |     |---> Object 2 ('Inner') created
   |     |
1s |     |<--- Object 2 ('Inner') destroyed
   |
   |---> Object 3 ('Parameter') created
   |
2s |<--- Object 3 ('Parameter') destroyed
   |
   |<--- Object 1 ('Outer') destroyed
   |
3s |---> Object 4 ('Array1') created
   |---> Object 5 ('Array2') created
   |---> Object 6 ('Array3') created
   |
5s |<--- Object 5 ('Array2') destroyed
   |
7s |<--- Object 4 ('Array1') destroyed
   |<--- Object 6 ('Array3') destroyed
   |
```

## Learning Outcomes

After completing this assignment, you will understand:
- How objects are created and destroyed in a program
- How scope affects object lifetime
- How the garbage collector manages memory
- How to track and visualize object lifecycles

## Extension Activities

If you finish early, try these additional challenges:

1. Add memory usage tracking to see how much memory each object uses
2. Create a more complex object hierarchy with parent-child relationships
3. Implement a reference counting system to track object references
4. Create an interactive visualization where users can create and destroy objects

## Submission Guidelines

Submit your D source code file with:
- Well-commented code explaining what each part does
- All required scenarios implemented
- A clear visualization of object lifecycles

## Memory Management Tips

When tracking object lifecycles in D:

**Object Allocation:**
- **Classes**: Created with `new ClassName()` - allocated on heap, managed by GC
- **Structs**: Can be stack-allocated or heap-allocated with `new StructName()`
- **Arrays**: Dynamic arrays grow automatically, fixed arrays need explicit sizing

**Object Lifetime:**
- **Scope-based**: Objects in functions are destroyed when the function exits
- **Reference counting**: Objects exist as long as there are references to them
- **Manual management**: For performance-critical code, manage memory explicitly

**Memory Leaks Prevention:**
- Use `scope(exit)` to ensure cleanup even if exceptions occur
- Avoid circular references that prevent GC cleanup
- Monitor object creation/destruction patterns

**GC Interaction:**
- The garbage collector runs periodically to free unused objects
- You can force collection with `GC.collect()` but this is rarely needed
- Use `@nogc` for functions that must not allocate GC memory

## Grading Criteria

- **Correctness**: Does your code correctly track object lifecycles?
- **Understanding**: Do you demonstrate understanding of object lifecycle concepts?
- **Visualization**: Is your timeline visualization clear and informative?
- **Code Quality**: Is your code well-organized and properly commented?
