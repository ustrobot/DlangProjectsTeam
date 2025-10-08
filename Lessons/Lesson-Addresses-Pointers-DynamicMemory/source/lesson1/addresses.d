/**
 * Lesson 1: Addresses and Pointer Fundamentals
 * Example: Memory Addresses
 *
 * This example demonstrates how to access and print memory addresses of variables.
 */
module lesson1.addresses;

import std.stdio;
import std.format;

void runExample() {
    writeln("=== Memory Addresses Example ===\n");
    
    // Declare variables of different types
    int integerVar = 42;
    double doubleVar = 3.14;
    char charVar = 'A';
    bool boolVar = true;
    int[5] arrayVar = [1, 2, 3, 4, 5];
    
    // Print the addresses of these variables
    writeln("Variable addresses in memory:");
    writefln("  integerVar: %s (value: %s)", &integerVar, integerVar);
    writefln("  doubleVar:  %s (value: %s)", &doubleVar, doubleVar);
    writefln("  charVar:    %s (value: %s)", &charVar, charVar);
    writefln("  boolVar:    %s (value: %s)", &boolVar, boolVar);
    writefln("  arrayVar:   %s (first element: %s)", &arrayVar, arrayVar[0]);
    
    // Demonstrate that local variables in different function calls
    // get different addresses
    writeln("\nCalling function multiple times shows different addresses for local variables:");
    demonstrateLocalAddresses();
    demonstrateLocalAddresses();
    
    // Show that variables of the same type have the same size
    writeln("\nSize of different variables in bytes:");
    writefln("  Size of int:    %d bytes", int.sizeof);
    writefln("  Size of double: %d bytes", double.sizeof);
    writefln("  Size of char:   %d bytes", char.sizeof);
    writefln("  Size of bool:   %d bytes", bool.sizeof);
    writefln("  Size of int[5]: %d bytes", (int[5]).sizeof);
    
    writeln("\nKey takeaways:");
    writeln("1. Every variable has a unique address in memory");
    writeln("2. The & operator returns the memory address of a variable");
    writeln("3. Local variables in function calls get new addresses each time");
    writeln("4. The size of a variable depends on its data type");
}

void demonstrateLocalAddresses() {
    int localVar = 10;
    writefln("  localVar address: %s", &localVar);
}
