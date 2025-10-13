/**
 * Lesson 4: Dynamic Data Structures
 * Example: Pointer-Based Linked List Implementation
 *
 * This example demonstrates a linked list implementation using pointers to Node structures
 * instead of references to Node class objects. This approach provides more direct memory
 * control and demonstrates manual memory management.
 */
module lesson4.pointer_linked_list;

import std.stdio;
import std.format;
import core.stdc.stdlib : malloc, free;

void runExample() {
    writeln("=== Pointer-Based Linked List Implementation Example ===\n");
    
    // 1. Create an empty linked list
    writeln("1. Creating a Linked List:");
    
    LinkedList!int list = new LinkedList!int();
    writefln("  Created an empty linked list");
    writefln("  Is empty: %s", list.isEmpty() ? "yes" : "no");
    writefln("  Size: %d", list.size());
    
    // 2. Add elements to the list
    writeln("\n2. Adding Elements to the List:");
    
    list.addFirst(10);
    list.addFirst(20);
    list.addFirst(30);
    
    writeln("  Added elements 30, 20, 10 to the front");
    write("  List contents: ");
    list.printList();
    writefln("  Size: %d", list.size());
    
    list.addLast(40);
    list.addLast(50);
    
    writeln("  Added elements 40, 50 to the end");
    write("  List contents: ");
    list.printList();
    writefln("  Size: %d", list.size());
    
    // 3. Access elements
    writeln("\n3. Accessing Elements:");
    
    writefln("  First element: %d", list.getFirst());
    writefln("  Last element: %d", list.getLast());
    
    try {
        writefln("  Element at index 2: %d", list.get(2));
        writefln("  Element at index 4: %d", list.get(4));
        
        // This would throw an exception
        // writefln("  Element at index 10: %d", list.get(10));
    } catch (Exception e) {
        writefln("  Error: %s", e.msg);
    }
    
    // 4. Search for elements
    writeln("\n4. Searching for Elements:");
    
    writefln("  Contains 30: %s", list.contains(30) ? "yes" : "no");
    writefln("  Contains 100: %s", list.contains(100) ? "yes" : "no");
    writefln("  Index of 40: %d", list.indexOf(40));
    writefln("  Index of 100: %d", list.indexOf(100));  // -1 means not found
    
    // 5. Remove elements
    writeln("\n5. Removing Elements:");
    
    int removed = list.removeFirst();
    writefln("  Removed first element: %d", removed);
    write("  List contents: ");
    list.printList();
    
    removed = list.removeLast();
    writefln("  Removed last element: %d", removed);
    write("  List contents: ");
    list.printList();
    
    bool success = list.remove(10);
    writefln("  Removed element 10: %s", success ? "success" : "not found");
    write("  List contents: ");
    list.printList();
    
    // 6. Clear the list
    writeln("\n6. Clearing the List:");
    
    list.clear();
    writefln("  Cleared the list");
    writefln("  Is empty: %s", list.isEmpty() ? "yes" : "no");
    writefln("  Size: %d", list.size());
    
    // 7. Work with a list of strings
    writeln("\n7. Linked List with Strings:");
    
    LinkedList!string strList = new LinkedList!string();
    strList.addLast("Hello");
    strList.addLast("Linked");
    strList.addLast("List");
    strList.addLast("World");
    
    write("  String list contents: ");
    strList.printList();
    
    writeln("\nPointer-Based Linked List Implementation:");
    writeln("  struct Node(T) {");
    writeln("      T value;");
    writeln("      Node!T* next;");
    writeln("  }");
    writeln("  ");
    writeln("  class LinkedList(T) {");
    writeln("      private Node!T* head;");
    writeln("      private Node!T* tail;");
    writeln("      private size_t count;");
    writeln("      ");
    writeln("      // Methods for adding, removing, and accessing elements");
    writeln("      void addFirst(T value) { ... }");
    writeln("      void addLast(T value) { ... }");
    writeln("      T removeFirst() { ... }");
    writeln("      T removeLast() { ... }");
    writeln("      bool remove(T value) { ... }");
    writeln("      // etc...");
    writeln("  }");
    
    writeln("\nKey takeaways:");
    writeln("1. Linked lists can be implemented using pointers to node structures");
    writeln("2. Manual memory management requires explicit allocation and deallocation");
    writeln("3. Pointer-based implementations offer more direct memory control");
    writeln("4. Proper memory cleanup is essential to prevent memory leaks");
    writeln("5. Pointer-based data structures can be more efficient than reference-based ones");
}

/**
 * Node structure for the linked list
 * Using a struct instead of a class for value semantics
 */
struct Node(T) {
    T value;        // The data stored in this node
    Node!T* next;   // Pointer to the next node
}

/**
 * Singly linked list implementation using pointers
 */
class LinkedList(T) {
private:
    Node!T* head;   // Pointer to the first node
    Node!T* tail;   // Pointer to the last node
    size_t count;   // Number of elements in the list
    
