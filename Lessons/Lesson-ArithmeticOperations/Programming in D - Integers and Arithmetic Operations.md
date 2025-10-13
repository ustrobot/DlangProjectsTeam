---
created: 2025-10-10T04:28:07 (UTC +03:00)
tags: [d programming language tutorial book integer arithmetic operations]
source: https://ddili.org/ders/d.en/arithmetic.html
author: 
---
---
created: 2025-10-10T04:29:42 (UTC +03:00)
tags: [d programming language tutorial book integer arithmetic operations]
source: https://ddili.org/ders/d.en/arithmetic.html
author: 
---

# Programming in D - Integers and Arithmetic Operations

> ## Excerpt
> The integer arithmetic operations of the D language

---
#### Integers and Arithmetic Operations

We have seen that the `if` and `while` statements allow programs to make decisions by using the `bool` type in the form of logical expressions. In this chapter, we will see arithmetic operations on the _integer_ types of D. These features will allow us to write much more useful programs.

Although arithmetic operations are a part of our daily lives and are actually simple, there are very important concepts that a programmer must be aware of in order to produce correct programs: the _bit length of a type_, _overflow_ (wrap), and _truncation_.

Before going further, I would like to summarize the arithmetic operations in the following table as a reference:

| Operator | Effect | Sample |
| --- | --- | --- |
| ++ | increments by one | ++variable |
| \-- | decrements by one | \--variable |
| + | the result of adding two values | first + second |
| \- | the result of subtracting 'second' from 'first' | first - second |
| \* | the result of multiplying two values | first \* second |
| / | the result of dividing 'first' by 'second' | first / second |
| % | the remainder of dividing 'first' by 'second' | first % second |
| ^^ | the result of raising 'first' to the power of 'second'  
(multiplying 'first' by itself 'second' times) | first ^^ second |

Most of those operators have counterparts that have an `=` sign attached: `+=`, `-=`, `*=`, `/=`, `%=`, and `^^=`. The difference with these operators is that they assign the result to the left-hand side:

```
    variable += 10;
```

That expression adds the value of `variable` and 10 and assigns the result to `variable`. In the end, the value of `variable` would be increased by 10. It is the equivalent of the following expression:

```
    variable = variable + 10;
```

I would like also to summarize two important concepts here before elaborating on them below.

**Overflow:** Not all values can fit in a variable of a given type. If the value is too big for the variable we say that the variable _overflows_. For example, a variable of type `ubyte` can have values only in the range of 0 to 255; so when assigned 260, the variable overflows, wraps around, and its value becomes 4. (_**Note:** Unlike some other languages like C and C++, overflow for signed types is legal in D. It has the same wrap around behavior of unsigned types._)

Similarly, a variable cannot have a value that is less than the minimum value of its type.

**Truncation:** Integer types cannot have values with fractional parts. For example, the value of the `int` expression `3/2` is 1, not 1.5.

We encounter arithmetic operations daily without many surprises: if a bagel is $1, two bagels are $2; if four sandwiches are $15, one sandwich is $3.75, etc.

Unfortunately, things are not as simple with arithmetic operations in computers. If we don't understand how values are stored in a computer, we may be surprised to see that a company's debt is _reduced_ to $1.7 billion when it borrows $3 billion more on top of its existing debt of $3 billion! Or when a box of ice cream serves 4 kids, an arithmetic operation may claim that 2 boxes would be sufficient for 11 kids!

Programmers must understand how integers are stored in computers.

###### Integer types

