# Detailed Lesson Plans with Code Examples

This document provides detailed breakdowns, code examples, and exercises for each lesson in the OOP with D and dlangui course.

---

## LESSON 1 - DETAILED BREAKDOWN

### Part 1: D Language Basics and Setup

#### Slide 1: Welcome and Course Overview (5 min)
- Course objectives
- What we'll build
- Why OOP matters
- Why dlangui is great for learning

#### Slide 2: D Language Introduction (10 min)
```d
// D language features that make it great:
// 1. Strong typing
// 2. Modern syntax
// 3. Great performance
// 4. Excellent GUI libraries

import std.stdio;    // Import standard I/O
import std.string;   // Import string utilities

void main() {
    // Variables
    string name = "Student";
    int age = 20;
    
    // Output
    writeln("Hello, ", name);
    writefln("You are %d years old", age);
    
    // Arrays
    int[] numbers = [1, 2, 3, 4, 5];
    
    // foreach loop
    foreach(num; numbers) {
        writeln(num);
    }
}
```

#### Slide 3: DUB Package Manager (10 min)
```bash
# Initialize new project
dub init myproject dlangui

# Build project
dub build

# Run project
dub run

# Add dependency
dub add packagename
```

**dub.json structure:**
```json
{
    "name": "myproject",
    "description": "My first dlangui project",
    "authors": ["Student Name"],
    "dependencies": {
        "dlangui": "~>0.10.0"
    },
    "stringImportPaths": ["views"]
}
```

#### Slide 4: Project Structure (5 min)
```
myproject/
├── dub.json          # Project configuration
├── source/
│   └── app.d        # Main application file
└── views/           # Resources (optional)
    └── res/
```

#### Demo: Live Coding (10 min)
1. Open terminal
2. Create new project: `dub init lesson1 dlangui`
3. Show generated files
4. Modify app.d
5. Build and run

### Part 2: Creating First GUI Window

#### Code Example 1: Minimal Window
```d
// source/app.d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // Create window
    Window window = Platform.instance.createWindow(
        "My First GUI",  // Window title
        null             // Parent window (null for main)
    );
    
    // Create a simple button
    Button button = new Button();
    button.text = "Hello, World!"d;  // 'd' suffix for dstring (UTF-32)
    
    // Set button as window content
    window.mainWidget = button;
    
    // Show window
    window.show();
    
    // Run event loop
    return Platform.instance.enterMessageLoop();
}
```

#### Code Example 2: Button with Properties
```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow(
        "Lesson 1 - Properties",
        null
    );
    
    // Create button with properties
    auto button = new Button();
    button.text = "Click Me!"d;
    button.margins = Rect(20, 20, 20, 20);  // left, top, right, bottom
    button.padding = Rect(10, 10, 10, 10);
    button.textColor = 0xFF0000;  // Red (0xAARRGGBB format)
    button.fontSize = 24;
    
    window.mainWidget = button;
    window.show();
    
    return Platform.instance.enterMessageLoop();
}
```

#### Code Example 3: Method Chaining
```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Method Chaining", null);
    
    // Chained property calls
    window.mainWidget = (new Button())
        .text("Styled Button"d)
        .margins(Rect(20, 20, 20, 20))
        .textColor(0x0000FF)  // Blue
        .fontSize(20)
        .backgroundColor(0xFFFFCC);  // Light yellow
    
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

#### Student Exercise 1 (20 min):
**Task:** Create a window with a button that has:
- Text: "My First Button"
- Margins: 30 pixels on all sides
- Text color: Green (0x00FF00)
- Font size: 18
- Background color: Light blue (0xCCCCFF)
- Window title: "Student Name - Lesson 1"

**Expected Output:** Compiled and running application with styled button

#### Student Exercise 2 (20 min):
**Task:** Experiment and answer:
1. What happens if you change margins to Rect(10, 20, 30, 40)?
2. Try different color values
3. What happens if you remove `.show()`?
4. What does the 'd' suffix on strings mean?
5. Change window size by adding width and height parameters

**Bonus Challenge:** 
Add window size parameters and make the window 400x300 pixels

---

## LESSON 2 - DETAILED BREAKDOWN

### Part 1: Classes Fundamentals

#### Slide 1: What is a Class? (10 min)

**Analogy:** A class is like a blueprint for a house
- Blueprint (Class) → Actual House (Object)
- One blueprint → Many houses
- Each house has same structure but different data

```d
// Class definition - the blueprint
class Dog {
    // Properties (data)
    string name;
    int age;
    string breed;
    