    /**
     * Helper function to create a new node with manual memory allocation
     */
    Node!T* createNode(T value) {
        // Allocate memory for a new node
        Node!T* newNode = cast(Node!T*)malloc(Node!T.sizeof);
        if (newNode is null) {
            throw new Exception("Memory allocation failed");
        }
        
        // Initialize the node
        newNode.value = value;
        newNode.next = null;
        
        return newNode;
    }
    
    /**
     * Helper function to delete a node and free its memory
     */
    void deleteNode(Node!T* node) {
        if (node !is null) {
            free(cast(void*)node);
        }
    }
    
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
     * Destructor - clean up all allocated memory
     */
    ~this() {
        clear();
    }
    
    /**
     * Add an element to the beginning of the list
     */
    void addFirst(T value) {
        Node!T* newNode = createNode(value);
        
        if (isEmpty()) {
            head = newNode;
            tail = newNode;
        } else {
            newNode.next = head;
            head = newNode;
        }
        
        count++;
    }
    
    /**
     * Add an element to the end of the list
     */
    void addLast(T value) {
        Node!T* newNode = createNode(value);
        
        if (isEmpty()) {
            head = newNode;
            tail = newNode;
        } else {
            tail.next = newNode;
            tail = newNode;
        }
        
        count++;
    }
    
    /**
     * Remove and return the first element
     */
    T removeFirst() {
        if (isEmpty()) {
            throw new Exception("Cannot remove from an empty list");
        }
        
        T value = head.value;
        Node!T* oldHead = head;
        
        if (head == tail) {
            // Only one element in the list
            head = null;
            tail = null;
        } else {
            head = head.next;
        }
        
        // Free the memory of the removed node
        deleteNode(oldHead);
        
        count--;
        return value;
    }
    
    /**
     * Remove and return the last element
     */
    T removeLast() {
        if (isEmpty()) {
            throw new Exception("Cannot remove from an empty list");
        }
        
        T value = tail.value;
        
        if (head == tail) {
            // Only one element in the list
            deleteNode(head);
            head = null;
            tail = null;
        } else {
            // Find the node before tail
            Node!T* current = head;
            while (current.next != tail) {
                current = current.next;
            }
            
            // Free the memory of the tail node
            deleteNode(tail);
            
            // Update tail
            current.next = null;
            tail = current;
        }
        
        count--;
        return value;
    }
    
    /**
     * Remove the first occurrence of a value
     */
    bool remove(T value) {
        if (isEmpty()) {
            return false;
        }
        
        // Special case: removing the head
        if (head.value == value) {
            removeFirst();
            return true;
        }
        
        // Find the node before the one to remove
        Node!T* current = head;
        while (current.next !is null && current.next.value != value) {
            current = current.next;
        }
        
        // If we found the value
        if (current.next !is null) {
            Node!T* nodeToRemove = current.next;
            
            // Special case: removing the tail
            if (nodeToRemove == tail) {
                tail = current;
            }
            
            // Update the link
            current.next = nodeToRemove.next;
            
            // Free the memory of the removed node
            deleteNode(nodeToRemove);
            
            count--;
            return true;
        }
        
        return false;
    }
    
    /**
     * Get the first element
     */
    T getFirst() {
        if (isEmpty()) {
            throw new Exception("List is empty");
        }
        return head.value;
    }
    
    /**
     * Get the last element
     */
    T getLast() {
        if (isEmpty()) {
            throw new Exception("List is empty");
        }
        return tail.value;
    }
    
    /**
     * Get element at a specific index
     */
    T get(size_t index) {
        if (index >= count) {
            throw new Exception("Index out of bounds");
        }
        
        Node!T* current = head;
        for (size_t i = 0; i < index; i++) {
            current = current.next;
        }
        
        return current.value;
    }
    
    /**
     * Check if the list contains a value
     */
    bool contains(T value) {
        return indexOf(value) != -1;
    }
    
    /**
     * Find the index of a value
     */
    int indexOf(T value) {
        Node!T* current = head;
        int index = 0;
        
        while (current !is null) {
            if (current.value == value) {
                return index;
            }
            current = current.next;
            index++;
        }
        
        return -1;  // Not found
    }
    
    /**
     * Clear the list and free all allocated memory
     */
    void clear() {
        // Free all nodes
        Node!T* current = head;
        while (current !is null) {
            Node!T* next = current.next;
            deleteNode(current);
            current = next;
        }
        
        head = null;
        tail = null;
        count = 0;
    }
    
    /**
     * Check if the list is empty
     */
    bool isEmpty() {
        return head is null;
    }
    
    /**
     * Get the number of elements in the list
     */
    size_t size() {
        return count;
    }
    
    /**
     * Print the list contents
     */
    void printList() {
        if (isEmpty()) {
            writeln("Empty list");
            return;
        }
        
        Node!T* current = head;
        while (current !is null) {
            write(current.value);
            if (current.next !is null) {
                write(" -> ");
            }
            current = current.next;
        }
        writeln();
    }
}
