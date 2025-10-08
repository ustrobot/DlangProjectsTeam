# Assignment 4.3: Hash Table with Custom Memory Management

## Objective

Implement a hash table that efficiently manages its own memory. This assignment will help you understand hash table data structures, collision resolution strategies, and advanced memory management techniques.

## Requirements

### 1. Create a `HashMap(K, V)` class

Implement a template class that:
- Uses custom bucket allocation strategy
- Handles key-value pairs efficiently
- Manages its own memory

```d
class HashMap(K, V) {
    // Your implementation here
}
```

### 2. Core Hash Table Operations

Implement the following methods:

- **Put a key-value pair**
  ```d
  void put(K key, V value);
  ```

- **Get a value by key**
  ```d
  V get(K key);
  ```

- **Remove a key-value pair**
  ```d
  bool remove(K key);
  ```

- **Check if a key exists**
  ```d
  bool contains(K key);
  ```

### 3. Collision Resolution

Implement one of these collision resolution strategies:
- Separate chaining (using linked lists)
- Open addressing (linear probing, quadratic probing, or double hashing)

### 4. Custom Hash Function

Create a custom hash function for at least one complex data type:
- Implement a good distribution strategy
- Handle edge cases
- Ensure consistent results

### 5. Iterator Functionality

Implement an iterator to traverse all key-value pairs:
- Allow iteration over all entries
- Support modification during iteration
- Handle empty buckets efficiently

### 6. Performance Metrics

Add performance metrics to compare with D's built-in associative arrays:
- Measure insertion time
- Measure lookup time
- Measure memory usage
- Report comparison results

## Starter Code

```d
module hashmap;

import std.stdio;
import std.string;
import std.conv;
import std.datetime.stopwatch;
import core.stdc.stdlib : malloc, free;

/**
 * Entry in the hash table
 */
struct HashEntry(K, V) {
    K key;
    V value;
    bool isOccupied;
    bool isDeleted;
}

/**
 * Hash table with custom memory management
 */
class HashMap(K, V) {
private:
    HashEntry!(K, V)* buckets;  // Array of buckets
    size_t capacity;            // Number of buckets
    size_t count;               // Number of entries
    double loadFactor;          // Maximum load factor before resizing
    
    // For separate chaining (optional)
    // LinkedList!(HashEntry!(K, V))[] chains;
    
public:
    /**
     * Constructor
     */
    this(size_t initialCapacity = 16, double loadFactor = 0.75) {
        // TODO: Initialize the hash table
        // Allocate buckets
        // Set capacity, count, and loadFactor
    }
    
    /**
     * Destructor
     */
    ~this() {
        // TODO: Clean up allocated memory
    }
    
    /**
     * Put a key-value pair into the hash table
     */
    void put(K key, V value) {
        // TODO: Implement put operation
        // Check if resize is needed
        // Handle collisions
        // Update existing entry or create new one
    }
    
    /**
     * Get a value by key
     */
    V get(K key) {
        // TODO: Implement get operation
        // Find the key
        // Return the value or default value
    }
    
    /**
     * Remove a key-value pair
     * Returns: true if key was found and removed, false otherwise
     */
    bool remove(K key) {
        // TODO: Implement remove operation
        // Find the key
        // Mark as deleted or remove from chain
        // Update count
    }
    
    /**
     * Check if a key exists
     */
    bool contains(K key) {
        // TODO: Implement contains operation
        // Find the key
        // Return true if found, false otherwise
    }
    
    /**
     * Get the number of entries in the hash table
     */
    size_t size() {
        return count;
    }
    
    /**
     * Check if the hash table is empty
     */
    bool isEmpty() {
        return count == 0;
    }
    
    /**
     * Clear the hash table
     */
    void clear() {
        // TODO: Implement clear operation
        // Reset all buckets
        // Reset count
    }
    
    /**
     * Get the current load factor
     */
    double getCurrentLoadFactor() {
        return cast(double)count / capacity;
    }
    
    /**
     * Get an iterator for the hash table
     */
    HashMapIterator!(K, V) iterator() {
        return new HashMapIterator!(K, V)(this);
    }
    
    /**
     * Print the hash table structure
     */
    void printStructure() {
        // TODO: Implement structure visualization
    }
    
private:
    /**
     * Hash function for the key
     */
    size_t hash(K key) {
        // TODO: Implement a good hash function
        // Handle different key types
        // Return a bucket index
    }
    
    /**
     * Find a bucket for the key
     */
    size_t findBucket(K key) {
        // TODO: Implement bucket finding logic
        // For open addressing: handle probing sequence
        // For separate chaining: find the right chain
    }
    
    /**
     * Resize the hash table
     */
    void resize(size_t newCapacity) {
        // TODO: Implement resizing
        // Allocate new buckets
        // Rehash all entries
        // Update capacity
    }
    
    // Make iterator a friend class to access private members
    friend class HashMapIterator!(K, V);
}

/**
 * Iterator for the hash table
 */
class HashMapIterator(K, V) {
private:
    HashMap!(K, V) hashMap;     // Reference to the hash map
    size_t currentBucket;       // Current bucket index
    
public:
    /**
     * Constructor
     */
    this(HashMap!(K, V) hashMap) {
        this.hashMap = hashMap;
        this.currentBucket = 0;
        // Move to first valid entry
        findNextValidBucket();
    }
    
    /**
     * Check if there are more entries
     */
    bool hasNext() {
        // TODO: Implement hasNext
    }
    
    /**
     * Get the next key-value pair
     */
    HashEntry!(K, V) next() {
        // TODO: Implement next
        // Return current entry
        // Move to next valid entry
    }
    
private:
    /**
     * Find the next valid bucket
     */
    void findNextValidBucket() {
        // TODO: Implement finding the next valid bucket
        // Skip empty and deleted buckets
    }
}

/**
 * Custom hash function for string keys
 */
size_t stringHash(string key, size_t capacity) {
    // TODO: Implement a good string hash function
    // Example: djb2 algorithm
    size_t hash = 5381;
    foreach (c; key) {
        hash = ((hash << 5) + hash) + c;
    }
    return hash % capacity;
}

/**
 * Test the hash table implementation
 */
void testHashMap() {
    writeln("=== Testing Hash Map ===\n");
    
    // Create a hash map
    auto map = new HashMap!(string, int)(16, 0.75);
    
    // Test putting values
    writeln("Adding key-value pairs:");
    map.put("one", 1);
    map.put("two", 2);
    map.put("three", 3);
    map.put("four", 4);
    map.put("five", 5);
    
    // Print structure
    writeln("\nHash table structure:");
    map.printStructure();
    
    // Test getting values
    writeln("\nRetrieving values:");
    writefln("  get(\"one\"): %d", map.get("one"));
    writefln("  get(\"three\"): %d", map.get("three"));
    writefln("  get(\"six\"): %d", map.get("six"));  // Should return default value
    
    // Test contains
    writeln("\nChecking keys:");
    writefln("  contains(\"two\"): %s", map.contains("two") ? "true" : "false");
    writefln("  contains(\"six\"): %s", map.contains("six") ? "true" : "false");
    
    // Test removing values
    writeln("\nRemoving values:");
    writefln("  remove(\"two\"): %s", map.remove("two") ? "removed" : "not found");
    writefln("  remove(\"six\"): %s", map.remove("six") ? "removed" : "not found");
    
    // Print updated structure
    writeln("\nHash table structure after removal:");
    map.printStructure();
    
    // Test iterator
    writeln("\nIterating through all entries:");
    auto iter = map.iterator();
    while (iter.hasNext()) {
        auto entry = iter.next();
        writefln("  %s: %d", entry.key, entry.value);
    }
    
    // Test performance compared to built-in AA
    writeln("\nPerformance comparison:");
    performanceTest();
}

/**
 * Performance comparison with built-in associative array
 */
void performanceTest() {
    enum size_t NUM_ENTRIES = 10_000;
    
    // Create test data
    string[] keys;
    for (size_t i = 0; i < NUM_ENTRIES; i++) {
        keys ~= "key" ~ to!string(i);
    }
    
    // Test custom hash map
    auto customMap = new HashMap!(string, int)(1024, 0.75);
    auto customTimer = StopWatch(AutoStart.yes);
    
    // Insertion
    foreach (i, key; keys) {
        customMap.put(key, cast(int)i);
    }
    
    // Lookup
    foreach (key; keys) {
        customMap.get(key);
    }
    
    customTimer.stop();
    
    // Test built-in associative array
    int[string] builtinMap;
    auto builtinTimer = StopWatch(AutoStart.yes);
    
    // Insertion
    foreach (i, key; keys) {
        builtinMap[key] = cast(int)i;
    }
    
    // Lookup
    foreach (key; keys) {
        auto val = builtinMap.get(key, -1);
    }
    
    builtinTimer.stop();
    
    // Report results
    writefln("Custom HashMap:    %s", customTimer.peek());
    writefln("Built-in AA:       %s", builtinTimer.peek());
    double ratio = cast(double)customTimer.peek().total!"usecs" / 
                  cast(double)builtinTimer.peek().total!"usecs";
    writefln("Performance ratio: %.2fx", ratio);
}

void main() {
    testHashMap();
}
```

