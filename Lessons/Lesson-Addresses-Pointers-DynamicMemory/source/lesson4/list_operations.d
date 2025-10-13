/**
 * Lesson 4: Dynamic Data Structures
 * Example: List Operations
 *
 * This example demonstrates common operations on linked lists.
 */
module lesson4.list_operations;

import std.stdio;
import std.format;

void runExample() {
    writeln("=== List Operations Example ===\n");
    
    // Create a linked list for our examples
    LinkedList!int list = createSampleList();
    write("Initial list: ");
    list.printList();
    
    // 1. Traversing a linked list
    writeln("\n1. Traversing a Linked List:");
    
    writeln("  Forward traversal:");
    traverseForward(list.head);
    
    writeln("  Recursive traversal:");
    traverseRecursive(list.head);
    
    // 2. Finding the middle element
    writeln("\n2. Finding the Middle Element:");
    
    int middle = findMiddle(list);
    writefln("  Middle element: %d", middle);
    
    // 3. Detecting a cycle
    writeln("\n3. Detecting a Cycle in a List:");
    
    writefln("  Has cycle: %s", hasCycle(list.head) ? "yes" : "no");
    
    // Create a list with a cycle for demonstration
    LinkedList!int cyclicList = createCyclicList();
    writeln("  Created a list with a cycle");
    writefln("  Has cycle: %s", hasCycle(cyclicList.head) ? "yes" : "no");
    
    // 4. Reversing a linked list
    writeln("\n4. Reversing a Linked List:");
    
    write("  Original list: ");
    list.printList();
    
    list.reverse();
    
    write("  Reversed list: ");
    list.printList();
    
    // 5. Merging two sorted lists
    writeln("\n5. Merging Two Sorted Lists:");
    
    LinkedList!int list1 = new LinkedList!int();
    list1.addLast(1);
    list1.addLast(3);
    list1.addLast(5);
    
    LinkedList!int list2 = new LinkedList!int();
    list2.addLast(2);
    list2.addLast(4);
    list2.addLast(6);
    
    write("  List 1: ");
    list1.printList();
    write("  List 2: ");
    list2.printList();
    
    LinkedList!int mergedList = mergeSortedLists(list1, list2);
    
    write("  Merged list: ");
    mergedList.printList();
    
    // 6. Removing duplicates
    writeln("\n6. Removing Duplicates:");
    
    LinkedList!int duplicatesList = new LinkedList!int();
    duplicatesList.addLast(1);
    duplicatesList.addLast(2);
    duplicatesList.addLast(2);
    duplicatesList.addLast(3);
    duplicatesList.addLast(3);
    duplicatesList.addLast(3);
    duplicatesList.addLast(4);
    
    write("  List with duplicates: ");
    duplicatesList.printList();
    
    removeDuplicates(duplicatesList);
    
    write("  After removing duplicates: ");
    duplicatesList.printList();
    
    writeln("\nKey takeaways:");
    writeln("1. List operations often involve traversing the list");
    writeln("2. Many algorithms use the two-pointer technique (fast/slow pointers)");
    writeln("3. Recursive operations can simplify some list manipulations");
    writeln("4. Detecting cycles is important for preventing infinite loops");
    writeln("5. List operations are fundamental to many complex algorithms");
}

/**
 * Node class for the linked list
 */
class Node(T) {
    T value;       // The data stored in this node
    Node!T next;   // Reference to the next node
    
    this(T value) {
        this.value = value;
        this.next = null;
    }
}

/**
 * Singly linked list implementation
 */
class LinkedList(T) {
    Node!T head;   // Reference to the first node
    Node!T tail;   // Reference to the last node
    size_t count;  // Number of elements in the list
    
    /**
     * Constructor
     */
    this() {
        head = null;
        tail = null;
        count = 0;
    }
    
    /**
     * Add an element to the end of the list
     */
    void addLast(T value) {
        Node!T newNode = new Node!T(value);
        
        if (head is null) {
            head = newNode;
            tail = newNode;
        } else {
            tail.next = newNode;
            tail = newNode;
        }
        
        count++;
    }
    
    /**
     * Print the list contents
     */
    void printList() {
        if (head is null) {
            writeln("Empty list");
            return;
        }
        
        Node!T current = head;
        while (current !is null) {
            write(current.value);
            if (current.next !is null) {
                write(" -> ");
            }
            current = current.next;
        }
        writeln();
    }
    