    // Constructor - how to create the object
    this(string name, int age, string breed) {
        this.name = name;
        this.age = age;
        this.breed = breed;
    }
}

// Creating objects (instances)
void main() {
    // Each object is independent
    Dog dog1 = new Dog("Max", 3, "Labrador");
    Dog dog2 = new Dog("Bella", 5, "Poodle");
    
    writeln(dog1.name);  // Max
    writeln(dog2.name);  // Bella
}
```

#### Slide 2: Classes in Memory (10 min)

```d
import std.stdio;

class Point {
    int x;
    int y;
    
    this(int x, int y) {
        this.x = x;
        this.y = y;
    }
}

void main() {
    Point p1 = new Point(10, 20);
    Point p2 = p1;  // Both reference same object!
    
    p2.x = 30;
    
    writeln(p1.x);  // 30 (not 10!)
    // p1 and p2 point to the same object in memory
}
```

**Key Concept:** Classes are reference types in D

#### Slide 3: Widget as a Class Example (10 min)

```d
// Simplified view of Widget class in dlangui
class Widget {
    // Properties
    string id;
    dstring text;
    uint textColor;
    uint backgroundColor;
    
    // Constructor
    this(string id = null) {
        this.id = id;
    }
    
    // Methods
    Widget text(dstring value) {
        this.text = value;
        return this;  // Return 'this' enables chaining
    }
    
    Widget textColor(uint color) {
        this.textColor = color;
        return this;
    }
}
```

#### Demo: Custom Class (10 min)

```d
import std.stdio;

class Student {
    string name;
    int studentId;
    double gpa;
    
    // Constructor
    this(string name, int id) {
        this.name = name;
        this.studentId = id;
        this.gpa = 0.0;
    }
    
    // Method
    void setGPA(double gpa) {
        if (gpa >= 0.0 && gpa <= 4.0) {
            this.gpa = gpa;
        }
    }
    
    // Method
    void printInfo() {
        writefln("Student: %s (ID: %d), GPA: %.2f", 
                 name, studentId, gpa);
    }
}

void main() {
    auto student = new Student("Alice", 12345);
    student.setGPA(3.8);
    student.printInfo();
}
```

### Part 2: Widget Classes and Properties

#### Code Example 1: Multiple Widgets

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Multiple Widgets", null);
    
    // Create multiple TextWidget objects
    TextWidget text1 = new TextWidget("text1");
    text1.text = "First Text Widget"d;
    text1.textColor = 0xFF0000;  // Red
    
    TextWidget text2 = new TextWidget("text2");
    text2.text = "Second Text Widget"d;
    text2.textColor = 0x0000FF;  // Blue
    
    TextWidget text3 = new TextWidget("text3");
    text3.text = "Third Text Widget"d;
    text3.textColor = 0x00FF00;  // Green
    
    // Problem: Window can only have one mainWidget!
    // Solution: We need a container (next lesson)
    // For now, we'll use just one
    window.mainWidget = text1;
    
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

#### Code Example 2: Widget Properties Showcase

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Widget Properties", null);
    
    // Create widget with comprehensive properties
    auto widget = new TextWidget();
    
    // Text properties
    widget.text = "Styled Text Widget"d;
    widget.textColor = 0x0000FF;        // Blue text
    widget.fontSize = 24;               // 24pt font
    
    // Layout properties
    widget.margins = Rect(20, 20, 20, 20);
    widget.padding = Rect(15, 15, 15, 15);
    
    // Appearance properties
    widget.backgroundColor = 0xFFFFCC;  // Light yellow background
    
    // Alignment
    widget.alignment = Align.Center;
    
    window.mainWidget = widget;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

#### Code Example 3: Property Chaining

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Chaining Demo", null);
    
    // Method 1: Setting properties one by one
    auto button1 = new Button("btn1");
    button1.text = "Button 1"d;
    button1.textColor = 0xFF0000;
    button1.margins = Rect(10, 10, 10, 10);
    
    // Method 2: Chained calls (more concise)
    auto button2 = (new Button("btn2"))
        .text("Button 2"d)
        .textColor(0x0000FF)
        .margins(Rect(10, 10, 10, 10))
        .fontSize(18);
    
    // Both do the same thing!
    window.mainWidget = button2;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

#### Student Exercise 1 (15 min):
**Task:** Create a Person class
```d
import std.stdio;

