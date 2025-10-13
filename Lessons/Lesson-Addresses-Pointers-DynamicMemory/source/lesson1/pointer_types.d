/**
 * Lesson 1: Addresses and Pointer Fundamentals
 * Example: Pointer Types and Type Safety
 *
 * This example demonstrates different pointer types and D's type safety features.
 */
module lesson1.pointer_types;

import std.stdio;

void runExample() {
    writeln("=== Pointer Types and Type Safety Example ===\n");
    
    // Declare variables of different types
    int intValue = 42;
    double doubleValue = 3.14;
    char charValue = 'A';
    bool boolValue = true;
    
    // Declare pointers of corresponding types
    int* pInt = &intValue;
    double* pDouble = &doubleValue;
    char* pChar = &charValue;
    bool* pBool = &boolValue;
    
    // Print the values and addresses
    writeln("Different pointer types:");
    writefln("  int*:    pInt = %s, *pInt = %d", pInt, *pInt);
    writefln("  double*: pDouble = %s, *pDouble = %f", pDouble, *pDouble);
    writefln("  char*:   pChar = %s, *pChar = %c", pChar, *pChar);
    writefln("  bool*:   pBool = %s, *pBool = %s", pBool, *pBool);
    
    // Demonstrate pointer size consistency
    writeln("\nPointer sizes (all pointers have the same size regardless of what they point to):");
    writefln("  Size of int*:    %d bytes", (int*).sizeof);
    writefln("  Size of double*: %d bytes", (double*).sizeof);
    writefln("  Size of char*:   %d bytes", (char*).sizeof);
    writefln("  Size of bool*:   %d bytes", (bool*).sizeof);
    
    // Type safety in D
    writeln("\nType safety in D:");
    
    // The following line would cause a compilation error in D
    // pInt = pDouble;  // Error: cannot implicitly convert expression (pDouble) of type double* to int*
    
    // We can demonstrate type safety with a void* pointer (generic pointer)
    void* genericPtr = pInt;  // Allowed: implicit conversion to void*
    writefln("  genericPtr = %s (pointing to intValue)", genericPtr);
    
    // Reassign to point to doubleValue
    genericPtr = pDouble;
    writefln("  genericPtr = %s (now pointing to doubleValue)", genericPtr);
    
    // To use genericPtr, we must cast it back to a specific type
    int* backToInt = cast(int*)genericPtr;  // This is unsafe! We're actually pointing to a double
    
    // This might cause unexpected results or crashes in a real program
    // because we're interpreting a double value as an int
    writeln("\nDemonstrating unsafe cast (not recommended in practice):");
    writefln("  Original doubleValue = %f", doubleValue);
    writefln("  Interpreted as int = %d (meaningless result)", *backToInt);
    
    // Safe casting with proper type
    double* backToDouble = cast(double*)genericPtr;  // This is safe because genericPtr points to a double
    writefln("  Properly cast back to double* = %f", *backToDouble);
    
    writeln("\nKey takeaways:");
    writeln("1. Each pointer type is specific to the type of data it points to");
    writeln("2. All pointers have the same size regardless of what they point to");
    writeln("3. D enforces type safety for pointers");
    writeln("4. void* can point to any type but requires explicit casting to use");
    writeln("5. Incorrect casting can lead to bugs and undefined behavior");
}