## Implementation Details

### Hash Function

Implement an effective hash function that:
1. Distributes keys evenly across buckets
2. Handles different key types appropriately
3. Minimizes collisions
4. Is reasonably fast to compute

### Collision Resolution

Choose and implement one of these strategies:

#### Separate Chaining
1. Use a linked list for each bucket
2. Add new entries to the appropriate chain
3. Handle chain traversal for operations

#### Open Addressing
1. Implement a probing sequence (linear, quadratic, or double hashing)
2. Handle deleted entries properly
3. Ensure the table doesn't get too full

### Dynamic Resizing

Implement a resizing strategy that:
1. Monitors the load factor
2. Allocates a larger bucket array when needed
3. Rehashes all existing entries
4. Updates capacity and related metrics

### Memory Management

Implement custom memory management that:
1. Allocates buckets efficiently
2. Minimizes fragmentation
3. Properly cleans up all allocated memory
4. Tracks memory usage statistics

## Evaluation Criteria

Your implementation will be evaluated based on:

1. **Correctness**: All hash table operations work as expected
2. **Collision Handling**: Effective collision resolution strategy
3. **Memory Efficiency**: Good memory management and usage
4. **Performance**: Competitive performance with built-in associative arrays
5. **Code Quality**: Clear, well-organized, and documented code

## Advanced Extensions

If you complete the basic requirements, try these extensions:

1. Implement multiple collision resolution strategies and compare them
2. Add support for custom hash functions provided by the user
3. Implement a thread-safe version of the hash table
4. Add support for iterating in insertion order
5. Implement a cuckoo hashing variant for better performance

## Submission

Submit your implementation as a single D file with:
- Complete `HashMap(K, V)` implementation
- Complete `HashMapIterator(K, V)` implementation
- Custom hash functions for different key types
- Performance comparison results
- Comments explaining your design choices

## Learning Outcomes

After completing this assignment, you should understand:
- Hash table implementation techniques
- Collision resolution strategies
- Hash function design principles
- Memory management for dynamic structures
- Performance optimization techniques
