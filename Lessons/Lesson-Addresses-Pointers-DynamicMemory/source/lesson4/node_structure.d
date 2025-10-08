/**
 * Lesson 4: Dynamic Data Structures
 * Example: Node Structure for Linked Lists
 *
 * This example demonstrates how to define a node structure for linked lists.
 */
module lesson4.node_structure;

import std.stdio;
import std.format;

void runExample() {
    writeln("=== Node Structure for Linked Lists Example ===\n");
    
    // 1. Define a basic Node structure
    writeln("1. Basic Node Structure:");
    
    // Create a single node
    Node!int node1 = new Node!int(10);
    writefln("  Created a node with value: %d", node1.value);
    writefln("  Node1 next pointer: %s", node1.next is null ? "null" : "points to another node");
    
    // Create another node
    Node!int node2 = new Node!int(20);
    writefln("  Created another node with value: %d", node2.value);
    
    // Link the nodes
    node1.next = node2;
    writefln("  Linked node1 to node2");
    writefln("  Node1 next pointer: %s", node1.next is null ? "null" : "points to another node");
    writefln("  Value in the next node: %d", node1.next.value);
    
    // 2. Create a small linked list manually
    writeln("\n2. Creating a Small Linked List Manually:");
    
    // Create nodes
    Node!int head = new Node!int(100);
    Node!int second = new Node!int(200);
    Node!int third = new Node!int(300);
    Node!int fourth = new Node!int(400);
    
    // Link nodes together
    head.next = second;
    second.next = third;
    third.next = fourth;
    
    // Print the list
    writeln("  Linked list contents:");
    printList(head);
    
    // 3. Different types of nodes
    writeln("\n3. Nodes with Different Data Types:");
    
    // String node
    Node!string strNode1 = new Node!string("Hello");
    Node!string strNode2 = new Node!string("World");
    strNode1.next = strNode2;
    
    writeln("  String linked list:");
    printList(strNode1);
    
    // Double node
    Node!double doubleNode1 = new Node!double(3.14);
    Node!double doubleNode2 = new Node!double(2.71);
    doubleNode1.next = doubleNode2;
    
    writeln("  Double linked list:");
    printList(doubleNode1);
    
    // 4. Node with additional data
    writeln("\n4. Enhanced Node Structure with Additional Data:");
    
    // Create a person node
    PersonNode person1 = new PersonNode("Alice", 30);
    PersonNode person2 = new PersonNode("Bob", 25);
    person1.next = person2;
    
    writeln("  Person linked list:");
    printPersonList(person1);
    
    // 5. Doubly-linked node
    writeln("\n5. Doubly-Linked Node Structure:");
    
    // Create doubly-linked nodes
    DoublyLinkedNode!int dNode1 = new DoublyLinkedNode!int(10);
    DoublyLinkedNode!int dNode2 = new DoublyLinkedNode!int(20);
    DoublyLinkedNode!int dNode3 = new DoublyLinkedNode!int(30);
    
    // Link nodes in both directions
    dNode1.next = dNode2;
    dNode2.prev = dNode1;
    dNode2.next = dNode3;
    dNode3.prev = dNode2;
    
    writeln("  Doubly-linked list (forward):");
    printDoublyLinkedList(dNode1, true);
    
    writeln("  Doubly-linked list (backward):");
    printDoublyLinkedList(dNode3, false);
    
    writeln("\nNode Structure Implementations:");
    writeln("  class Node(T) {");
    writeln("      T value;");
    writeln("      Node!T next;");
    writeln("      this(T value) {");
    writeln("          this.value = value;");
    writeln("          this.next = null;");
    writeln("      }");
    writeln("  }");
    
    writeln("\n  class DoublyLinkedNode(T) {");
    writeln("      T value;");
    writeln("      DoublyLinkedNode!T next;");
    writeln("      DoublyLinkedNode!T prev;");
    writeln("      this(T value) {");
    writeln("          this.value = value;");
    writeln("          this.next = null;");
    writeln("          this.prev = null;");
    writeln("      }");
    writeln("  }");
    
    writeln("\nKey takeaways:");
    writeln("1. A node contains data and a reference to the next node");
    writeln("2. Nodes are linked together to form a linked list");
    writeln("3. Nodes can store any data type using generics/templates");
    writeln("4. Doubly-linked nodes contain references to both next and previous nodes");
    writeln("5. Node structures are the foundation of many dynamic data structures");
}

/**
 * Basic node structure for a singly linked list
 */
class Node(T) {
    T value;           // The data stored in this node
    Node!T next;       // Reference to the next node
    
    this(T value) {
        this.value = value;
        this.next = null;
    }
}

/**
 * Node structure for a doubly linked list
 */
class DoublyLinkedNode(T) {
    T value;                     // The data stored in this node
    DoublyLinkedNode!T next;     // Reference to the next node
    DoublyLinkedNode!T prev;     // Reference to the previous node
    
    this(T value) {
        this.value = value;
        this.next = null;
        this.prev = null;
    }
}

/**
 * Enhanced node structure with specific data fields
 */
class PersonNode {
    string name;
    int age;
    PersonNode next;
    
    this(string name, int age) {
        this.name = name;
        this.age = age;
        this.next = null;
    }
}

/**
 * Print a singly linked list
 */
void printList(T)(Node!T head) {
    Node!T current = head;
    write("    ");
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
 * Print a list of person nodes
 */
void printPersonList(PersonNode head) {
    PersonNode current = head;
    write("    ");
    while (current !is null) {
        write(format("%s (%d years)", current.name, current.age));
        if (current.next !is null) {
            write(" -> ");
        }
        current = current.next;
    }
    writeln();
}

/**
 * Print a doubly linked list (forward or backward)
 */
void printDoublyLinkedList(T)(DoublyLinkedNode!T node, bool forward) {
    DoublyLinkedNode!T current = node;
    write("    ");
    while (current !is null) {
        write(current.value);
        if ((forward && current.next !is null) || (!forward && current.prev !is null)) {
            write(" <-> ");
        }
        current = forward ? current.next : current.prev;
    }
    writeln();
}
