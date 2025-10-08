/**
 * Lesson 4: Dynamic Data Structures
 * Example: Stack Implementation Using Pointers
 *
 * This example demonstrates how to implement a stack using pointers.
 */
module lesson4.stack_implementation;

import std.stdio;
import std.format;
import std.exception;

void runExample() {
    writeln("=== Stack Implementation Using Pointers Example ===\n");
    
    // 1. Create a stack
    writeln("1. Creating a Stack:");
    
    Stack!int stack = new Stack!int();
    writefln("  Created an empty stack");
    writefln("  Is empty: %s", stack.isEmpty() ? "yes" : "no");
    writefln("  Size: %d", stack.size());
    
    // 2. Push elements onto the stack
    writeln("\n2. Pushing Elements:");
    
    stack.push(10);
    stack.push(20);
    stack.push(30);
    stack.push(40);
    stack.push(50);
    
    writefln("  Pushed 5 elements onto the stack");
    writefln("  Stack size: %d", stack.size());
    writefln("  Top element: %d", stack.peek());
    
    // 3. Pop elements from the stack
    writeln("\n3. Popping Elements:");
    
    int popped = stack.pop();
    writefln("  Popped: %d", popped);
    writefln("  New top element: %d", stack.peek());
    writefln("  Stack size: %d", stack.size());
    
    popped = stack.pop();
    writefln("  Popped: %d", popped);
    writefln("  New top element: %d", stack.peek());
    writefln("  Stack size: %d", stack.size());
    
    // 4. Check for stack underflow
    writeln("\n4. Stack Underflow Check:");
    
    try {
        // Pop until empty
        while (!stack.isEmpty()) {
            writefln("  Popped: %d", stack.pop());
        }
        
        writefln("  Stack is now empty");
        
        // Try to pop from an empty stack
        writeln("  Attempting to pop from empty stack...");
        stack.pop();
    } catch (Exception e) {
        writefln("  Caught exception: %s", e.msg);
    }
    
    // 5. Stack with different data types
    writeln("\n5. Stack with Different Data Types:");
    
    // String stack
    Stack!string stringStack = new Stack!string();
    stringStack.push("Hello");
    stringStack.push("World");
    stringStack.push("Stack");
    
    writefln("  String stack size: %d", stringStack.size());
    writefln("  Top element: %s", stringStack.peek());
    
    // Pop all elements
    writeln("  Popping all elements:");
    while (!stringStack.isEmpty()) {
        writefln("    Popped: %s", stringStack.pop());
    }
    
    // 6. Stack applications
    writeln("\n6. Stack Applications:");
    
    // Check balanced parentheses
    string balanced = "((2+3)*(4+5))";
    string unbalanced = "((2+3)*(4+5)";
    
    writefln("  Expression '%s' is %s", 
             balanced, 
             checkBalancedParentheses(balanced) ? "balanced" : "unbalanced");
    
    writefln("  Expression '%s' is %s", 
             unbalanced, 
             checkBalancedParentheses(unbalanced) ? "balanced" : "unbalanced");
    
    // Reverse a string using a stack
    string original = "Hello, Stack!";
    string reversed = reverseString(original);
    
    writefln("  Original string: '%s'", original);
    writefln("  Reversed string: '%s'", reversed);
    
    writeln("\nStack Implementation:");
    writeln("  class Stack(T) {");
    writeln("      private Node!T top;");
    writeln("      private size_t count;");
    writeln("      ");
    writeln("      void push(T value) {");
    writeln("          Node!T newNode = new Node!T(value);");
    writeln("          newNode.next = top;");
    writeln("          top = newNode;");
    writeln("          count++;");
    writeln("      }");
    writeln("      ");
    writeln("      T pop() {");
    writeln("          if (isEmpty()) throw new Exception(\"Stack is empty\");");
    writeln("          T value = top.value;");
    writeln("          top = top.next;");
    writeln("          count--;");
    writeln("          return value;");
    writeln("      }");
    writeln("      // etc...");
    writeln("  }");
    
    writeln("\nKey takeaways:");
    writeln("1. A stack is a LIFO (Last In, First Out) data structure");
    writeln("2. Stacks can be efficiently implemented using linked lists");
    writeln("3. Key operations are push (add), pop (remove), and peek (view top)");
    writeln("4. Stacks are useful for parsing expressions, function calls, and more");
    writeln("5. Stack operations have O(1) time complexity");
}

/**
 * Node class for the stack
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
 * Stack implementation using a linked list
 */
class Stack(T) {
private:
    Node!T top;    // Reference to the top node
    size_t count;  // Number of elements in the stack
    
public:
    /**
     * Constructor
     */
    this() {
        top = null;
        count = 0;
    }
    
    /**
     * Push an element onto the stack
     */
    void push(T value) {
        Node!T newNode = new Node!T(value);
        
        // Link the new node to the current top
        newNode.next = top;
        
        // Update the top to be the new node
        top = newNode;
        
        count++;
    }
    
    /**
     * Pop an element from the stack
     */
    T pop() {
        if (isEmpty()) {
            throw new Exception("Stack underflow: Cannot pop from an empty stack");
        }
        
        // Get the value from the top node
        T value = top.value;
        
        // Update the top to be the next node
        top = top.next;
        
        count--;
        return value;
    }
    
    /**
     * Peek at the top element without removing it
     */
    T peek() {
        if (isEmpty()) {
            throw new Exception("Stack is empty: Cannot peek");
        }
        
        return top.value;
    }
    
    /**
     * Check if the stack is empty
     */
    bool isEmpty() {
        return top is null;
    }
    
    /**
     * Get the number of elements in the stack
     */
    size_t size() {
        return count;
    }
    
    /**
     * Clear the stack
     */
    void clear() {
        top = null;
        count = 0;
    }
}

/**
 * Check if parentheses in an expression are balanced
 */
bool checkBalancedParentheses(string expression) {
    Stack!char stack = new Stack!char();
    
    foreach (char c; expression) {
        if (c == '(') {
            stack.push(c);
        } else if (c == ')') {
            if (stack.isEmpty()) {
                return false;  // Closing parenthesis without matching opening
            }
            stack.pop();
        }
    }
    
    return stack.isEmpty();  // Stack should be empty if all parentheses matched
}

/**
 * Reverse a string using a stack
 */
string reverseString(string input) {
    Stack!char stack = new Stack!char();
    
    // Push all characters onto the stack
    foreach (char c; input) {
        stack.push(c);
    }
    
    // Pop characters to form the reversed string
    char[] result = new char[input.length];
    for (size_t i = 0; i < input.length; i++) {
        result[i] = stack.pop();
    }
    
    return cast(string)result;
}