class Person {
    // TODO: Add properties: name (string), age (int), email (string)
    
    // TODO: Add constructor that takes name and age
    
    // TODO: Add method printInfo() that displays person details
}

void main() {
    // Create 3 different Person objects
    // Set their properties
    // Call printInfo on each
}
```

#### Student Exercise 2 (25 min):
**Task:** Create a window with TextWidget displaying your information

Requirements:
1. Create TextWidget with your name
2. Set text color to your favorite color
3. Set font size to 20
4. Add margins of 25 pixels
5. Add padding of 10 pixels
6. Set background color
7. Center align the text
8. Use method chaining for all properties

**Bonus:** Try creating multiple TextWidget objects and observe why you can only show one (foreshadowing next lesson on layouts)

---

## LESSON 3 - DETAILED BREAKDOWN

### Part 1: Understanding Layouts

#### Slide 1: The Layout Problem (5 min)

**Problem:**
```d
// This doesn't work!
window.mainWidget = widget1;
window.mainWidget = widget2;  // Replaces widget1!
```

**Solution:** Use layout containers

#### Slide 2: VerticalLayout Concept (10 min)

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Vertical Layout", null);
    
    // Create a vertical layout container
    VerticalLayout layout = new VerticalLayout();
    
    // Add children to layout
    layout.addChild(new TextWidget(null, "First"d));
    layout.addChild(new TextWidget(null, "Second"d));
    layout.addChild(new TextWidget(null, "Third"d));
    
    // Layout is the main widget
    window.mainWidget = layout;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

**Output:**
```
┌─────────┐
│ First   │
│ Second  │
│ Third   │
└─────────┘
```

#### Slide 3: HorizontalLayout Concept (10 min)

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Horizontal Layout", null);
    
    // Create a horizontal layout container
    HorizontalLayout layout = new HorizontalLayout();
    
    // Add children to layout
    layout.addChild(new Button(null, "One"d));
    layout.addChild(new Button(null, "Two"d));
    layout.addChild(new Button(null, "Three"d));
    
    window.mainWidget = layout;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

**Output:**
```
┌────────────────────────┐
│ [One] [Two] [Three]    │
└────────────────────────┘
```

#### Slide 4: Layout Properties (15 min)

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Layout Properties", null);
    
    auto layout = new VerticalLayout();
    
    // Layout properties
    layout.margins = Rect(10, 10, 10, 10);   // Outside spacing
    layout.padding = Rect(5, 5, 5, 5);       // Inside spacing
    layout.backgroundColor = 0xCCCCFF;        // Light blue
    
    // Add styled widgets
    auto text1 = (new TextWidget())
        .text("Widget 1"d)
        .margins(Rect(5, 5, 5, 5))
        .backgroundColor(0xFFCCCC);  // Light red
        
    auto text2 = (new TextWidget())
        .text("Widget 2"d)
        .margins(Rect(5, 5, 5, 5))
        .backgroundColor(0xCCFFCC);  // Light green
        
    layout.addChild(text1);
    layout.addChild(text2);
    
    window.mainWidget = layout;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

### Part 2: Building Complex Layouts

#### Code Example 1: Nested Layouts

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Nested Layouts", null);
    
    // Main vertical layout
    auto mainLayout = new VerticalLayout();
    mainLayout.margins = Rect(10, 10, 10, 10);
    
    // Add title
    mainLayout.addChild((new TextWidget())
        .text("My Application"d)
        .fontSize(24)
        .alignment(Align.Center));
    
    // Horizontal layout for buttons
    auto buttonRow = new HorizontalLayout();
    buttonRow.addChild(new Button(null, "Save"d));
    buttonRow.addChild(new Button(null, "Load"d));
    buttonRow.addChild(new Button(null, "Delete"d));
    
    // Add button row to main layout
    mainLayout.addChild(buttonRow);
    
    window.mainWidget = mainLayout;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

#### Code Example 2: TableLayout for Forms

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Form Layout", null);
    
    // Table layout with 2 columns
    auto layout = new TableLayout();
    layout.colCount = 2;  // Important!
    layout.margins = Rect(20, 20, 20, 20);
    layout.padding = Rect(10, 10, 10, 10);
    
    // Add label and input pairs
    // Row 1
    layout.addChild(new TextWidget(null, "Name:"d));
    layout.addChild(new EditLine(null, ""d));
    
    // Row 2
    layout.addChild(new TextWidget(null, "Email:"d));
    layout.addChild(new EditLine(null, ""d));
    
    // Row 3
    layout.addChild(new TextWidget(null, "Age:"d));
    layout.addChild(new EditLine(null, ""d));
    
    window.mainWidget = layout;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

#### Code Example 3: Login Form (Complete)

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Login Form", null);
    
    // Main vertical layout
    auto mainLayout = new VerticalLayout();
    mainLayout.margins = Rect(20, 20, 20, 20);
    mainLayout.padding = Rect(15, 15, 15, 15);
    mainLayout.backgroundColor = 0xF0F0F0;
    
    // Title
    auto title = (new TextWidget())
        .text("Login"d)
        .fontSize(28)
        .alignment(Align.Center)
        .textColor(0x333333);
    mainLayout.addChild(title);
    
    // Form (TableLayout)
    auto form = new TableLayout();
    form.colCount = 2;
    form.margins = Rect(0, 20, 0, 20);
    
    // Username row
    form.addChild(new TextWidget(null, "Username:"d));
    auto usernameEdit = new EditLine("username", ""d);
    usernameEdit.layoutWidth = FILL_PARENT;
    form.addChild(usernameEdit);
    
    // Password row
    form.addChild(new TextWidget(null, "Password:"d));
    auto passwordEdit = new EditLine("password", ""d);
    passwordEdit.layoutWidth = FILL_PARENT;
    form.addChild(passwordEdit);
    
    mainLayout.addChild(form);
    
    // Button row
    auto buttonRow = new HorizontalLayout();
    buttonRow.addChild(new Button("btnLogin", "Login"d));
    buttonRow.addChild(new Button("btnCancel", "Cancel"d));
    
    mainLayout.addChild(buttonRow);
    
    window.mainWidget = mainLayout;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

#### Student Exercise 1 (20 min):
**Task:** Create a "Contact Information Form"

Requirements:
- Use TableLayout with 2 columns
- Fields: First Name, Last Name, Phone, Email, Address
- Each field should have a label and EditLine
- Add margins and padding
- Style with colors
- Add a title at the top

#### Student Exercise 2 (20 min):
**Task:** Create a "Calculator Layout"

Requirements:
- Create button layout for calculator (4x4 grid)
- Numbers 0-9, operators (+, -, *, /)
- Display area at top (use TextWidget or EditLine)
- Use nested layouts
- Make it look nice with colors

**Hint:** Use HorizontalLayouts inside a VerticalLayout

---

## LESSON 4 - DETAILED BREAKDOWN

### Part 1: Access Modifiers and Properties

#### Slide 1: Encapsulation Concept (10 min)

**Bad Example:**
```d
class BankAccount {
    double balance;  // Public - anyone can modify!
}

