# Assignment 4.4: Friendship Network

## Objective

Create a simple social network model to understand graph structures. This assignment will help you understand how computers represent connections between people or things using graph data structures.

## Introduction

Social networks like Facebook, Instagram, or TikTok use graph structures to keep track of who is friends with whom. In this assignment, you'll create your own simple friendship network to understand how these connections work in computer programs.

## Requirements

### 1. Create a `Person` class

Create a D program with a `Person` class that:
- Stores a name and interests
- Maintains a list of friends

```d
// Example starter code
import std.stdio;
import std.string;
import std.array;
import std.algorithm;

class Person {
    string name;
    string[] interests;
    Person[] friends;
    
    // Constructor
    this(string name, string[] interests) {
        this.name = name;
        this.interests = interests;
        this.friends = [];
    }
    
    // Add a friend (and make sure the friendship is bidirectional)
    void addFriend(Person other) {
        // Check if already friends
        if (!isFriendsWith(other) && other !is this) {
            // Add other as friend to this person
            friends ~= other;
            
            // Add this person as friend to other person
            if (!other.isFriendsWith(this)) {
                other.addFriend(this);
            }
        }
    }
    
    // Remove a friend (and make sure the friendship is removed in both directions)
    void removeFriend(Person other) {
        // TODO: Implement friend removal
    }
    
    // Check if this person is friends with another person
    bool isFriendsWith(Person other) {
        return friends.canFind(other);
    }
    
    // Get a list of friends of friends (people who are not direct friends but are friends with friends)
    Person[] getFriendsOfFriends() {
        // TODO: Implement friends of friends
    }
    
    // Find common interests with another person
    string[] getCommonInterests(Person other) {
        // TODO: Implement common interests finder
    }
}

class FriendshipNetwork {
    Person[] people;
    
    // Constructor
    this() {
        people = [];
    }
    
    // Add a person to the network
    void addPerson(Person person) {
        if (!people.canFind(person)) {
            people ~= person;
        }
    }
    
    // Find friend groups (connected components in the graph)
    Person[][] findFriendGroups() {
        // TODO: Implement friend group finder
    }
    
    // Visualize the network
    void visualizeNetwork() {
        // TODO: Implement network visualization
    }
}
```

### 2. Build a friendship network

Create a network where:
- People can be friends with multiple others
- Friendships are bidirectional (if A is friends with B, then B is friends with A)

```d
// Example network creation
void createFriendshipNetwork() {
    // Create some people with their interests
    auto alice = new Person("Alice", ["reading", "music", "hiking"]);
    auto bob = new Person("Bob", ["gaming", "music", "movies"]);
    auto charlie = new Person("Charlie", ["sports", "cooking", "music"]);
    auto diana = new Person("Diana", ["art", "hiking", "travel"]);
    auto evan = new Person("Evan", ["gaming", "technology", "movies"]);
    auto fiona = new Person("Fiona", ["reading", "art", "travel"]);
    
    // Create a network
    auto network = new FriendshipNetwork();
    
    // Add people to the network
    network.addPerson(alice);
    network.addPerson(bob);
    network.addPerson(charlie);
    network.addPerson(diana);
    network.addPerson(evan);
    network.addPerson(fiona);
    
    // Create friendships
    alice.addFriend(bob);
    alice.addFriend(diana);
    bob.addFriend(charlie);
    charlie.addFriend(diana);
    evan.addFriend(fiona);
    
    // TODO: Add more people and friendships
}
```

### 3. Implement network operations

Add methods to your program that:
- Add and remove friendships
- Find friends of friends
- Identify groups of friends

### 4. Create a text-based visualization of the network

Create a simple ASCII art visualization that shows the friendship connections:

```
Friendship Network:

Alice ------ Bob
  |          |
  |          |
Diana ----- Charlie

Evan ------ Fiona
```

## Step-by-Step Guide

1. **Create the Person class**
   - Define a class that stores name, interests, and friends
   - Implement methods to add and remove friends
   - Make sure friendships are bidirectional

2. **Build the friendship network**
   - Create multiple people with different interests
   - Establish friendships between them
   - Make sure the network has multiple friend groups

3. **Implement network operations**
   - Write a method to find friends of friends
   - Write a method to find common interests between people
   - Write a method to identify separate friend groups

4. **Create a network visualization**
   - Implement a function to display the friendship network
   - Use ASCII characters to show connections
   - Format the output to make the network structure clear

## Example Output

Your program should produce output similar to this:

```
=== Friendship Network Explorer ===

Created network with 6 people.

Friendship Network Visualization:

Alice ------ Bob
  |          |
  |          |
Diana ----- Charlie

Evan ------ Fiona

Network Operations:

Friends of Alice:
- Bob
- Diana

Friends of friends for Alice:
- Charlie

Common interests between Alice and Bob:
- music

Friend Groups:
Group 1: Alice, Bob, Charlie, Diana
Group 2: Evan, Fiona

Adding friendship between Diana and Fiona...
Updated Friendship Network:

Alice ------ Bob
  |          |
  |          |
Diana ----- Charlie
  |
  |
Evan ------ Fiona

Now there is only one friend group!
```

## Learning Outcomes

After completing this assignment, you will understand:
- How graph structures represent connections between entities
- How to navigate through connected data
- How to identify groups in a network
- How to visualize network connections

## Extension Activities

If you finish early, try these additional challenges:

1. Add a "friendship strength" value based on the number of common interests
2. Implement a "friend recommendation" feature that suggests potential new friends
3. Add the ability to find the shortest path between two people in the network
4. Create a more sophisticated visualization with different symbols for people and connections

## Submission Guidelines

Submit your D source code file with:
- Well-commented code explaining what each part does
- A complete friendship network with multiple people
- All required network operations implemented
- A clear visualization of the friendship network

## Memory Management Tips

When working with social network graphs in D:

**Graph Node Allocation:**
- **Class-based**: `new Person(name, interests)` - GC-managed heap allocation
- **Struct-based**: `malloc(Person.sizeof)` for manual memory management
- **Arrays of references**: `Person[] people` creates array of references, not objects

**Graph Edge Management:**
- **Adjacency lists**: Use arrays or linked lists to store connections
- **Bidirectional edges**: Ensure both directions are maintained consistently
- **Edge removal**: Must remove edges from both nodes in undirected graphs

**Memory Patterns in Graphs:**
- **Sparse graphs**: Most nodes have few connections - use efficient storage
- **Dense graphs**: Many connections - may benefit from matrix representation
- **Dynamic graphs**: Nodes and edges added/removed frequently need efficient algorithms

**Garbage Collection Impact:**
- Graph algorithms may create many temporary objects
- Consider using `@nogc` for performance-critical graph operations
- Monitor GC pressure with `GC.stats()` during graph operations

## Grading Criteria

- **Correctness**: Does your code correctly implement all required operations?
- **Understanding**: Do you demonstrate understanding of graph structures?
- **Visualization**: Is your network visualization clear and helpful?
- **Code Quality**: Is your code well-organized and properly commented?
