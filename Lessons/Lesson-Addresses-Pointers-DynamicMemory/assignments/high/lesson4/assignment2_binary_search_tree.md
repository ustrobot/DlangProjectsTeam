# Assignment 4.2: Memory-Efficient Binary Search Tree

## Objective

Implement a memory-efficient Binary Search Tree with custom memory management. This assignment will help you understand hierarchical data structures, tree algorithms, and advanced memory management techniques.

## Requirements

### 1. Create a `BinarySearchTree(T)` class

Implement a template class that:
- Uses a custom node pool allocator for memory efficiency
- Implements standard BST operations
- Includes traversal methods

```d
class BinarySearchTree(T) {
    // Your implementation here
}
```

### 2. Core BST Operations

Implement the following methods:

- **Insert a value**
  ```d
  void insert(T value);
  ```

- **Remove a value**
  ```d
  bool remove(T value);
  ```

- **Find a value**
  ```d
  bool find(T value);
  ```

- **Get the minimum and maximum values**
  ```d
  T findMin();
  T findMax();
  ```

### 3. Tree Traversal Methods

Implement the standard tree traversal algorithms:

- **Inorder traversal**
  ```d
  void inorder(void delegate(T value) visit);
  ```

- **Preorder traversal**
  ```d
  void preorder(void delegate(T value) visit);
  ```

- **Postorder traversal**
  ```d
  void postorder(void delegate(T value) visit);
  ```

### 4. Tree Balancing

Implement a mechanism to prevent tree degeneration:
- Self-balancing algorithm (AVL, Red-Black, or similar)
- Rebalancing after insertions and deletions
- Height/balance factor tracking

### 5. Tree Visualization

Create a method to visualize the tree structure:
- Text-based representation of the tree
- Show node values and relationships
- Indicate tree height and balance factors

### 6. Memory Management

Implement custom memory management:
- Create a node pool allocator for tree nodes
- Track memory usage statistics
- Ensure proper cleanup to prevent leaks

## Starter Code