Integer types are the types that can have only whole values like -2, 0, 10, etc. These types cannot have fractional parts, as in 2.5. All of the integer types that we saw in the [Fundamental Types chapter](https://ddili.org/ders/d.en/types.html) are the following:

|   
Type | Number of  
Bits | Initial  
Value |
| --- | --- | --- |
| byte | 8 | 0 |
| ubyte | 8 | 0 |
| short | 16 | 0 |
| ushort | 16 | 0 |
| int | 32 | 0 |
| uint | 32 | 0 |
| long | 64 | 0L |
| ulong | 64 | 0LU |

The `u` at the beginning of the type names stands for "unsigned" and indicates that such types cannot have values less than zero.

Although they are equal to `0`; `0L` and `0LU` are _manifest constants_ typed as `long` and `ulong`, respectively.

###### Number of bits of a type

In today's computer systems, the smallest unit of information is called a _bit_. At the physical level, a bit is represented by electrical signals around certain points in the circuitry of a computer. A bit can be in one of two states that correspond to different voltages in the area that defines that particular bit. These two states are arbitrarily defined to have the values 0 and 1. As a result, a bit can have one of these two values.

As there aren't many concepts that can be represented by just two states, a bit is not a very useful type. It can only be useful for concepts with two states like heads or tails or whether a light switch is on or off.

If we consider two bits together, the total amount of information that can be represented multiplies. Based on each bit having a value of 0 or 1 individually, there are a total of 4 possible states. Assuming that the left and right digits represent the first and second bit respectively, these states are 00, 01, 10, and 11. Let's add one more bit to see this effect better; three bits can be in 8 different states: 000, 001, 010, 011, 100, 101, 110, 111. As can be seen, each added bit doubles the total number of states that can be represented.

The values to which these eight states correspond are defined by conventions. The following table shows these values for the signed and unsigned representations of 3 bits:

| Bit State | Unsigned Value | Signed Value |
| --- | --- | --- |
| 000 | 0 | 0 |
| 001 | 1 | 1 |
| 010 | 2 | 2 |
| 011 | 3 | 3 |
| 100 | 4 | \-4 |
| 101 | 5 | \-3 |
| 110 | 6 | \-2 |
| 111 | 7 | \-1 |

We can construct the following table by adding more bits:

| Bits | Number of Distinct Values | D Type | Minimum Value | Maximum Value |
| --- | --- | --- | --- | --- |
| 1 | 2 |  |  |  |
| 2 | 4 |  |  |  |
| 3 | 8 |  |  |  |
| 4 | 16 |  |  |  |
| 5 | 32 |  |  |  |
| 6 | 64 |  |  |  |
| 7 | 128 |  |  |  |
| 8 | 256 | byte  
ubyte | \-128  
0 | 127  
255 |
| ... | ... |  |  |  |
| 16 | 65536 | short  
ushort | \-32768  
0 | 32767  
65535 |
| ... | ... |  |  |  |
| 32 | 4294967296 | int  
uint | \-2147483648  
0 | 2147483647  
4294967295 |
| ... | ... |  |  |  |
| 64 | 18446744073709551616 | long  
ulong | \-9223372036854775808  
0 | 9223372036854775807  
18446744073709551615 |
| ... | ... |  |  |  |

I skipped many rows in the table and indicated the signed and unsigned versions of the D types that have the same number of bits on the same row (e.g. `int` and `uint` are both on the 32-bit row).

###### Choosing a type

D has no 3-bit type. But such a hypothetical type could only have 8 distinct values. It could only represent concepts such as the value of a die, or the week's day number.

On the other hand, although `uint` is a very large type, it cannot represent the concept of an ID number for each living person, as its maximum value is less than the world population of 7 billion. `long` and `ulong` would be more than enough to represent many concepts.

As a general rule, as long as there is no specific reason not to, you can use `int` for integer values.

###### Overflow

The fact that types can only hold values within a limited range may cause unexpected results. For example, although adding two `uint` variables with values of 3 billion each should produce 6 billion, because that sum is greater than the maximum value that a `uint` variable can hold (about 4 billion), this sum _overflows_. Without any warning, only the difference of 6 and 4 billion gets stored. (A little more accurately, 6 minus 4.3 billion.)

###### Truncation

Since integers cannot have values with fractional parts, they lose the part after the decimal point. For example, assuming that a box of ice cream serves 4 kids, although 11 kids would actually need 2.75 boxes, the fractional part of that value cannot be stored in an integer type, so the value becomes 2.

I will show limited techniques to help reduce the risk of overflow and truncation later in the chapter.

###### `.min` and `.max`

I will take advantage of the `.min` and `.max` properties below, which we have seen in the [Fundamental Types chapter](https://ddili.org/ders/d.en/types.html). These properties provide the minimum and maximum values that an integer type can have.

###### Increment: `++`

This operator is used with a single variable (more generally, with a single expression) and is written before the name of that variable. It increments the value of that variable by 1:

```
import std.stdio;

void main() {
int number = 10;
++number;
    writeln("New value: ", number);
}
```

```
New value: 11
```

The increment operator is the equivalent of using the _add-and-assign_ operator with the value of 1:

```
    number += 1;      
```

If the result of the increment operation is greater than the maximum value of that type, the result _overflows_ and becomes the minimum value. We can see this effect by incrementing a variable that initially has the value `int.max`:

```
import std.stdio;

void main() {
    writeln("minimum int value   : ", int.min);
    writeln("maximum int value   : ", int.max);

int number = int.max;
    writeln("before the increment: ", number);
    ++number;
    writeln("after the increment : ", number);
}
```

The value becomes `int.min` after the increment:

```
minimum int value   : -2147483648
maximum int value   : 2147483647
before the increment: 2147483647
after the increment : -2147483648
```

This is a very important observation because the value changes from the maximum to the minimum as a result of _incrementing_ and without any warning! This effect is called _overflow_. We will see similar effects with other operations.

###### Decrement: `--`

This operator is similar to the increment operator; the difference is that the value is decreased by 1:

```
    --number;   
```

The decrement operation is the equivalent of using the _subtract-and-assign_ operator with the value of 1:

```
    number -= 1;      
```

Similar to the `++` operator, if the value is the minimum value to begin with, it becomes the maximum value. This effect is called _overflow_ as well.

###### Addition: +

This operator is used with two expressions and adds their values:

```
import std.stdio;

void main() {
int number_1 = 12;
int number_2 = 100;

    writeln("Result: ", number_1 + number_2);
    writeln("With a constant expression: ", 1000 + number_2);
}
```

```
Result: 112
With a constant expression: 1100
```

If the sum of the two expressions is greater than the maximum value of that type, it overflows and becomes a value that is less than both of the expressions:

```
import std.stdio;

void main() {
uint number_1 = 3000000000;
uint number_2 = 3000000000;

    writeln("maximum value of uint: ", uint.max);
    writeln("             number_1: ", number_1);
    writeln("             number_2: ", number_2);
    writeln("                  sum: ", number_1 + number_2);
    writeln("OVERFLOW! The result is not 6 billion!");
}
```

```
maximum value of uint: 4294967295
             number_1: 3000000000
             number_2: 3000000000
                  sum: 1705032704
OVERFLOW! The result is not 6 billion!
```

###### Subtraction: `-`

This operator is used with two expressions and gives the difference between the first and the second:

```
import std.stdio;

void main() {
int number_1 = 10;
int number_2 = 20;

    writeln(number_1 - number_2);
    writeln(number_2 - number_1);
}
```

```
-10
10
```

It is again surprising if the actual result is less than zero and is stored in an unsigned type. Let's rewrite the program using the `uint` type:

```
import std.stdio;

void main() {
uint number_1 = 10;
uint number_2 = 20;

    writeln("PROBLEM! uint cannot have negative values:");
    writeln(number_1 - number_2);
    writeln(number_2 - number_1);
}
```

```
PROBLEM! uint cannot have negative values:
4294967286
10
```

It is a good guideline to use signed types to represent concepts that may ever be subtracted. As long as there is no specific reason not to, you can choose `int`.

###### Multiplication: `*`

This operator multiplies the values of two expressions; the result is again subject to overflow:

```
import std.stdio;

void main() {
uint number_1 = 6;
uint number_2 = 7;

    writeln(number_1 * number_2);
}
```

```
42
```

###### Division: `/`

This operator divides the first expression by the second expression. Since integer types cannot have fractional values, the fractional part of the value is discarded. This effect is called _truncation_. As a result, the following program prints 3, not 3.5:

```
import std.stdio;

void main() {
    writeln(7 / 2);
}
```

```
3
```

For calculations where fractional parts matter, _floating point types_ must be used instead of integers. We will see floating point types in the next chapter.

###### Remainder (modulus): %

This operator divides the first expression by the second expression and produces the remainder of the division:

```
import std.stdio;

void main() {
    writeln(10 % 6);
}
```

```
4
```

A common application of this operator is to determine whether a value is odd or even. Since the remainder of dividing an even number by 2 is always 0, comparing the result against 0 is sufficient to make that distinction:

```
if ((number % 2) == 0) {
        writeln("even number");

    } else {
        writeln("odd number");
    }
```

###### Power: ^^

This operator raises the first expression to the power of the second expression. For example, raising 3 to the power of 4 is multiplying 3 by itself 4 times:

```
import std.stdio;

void main() {
    writeln(3 ^^ 4);
}
```

```
81
```

###### Arithmetic operations with assignment

All of the operators that take two expressions have _assignment_ counterparts. These operators assign the result back to the expression that is on the left-hand side:

```
import std.stdio;

void main() {
int number = 10;

    number += 20;      number -= 5;       number *= 2;       number /= 3;       number %= 7;       number ^^= 6;  
    writeln(number);
}
```

```
64
```

###### Negation: `-`

This operator converts the value of the expression from negative to positive or positive to negative:

```
import std.stdio;

void main() {
int number_1 = 1;
int number_2 = -2;

    writeln(-number_1);
    writeln(-number_2);
}
```

```
-1
2
```

The type of the result of this operation is the same as the type of the expression. Since unsigned types cannot have negative values, the result of using this operator with unsigned types can be surprising:

```
uint number = 1;
    writeln("negation: ", -number);
```

The type of `-number` is `uint` as well, which cannot have negative values:

```
negation: 4294967295
```

###### Plus sign: `+`

This operator has no effect and exists only for symmetry with the negation operator. Positive values stay positive and negative values stay negative:

```
import std.stdio;

void main() {
int number_1 = 1;
int number_2 = -2;

    writeln(+number_1);
    writeln(+number_2);
}
```

```
1
-2
```

###### Post-increment: `++`

_**Note:** Unless there is a strong reason not to, always use the regular increment operator (which is sometimes called the pre-increment operator)._

Contrary to the regular increment operator, it is written after the expression and still increments the value of the expression by 1. The difference is that the post-increment operation produces the old value of the expression. To see this difference, let's compare it with the regular increment operator:

```
import std.stdio;

void main() {
int incremented_regularly = 1;
    writeln(++incremented_regularly);          writeln(incremented_regularly);        
int post_incremented = 1;

        writeln(post_incremented++);               writeln(post_incremented);             }
```

```
2
2
1
2
```

The `writeln(post_incremented++);` statement above is the equivalent of the following code:

```
int old_value = post_incremented;
    ++post_incremented;
    writeln(old_value);                    
```

###### Post-decrement: `--`

_**Note:** Unless there is a strong reason not to, always use the regular decrement operator (which is sometimes called the pre-decrement operator)._

This operator behaves the same way as the post-increment operator except that it decrements.

###### Operator precedence

The operators we've discussed above have all been used in operations on their own with only one or two expressions. However, similar to logical expressions, it is common to combine these operators to form more complex arithmetic expressions:

```
int value = 77;
int result = (((value + 8) * 3) / (value - 1)) % 5;
```

As with logical operators, arithmetic operators also obey operator precedence rules. For example, the `*` operator has precedence over the `+` operator. For that reason, when parentheses are not used (e.g. in the `value + 8 * 3` expression), the `*` operator is evaluated before the `+` operator. As a result, that expression becomes the equivalent of `value + 24`, which is quite different from `(value + 8) * 3`.

Using parentheses is useful both for ensuring correct results and for communicating the intent of the code to programmers who may work on it in the future.

The operator precedence table will be presented [later in the book](https://ddili.org/ders/d.en/operator_precedence.html).

###### Detecting overflow

Although it uses [functions](https://ddili.org/ders/d.en/functions.html) and [`ref` parameters](https://ddili.org/ders/d.en/function_parameters.html), which we have not covered yet, I would like to mention here that [the `core.checkedint` module](http://dlang.org/phobos/core_checkedint.html) contains arithmetic functions that detect overflow. Instead of operators like `+` and `-`, this module uses functions: `adds` and `addu` for signed and unsigned addition, `muls` and `mulu` for signed and unsigned multiplication, `subs` and `subu` for signed and unsigned subtraction, and `negs` for negation.

For example, assuming that `a` and `b` are two `int` variables, the following code would detect whether adding them has caused an overflow:

```
import core.checkedint;

void main() {
int a = int.max - 1;
int b = 2;

bool hasOverflowed = false;
int result = adds(a, b, hasOverflowed);

if (hasOverflowed) {
                
    } else {
                    }
}
```

There is also [the std.experimental.checkedint](https://dlang.org/phobos/std_experimental_checkedint.html) module that defines the `Checked` template but both its usage and its implementation are too advanced at this point in the book.

###### Preventing overflow

If the result of an operation cannot fit in the type of the result, then there is nothing that can be done. Sometimes, although the ultimate result would fit in a certain type, the intermediate calculations may overflow and cause incorrect results.

As an example, let's assume that we need to plant an apple tree per 1000 square meters of an area that is 40 by 60 kilometers. How many trees are needed?

When we solve this problem on paper, we see that the result is 40000 times 60000 divided by 1000, being equal to 2.4 million trees. Let's write a program that executes this calculation:

```
import std.stdio;

void main() {
int width  = 40000;
int length = 60000;
int areaPerTree = 1000;

int treesNeeded = width * length / areaPerTree;

    writeln("Number of trees needed: ", treesNeeded);
}
```

```
Number of trees needed: -1894967
```

Not to mention it is not even close, the result is also less than zero! In this case, the intermediate calculation `width * length` overflows and the subsequent calculation of `/ areaPerTree` produces an incorrect result.

One way of avoiding the overflow in this example is to change the order of operations:

```
int treesNeeded = width / areaPerTree * length ;
```

The result would now be correct:

```
Number of trees needed: 2400000
```

The reason this method works is the fact that all of the steps of the calculation now fit the `int` type.

Please note that this is not a complete solution because this time the intermediate value is prone to truncation, which may affect the result significantly in certain other calculations. Another solution might be to use a floating point type instead of an integer type: `float`, `double`, or `real`.

###### Preventing truncation

Changing the order of operations may be a solution to truncation as well. An interesting example of truncation can be seen by dividing and multiplying a value with the same number. We would expect the result of 10/9\*9 to be 10, but it comes out as 9:

```
import std.stdio;

void main() {
    writeln(10 / 9 * 9);
}
```

```
9
```

The result is correct when truncation is avoided by changing the order of operations:

```
    writeln(10 * 9 / 9);
```

```
10
```

This too is not a complete solution: This time the intermediate calculation could be prone to overflow. Using a floating point type may be another solution to truncation in certain calculations.

##### Additional Exercises

1. **Basic Arithmetic Operations**: Write a program that declares two integer variables with values 15 and 7. Calculate and print their sum, difference, product, quotient, and remainder.

2. **Increment and Decrement**: Start with a variable `count = 5`. Use increment and decrement operators to modify its value and print the results at each step.

3. **Assignment Operators**: Start with a variable `total = 100`. Use the compound assignment operators (+=, -=, *=, /=, %=) with different values and print the result after each operation.

4. **Unary Operators**: Declare an integer variable with value 42 and another with value -17. Use the unary plus (+) and unary minus (-) operators and print the results.

5. **Even or Odd**: Write a program that checks if a given number (like 23) is even or odd using the modulus operator and prints the result.

6. **Power Operations**: Calculate 2 raised to the power of 8 and 3 raised to the power of 4 using the power operator (^^) and print the results.

7. **Integer Type Ranges**: Print the minimum and maximum values for `byte`, `ubyte`, `int`, and `uint` types using the `.min` and `.max` properties.

8. **Overflow Demonstration**: Try to add two large `uint` values that would cause overflow (like 4000000000 + 4000000000) and observe what happens.

9. **Truncation Example**: Demonstrate integer division truncation by dividing 17 by 3 and 22 by 7, showing how the fractional parts are lost.

10. **Mixed Operations**: Write an expression that uses multiple arithmetic operators in the correct order of precedence, like `(10 + 5) * 3 - 8 / 2`, and print the result.

##### Original Exercises

1.  Write a program that takes two integers from the user, prints the integer quotient resulting from the division of the first by the second, and also prints the remainder. For example, when 7 and 3 are entered, have the program print the following equation:

    ```
    7 = 3 * 2 + 1
    ```

2.  Modify the program to print a shorter output when the remainder is 0. For example, when 10 and 5 are entered, it should not print "10 = 5 \* 2 + 0" but just the following:

    ```
    10 = 5 * 2
    ```

3.  Write a simple calculator that supports the four basic arithmetic operations. Have the program let the operation to be selected from a menu and apply that operation to the two values that are entered. You can ignore overflow and truncation in this program.
4.  Write a program that prints the values from 1 to 10, each on a separate line, with the exception of value 7. Do not use repeated lines as in the following code:

    ```
import std.stdio;

void main() {
            writeln(1);
        writeln(2);
        writeln(3);
        writeln(4);
        writeln(5);
        writeln(6);
        writeln(8);
        writeln(9);
        writeln(10);
    }
    ```

    Instead, imagine a variable whose value is incremented in a loop. You may need to take advantage of the _is not equal to_ operator `!=` here.

##### Additional Advanced Exercises

1. **Binary to Decimal Converter**: Write a program that converts a 4-digit binary number (like 1101) to its decimal equivalent using arithmetic operations. Hint: Use powers of 2 and the relationship between binary positions and values.

2. **Temperature Unit Converter**: Create a program that converts Celsius to Fahrenheit using the formula F = (C × 9/5) + 32. Demonstrate how integer division might affect accuracy and implement a solution that avoids truncation issues.

3. **Digit Extractor**: Write a program that extracts and displays each digit of a 4-digit number separately. For example, for 5372, display "5 3 7 2". Use integer division and modulus operations.

4. **Arithmetic Progression Generator**: Create a program that generates the first 10 terms of an arithmetic progression given the first term (a) and common difference (d). Demonstrate how to avoid potential overflow when calculating larger terms.

5. **Time Calculator**: Write a program that converts a given number of seconds into hours, minutes, and remaining seconds. For example, 3665 seconds should be displayed as "1 hour, 1 minute, 5 seconds". Use integer division and modulus.

6. **Bit Manipulation**: Create a program that demonstrates how to set, clear, and toggle specific bits in an integer using bitwise operations. Show the results in both decimal and binary representation.

7. **Integer Division Rounding**: Write a program that implements integer division with rounding to the nearest integer (not just truncation). For example, 7/2 should give 4, while 7/3 should give 2. Hint: Add half the divisor before dividing.

8. **Factorial Calculator with Overflow Detection**: Implement a program that calculates the factorial of a number while detecting potential overflow. Show the largest factorial that can be calculated correctly for different integer types (int, long).

9. **Divisibility Checker**: Create a program that checks if a number is divisible by 2, 3, 5, and 11 using efficient divisibility rules. For divisibility by 3 and 11, implement the digit sum method.

10. **Integer Square Root**: Implement a function that calculates the integer square root of a number without using any floating-point operations. Compare your result with the built-in mathematical functions to verify accuracy.

##### Simple Practice Exercises

1. **Basic Addition**: Write a program that adds two integers (7 and 3) and prints the result.

2. **Multiple Operations**: Calculate and print the result of 5 + 10 * 2.

3. **Variable Manipulation**: Create a variable with value 10, increment it twice, then decrement it once, and print the final value.

4. **Modulus Practice**: Write a program that prints the remainder when 17 is divided by 5.

5. **Value Swapping**: Write a program that swaps the values of two integer variables without using a third variable. Use only arithmetic operations.

6. **Counting by Threes**: Print numbers from 3 to 30, counting by 3 each time (3, 6, 9, etc.).

7. **Simple Calculator**: Write a program that takes an operation (+, -, *, /) and two numbers, then performs that operation and prints the result.

8. **Celsius to Fahrenheit**: Convert 25 degrees Celsius to Fahrenheit using the formula F = C * 9/5 + 32.

9. **Sum of Digits**: Write a program that calculates the sum of digits for the number 123 (1+2+3=6).

10. **Area Calculator**: Calculate the area of a rectangle with width 5 and height 8 using multiplication.
