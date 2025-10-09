# Assignment 3.1: Array Basics and Memory

## Objective

Understand how arrays are stored in memory and practice basic array operations. This assignment will help you visualize how computers organize data in memory.

## Introduction

Arrays are like rows of mailboxes - they store multiple items of the same type in order. In this assignment, you'll learn how arrays work in computer memory and practice some common array operations.

## Requirements

### 1. Create a program that explores arrays in memory

Create a D program that:
- Creates arrays of different types (numbers, characters, strings)
- Prints the memory addresses of array elements
- Shows how elements are stored next to each other in memory

```d
// Example starter code
import std.stdio;

void main() {
    // Create arrays of different types
    int[] numbers = [10, 20, 30, 40, 50];
    char[] letters = ['A', 'B', 'C', 'D', 'E'];
    string[] words = ["apple", "banana", "cherry", "date", "elderberry"];
    
    // TODO: Print the memory addresses of array elements
    writeln("Memory addresses of numbers array:");
    // Your code here
    
    // TODO: Print the memory addresses of letters array
    
    // TODO: Print the memory addresses of words array
    
    // TODO: Show how elements are stored sequentially
}
```

### 2. Implement basic array operations

Add functions to your program that:
- Find the largest and smallest values in a numeric array
- Calculate the average of a numeric array
- Reverse an array

```d
// Example function signatures
int findLargest(int[] arr) {
    // Your code here
}

int findSmallest(int[] arr) {
    // Your code here
}

double calculateAverage(int[] arr) {
    // Your code here
}

T[] reverseArray(T)(T[] arr) {
    // Your code here
}
```

### 3. Create a simple memory visualization

Create a simple ASCII art visualization that shows how array elements are stored in memory:

```
Memory layout for numbers array:
Address: 0x1000 | Value: 10
Address: 0x1004 | Value: 20
Address: 0x1008 | Value: 30
Address: 0x100C | Value: 40
Address: 0x1010 | Value: 50
```

## Step-by-Step Guide

1. **Create arrays of different types**
   - Declare and initialize arrays of integers, characters, and strings
   - Make sure each array has at least 5 elements

2. **Print memory addresses**
   - Use the `&` operator to get the address of each element
   - Print the addresses in a readable format
   - Notice the pattern between consecutive elements

3. **Implement array operations**
   - Write a function to find the largest value in an array
   - Write a function to find the smallest value in an array
   - Write a function to calculate the average of values in an array
   - Write a function to reverse an array

4. **Create memory visualization**
   - Print a simple ASCII representation of memory
   - Show addresses and values side by side
   - Use formatting to make it easy to read

## Example Output

Your program should produce output similar to this:

```
Array Elements and Addresses:
numbers[0] = 10 at address 0x7FFF1234
numbers[1] = 20 at address 0x7FFF1238
numbers[2] = 30 at address 0x7FFF123C
numbers[3] = 40 at address 0x7FFF1240
numbers[4] = 50 at address 0x7FFF1244

Array Operations:
Largest value: 50
Smallest value: 10
Average value: 30.0
Reversed array: [50, 40, 30, 20, 10]

Memory Visualization:
[0x7FFF1234] | 10 |
[0x7FFF1238] | 20 |
[0x7FFF123C] | 30 |
[0x7FFF1240] | 40 |
[0x7FFF1244] | 50 |
```

## Learning Outcomes

After completing this assignment, you will understand:
- How arrays are stored in computer memory
- How to access memory addresses in D
- How to perform basic operations on arrays
- How to visualize memory layout

## Extension Activities

If you finish early, try these additional challenges:

1. Create a 2D array (an array of arrays) and visualize its memory layout
2. Write a function that searches for a specific value in an array and returns its address
3. Create arrays of different data types and compare how much memory each type uses
4. Implement a "memory game" where the user has to guess which array element is at a specific address

## Submission Guidelines

Submit your D source code file with:
- Well-commented code explaining what each part does
- All required functionality implemented
- Output showing the results of your program

## Memory Management Tips

When working with arrays in D:

**Allocation:**
- Arrays are automatically allocated when declared: `int[] arr = [1, 2, 3];`
- Dynamic arrays can grow automatically: `arr ~= 4;` adds an element
- Use `new int[n]` for fixed-size arrays that won't change size

**Deallocation:**
- D's garbage collector automatically frees array memory when no longer referenced
- For performance-critical code, arrays are generally GC-managed, so no manual deallocation needed
- Avoid creating many temporary arrays in loops to prevent GC pressure

## Grading Criteria

- **Correctness**: Does your code correctly implement all required functionality?
- **Understanding**: Do you demonstrate understanding of memory addresses and array operations?
- **Visualization**: Is your memory visualization clear and accurate?
- **Code Quality**: Is your code well-organized and properly commented?
