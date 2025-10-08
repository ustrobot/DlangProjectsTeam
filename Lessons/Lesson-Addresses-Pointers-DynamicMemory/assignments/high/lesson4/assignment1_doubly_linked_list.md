# Assignment 4.1: Custom Doubly-Linked List with Iterator

## Objective

Implement a doubly-linked list with a proper iterator interface. This assignment will help you understand node-based data structures, pointer manipulation, and iterator design patterns.

## Requirements

### 1. Create a `DoublyLinkedList(T)` class

Implement a template class that can store and manipulate a doubly-linked list of any data type.

```d
class DoublyLinkedList(T) {
    // Your implementation here
}
```

### 2. Core Functionality

Implement the following methods:

- **Add elements to the list**
  ```d
  void addFirst(T value);
  void addLast(T value);
  ```

- **Remove elements from the list**
  ```d
  T removeFirst();
  T removeLast();
  ```

- **Insert elements at specific positions**
  ```d
  void insertAfter(Node!T* node, T value);
  void insertBefore(Node!T* node, T value);
  ```

- **Remove a specific node**
  ```d
  T remove(Node!T* node);
  ```

- **Find a node containing a value**
  ```d
  Node!T* find(T value);
  ```

### 3. Iterator Implementation

Create an iterator class that allows traversal of the list:

- **Forward iteration**
  ```d
  bool hasNext();
  T next();
  ```

- **Backward iteration**
  ```d
  bool hasPrev();
  T prev();
  ```

- **Access current value**
  ```d
  T value();
  ```

### 4. D Range Interface (Optional Advanced)

Make your list compatible with D's range interfaces:
- Implement `front`, `popFront`, and `empty` for forward ranges
- Implement `back` and `popBack` for bidirectional ranges

### 5. Sorting Method

Implement a method to sort the linked list:
- Choose an appropriate sorting algorithm for linked lists
- Handle edge cases (empty list, single element)
- Allow for custom comparators

## Starter Code

