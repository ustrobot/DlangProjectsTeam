# Assignment 4.2: Simple Tree Explorer

## Objective

Build a simple family tree to understand hierarchical data structures. This assignment will help you understand how computers can represent relationships between data in a tree-like structure.

## Introduction

Family trees are a perfect example of a hierarchical structure - parents have children, who may become parents themselves. In programming, tree structures work similarly and are used to represent all kinds of hierarchical data. In this assignment, you'll create a family tree program!

## Requirements

### 1. Create a `Person` class

Create a D program with a `Person` class that:
- Stores a name and age
- Has references to parents and children

```d
// Example starter code
import std.stdio;
import std.string;
import std.array;

class Person {
    string name;
    int age;
    Person mother;
    Person father;
    Person[] children;
    
    // Constructor
    this(string name, int age) {
        this.name = name;
        this.age = age;
        this.children = [];
    }
    
    // Add a child to this person
    void addChild(Person child) {
        children ~= child;
    }
    
    // Set this person's parents
    void setParents(Person mother, Person father) {
        this.mother = mother;
        this.father = father;
        
        // Add this person as a child to both parents
        if (mother !is null) {
            mother.addChild(this);
        }
        
        if (father !is null) {
            father.addChild(this);
        }
    }
    
    // TODO: Implement method to find all ancestors
    Person[] findAncestors() {
        // Your code here
    }
    
    // TODO: Implement method to find all descendants
    Person[] findDescendants() {
        // Your code here
    }
    
    // TODO: Implement method to calculate family size
    int calculateFamilySize() {
        // Your code here
    }
    
    // TODO: Implement method to find relationship with another person
    string findRelationship(Person other) {
        // Your code here
    }
}
```

### 2. Build a family tree

Create a family tree with:
- Multiple generations
- Multiple children per parent

```d
// Example family tree creation
void createFamilyTree() {
    // Grandparents generation
    auto grandfather1 = new Person("Grandpa Joe", 75);
    auto grandmother1 = new Person("Grandma Emma", 72);
    auto grandfather2 = new Person("Grandpa Mike", 78);
    auto grandmother2 = new Person("Grandma Susan", 76);
    
    // Parents generation
    auto father = new Person("Dad John", 45);
    father.setParents(grandmother1, grandfather1);
    
    auto mother = new Person("Mom Lisa", 42);
    mother.setParents(grandmother2, grandfather2);
    
    // Children generation
    auto child1 = new Person("Alex", 15);
    child1.setParents(mother, father);
    
    auto child2 = new Person("Emma", 12);
    child2.setParents(mother, father);
    
    auto child3 = new Person("Max", 8);
    child3.setParents(mother, father);
    
    // TODO: Add more family members to make the tree more interesting
}
```

### 3. Implement tree operations

Add methods to your program that:
- Find ancestors and descendants of a person
- Calculate family size
- Find relationships between people

### 4. Create a text-based visualization of the tree

Create a simple ASCII art visualization that shows the family tree:

```
                  Grandpa Joe (75) --- Grandma Emma (72)   Grandpa Mike (78) --- Grandma Susan (76)
                          |                                           |
                          |                                           |
                          |                                           |
                  Dad John (45) ----------------------------- Mom Lisa (42)
                          |
                          |
          ---------------------------------
          |               |               |
     Alex (15)       Emma (12)        Max (8)
```

## Step-by-Step Guide

1. **Create the Person class**
   - Define a class that stores name, age, parents, and children
   - Implement methods to add children and set parents
   - Make sure parent-child relationships are consistent

2. **Build a family tree**
   - Create multiple generations of family members
   - Establish parent-child relationships
   - Make sure the tree has multiple branches

3. **Implement tree operations**
   - Write a method to find all ancestors of a person
   - Write a method to find all descendants of a person
   - Write a method to calculate the total size of a family
   - Write a method to determine the relationship between two people

4. **Create a tree visualization**
   - Implement a function to display the family tree
   - Use ASCII characters to show relationships
   - Format the output to make the tree structure clear

## Example Output

Your program should produce output similar to this:

```
=== Family Tree Explorer ===

Created family tree with 8 members.

Family Tree Visualization:
                  Grandpa Joe (75) --- Grandma Emma (72)   Grandpa Mike (78) --- Grandma Susan (76)
                          |                                           |
                          |                                           |
                          |                                           |
                  Dad John (45) ----------------------------- Mom Lisa (42)
                          |
                          |
          ---------------------------------
          |               |               |
     Alex (15)       Emma (12)        Max (8)

Tree Operations:

Ancestors of Emma (12):
- Mom Lisa (42)
- Dad John (45)
- Grandma Susan (76)
- Grandpa Mike (78)
- Grandma Emma (72)
- Grandpa Joe (75)

Descendants of Dad John (45):
- Alex (15)
- Emma (12)
- Max (8)

Family size of Grandma Emma (72): 7 members

Relationship finder:
- Grandpa Joe is Emma's grandfather
- Alex and Max are siblings
- Grandma Susan is Alex's grandmother
- Dad John and Mom Lisa are spouses
```

## Learning Outcomes

After completing this assignment, you will understand:
- How tree structures represent hierarchical relationships
- How to navigate up and down a tree structure
- How to calculate properties of tree structures
- How to visualize tree relationships

## Extension Activities

If you finish early, try these additional challenges:

1. Add more types of relationships (cousins, aunts, uncles, etc.)
2. Implement a function to find the most recent common ancestor of two people
3. Add birth years and create a timeline of the family history
4. Create an interactive family tree explorer where users can navigate the tree

## Submission Guidelines

Submit your D source code file with:
- Well-commented code explaining what each part does
- A complete family tree with multiple generations
- All required tree operations implemented
- A clear visualization of the family tree

## Memory Management Tips

When working with tree structures in D:

**Node Allocation:**
- **Class-based trees**: Use `new Person(name, age)` - GC-managed heap allocation
- **Struct-based trees**: Use `malloc(Person.sizeof)` for manual allocation
- **Recursive structures**: Be careful with deep recursion to avoid stack overflow

**Tree Traversal Memory:**
- **Depth-first**: Uses stack space proportional to tree depth
- **Breadth-first**: Uses queue space proportional to tree width
- **Recursive traversal**: Each recursive call adds a stack frame

**Memory Cleanup:**
- **Automatic**: GC handles class-based trees when no references exist
- **Manual**: Must explicitly free all nodes in struct-based trees
- **Circular references**: Can prevent GC cleanup in complex tree structures

**Performance Considerations:**
- Trees with many nodes benefit from efficient allocation patterns
- Consider using object pools for frequently created/destroyed tree nodes
- Profile memory usage to identify allocation hotspots

## Grading Criteria

- **Correctness**: Does your code correctly implement all required operations?
- **Understanding**: Do you demonstrate understanding of tree structures?
- **Visualization**: Is your tree visualization clear and helpful?
- **Code Quality**: Is your code well-organized and properly commented?