```d
module binarysearchtree;

import std.stdio;
import std.algorithm;
import std.string;
import std.conv;
import core.stdc.stdlib : malloc, free;

/**
 * Node pool allocator for tree nodes
 */
class NodePool(T) {
private:
    struct Block {
        void* memory;
        size_t capacity;
        Block* next;
    }
    
    struct FreeNode {
        FreeNode* next;
    }
    
    enum size_t BLOCK_SIZE = 1024;  // Nodes per block
    enum size_t NODE_SIZE = (TreeNode!T).sizeof > FreeNode.sizeof ? 
                            (TreeNode!T).sizeof : FreeNode.sizeof;
    
    Block* blocks;        // List of allocated blocks
    FreeNode* freeList;   // List of free nodes
    size_t totalNodes;    // Total number of nodes allocated
    size_t usedNodes;     // Number of nodes currently in use
    
public:
    /**
     * Constructor
     */
    this() {
        blocks = null;
        freeList = null;
        totalNodes = 0;
        usedNodes = 0;
    }
    
    /**
     * Destructor
     */
    ~this() {
        // Free all blocks
        while (blocks !is null) {
            Block* next = blocks.next;
            free(blocks.memory);
            free(blocks);
            blocks = next;
        }
    }
    
    /**
     * Allocate a node
     */
    TreeNode!T* allocate() {
        // TODO: Implement node allocation
        // If free list is empty, allocate a new block
        // Remove a node from the free list
        // Update statistics
        // Return the node
    }
    
    /**
     * Deallocate a node
     */
    void deallocate(TreeNode!T* node) {
        // TODO: Implement node deallocation
        // Add the node to the free list
        // Update statistics
    }
    
    /**
     * Get memory usage statistics
     */
    void printStats() {
        writefln("Node pool statistics:");
        writefln("  Total nodes: %d", totalNodes);
        writefln("  Used nodes: %d", usedNodes);
        writefln("  Free nodes: %d", totalNodes - usedNodes);
        
        // Count blocks
        size_t blockCount = 0;
        Block* current = blocks;
        while (current !is null) {
            blockCount++;
            current = current.next;
        }
        writefln("  Number of blocks: %d", blockCount);
        writefln("  Memory used: %d bytes", totalNodes * NODE_SIZE);
    }
}

/**
 * Tree node structure
 */
class TreeNode(T) {
    T value;              // Node value
    TreeNode!T left;      // Left child
    TreeNode!T right;     // Right child
    int height;           // Height for balancing (AVL)
    
    /**
     * Constructor
     */
    this(T value) {
        this.value = value;
        this.left = null;
        this.right = null;
        this.height = 1;  // Leaf nodes have height 1
    }
}

/**
 * Binary Search Tree with custom memory management
 */
class BinarySearchTree(T) {
private:
    TreeNode!T root;      // Root of the tree
    NodePool!T nodePool;  // Custom memory allocator for nodes
    size_t nodeCount;     // Number of nodes in the tree
    
public:
    /**
     * Constructor
     */
    this() {
        root = null;
        nodePool = new NodePool!T();
        nodeCount = 0;
    }
    
    /**
     * Destructor
     */
    ~this() {
        clear();
    }
    
    /**
     * Insert a value into the tree
     */
    void insert(T value) {
        // TODO: Implement insertion with balancing
    }
    
    /**
     * Remove a value from the tree
     * Returns: true if value was found and removed, false otherwise
     */
    bool remove(T value) {
        // TODO: Implement removal with balancing
    }
    
    /**
     * Find a value in the tree
     * Returns: true if value exists, false otherwise
     */
    bool find(T value) {
        // TODO: Implement find operation
    }
    
    /**
     * Find the minimum value in the tree
     */
    T findMin() {
        // TODO: Implement findMin operation
    }
    
    /**
     * Find the maximum value in the tree
     */
    T findMax() {
        // TODO: Implement findMax operation
    }
    
    /**
     * Perform an inorder traversal
     */
    void inorder(void delegate(T value) visit) {
        // TODO: Implement inorder traversal
    }
    
    /**
     * Perform a preorder traversal
     */
    void preorder(void delegate(T value) visit) {
        // TODO: Implement preorder traversal
    }
    
    /**
     * Perform a postorder traversal
     */
    void postorder(void delegate(T value) visit) {
        // TODO: Implement postorder traversal
    }
    
    /**
     * Get the number of nodes in the tree
     */
    size_t size() {
        return nodeCount;
    }
    
    /**
     * Check if the tree is empty
     */
    bool isEmpty() {
        return root is null;
    }
    
    /**
     * Clear the tree
     */
    void clear() {
        // TODO: Implement tree clearing
    }
    
    /**
     * Print the tree structure
     */
    void printTree() {
        // TODO: Implement tree visualization
    }
    
    /**
     * Print memory usage statistics
     */
    void printMemoryStats() {
        nodePool.printStats();
    }
    
private:
    /**
     * Get the height of a node (null nodes have height 0)
     */
    int height(TreeNode!T node) {
        return node is null ? 0 : node.height;
    }
    
    /**
     * Get the balance factor of a node
     */
    int balanceFactor(TreeNode!T node) {
        return node is null ? 0 : height(node.left) - height(node.right);
    }
    
    /**
     * Update the height of a node based on its children
     */
    void updateHeight(TreeNode!T node) {
        if (node !is null) {
            node.height = max(height(node.left), height(node.right)) + 1;
        }
    }
    
    /**
     * Perform a right rotation
     */
    TreeNode!T rotateRight(TreeNode!T y) {
        // TODO: Implement right rotation
    }
    
    /**
     * Perform a left rotation
     */
    TreeNode!T rotateLeft(TreeNode!T x) {
        // TODO: Implement left rotation
    }
    
    /**
     * Balance a node
     */
    TreeNode!T balance(TreeNode!T node) {
        // TODO: Implement balancing logic
    }
}

/**
 * Test the binary search tree implementation
 */
void testBinarySearchTree() {
    writeln("=== Testing Binary Search Tree ===\n");
    
    // Create a tree
    auto bst = new BinarySearchTree!int();
    
    // Test insertion
    writeln("Inserting values:");
    int[] values = [50, 30, 70, 20, 40, 60, 80, 15, 25, 35, 45, 55, 65, 75, 85];
    foreach (value; values) {
        bst.insert(value);
        writef("%d ", value);
    }
    writeln("\n");
    
    // Print the tree structure
    writeln("Tree structure:");
    bst.printTree();
    writeln();
    
    // Test traversals
    writeln("Inorder traversal:");
    write("  ");
    bst.inorder((value) { writef("%d ", value); });
    writeln("\n");
    
    writeln("Preorder traversal:");
    write("  ");
    bst.preorder((value) { writef("%d ", value); });
    writeln("\n");
    
    writeln("Postorder traversal:");
    write("  ");
    bst.postorder((value) { writef("%d ", value); });
    writeln("\n");
    
    // Test find
    writeln("Finding values:");
    writefln("  Find 40: %s", bst.find(40) ? "Found" : "Not found");
    writefln("  Find 90: %s", bst.find(90) ? "Found" : "Not found");
    
    // Test min/max
    writefln("  Minimum value: %d", bst.findMin());
    writefln("  Maximum value: %d", bst.findMax());
    
    // Test removal
    writeln("\nRemoving values:");
    int[] toRemove = [20, 40, 70];
    foreach (value; toRemove) {
        bool removed = bst.remove(value);
        writefln("  Remove %d: %s", value, removed ? "Removed" : "Not found");
    }
    
    // Print the tree after removal
    writeln("\nTree structure after removal:");
    bst.printTree();
    writeln();
    
    // Print memory statistics
    writeln("Memory statistics:");
    bst.printMemoryStats();
}

void main() {
    testBinarySearchTree();
}
```