void main() {
    auto account = new BankAccount();
    account.balance = 1000000;  // Cheat!
    account.balance = -500;     // Invalid!
}
```

**Good Example:**
```d
class BankAccount {
    private double _balance;  // Protected from direct access
    
    // Getter
    @property double balance() const {
        return _balance;
    }
    
    // Controlled modification
    void deposit(double amount) {
        if (amount > 0) {
            _balance += amount;
        }
    }
    
    void withdraw(double amount) {
        if (amount > 0 && amount <= _balance) {
            _balance -= amount;
        }
    }
}
```

#### Slide 2: Access Modifiers in D (10 min)

```d
class MyClass {
    public int publicVar;        // Accessible everywhere
    private int privateVar;      // Only within this class
    protected int protectedVar;  // This class and derived classes
    package int packageVar;      // Within same package
    
    private void privateMethod() {
        // Only callable from within this class
    }
    
    public void publicMethod() {
        // Callable from anywhere
        privateMethod();  // OK - we're inside the class
    }
}

void main() {
    auto obj = new MyClass();
    obj.publicVar = 10;     // OK
    // obj.privateVar = 20;  // ERROR!
}
```

#### Slide 3: Properties with @property (10 min)

```d
class Person {
    private string _name;
    private int _age;
    
    // Property getter
    @property string name() const {
        return _name;
    }
    
