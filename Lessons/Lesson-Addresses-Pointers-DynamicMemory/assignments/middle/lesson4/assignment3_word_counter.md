# Assignment 4.3: Word Counter and Organizer

## Objective

Create a simple word counting and organizing tool using a basic dictionary structure. This assignment will help you understand how computers can store and organize data using key-value pairs.

## Introduction

Have you ever wondered how many times a particular word appears in a book or article? Or which words are used most frequently? In this assignment, you'll build a word counter that can analyze text and tell you exactly that! You'll learn how computers use dictionary structures to keep track of information using keys and values.

## Requirements

### 1. Create a program that processes text

Create a D program that:
- Reads text from a file or user input
- Counts word occurrences
- Organizes words alphabetically

```d
// Example starter code
import std.stdio;
import std.string;
import std.array;
import std.algorithm;
import std.conv;

void main() {
    writeln("=== Word Counter and Organizer ===\n");
    
    // Sample text (you can replace this with file reading code)
    string text = "This is a sample text. This text contains some words that repeat. " ~
                  "The word counter should count how many times each word appears in the text. " ~
                  "Some words will appear more than others in this sample text.";
    
    writeln("Text to analyze:");
    writeln(text);
    writeln();
    
    // TODO: Process the text and count words
    int[string] wordCounts = countWords(text);
    
    // TODO: Display word counts
    displayWordCounts(wordCounts);
    
    // TODO: Display words alphabetically
    displayAlphabetically(wordCounts);
    
    // TODO: Display most/least common words
    displayByFrequency(wordCounts);
}

// TODO: Implement function to count words
int[string] countWords(string text) {
    // Your code here
}

// TODO: Implement function to display word counts
void displayWordCounts(int[string] wordCounts) {
    // Your code here
}

// TODO: Implement function to display words alphabetically
void displayAlphabetically(int[string] wordCounts) {
    // Your code here
}

// TODO: Implement function to display words by frequency
void displayByFrequency(int[string] wordCounts) {
    // Your code here
}
```

### 2. Implement a simple dictionary structure

Use D's associative array to:
- Store word-count pairs
- Allow looking up counts by word
- Sort words by frequency

### 3. Create visualizations of the results

Generate visual representations of the data:
- Word frequency chart
- Alphabetical listing
- Most/least common words

## Step-by-Step Guide

1. **Process the text**
   - Split the text into individual words
   - Clean up the words (remove punctuation, convert to lowercase)
   - Count occurrences of each word

2. **Store the results in a dictionary**
   - Use an associative array to store word-count pairs
   - Implement functions to access and manipulate the data

3. **Create different views of the data**
   - Implement a function to display words alphabetically
   - Implement a function to display words by frequency
   - Create simple visualizations of the results

4. **Add analysis features**
   - Calculate statistics like total words, unique words, etc.
   - Find the most and least common words
   - Generate a simple report with the findings

## Example Output

Your program should produce output similar to this:

```
=== Word Counter and Organizer ===

Text to analyze:
This is a sample text. This text contains some words that repeat. The word counter should count how many times each word appears in the text. Some words will appear more than others in this sample text.

Word Count Results:
Total words: 35
Unique words: 23

Word Counts:
a: 1
appears: 1
contains: 1
count: 1
counter: 1
each: 1
how: 1
in: 1
is: 1
more: 1
others: 1
repeat: 1
sample: 2
should: 1
some: 2
text: 3
than: 1
that: 1
the: 2
this: 2
times: 1
will: 1
word: 2
words: 3

Words by Frequency:
[Chart: each * represents one occurrence]
text:   ***
words:  ***
sample: **
some:   **
the:    **
this:   **
word:   **
a:      *
appears: *
...

Most Common Words:
1. text (3 occurrences)
2. words (3 occurrences)
3. sample (2 occurrences)
4. some (2 occurrences)
5. the (2 occurrences)

Least Common Words:
(19 words with 1 occurrence each)
```

## Learning Outcomes

After completing this assignment, you will understand:
- How dictionary (key-value) data structures work
- How to process and analyze text data
- How to organize and visualize data in different ways
- Basic concepts of data analysis and reporting

## Extension Activities

If you finish early, try these additional challenges:

1. Add the ability to read text from a file
2. Create a more sophisticated text visualization (word cloud)
3. Add the ability to compare two different texts
4. Implement a simple search function to find all sentences containing a specific word

## Submission Guidelines

Submit your D source code file with:
- Well-commented code explaining what each part does
- All required functionality implemented
- Clear visualizations of the word count results

## Grading Criteria

- **Correctness**: Does your code correctly count and organize words?
- **Understanding**: Do you demonstrate understanding of dictionary structures?
- **Visualization**: Are your data visualizations clear and informative?
- **Code Quality**: Is your code well-organized and properly commented?