## Implementation Details

### Node Pool Allocator

Implement an efficient memory pool for tree nodes:
1. Allocate memory in blocks to reduce fragmentation
2. Maintain a free list for quick allocation/deallocation
3. Track memory usage statistics

### Tree Balancing

Implement a self-balancing mechanism:
1. Track height or balance factor for each node
2. Implement rotation operations (left, right, left-right, right-left)
3. Rebalance after insertions and deletions

### Tree Visualization

Create a text-based visualization that shows:
1. Tree structure with proper indentation
2. Node values and relationships
3. Balance factors or heights
4. Example:
```
        50(0)
       /     \
   30(0)     70(0)
  /    \     /    \
20(-1) 40(0) 60(0) 80(0)
```

### Memory Usage Report

Generate a report showing:
1. Number of nodes in the tree
2. Total memory allocated
3. Memory efficiency compared to standard allocation
4. Fragmentation statistics

## Evaluation Criteria

Your implementation will be evaluated based on:

1. **Correctness**: All BST operations work as expected
2. **Memory Efficiency**: Effective use of the node pool allocator
3. **Balancing**: Proper implementation of tree balancing
4. **Visualization**: Clear and informative tree visualization
5. **Code Quality**: Clear, well-organized, and documented code

## Advanced Extensions

If you complete the basic requirements, try these extensions:

1. Implement a more advanced balancing scheme (Red-Black Tree)
2. Add range queries (find all values between min and max)
3. Implement tree serialization and deserialization
4. Add support for duplicate values
5. Create a threaded binary tree for more efficient traversal

## Submission

Submit your implementation as a single D file with:
- Complete `BinarySearchTree(T)` implementation
- Complete `NodePool(T)` implementation
- Test cases demonstrating all functionality
- Tree visualization examples
- Memory usage statistics
- Comments explaining your design choices

## Learning Outcomes

After completing this assignment, you should understand:
- Binary search tree implementation
- Self-balancing tree algorithms
- Custom memory allocation strategies
- Tree traversal algorithms
- Memory efficiency optimization techniques