    /**
     * Reverse the linked list
     */
    void reverse() {
        if (head is null || head.next is null) {
            return;  // Empty list or single element
        }
        
        Node!T prev = null;
        Node!T current = head;
        Node!T next = null;
        
        // Update tail to point to the current head
        tail = head;
        
        while (current !is null) {
            next = current.next;    // Store next node
            current.next = prev;    // Reverse the link
            prev = current;         // Move prev forward
            current = next;         // Move current forward
        }
        
        // Update head to point to the new front (old tail)
        head = prev;
    }
}

/**
 * Create a sample linked list for demonstrations
 */
LinkedList!int createSampleList() {
    LinkedList!int list = new LinkedList!int();
    list.addLast(10);
    list.addLast(20);
    list.addLast(30);
    list.addLast(40);
    list.addLast(50);
    return list;
}

/**
 * Create a linked list with a cycle for demonstration
 */
LinkedList!int createCyclicList() {
    LinkedList!int list = new LinkedList!int();
    list.addLast(1);
    list.addLast(2);
    list.addLast(3);
    list.addLast(4);
    
    // Create a cycle: last node points to the second node
    Node!int lastNode = list.tail;
    Node!int secondNode = list.head.next;
    lastNode.next = secondNode;
    
    return list;
}

/**
 * Traverse a linked list iteratively
 */
void traverseForward(Node!int head) {
    write("    ");
    Node!int current = head;
    while (current !is null) {
        write(current.value);
        if (current.next !is null) {
            write(" -> ");
        }
        current = current.next;
    }
    writeln();
}

/**
 * Traverse a linked list recursively
 */
void traverseRecursive(Node!int node, bool isFirst = true) {
    if (isFirst) {
        write("    ");
    }
    
    if (node is null) {
        writeln();
        return;
    }
    
    write(node.value);
    if (node.next !is null) {
        write(" -> ");
    }
    
    traverseRecursive(node.next, false);
}

/**
 * Find the middle element of a linked list using the slow/fast pointer technique
 */
int findMiddle(LinkedList!int list) {
    if (list.head is null) {
        throw new Exception("List is empty");
    }
    
    Node!int slow = list.head;
    Node!int fast = list.head;
    
    // Fast pointer moves twice as fast as slow pointer
    // When fast reaches the end, slow will be at the middle
    while (fast !is null && fast.next !is null) {
        slow = slow.next;
        fast = fast.next.next;
    }
    
    return slow.value;
}

/**
 * Detect if a linked list has a cycle using Floyd's Cycle-Finding Algorithm
 */
bool hasCycle(Node!int head) {
    if (head is null || head.next is null) {
        return false;
    }
    
    Node!int slow = head;
    Node!int fast = head;
    
    while (fast !is null && fast.next !is null) {
        slow = slow.next;          // Move one step
        fast = fast.next.next;     // Move two steps
        
        // If slow and fast pointers meet, there's a cycle
        if (slow == fast) {
            return true;
        }
    }
    
    return false;  // Reached the end, no cycle
}

/**
 * Merge two sorted linked lists into a new sorted list
 */
LinkedList!int mergeSortedLists(LinkedList!int list1, LinkedList!int list2) {
    LinkedList!int result = new LinkedList!int();
    
    Node!int current1 = list1.head;
    Node!int current2 = list2.head;
    
    // Compare elements from both lists and add the smaller one to the result
    while (current1 !is null && current2 !is null) {
        if (current1.value <= current2.value) {
            result.addLast(current1.value);
            current1 = current1.next;
        } else {
            result.addLast(current2.value);
            current2 = current2.next;
        }
    }
    
    // Add any remaining elements from list1
    while (current1 !is null) {
        result.addLast(current1.value);
        current1 = current1.next;
    }
    
    // Add any remaining elements from list2
    while (current2 !is null) {
        result.addLast(current2.value);
        current2 = current2.next;
    }
    
    return result;
}

/**
 * Remove duplicate elements from a sorted linked list
 */
void removeDuplicates(LinkedList!int list) {
    if (list.head is null || list.head.next is null) {
        return;  // Empty list or single element
    }
    
    Node!int current = list.head;
    
    while (current !is null && current.next !is null) {
        if (current.value == current.next.value) {
            // Duplicate found, skip the next node
            current.next = current.next.next;
            list.count--;
            
            // Update tail if necessary
            if (current.next is null) {
                list.tail = current;
            }
        } else {
            // Move to the next node
            current = current.next;
        }
    }
}
