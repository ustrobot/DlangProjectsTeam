# Assignment 4.1: Linked Chain

## Objective

Implement a simple linked chain to understand pointer-based data structures. This assignment will help you understand how computers can connect pieces of data together using pointers.

## Introduction

Imagine a treasure hunt where each clue tells you where to find the next clue. That's similar to how a linked chain works in programming - each piece of data points to the next piece. This is different from arrays, where all the data is stored in one continuous block. In this assignment, you'll create your own linked chain!

## Requirements

### 1. Create a `Link` class

Create a D program with a `Link` class that:
- Stores a value (name, number, etc.)
- Points to the next link in the chain

```d
// Example starter code
import std.stdio;
import std.string;

class Link {
    string value;  // The data stored in this link
    Link next;     // Reference to the next link in the chain
    
    // Constructor
    this(string value) {
        this.value = value;
        this.next = null;
    }
}

class LinkedChain {
    Link first;  // First link in the chain
    Link last;   // Last link in the chain
    int length;  // Number of links in the chain
    
    // Constructor
    this() {
        first = null;
        last = null;
        length = 0;
    }
    
    // TODO: Implement method to add a link to the end
    void addLink(string value) {
        // Your code here
    }
    
    // TODO: Implement method to remove a link
    bool removeLink(string value) {
        // Your code here
    }
    
    // TODO: Implement method to find a link by value
    Link findLink(string value) {
        // Your code here
    }
    
    // TODO: Implement method to print the entire chain
    void printChain() {
        // Your code here
    }
}
```

### 2. Implement basic operations

Add methods to your `LinkedChain` class that:
- Add a link to the end of the chain
- Remove a link from the chain
- Find a link by its value
- Print the entire chain

### 3. Create a visual representation of the chain

Create a simple ASCII art visualization that shows the links in the chain:

```
[First] --> [Second] --> [Third] --> [Fourth] --> [End]
```

## Step-by-Step Guide

1. **Create the Link class**
   - Define a class that stores a value
   - Add a reference to the next link in the chain
   - Implement a constructor to initialize the link

2. **Create the LinkedChain class**
   - Keep track of the first and last links in the chain
   - Track the length of the chain
   - Implement methods to add, remove, find, and print links

3. **Implement the addLink method**
   - Handle the case when the chain is empty
   - Add the new link to the end of the chain
   - Update the last reference and length

4. **Implement the removeLink method**
   - Handle the case when the link to remove is the first one
   - Handle the case when the link is in the middle or end
   - Update the chain connections and length

5. **Implement the findLink method**
   - Traverse the chain from the beginning
   - Return the link if found, or null if not found

6. **Implement the printChain method**
   - Traverse the chain and print each link's value
   - Add visual elements to show the connections

## Example Output

Your program should produce output similar to this:

```
=== Linked Chain Demo ===

Adding links to the chain:
Added "Apple" to the chain
Added "Banana" to the chain
Added "Cherry" to the chain
Added "Date" to the chain

Current chain:
[Apple] --> [Banana] --> [Cherry] --> [Date] --> [End]
Chain length: 4

Finding links:
Found "Cherry" at position 3
"Grape" not found in the chain

Removing links:
Removed "Banana" from the chain

Updated chain:
[Apple] --> [Cherry] --> [Date] --> [End]
Chain length: 3

Adding more links:
Added "Elderberry" to the chain
Added "Fig" to the chain

Final chain:
[Apple] --> [Cherry] --> [Date] --> [Elderberry] --> [Fig] --> [End]
Chain length: 5
```

## Learning Outcomes

After completing this assignment, you will understand:
- How linked structures work in programming
- How pointers connect data elements together
- Basic operations on linked chains
- Differences between arrays and linked structures

## Extension Activities

If you finish early, try these additional challenges:

1. Add a method to insert a link at a specific position in the chain
2. Add a method to reverse the chain
3. Implement a doubly-linked chain where each link points to both the next and previous links
4. Create a circular chain where the last link points back to the first

## Submission Guidelines

Submit your D source code file with:
- Well-commented code explaining what each part does
- All required operations implemented
- A clear visualization of the chain

## Grading Criteria

- **Correctness**: Does your code correctly implement all required operations?
- **Understanding**: Do you demonstrate understanding of linked structures?
- **Visualization**: Is your chain visualization clear and helpful?
- **Code Quality**: Is your code well-organized and properly commented?
