# Assignment 3.3: Memory Usage Detective

## Objective

Investigate how different data types and structures use memory. This assignment will help you understand how computers allocate memory for different kinds of data.

## Introduction

Different types of data take up different amounts of memory. A single letter takes less space than a whole number, which takes less space than a decimal number. In this assignment, you'll become a "memory detective" and investigate how much memory different data types use!

## Requirements

### 1. Create a program that investigates data type sizes

Create a D program that:
- Declares variables of different types (int, double, char, bool, etc.)
- Creates arrays and structures
- Reports the size of each in memory

```d
// Example starter code
import std.stdio;

// A simple structure to investigate
struct Person {
    string name;
    int age;
    double height;
    char gender;
}

void main() {
    // Investigate basic types
    writeln("=== Memory Detective Report: Basic Types ===");
    
    // TODO: Declare variables of different types and print their sizes
    // Example:
    int intVar = 42;
    writefln("int variable: %d bytes", int.sizeof);
    
    // TODO: Add more basic types (double, char, bool, etc.)
    
    // Investigate arrays
    writeln("\n=== Memory Detective Report: Arrays ===");
    
    // TODO: Create arrays of different types and sizes and print their memory usage
    // Example:
    int[] intArray = [1, 2, 3, 4, 5];
    writefln("int array with %d elements: %d bytes", intArray.length, intArray.length * int.sizeof);
    
    // Investigate structures
    writeln("\n=== Memory Detective Report: Structures ===");
    
    // TODO: Create structures and print their sizes
    Person person = Person("Alice", 12, 5.2, 'F');
    writefln("Person structure: %d bytes", Person.sizeof);
    
    // TODO: Compare the size of the structure with the sum of its parts
}
```

### 2. Implement a "memory detective" that analyzes memory usage

Add functions to your program that:
- Compares memory usage between different approaches
- Shows how memory alignment works
- Demonstrates memory padding in structures

```d
// Example structure to demonstrate padding
struct BadlyPacked {
    char a;    // 1 byte
    int b;     // 4 bytes
    char c;    // 1 byte
    double d;  // 8 bytes
}

// Same fields but ordered differently to reduce padding
struct WellPacked {
    double d;  // 8 bytes
    int b;     // 4 bytes
    char a;    // 1 byte
    char c;    // 1 byte
}

// TODO: Create a function to analyze and report on structure padding
void investigateStructurePadding() {
    // Your code here
}
```

### 3. Create a simple report showing the findings

Generate a report that:
- Shows the size of each data type
- Compares memory usage of different structures
- Provides insights on efficient memory usage

## Step-by-Step Guide

1. **Investigate basic data types**
   - Declare variables of different types (int, double, char, bool, etc.)
   - Use the `.sizeof` property to determine their size in bytes
   - Create a table showing the results

2. **Investigate arrays**
   - Create arrays of different types and sizes
   - Calculate their total memory usage
   - Compare arrays of different types with the same number of elements

3. **Investigate structures**
   - Create structures with different field types
   - Measure the size of the entire structure
   - Compare the structure size with the sum of its individual fields
   - Create structures with the same fields in different orders to demonstrate padding

4. **Create a memory usage report**
   - Summarize your findings in a clear, organized way
   - Include recommendations for efficient memory usage
   - Use visual elements like tables or ASCII charts if possible

## Example Output

Your program should produce output similar to this:

```
=== Memory Detective Report: Basic Types ===
bool variable: 1 bytes
char variable: 1 bytes
int variable: 4 bytes
long variable: 8 bytes
float variable: 4 bytes
double variable: 8 bytes
string variable: 16 bytes (reference type)

=== Memory Detective Report: Arrays ===
int array with 5 elements: 20 bytes
char array with 5 elements: 5 bytes
double array with 5 elements: 40 bytes

=== Memory Detective Report: Structures ===
Person structure: 32 bytes
Sum of Person fields: 29 bytes
Extra bytes due to padding: 3 bytes

Structure Padding Investigation:
BadlyPacked structure: 24 bytes
WellPacked structure: 16 bytes
Saved by better packing: 8 bytes (33% reduction!)

Memory Usage Summary:
- Smallest type: bool, char (1 byte)
- Largest basic type: double, long (8 bytes)
- Most efficient array: char array (1 byte per element)
- Structure padding can significantly impact memory usage!
```

## Learning Outcomes

After completing this assignment, you will understand:
- How different data types use memory
- How arrays store elements in memory
- How structure padding affects memory usage
- How to optimize memory usage through proper data organization

## Extension Activities

If you finish early, try these additional challenges:

1. Create a visual representation of memory usage using ASCII art
2. Investigate how unions work and how they can save memory
3. Create a "memory calculator" that predicts how much memory a program will use
4. Experiment with different compiler options that affect memory layout

## Submission Guidelines

Submit your D source code file with:
- Well-commented code explaining what each part does
- All required investigations implemented
- A clear, organized report of your findings

## Grading Criteria

- **Thoroughness**: Did you investigate a variety of data types and structures?
- **Understanding**: Do you demonstrate understanding of memory usage concepts?
- **Analysis**: Is your report insightful and well-organized?
- **Code Quality**: Is your code well-organized and properly commented?
