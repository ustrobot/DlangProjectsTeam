# Assignments for Addresses, Pointers, and Dynamic Memory

This directory contains programming assignments for the "Addresses, Pointers, and Dynamic Memory" course. These assignments are designed to help students practice and deepen their understanding of memory management and data structures in D.

## Assignment Levels

Assignments are organized into two difficulty levels:

- **Middle School**: Simplified assignments with more guidance, focusing on fundamental concepts
- **High School**: More advanced assignments requiring deeper understanding and implementation

## Lesson 3: Dynamic Memory Allocation

### Middle School Assignments

#### [Assignment 3.1: Array Basics and Memory](middle/lesson3/assignment1_array_basics.md)
Understand how arrays are stored in memory and practice basic array operations.

**Key concepts:**
- Basic understanding of how arrays are stored in memory
- Practice with array operations
- Introduction to memory addresses

#### [Assignment 3.2: Memory Blocks Explorer](middle/lesson3/assignment2_memory_blocks.md)
Visualize memory allocation with a simple block-based memory system.

**Key concepts:**
- Understanding memory allocation concepts
- Visualizing memory usage
- Introduction to memory fragmentation

#### [Assignment 3.3: Memory Usage Detective](middle/lesson3/assignment3_memory_usage_detective.md)
Investigate how different data types and structures use memory.

**Key concepts:**
- Understanding memory usage of different data types
- Introduction to memory alignment
- Basic memory optimization concepts

#### [Assignment 3.4: Object Lifecycle Tracker](middle/lesson3/assignment4_object_lifecycle.md)
Understand object creation, use, and cleanup through a simple tracking system.

**Key concepts:**
- Understanding object lifecycles
- Introduction to scope and memory management
- Basics of reference tracking

### High School Assignments

#### [Assignment 3.1: Custom Dynamic Array Implementation](high/lesson3/assignment1_dynamic_array.md)
Implement a custom dynamic array that manages its own memory without using D's built-in dynamic arrays.

**Key concepts:**
- Manual memory allocation/deallocation
- Dynamic array resizing strategies
- Memory management best practices
- Error handling for memory operations

#### [Assignment 3.2: Memory Pool Allocator](high/lesson3/assignment2_memory_pool.md)
Create a memory pool allocator to efficiently manage memory for objects of fixed size.

**Key concepts:**
- Advanced memory management techniques
- Performance optimization for memory allocation
- Understanding memory fragmentation
- Working with @nogc constraints

#### [Assignment 3.3: Stack and Heap Analyzer](high/lesson3/assignment3_memory_analyzer.md)
Create a tool that analyzes and visualizes memory usage patterns in stack vs heap allocations.

**Key concepts:**
- Understanding memory layout
- Visualizing memory usage
- Analyzing allocation patterns
- Detecting memory issues

#### [Assignment 3.4: Custom Reference Counting System](high/lesson3/assignment4_reference_counting.md)
Implement a simple reference counting system for memory management.

**Key concepts:**
- Understanding reference counting as a memory management strategy
- Implementing copy semantics
- Handling object lifetime
- Detecting and resolving memory leaks

## Lesson 4: Dynamic Data Structures

### Middle School Assignments

#### [Assignment 4.1: Linked Chain](middle/lesson4/assignment1_linked_chain.md)
Implement a simple linked chain to understand pointer-based data structures.

**Key concepts:**
- Understanding linked structures
- Introduction to pointers and references
- Basic operations on linked data

#### [Assignment 4.2: Simple Tree Explorer](middle/lesson4/assignment2_simple_tree.md)
Build a simple family tree to understand hierarchical data structures.

**Key concepts:**
- Understanding hierarchical data structures
- Tree traversal concepts
- Parent-child relationships in data

#### [Assignment 4.3: Word Counter and Organizer](middle/lesson4/assignment3_word_counter.md)
Create a simple word counting and organizing tool using a basic dictionary structure.

**Key concepts:**
- Introduction to key-value data structures
- Basic data organization and retrieval
- Simple text processing

#### [Assignment 4.4: Friendship Network](middle/lesson4/assignment4_friendship_network.md)
Create a simple social network model to understand graph structures.

**Key concepts:**
- Introduction to graph data structures
- Understanding connections and relationships in data
- Basic network traversal concepts

### High School Assignments

#### [Assignment 4.1: Custom Doubly-Linked List with Iterator](high/lesson4/assignment1_doubly_linked_list.md)
Implement a doubly-linked list with a proper iterator interface.

**Key concepts:**
- Advanced pointer manipulation
- Iterator pattern implementation
- Bidirectional traversal of linked structures
- Understanding node-based data structures

#### [Assignment 4.2: Memory-Efficient Binary Search Tree](high/lesson4/assignment2_binary_search_tree.md)
Implement a memory-efficient Binary Search Tree with custom memory management.

**Key concepts:**
- Hierarchical data structure implementation
- Tree traversal algorithms
- Memory optimization techniques
- Tree balancing algorithms
- Visualization of memory structures

#### [Assignment 4.3: Hash Table with Custom Memory Management](high/lesson4/assignment3_hash_table.md)
Implement a hash table that efficiently manages its own memory.

**Key concepts:**
- Hash table implementation techniques
- Collision resolution strategies
- Memory management for dynamic structures
- Performance optimization
- Hash function design

#### [Assignment 4.4: Memory-Efficient Graph Implementation](high/lesson4/assignment4_graph_implementation.md)
Create a memory-efficient graph data structure with custom memory management.

**Key concepts:**
- Graph representation techniques
- Memory-efficient adjacency structures
- Graph algorithm implementation
- Custom allocators for complex structures
- Memory management for dynamic, interconnected data

## Submission Guidelines

For each assignment:
1. Implement the required functionality in a single D file
2. Include comprehensive test cases demonstrating all features
3. Add comments explaining your design choices and implementation details
4. Ensure your code compiles and runs without errors
5. Follow D language best practices and coding standards

## Evaluation Criteria

Your assignments will be evaluated based on:
1. **Correctness**: All operations work as expected
2. **Memory Management**: Proper allocation and deallocation
3. **Error Handling**: Appropriate error checking and handling
4. **Efficiency**: Reasonable performance and memory usage
5. **Code Quality**: Clear, well-organized, and documented code