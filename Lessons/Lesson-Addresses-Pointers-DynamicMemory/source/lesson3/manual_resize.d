/**
 * Lesson 3: Dynamic Memory Allocation
 * Example: Manually Resizing a Dynamic Array
 *
 * This example demonstrates how to manually resize a dynamic array
 * by creating a new array, copying data, and managing memory.
 */
module lesson3.manual_resize;

import std.stdio;
import std.string;
import core.stdc.stdlib;

void runExample() {
    writeln("=== Manually Resizing a Dynamic Array Example ===\n");
    
    // In D, we rarely need to manually resize arrays because
    // the language provides built-in resizing with .length
    // However, this example shows how it works under the hood
    
    // 1. First, let's demonstrate D's built-in resizing
    writeln("1. D's Built-in Array Resizing:");
    
    int[] autoArray = [1, 2, 3, 4, 5];
    writefln("  Original array: %s, length: %d", autoArray, autoArray.length);
    
    // Resize to larger size
    autoArray.length = 10;
    
    // Fill new elements
    for (int i = 5; i < autoArray.length; i++) {
        autoArray[i] = (i + 1) * 10;
    }
    
    writefln("  After automatic resize: %s, length: %d", autoArray, autoArray.length);
    
    // 2. Now let's implement manual resizing
    writeln("\n2. Manual Array Resizing (D style):");
    
    // Create an initial array
    int[] manualArray = [10, 20, 30, 40, 50];
    writefln("  Original array: %s, length: %d", manualArray, manualArray.length);
    
    // Manually resize the array (D style)
    manualArray = manualResize(manualArray, 8);
    
    // Fill new elements
    for (int i = 5; i < manualArray.length; i++) {
        manualArray[i] = (i + 1) * 100;
    }
    
    writefln("  After manual resize: %s, length: %d", manualArray, manualArray.length);
    
    // Resize to smaller size
    manualArray = manualResize(manualArray, 4);
    writefln("  After manual shrink: %s, length: %d", manualArray, manualArray.length);
    
    // 3. C-style manual memory management
    writeln("\n3. C-style Manual Memory Management:");
    
    // Allocate memory for an array
    int* cArray = cast(int*)malloc(5 * int.sizeof);
    
    // Initialize the array
    for (int i = 0; i < 5; i++) {
        cArray[i] = (i + 1) * 5;
    }
    
    // Print the array
    write("  Original C-style array: [");
    for (int i = 0; i < 5; i++) {
        write(cArray[i]);
        if (i < 4) write(", ");
    }
    writeln("]");
    
    // Resize the array using realloc
    int* newCArray = cast(int*)realloc(cArray, 8 * int.sizeof);
    if (newCArray is null) {
        writeln("  Failed to reallocate memory");
        free(cArray);
        return;
    }
    
    // Update our pointer
    cArray = newCArray;
    
    // Initialize new elements
    for (int i = 5; i < 8; i++) {
        cArray[i] = (i + 1) * 5;
    }
    
    // Print the resized array
    write("  Resized C-style array: [");
    for (int i = 0; i < 8; i++) {
        write(cArray[i]);
        if (i < 7) write(", ");
    }
    writeln("]");
    
    // Free the memory
    free(cArray);
    
    // 4. Implementing a dynamic array class
    writeln("\n4. Custom Dynamic Array Implementation:");
    
    // Create a dynamic array using our custom class
    auto dynamicArray = new DynamicArray!int();
    
    // Add elements
    for (int i = 0; i < 10; i++) {
        dynamicArray.add(i * 10);
    }
    
    writefln("  Custom dynamic array: %s", dynamicArray.toString());
    
    // Remove some elements
    dynamicArray.removeAt(3);
    dynamicArray.removeAt(5);
    
    writefln("  After removing elements: %s", dynamicArray.toString());
    
    writeln("\nKey takeaways:");
    writeln("1. D handles array resizing automatically with .length");
    writeln("2. Manual resizing involves allocating new memory and copying data");
    writeln("3. C-style memory management is available but rarely needed in D");
    writeln("4. Custom dynamic array implementations can provide more control");
    writeln("5. Understanding manual resizing helps appreciate D's built-in features");
}

/**
 * Manually resize an array by creating a new array and copying data
 */
T[] manualResize(T)(T[] array, size_t newSize) {
    // Create a new array with the desired size
    T[] newArray = new T[newSize];
    
    // Calculate how many elements to copy
    size_t elementsToCopy = array.length < newSize ? array.length : newSize;
    
    // Copy elements from the old array to the new one
    for (size_t i = 0; i < elementsToCopy; i++) {
        newArray[i] = array[i];
    }
    
    // Return the new array (old array will be garbage collected)
    return newArray;
}

/**
 * A simple dynamic array implementation to demonstrate manual resizing
 */
class DynamicArray(T) {
private:
    T[] data;
    size_t count;
    size_t capacity;
    
    // Initial capacity and growth factor
    enum size_t INITIAL_CAPACITY = 4;
    enum float GROWTH_FACTOR = 1.5;
    
    void ensureCapacity(size_t minCapacity) {
        if (capacity >= minCapacity) return;
        
        // Calculate new capacity
        size_t newCapacity = cast(size_t)(capacity * GROWTH_FACTOR);
        if (newCapacity < minCapacity) newCapacity = minCapacity;
        
        // Create new array with increased capacity
        T[] newData = new T[newCapacity];
        
        // Copy existing elements
        for (size_t i = 0; i < count; i++) {
            newData[i] = data[i];
        }
        
        // Update data and capacity
        data = newData;
        capacity = newCapacity;
    }
    
public:
    this() {
        // Initialize with default capacity
        data = new T[INITIAL_CAPACITY];
        capacity = INITIAL_CAPACITY;
        count = 0;
    }
    
    void add(T item) {
        // Ensure we have enough space
        ensureCapacity(count + 1);
        
        // Add the item and increment count
        data[count++] = item;
    }
    
    T get(size_t index) {
        if (index >= count) {
            throw new Exception("Index out of bounds");
        }
        return data[index];
    }
    
    void set(size_t index, T value) {
        if (index >= count) {
            throw new Exception("Index out of bounds");
        }
        data[index] = value;
    }
    
    void removeAt(size_t index) {
        if (index >= count) {
            throw new Exception("Index out of bounds");
        }
        
        // Shift elements to fill the gap
        for (size_t i = index; i < count - 1; i++) {
            data[i] = data[i + 1];
        }
        
        // Decrement count
        count--;
    }
    
    size_t size() {
        return count;
    }
    
    override string toString() {
        string result = "[";
        for (size_t i = 0; i < count; i++) {
            result ~= format("%s", data[i]);
            if (i < count - 1) result ~= ", ";
        }
        result ~= "]";
        return result;
    }
}