```d
module doublylinkedlist;

import std.stdio;
import std.algorithm;
import std.range;

/**
 * Node for the doubly-linked list
 */
class Node(T) {
    T value;           // The data stored in this node
    Node!T next;       // Reference to the next node
    Node!T prev;       // Reference to the previous node
    
    /**
     * Constructor
     */
    this(T value) {
        this.value = value;
        this.next = null;
        this.prev = null;
    }
}

/**
 * Iterator for the doubly-linked list
 */
class Iterator(T) {
private:
    Node!T current;    // Current node
    
public:
    /**
     * Constructor
     */
    this(Node!T start) {
        this.current = start;
    }
    
    /**
     * Check if there's a next element
     */
    bool hasNext() {
        // TODO: Implement
    }
    
    /**
     * Move to next element and return its value
     */
    T next() {
        // TODO: Implement
    }
    
    /**
     * Check if there's a previous element
     */
    bool hasPrev() {
        // TODO: Implement
    }
    
    /**
     * Move to previous element and return its value
     */
    T prev() {
        // TODO: Implement
    }
    
    /**
     * Get the current value
     */
    T value() {
        // TODO: Implement
    }
    
    /**
     * Get the current node
     */
    Node!T getNode() {
        return current;
    }
}

/**
 * Doubly-linked list implementation
 */
class DoublyLinkedList(T) {
private:
    Node!T head;       // First node in the list
    Node!T tail;       // Last node in the list
    size_t count;      // Number of elements in the list
    
public:
    /**
     * Constructor
     */
    this() {
        head = null;
        tail = null;
        count = 0;
    }
    
    /**
     * Add an element to the beginning of the list
     */
    void addFirst(T value) {
        // TODO: Implement
    }
    
    /**
     * Add an element to the end of the list
     */
    void addLast(T value) {
        // TODO: Implement
    }
    
    /**
     * Remove and return the first element
     */
    T removeFirst() {
        // TODO: Implement
    }
    
    /**
     * Remove and return the last element
     */
    T removeLast() {
        // TODO: Implement
    }
    
    /**
     * Insert a value after the specified node
     */
    void insertAfter(Node!T node, T value) {
        // TODO: Implement
    }
    
    /**
     * Insert a value before the specified node
     */
    void insertBefore(Node!T node, T value) {
        // TODO: Implement
    }
    
    /**
     * Remove the specified node
     */
    T remove(Node!T node) {
        // TODO: Implement
    }
    
    /**
     * Find the first node containing the specified value
     */
    Node!T find(T value) {
        // TODO: Implement
    }
    
    /**
     * Get the number of elements in the list
     */
    size_t size() {
        return count;
    }
    
    /**
     * Check if the list is empty
     */
    bool isEmpty() {
        return count == 0;
    }
    
    /**
     * Get an iterator starting at the head
     */
    Iterator!T iterator() {
        return new Iterator!T(head);
    }
    
    /**
     * Get an iterator starting at the tail
     */
    Iterator!T reverseIterator() {
        return new Iterator!T(tail);
    }
    
    /**
     * Sort the list
     */
    void sort() {
        // TODO: Implement
    }
    
    /**
     * Sort the list with a custom comparator
     */
    void sort(bool function(T a, T b) lessThan) {
        // TODO: Implement
    }
    
    /**
     * Print the list contents
     */
    void printList() {
        if (isEmpty()) {
            writeln("Empty list");
            return;
        }
        
        Node!T current = head;
        while (current !is null) {
            write(current.value);
            if (current.next !is null) {
                write(" <-> ");
            }
            current = current.next;
        }
        writeln();
    }
    
    // Optional: Implement range interface methods
    // auto front() { ... }
    // void popFront() { ... }
    // bool empty() { ... }
    // auto back() { ... }
    // void popBack() { ... }
}

/**
 * Test the doubly-linked list implementation
 */
void testDoublyLinkedList() {
    writeln("=== Testing Doubly-Linked List ===\n");
    
    // Create a list
    auto list = new DoublyLinkedList!int();
    
    // Test adding elements
    writeln("Adding elements:");
    list.addLast(10);
    list.addLast(20);
    list.addLast(30);
    list.addFirst(5);
    list.addFirst(1);
    write("  List: ");
    list.printList();
    writefln("  Size: %d", list.size());
    
    // Test iterator
    writeln("\nIterating forward:");
    auto iter = list.iterator();
    write("  ");
    while (iter.hasNext()) {
        write(iter.next(), " ");
    }
    writeln();
    
    writeln("\nIterating backward:");
    auto revIter = list.reverseIterator();
    write("  ");
    while (revIter.hasPrev()) {
        write(revIter.prev(), " ");
    }
    writeln();
    
    // Test finding and removing
    writeln("\nFinding and removing elements:");
    auto node = list.find(20);
    if (node !is null) {
        writefln("  Found node with value: %d", node.value);
        list.remove(node);
        write("  After removing 20: ");
        list.printList();
    }
    
    // Test insertion
    writeln("\nInserting elements:");
    node = list.find(10);
    if (node !is null) {
        list.insertAfter(node, 15);
        list.insertBefore(node, 7);
        write("  After inserting 15 after 10 and 7 before 10: ");
        list.printList();
    }
    
    // Test sorting
    writeln("\nSorting the list:");
    list.sort();
    write("  Sorted list: ");
    list.printList();
    
    // Test removing from ends
    writeln("\nRemoving from ends:");
    int first = list.removeFirst();
    int last = list.removeLast();
    writefln("  Removed first: %d, last: %d", first, last);
    write("  Remaining list: ");
    list.printList();
    
    // Optional: Test range interface
    // writeln("\nUsing range interface:");
    // foreach (value; list) {
    //     write(value, " ");
    // }
    // writeln();
}

void main() {
    testDoublyLinkedList();
}
```

## Implementation Details

### Node Structure

Implement a proper doubly-linked node structure that:
- Stores the value
- Has references to both next and previous nodes
- Can be easily traversed in both directions

### List Operations

Ensure your list operations handle all edge cases:
- Empty list
- Single element list
- Adding/removing at the beginning/end
- Adding/removing in the middle

### Iterator Design

Your iterator should:
- Track the current position in the list
- Support both forward and backward traversal
- Provide access to the current node and value
- Handle boundary conditions (beginning/end of list)

### Sorting Algorithm

Implement an appropriate sorting algorithm for linked lists:
- Merge sort is often a good choice for linked lists
- Consider the time and space complexity
- Handle edge cases properly

## Evaluation Criteria

Your implementation will be evaluated based on:

1. **Correctness**: All operations work as expected
2. **Pointer Manipulation**: Proper handling of node pointers
3. **Iterator Implementation**: Correct bidirectional traversal
4. **Edge Cases**: Handling of empty lists, single elements, etc.
5. **Code Quality**: Clear, well-organized, and documented code

## Advanced Extensions

If you complete the basic requirements, try these extensions:

1. Make your list fully compatible with D's range interfaces
2. Implement additional operations like `reverse()`, `clear()`, and `toArray()`
3. Add a circular list option
4. Implement a memory-efficient version using a custom allocator
5. Add thread safety features

## Submission

Submit your implementation as a single D file with:
- Complete `DoublyLinkedList(T)` implementation
- Complete `Iterator(T)` implementation
- Test cases demonstrating all functionality
- Comments explaining your design choices

## Learning Outcomes

After completing this assignment, you should understand:
- Node-based data structure implementation
- Pointer manipulation for linked structures
- Iterator design patterns
- Bidirectional traversal algorithms
- Sorting algorithms for linked lists