    // Property setter with validation
    @property void name(string value) {
        if (value.length > 0) {
            _name = value;
        }
    }
    
    // Read-only property (no setter)
    @property int age() const {
        return _age;
    }
    
    // Controlled age modification
    void celebrateBirthday() {
        _age++;
    }
}

void main() {
    auto person = new Person();
    person.name = "Alice";        // Calls name setter
    writeln(person.name);         // Calls name getter
    // person.age = 25;            // ERROR - no setter!
    person.celebrateBirthday();   // OK - controlled
}
```

#### Demo: Temperature Class (10 min)

```d
import std.stdio;

class Temperature {
    private double _celsius;
    
    // Celsius property
    @property double celsius() const {
        return _celsius;
    }
    
    @property void celsius(double value) {
        if (value >= -273.15) {  // Absolute zero
            _celsius = value;
        }
    }
    
    // Calculated property - Fahrenheit
    @property double fahrenheit() const {
        return _celsius * 9.0 / 5.0 + 32.0;
    }
    
    @property void fahrenheit(double value) {
        celsius = (value - 32.0) * 5.0 / 9.0;
    }
}

void main() {
    auto temp = new Temperature();
    temp.celsius = 100;
    writefln("%.1f°C = %.1f°F", temp.celsius, temp.fahrenheit);
    
    temp.fahrenheit = 32;
    writefln("%.1f°F = %.1f°C", temp.fahrenheit, temp.celsius);
}
```

### Part 2: Creating Custom Widget Class

#### Code Example 1: Simple Custom Widget

```d
import dlangui;

// Custom widget combining label and edit line
class LabeledEditLine : HorizontalLayout {
    private TextWidget _label;
    private EditLine _editLine;
    
    this(string id, dstring labelText) {
        super(id);
        
        // Create private widgets
        _label = new TextWidget();
        _label.text = labelText;
        _label.minWidth = 100;
        
        _editLine = new EditLine();
        _editLine.layoutWidth = FILL_PARENT;
        
        // Add to layout
        addChild(_label);
        addChild(_editLine);
    }
    
    // Public interface
    @property dstring value() const {
        return _editLine.text;
    }
    
    @property void value(dstring text) {
        _editLine.text = text;
    }
    
    @property dstring label() const {
        return _label.text;
    }
    
    @property void label(dstring text) {
        _label.text = text;
    }
}

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Custom Widget", null);
    
    auto layout = new VerticalLayout();
    layout.margins = Rect(20, 20, 20, 20);
    
    // Use custom widget
    auto nameField = new LabeledEditLine("name", "Name:"d);
    auto emailField = new LabeledEditLine("email", "Email:"d);
    
    layout.addChild(nameField);
    layout.addChild(emailField);
    
    // Can set values through properties
    nameField.value = "John Doe"d;
    emailField.value = "john@example.com"d;
    
    window.mainWidget = layout;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

#### Code Example 2: NumberBox with Validation

```d
import dlangui;
import std.conv;
import std.exception;

class NumberBox : VerticalLayout {
    private TextWidget _label;
    private EditLine _editLine;
    private int _value;
    private int _minValue;
    private int _maxValue;
    
    this(string id, dstring labelText, int minVal = 0, int maxVal = 100) {
        super(id);
        _minValue = minVal;
        _maxValue = maxVal;
        _value = minVal;
        
        _label = new TextWidget();
        _label.text = labelText;
        
        _editLine = new EditLine();
        _editLine.text = to!dstring(_value);
        
        addChild(_label);
        addChild(_editLine);
    }
    
    @property int value() {
        try {
            int val = to!int(_editLine.text);
            if (val >= _minValue && val <= _maxValue) {
                _value = val;
            }
        } catch (Exception e) {
            // Invalid input - keep old value
        }
        return _value;
    }
    
    @property void value(int val) {
        if (val >= _minValue && val <= _maxValue) {
            _value = val;
            _editLine.text = to!dstring(val);
        }
    }
}
```

