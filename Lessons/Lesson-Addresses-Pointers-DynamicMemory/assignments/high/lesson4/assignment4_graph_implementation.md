# Assignment 4.4: Memory-Efficient Graph Implementation

## Objective

Create a memory-efficient graph data structure with custom memory management. This assignment will help you understand graph representations, algorithms, and advanced memory management techniques for complex interconnected data structures.

## Requirements

### 1. Implement a `Graph(T)` class

Create a template class that supports:
- Both directed and undirected graphs
- Adding/removing vertices and edges
- Storing data in vertices and optional weights on edges
- Memory-efficient adjacency representation

```d
class Graph(T, bool isDirected = false) {
    // Your implementation here
}
```

### 2. Graph Operations

Implement the following methods:

- **Add a vertex with data**
  ```d
  VertexId addVertex(T data);
  ```

- **Add an edge between vertices**
  ```d
  void addEdge(VertexId from, VertexId to, double weight = 1.0);
  ```

- **Remove a vertex**
  ```d
  bool removeVertex(VertexId id);
  ```

- **Remove an edge**
  ```d
  bool removeEdge(VertexId from, VertexId to);
  ```

- **Get vertex data**
  ```d
  T getVertexData(VertexId id);
  ```

- **Get edge weight**
  ```d
  double getEdgeWeight(VertexId from, VertexId to);
  ```

### 3. Graph Algorithms

Implement common graph algorithms:

- **Depth-first search**
  ```d
  void dfs(VertexId start, void delegate(VertexId id) visit);
  ```

- **Breadth-first search**
  ```d
  void bfs(VertexId start, void delegate(VertexId id) visit);
  ```