#### Student Exercise 1 (20 min):
**Task:** Create a `Rectangle` class with encapsulation

```d
import std.stdio;

class Rectangle {
    // TODO: Add private fields _width and _height
    
    // TODO: Add constructor
    
    // TODO: Add properties for width and height with validation (> 0)
    
    // TODO: Add read-only properties for area and perimeter
}

void main() {
    auto rect = new Rectangle();
    rect.width = 10;
    rect.height = 5;
    writeln("Area: ", rect.area);
    writeln("Perimeter: ", rect.perimeter);
}
```

#### Student Exercise 2 (20 min):
**Task:** Create custom `LabeledCheckBox` widget

Requirements:
- Inherit from HorizontalLayout
- Private CheckBox and TextWidget
- Constructor takes id and label text
- Property for checked state
- Property to change label
- Use in a settings form

---

## Additional Lessons Continue...

*Due to length constraints, this document covers detailed breakdowns for Lessons 1-4. The same level of detail should be applied to remaining lessons (5-20), following the structure outlined in COURSE_PLAN.md*

---

## Teaching Tips for All Lessons

### Code Organization Best Practices:
```d
// 1. Imports at top
import dlangui;
import std.stdio;

// 2. Constants
const int MAX_VALUE = 100;

// 3. Classes
class MyWidget : VerticalLayout {
    // Private members first
    private int _value;
    
    // Constructor
    this(string id) {
        super(id);
    }
    
    // Properties
    @property int value() const { return _value; }
    
    // Public methods
    void doSomething() { }
    
    // Private methods last
    private void helper() { }
}

// 4. Main entry point
mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // Application code
}
```

### Common Student Mistakes and Solutions:

1. **Forgetting 'd' suffix on strings**
   ```d
   widget.text = "Hello";   // ERROR
   widget.text = "Hello"d;  // CORRECT
   ```

2. **Not calling show() on window**
   ```d
   Window window = Platform.instance.createWindow("Title", null);
   window.mainWidget = widget;
   // window.show();  // FORGOT THIS!
   return Platform.instance.enterMessageLoop();
   ```

3. **Incorrect color format**
   ```d
   textColor = #FF0000;      // ERROR
   textColor = "FF0000";     // ERROR
   textColor = 0xFF0000;     // CORRECT
   ```

4. **Margins vs Padding confusion**
   ```
   Margins: Space OUTSIDE widget (between widgets)
   Padding: Space INSIDE widget (around content)
   ```

### Debugging Tips:

1. **Use Log.d for debugging**
   ```d
   import dlangui;
   
   Log.d("Debug message: ", value);
   ```

2. **Check widget tree**
   ```d
   // Print widget hierarchy
   window.mainWidget.dump();
   ```

3. **Verify widget creation**
   ```d
   auto widget = new Button();
   Log.d("Widget created: ", widget !is null);
   ```

---

## Assessment Rubrics

### Weekly Exercises (10 points each):
- **Compiles without errors (3 pts)**
- **Meets requirements (4 pts)**
- **Code organization (1 pt)**
- **Comments and readability (1 pt)**
- **Creativity/extras (1 pt)**

### Final Project (100 points):
- **Architecture (20 pts)**
  - Class design
  - OOP principles applied
  - Code organization
  
- **Functionality (30 pts)**
  - All features work
  - No crashes
  - Error handling
  
- **User Interface (20 pts)**
  - Layout quality
  - Visual appeal
  - Usability
  
- **Code Quality (20 pts)**
  - Readability
  - Comments
  - Best practices
  
- **Presentation (10 pts)**
  - Demonstrates understanding
  - Explains design decisions

---

**Note:** Each lesson should include live coding demonstrations, student pair programming opportunities, and code review sessions to reinforce learning.