- **Shortest path (Dijkstra's algorithm)**
  ```d
  Path shortestPath(VertexId start, VertexId end);
  ```

### 4. Memory Management

Implement custom memory management for graph components:
- Create a memory pool for vertices and edges
- Reuse memory from removed vertices/edges
- Track memory usage statistics

### 5. Graph Visualization

Create a method to visualize the graph structure:
- Text-based representation of vertices and edges
- Show vertex data and edge weights
- Indicate directed vs undirected edges

### 6. Memory Usage Statistics

Include detailed memory usage statistics:
- Number of vertices and edges
- Memory used for vertices and edges
- Comparison with standard allocation
- Fragmentation metrics

## Starter Code

```d
module graph;

import std.stdio;
import std.container;
import std.algorithm;
import std.range;
import std.conv;
import std.string;
import core.stdc.stdlib : malloc, free;

/**
 * Vertex ID type
 */
alias VertexId = size_t;

/**
 * Edge structure
 */
struct Edge {
    VertexId to;        // Destination vertex
    double weight;      // Edge weight
    Edge* next;         // Next edge in adjacency list
}

/**
 * Vertex structure
 */
struct Vertex(T) {
    VertexId id;        // Vertex ID
    T data;             // Vertex data
    Edge* edges;        // Adjacency list (linked list of edges)
    bool isActive;      // Whether the vertex is active or deleted
}

/**
 * Path structure for shortest path results
 */
struct Path {
    VertexId[] vertices;  // Sequence of vertices in the path
    double totalWeight;   // Total path weight
    bool exists;          // Whether a path exists
}

/**
 * Memory pool for edges
 */
class EdgePool {
private:
    struct FreeEdge {
        FreeEdge* next;
    }
    
    Edge* edges;          // Array of edge objects
    size_t capacity;      // Total capacity
    size_t used;          // Number of edges in use
    FreeEdge* freeList;   // List of free edges
    
public:
    /**
     * Constructor
     */
    this(size_t initialCapacity = 1024) {
        // TODO: Implement edge pool initialization
    }
    
    /**
     * Destructor
     */
    ~this() {
        // TODO: Clean up allocated memory
    }
    
    /**
     * Allocate an edge
     */
    Edge* allocate() {
        // TODO: Implement edge allocation
    }
    
    /**
     * Deallocate an edge
     */
    void deallocate(Edge* edge) {
        // TODO: Implement edge deallocation
    }
    
    /**
     * Get memory usage statistics
     */
    void printStats() {
        writefln("Edge pool statistics:");
        writefln("  Capacity: %d edges", capacity);
        writefln("  Used: %d edges", used);
        writefln("  Free: %d edges", capacity - used);
        writefln("  Memory used: %d bytes", capacity * Edge.sizeof);
    }
}

/**
 * Graph implementation with custom memory management
 */
class Graph(T, bool isDirected = false) {
private:
    Vertex!T[] vertices;      // Array of vertices
    EdgePool edgePool;        // Memory pool for edges
    size_t vertexCount;       // Number of active vertices
    size_t edgeCount;         // Number of edges
    size_t nextVertexId;      // Next vertex ID to assign
    
public:
    /**
     * Constructor
     */
    this(size_t initialVertexCapacity = 128, size_t initialEdgeCapacity = 1024) {
        // TODO: Initialize the graph
        // Create vertex array
        // Initialize edge pool
        // Set counters
    }
    
    /**
     * Destructor
     */
    ~this() {
        // TODO: Clean up all allocated memory
    }
    
    /**
     * Add a vertex with data
     * Returns: ID of the new vertex
     */
    VertexId addVertex(T data) {
        // TODO: Implement vertex addition
        // Find a free slot or expand the array
        // Initialize the vertex
        // Return the vertex ID
    }
    
    /**
     * Add an edge between vertices
     */
    void addEdge(VertexId from, VertexId to, double weight = 1.0) {
        // TODO: Implement edge addition
        // Validate vertex IDs
        // Allocate an edge from the pool
        // Add to adjacency list
        // For undirected graphs, add the reverse edge
    }
    
    /**
     * Remove a vertex
     * Returns: true if vertex was found and removed, false otherwise
     */
    bool removeVertex(VertexId id) {
        // TODO: Implement vertex removal
        // Find and mark the vertex as inactive
        // Remove all edges to/from this vertex
        // Update counters
    }
    
    /**
     * Remove an edge
     * Returns: true if edge was found and removed, false otherwise
     */
    bool removeEdge(VertexId from, VertexId to) {
        // TODO: Implement edge removal
        // Find the edge in the adjacency list
        // Remove it and update the list
        // For undirected graphs, remove the reverse edge
    }
    
    /**
     * Get vertex data
     */
    T getVertexData(VertexId id) {
        // TODO: Implement data retrieval
        // Validate vertex ID
        // Return the data
    }
    
    /**
     * Set vertex data
     */
    void setVertexData(VertexId id, T data) {
        // TODO: Implement data update
        // Validate vertex ID
        // Update the data
    }
    
    /**
     * Get edge weight
     */
    double getEdgeWeight(VertexId from, VertexId to) {
        // TODO: Implement weight retrieval
        // Find the edge
        // Return its weight or infinity if not found
    }
    
    /**
     * Check if an edge exists
     */
    bool hasEdge(VertexId from, VertexId to) {
        // TODO: Implement edge check
        // Find the edge in the adjacency list
        // Return true if found
    }
    
    /**
     * Get the number of vertices
     */
    size_t getVertexCount() {
        return vertexCount;
    }
    
    /**
     * Get the number of edges
     */
    size_t getEdgeCount() {
        return edgeCount;
    }
    
    /**
     * Get all vertex IDs
     */
    VertexId[] getVertices() {
        // TODO: Implement vertex ID collection
        // Collect IDs of all active vertices
    }
    
    /**
     * Get adjacent vertices
     */
    VertexId[] getAdjacentVertices(VertexId id) {
        // TODO: Implement adjacency list retrieval
        // Collect IDs of all adjacent vertices
    }
    
    /**
     * Perform depth-first search
     */
    void dfs(VertexId start, void delegate(VertexId id) visit) {
        // TODO: Implement DFS
        // Use a stack for traversal
        // Mark visited vertices
        // Call the visit delegate for each vertex
    }
    
    /**
     * Perform breadth-first search
     */
    void bfs(VertexId start, void delegate(VertexId id) visit) {
        // TODO: Implement BFS
        // Use a queue for traversal
        // Mark visited vertices
        // Call the visit delegate for each vertex
    }
    
    /**
     * Find shortest path (Dijkstra's algorithm)
     */
    Path shortestPath(VertexId start, VertexId end) {
        // TODO: Implement Dijkstra's algorithm
        // Use a priority queue for vertices
        // Track distances and previous vertices
        // Reconstruct the path
    }
    
    /**
     * Print the graph structure
     */
    void printGraph() {
        // TODO: Implement graph visualization
        // Print vertices with their data
        // Print edges with their weights
        // Format appropriately for directed/undirected
    }
    
    /**
     * Print memory usage statistics
     */
    void printMemoryStats() {
        writefln("Graph memory statistics:");
        writefln("  Vertices: %d (capacity: %d)", vertexCount, vertices.length);
        writefln("  Edges: %d", edgeCount);
        writefln("  Vertex memory: %d bytes", vertices.length * Vertex!T.sizeof);
        
        edgePool.printStats();
    }
}

/**
 * Test the graph implementation
 */
void testGraph() {
    writeln("=== Testing Graph Implementation ===\n");
    
    // Create a graph
    auto graph = new Graph!(string)(10, 20);
    
    // Add vertices
    writeln("Adding vertices:");
    auto v1 = graph.addVertex("A");
    auto v2 = graph.addVertex("B");
    auto v3 = graph.addVertex("C");
    auto v4 = graph.addVertex("D");
    auto v5 = graph.addVertex("E");
    
    writefln("  Added vertices: %s", [v1, v2, v3, v4, v5]);
    
    // Add edges
    writeln("\nAdding edges:");
    graph.addEdge(v1, v2, 1.0);
    graph.addEdge(v1, v3, 2.0);
    graph.addEdge(v2, v3, 3.0);
    graph.addEdge(v2, v4, 1.5);
    graph.addEdge(v3, v5, 2.5);
    graph.addEdge(v4, v5, 1.0);
    
    // Print the graph
    writeln("\nGraph structure:");
    graph.printGraph();
    
    // Test traversals
    writeln("\nDepth-first search from vertex A:");
    write("  ");
    graph.dfs(v1, (id) { writef("%s ", graph.getVertexData(id)); });
    writeln();
    
    writeln("\nBreadth-first search from vertex A:");
    write("  ");
    graph.bfs(v1, (id) { writef("%s ", graph.getVertexData(id)); });
    writeln();
    
    // Test shortest path
    writeln("\nShortest path from A to E:");
    auto path = graph.shortestPath(v1, v5);
    if (path.exists) {
        write("  Path: ");
        foreach (id; path.vertices) {
            writef("%s ", graph.getVertexData(id));
        }
        writefln("\n  Total weight: %.1f", path.totalWeight);
    } else {
        writeln("  No path exists");
    }
    
    // Test vertex/edge removal
    writeln("\nRemoving vertex C and edge B->D:");
    graph.removeVertex(v3);
    graph.removeEdge(v2, v4);
    
    writeln("\nUpdated graph structure:");
    graph.printGraph();
    
    // Print memory statistics
    writeln("\nMemory statistics:");
    graph.printMemoryStats();
}

void main() {
    testGraph();
}
```

## Implementation Details

### Graph Representation

Choose an appropriate graph representation:

1. **Adjacency List**
   - Each vertex has a list of adjacent vertices
   - Good for sparse graphs
   - Efficient for most operations

2. **Adjacency Matrix**
   - Matrix representation of edges
   - Good for dense graphs
   - Fast edge lookups

### Memory Pool for Edges

Implement an efficient memory pool for edges:
1. Pre-allocate blocks of edges
2. Maintain a free list for quick allocation/deallocation
3. Grow the pool as needed
4. Track memory usage statistics

### Graph Algorithms

Implement the following algorithms:

1. **Depth-First Search (DFS)**
   - Use a stack or recursion
   - Track visited vertices
   - Handle disconnected components

2. **Breadth-First Search (BFS)**
   - Use a queue
   - Track visited vertices
   - Handle disconnected components

3. **Dijkstra's Algorithm**
   - Use a priority queue
   - Track distances and paths
   - Handle unreachable vertices

### Graph Visualization

Create a text-based visualization that shows:
1. Vertices with their data
2. Edges with their weights
3. Direction of edges (for directed graphs)

Example:
```
Graph with 5 vertices and 6 edges:
Vertices:
  0: A
  1: B
  2: C
  3: D
  4: E

Edges:
  A --1.0--> B
  A --2.0--> C
  B --3.0--> C
  B --1.5--> D
  C --2.5--> E
  D --1.0--> E
```

## Evaluation Criteria

Your implementation will be evaluated based on:

1. **Correctness**: All graph operations work as expected
2. **Memory Efficiency**: Effective use of memory pools
3. **Algorithm Implementation**: Correct implementation of graph algorithms
4. **Visualization**: Clear and informative graph visualization
5. **Code Quality**: Clear, well-organized, and documented code

## Advanced Extensions

If you complete the basic requirements, try these extensions:

1. Implement additional graph algorithms (MST, topological sort)
2. Add support for subgraphs and graph operations (union, intersection)
3. Implement a more advanced visualization (ASCII art or export to DOT format)
4. Add support for vertex and edge attributes
5. Create a thread-safe version of the graph

## Submission

Submit your implementation as a single D file with:
- Complete `Graph(T, isDirected)` implementation
- Complete `EdgePool` implementation
- Implementation of all required algorithms
- Graph visualization examples
- Memory usage statistics
- Comments explaining your design choices

## Learning Outcomes

After completing this assignment, you should understand:
- Graph representation techniques
- Graph traversal and path-finding algorithms
- Memory-efficient adjacency structures
- Custom allocators for complex structures
- Memory management for dynamic, interconnected data
