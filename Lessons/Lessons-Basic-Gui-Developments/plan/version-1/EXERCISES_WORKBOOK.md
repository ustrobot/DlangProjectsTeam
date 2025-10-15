# Student Exercises Workbook
## OOP with D Language and dlangui Framework

This workbook contains all practical exercises for students to complete during and between lessons.

---

## Table of Contents

- [Lesson 1: First GUI Application](#lesson-1-exercises)
- [Lesson 2: Classes and Objects](#lesson-2-exercises)
- [Lesson 3: Layouts](#lesson-3-exercises)
- [Lesson 4: Encapsulation](#lesson-4-exercises)
- [Lesson 5: Methods and Behaviors](#lesson-5-exercises)
- [Lesson 6: Inheritance](#lesson-6-exercises)
- [Lesson 7-8: Polymorphism](#lesson-7-8-exercises)
- [Lesson 9: Interfaces](#lesson-9-exercises)
- [Lesson 10: Composition](#lesson-10-exercises)
- [Lesson 11: DML](#lesson-11-exercises)
- [Lesson 12: Styling](#lesson-12-exercises)
- [Lesson 13: Resources](#lesson-13-exercises)
- [Lesson 14: Events](#lesson-14-exercises)
- [Lesson 15: Lists](#lesson-15-exercises)
- [Lesson 16: Grids](#lesson-16-exercises)
- [Lesson 17: Trees](#lesson-17-exercises)
- [Lesson 18: Dialogs](#lesson-18-exercises)
- [Lesson 19: Templates](#lesson-19-exercises)
- [Lesson 20: Final Project](#lesson-20-final-project)
- [Bonus Projects](#bonus-projects)

---

## LESSON 1 EXERCISES

### Exercise 1.1: Your First Window (Easy)
**Time:** 15 minutes

Create a dlangui application that displays a window with a button.

**Requirements:**
- Window title: "Exercise 1.1 - [Your Name]"
- Button text: "My First Button"
- Margins: 25 pixels on all sides
- Text color: Blue (0x0000FF)
- Font size: 20

**Starter Code:**
```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // TODO: Create window
    // TODO: Create button with properties
    // TODO: Set button as window content
    // TODO: Show window and enter message loop
}
```

**Expected Output:** A window with a blue "My First Button" button centered with margins.

### Exercise 1.2: Experimenting with Properties (Medium)
**Time:** 20 minutes

Create an application with a styled text widget.

**Requirements:**
1. TextWidget with your name
2. Font size: 28
3. Text color: Your choice (try different colors)
4. Background color: Light color of your choice
5. Margins: 30 pixels
6. Padding: 20 pixels
7. Center alignment

**Challenge Questions:**
- What happens when you use very large margins?
- Try Rect(10, 20, 30, 40) for margins - what does each number control?
- What's the difference between margins and padding?

**Deliverable:** Screenshot and code

### Exercise 1.3: Window Sizes (Easy)
**Time:** 10 minutes

Create windows with specific sizes.

**Requirements:**
- Create 3 different windows (one per run, comment out others)
- Window 1: 400x300 pixels
- Window 2: 800x600 pixels
- Window 3: Let dlangui auto-size it

**Code Hint:**
```d
Window window = Platform.instance.createWindow(
    "Title",
    null,
    WindowFlag.Resizable,
    400,  // width
    300   // height
);
```

**Questions to Answer:**
1. What happens if you make the window very small?
2. Can you resize the windows?
3. What does WindowFlag.Resizable do?

### Homework 1: Button Showcase
**Time:** 30 minutes

Create an application showcasing different button styles.

**Requirements:**
- Create buttons with:
  - Different text
  - Different colors
  - Different sizes
  - Different margins
- Try to make each button unique
- Add comments explaining each property

**Bonus:** Find the minimum and maximum reasonable font sizes.

---

## LESSON 2 EXERCISES

### Exercise 2.1: Person Class (Easy)
**Time:** 15 minutes

Create a Person class and use it.

**Requirements:**
```d
import std.stdio;

class Person {
    // TODO: Add properties: name, age, occupation
    
    // TODO: Add constructor
    
    // TODO: Add method printInfo() to display all information
    
    // TODO: Add method celebrateBirthday() to increment age
}

void main() {
    // TODO: Create 3 Person objects
    // TODO: Print their information
    // TODO: Make them celebrate birthdays
    // TODO: Print information again
}
```

**Expected Output:**
```
Name: Alice, Age: 25, Occupation: Engineer
Name: Bob, Age: 30, Occupation: Teacher
Name: Carol, Age: 22, Occupation: Student

After birthdays:
Name: Alice, Age: 26, Occupation: Engineer
...
```

### Exercise 2.2: Car Class (Medium)
**Time:** 20 minutes

Create a Car class with properties and methods.

**Requirements:**
- Properties: make, model, year, mileage
- Constructor taking make, model, and year
- Method: drive(miles) - increases mileage
- Method: printInfo() - displays car information
- Method: getAge() - returns car age based on current year (2025)

**Test Code:**
```d
void main() {
    auto car = new Car("Toyota", "Camry", 2020);
    car.printInfo();
    car.drive(150);
    car.printInfo();
    writeln("Car age: ", car.getAge(), " years");
}
```

### Exercise 2.3: Three TextWidgets (Easy)
**Time:** 15 minutes

Display multiple TextWidgets (even though only one shows).

**Requirements:**
- Create 3 TextWidget objects
- Each with different text, color, and size
- Try displaying each one
- Document what happens (for next lesson!)

### Exercise 2.4: Styled Button Collection (Medium)
**Time:** 20 minutes

Create multiple button objects with different styles.

**Requirements:**
- Create 5 different Button objects
- Store them in an array: `Button[] buttons`
- Each button should have unique:
  - Text
  - Text color
  - Background color
  - Font size
- Use method chaining for styling

**Code Structure:**
```d
Button[] buttons;
buttons ~= (new Button()).text("Button 1"d).textColor(0xFF0000)...;
buttons ~= (new Button()).text("Button 2"d).textColor(0x00FF00)...;
// etc.
```

**Note:** You can't display them all yet, but you're learning object creation!

### Homework 2: BankAccount Class
**Time:** 45 minutes

Create a BankAccount class with proper encapsulation (even though we haven't covered it yet - challenge yourself!).

**Requirements:**
- Properties: accountNumber, holderName, balance
- Constructor: takes accountNumber and holderName (balance starts at 0)
- Methods:
  - deposit(amount) - adds money
  - withdraw(amount) - removes money (check sufficient funds!)
  - getBalance() - returns current balance
  - printStatement() - shows account info
- Create test scenarios:
  - Create account
  - Deposit money
  - Withdraw money
  - Try to withdraw more than balance
  - Print statement

**Bonus:** Add transaction history tracking

---

## LESSON 3 EXERCISES

### Exercise 3.1: Vertical List (Easy)
**Time:** 15 minutes

Create a vertical list of items.

**Requirements:**
- Use VerticalLayout
- Add 5 TextWidgets with different texts
- Add margins to the layout
- Add background color to the layout
- Add different background colors to each text widget

**Expected Layout:**
```
┌──────────────┐
│ Item 1       │ (light red)
│ Item 2       │ (light blue)
│ Item 3       │ (light green)
│ Item 4       │ (light yellow)
│ Item 5       │ (light pink)
└──────────────┘
```

### Exercise 3.2: Button Toolbar (Easy)
**Time:** 15 minutes

Create a horizontal toolbar with buttons.

**Requirements:**
- Use HorizontalLayout
- Add buttons: "New", "Open", "Save", "Close", "Help"
- Style the toolbar with padding and background color
- Make buttons visually consistent

### Exercise 3.3: Simple Form (Medium)
**Time:** 25 minutes

Create a registration form.

**Requirements:**
- Use TableLayout with 2 columns
- Fields:
  - Name
  - Email
  - Phone
  - Address
  - City
- Each field has label (TextWidget) and input (EditLine)
- Add title at top using TextWidget
- Add margins and padding
- Use pleasing colors

**Layout:**
```
┌─────────────────────────┐
│   Registration Form     │
│                         │
│ Name:     [_________]   │
│ Email:    [_________]   │
│ Phone:    [_________]   │
│ Address:  [_________]   │
│ City:     [_________]   │
└─────────────────────────┘
```

### Exercise 3.4: Nested Layouts (Medium)
**Time:** 20 minutes

Create a complex nested layout.

**Requirements:**
- Main VerticalLayout
  - Title (TextWidget, large font, centered)
  - HorizontalLayout with 3 buttons
  - TableLayout (2 columns) with 3 form fields
  - HorizontalLayout with "Submit" and "Cancel" buttons

**This teaches:** Layout composition and nesting

### Exercise 3.5: Calculator Layout (Hard)
**Time:** 35 minutes

Create calculator button layout.

**Requirements:**
- Display area at top (EditLine or TextWidget)
- 4 rows of buttons in HorizontalLayouts:
  - Row 1: [7] [8] [9] [/]
  - Row 2: [4] [5] [6] [*]
  - Row 3: [1] [2] [3] [-]
  - Row 4: [0] [.] [=] [+]
- Use VerticalLayout to contain all rows
- Make it look like a real calculator
- Add colors and spacing

**Bonus:** Add C (clear) button

### Homework 3: Login Screen
**Time:** 45 minutes

Create a complete login screen.

**Requirements:**
- App title (large, centered)
- Username field (label + edit)
- Password field (label + edit)
- "Remember Me" checkbox
- "Login" and "Cancel" buttons
- "Forgot Password?" link (use Button with different style)
- Proper spacing and colors
- Centered on window

**Challenge:** Make it look professional!

---

## LESSON 4 EXERCISES

### Exercise 4.1: Rectangle Class with Encapsulation (Medium)
**Time:** 20 minutes

```d
import std.stdio;

class Rectangle {
    // TODO: Private fields _width, _height
    
    // TODO: Constructor
    
    // TODO: Properties with validation (must be > 0)
    @property double width() { /* getter */ }
    @property void width(double w) { /* setter with validation */ }
    @property double height() { /* getter */ }
    @property void height(double h) { /* setter with validation */ }
    
    // TODO: Read-only calculated properties
    @property double area() const { /* width * height */ }
    @property double perimeter() const { /* 2 * (width + height) */ }
}

void main() {
    auto rect = new Rectangle();
    rect.width = 10;
    rect.height = 5;
    writeln("Area: ", rect.area);
    writeln("Perimeter: ", rect.perimeter);
    
    // This should fail validation:
    rect.width = -5;  // Should not change width
    writeln("Width after invalid set: ", rect.width);  // Should still be 10
}
```

### Exercise 4.2: Student Class (Medium)
**Time:** 25 minutes

Create Student class with encapsulation.

**Requirements:**
- Private fields: _name, _id, _grades (array of doubles)
- Properties: name (read/write), id (read-only), grades (read-only)
- Methods:
  - addGrade(grade) - validates grade is 0-100
  - getAverageGrade() - calculates average
  - getLetterGrade() - returns A/B/C/D/F based on average

**Test:**
```d
void main() {
    auto student = new Student("Alice", 12345);
    student.addGrade(85);
    student.addGrade(92);
    student.addGrade(78);
    writeln(student.name, " average: ", student.getAverageGrade());
    writeln("Letter grade: ", student.getLetterGrade());
}
```

### Exercise 4.3: LabeledEditLine Widget (Medium)
**Time:** 30 minutes

Create custom widget combining label and edit field.

**Requirements:**
```d
import dlangui;

class LabeledEditLine : HorizontalLayout {
    private TextWidget _label;
    private EditLine _editLine;
    
    // TODO: Constructor(id, labelText)
    // TODO: Initialize _label and _editLine
    // TODO: Add both to layout
    
    // TODO: Property for value (gets/sets EditLine text)
    @property dstring value() const { }
    @property void value(dstring text) { }
    
    // TODO: Property for label text
    @property dstring labelText() const { }
    @property void labelText(dstring text) { }
}

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // TODO: Create window
    // TODO: Create VerticalLayout
    // TODO: Add 3 LabeledEditLine widgets
    // TODO: Test setting and getting values
}
```

### Exercise 4.4: LabeledCheckBox Widget (Medium)
**Time:** 25 minutes

Create custom checkbox with label.

**Requirements:**
- Inherit from HorizontalLayout
- Private CheckBox and TextWidget
- Constructor takes id and label text
- Property for checked state
- Property for label text
- Use in a preferences form with 5 options

### Homework 4: Temperature Converter Widget
**Time:** 60 minutes

Create a custom Temperature Converter widget.

**Requirements:**
- Custom widget class: `TemperatureConverter`
- Private EditLine for Celsius
- Private EditLine for Fahrenheit
- Private TextWidget for Kelvin (read-only display)
- When user types in Celsius, update others
- When user types in Fahrenheit, update others
- Validate input (no below absolute zero!)
- Formula:
  - F = C × 9/5 + 32
  - K = C + 273.15

**This teaches:** Encapsulation, calculated properties, validation

---

## LESSON 5 EXERCISES

### Exercise 5.1: Counter Button (Easy)
**Time:** 15 minutes

Create a button that counts clicks.

**Requirements:**
```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("Counter", null);
    
    int count = 0;
    auto button = new Button();
    button.text = "Clicks: 0"d;
    
    // TODO: Add click handler that:
    // 1. Increments count
    // 2. Updates button text to show count
    button.click = delegate(Widget w) {
        // Your code here
        return true;
    };
    
    window.mainWidget = button;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

### Exercise 5.2: Simple Calculator (Medium)
**Time:** 35 minutes

Create working calculator with basic operations.

**Requirements:**
- Layout from Lesson 3 (calculator buttons)
- Display area (EditLine)
- Click handlers for all buttons
- Implement basic arithmetic (+, -, *, /)
- Clear button
- Equals button

**Hints:**
- Keep track of: firstNumber, operation, secondNumber
- On number click: append to display
- On operation click: save firstNumber and operation
- On equals: calculate result

### Exercise 5.3: Todo List (Medium)
**Time:** 30 minutes

Create simple todo list with add/remove.

**Requirements:**
- EditLine for input
- "Add" button
- VerticalLayout to display todos
- Each todo has text and "Remove" button
- Clicking "Add" creates new todo item
- Clicking "Remove" deletes that todo

**Layout:**
```
┌──────────────────────────┐
│ [_________________] [Add]│
│                          │
│ • Buy milk      [Remove] │
│ • Study OOP     [Remove] │
│ • Code project  [Remove] │
└──────────────────────────┘
```

### Exercise 5.4: Color Picker (Medium)
**Time:** 30 minutes

Create RGB color picker.

**Requirements:**
- 3 EditLines for R, G, B values (0-255)
- Preview widget showing the color
- Update preview when any value changes
- Validate input (0-255 range)

**Hint:**
- Use EditLine change event
- Create color: uint color = (r << 16) | (g << 8) | b | 0xFF000000;

### Homework 5: Quiz Application
**Time:** 90 minutes

Create a simple quiz application.

**Requirements:**
- Display question (TextWidget)
- 4 answer buttons (RadioButtons or Buttons)
- "Next Question" button
- Score display
- At least 5 questions
- Show final score at end

**Questions Example:**
1. "What does OOP stand for?"
   - Object Oriented Programming ✓
   - Only One Program
   - ...

**Features:**
- Track correct answers
- Disable selection after answering
- Show score at end
- "Restart Quiz" button

---

## LESSON 6 EXERCISES

### Exercise 6.1: Animal Hierarchy (Easy)
**Time:** 20 minutes

Create animal class hierarchy.

**Requirements:**
```d
import std.stdio;

class Animal {
    string name;
    
    this(string name) {
        this.name = name;
    }
    
    void makeSound() {
        writeln(name, " makes a sound");
    }
    
    void eat() {
        writeln(name, " is eating");
    }
}

// TODO: Create Dog class inheriting from Animal
class Dog : Animal {
    // TODO: Constructor
    // TODO: Override makeSound() to print "Woof!"
    // TODO: Add method wagTail()
}

// TODO: Create Cat class inheriting from Animal
class Cat : Animal {
    // TODO: Constructor
    // TODO: Override makeSound() to print "Meow!"
    // TODO: Add method purr()
}

// TODO: Create Bird class
class Bird : Animal {
    // TODO: Constructor
    // TODO: Override makeSound() to print "Tweet!"
    // TODO: Add method fly()
}

void main() {
    auto dog = new Dog("Rex");
    auto cat = new Cat("Whiskers");
    auto bird = new Bird("Tweety");
    
    dog.makeSound();
    dog.eat();
    dog.wagTail();
    
    cat.makeSound();
    cat.purr();
    
    bird.makeSound();
    bird.fly();
}
```

### Exercise 6.2: Shape Hierarchy (Medium)
**Time:** 25 minutes

Create shape class hierarchy.

**Requirements:**
- Base class: Shape with constructor taking color
- Derived classes: Circle, Rectangle, Triangle
- Each derived class:
  - Specific constructor (radius, width/height, sides)
  - Method: calculateArea()
  - Method: describe() showing type, color, and area

**Test:**
```d
void main() {
    auto circle = new Circle("red", 5);
    auto rect = new Rectangle("blue", 4, 6);
    auto triangle = new Triangle("green", 3, 4, 5);
    
    circle.describe();
    rect.describe();
    triangle.describe();
}
```

### Exercise 6.3: ColoredButton Widget (Easy)
**Time:** 20 minutes

Create custom button with preset colors.

**Requirements:**
```d
import dlangui;

class ColoredButton : Button {
    this(string id, dstring text, uint color) {
        super(id, text);
        this.backgroundColor = color;
        this.textColor = 0xFFFFFF;  // White text
        this.margins = Rect(5, 5, 5, 5);
        this.padding = Rect(10, 5, 10, 5);
    }
}

// TODO: Create specialized buttons
class RedButton : ColoredButton {
    this(string id, dstring text) {
        super(id, text, 0xFF0000);
    }
}

class GreenButton : ColoredButton {
    // TODO: Implement (green color: 0x00FF00)
}

class BlueButton : ColoredButton {
    // TODO: Implement (blue color: 0x0000FF)
}

// Use in application
mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // TODO: Create window
    // TODO: Create layout with red, green, and blue buttons
}
```

### Exercise 6.4: Custom TextWidget Variants (Medium)
**Time:** 30 minutes

Create specialized text widgets.

**Requirements:**
- Base: StyledTextWidget (inherit from TextWidget)
- Derived classes:
  - TitleTextWidget (large, bold, centered)
  - SubtitleTextWidget (medium, centered)
  - ErrorTextWidget (red, italic if possible)
  - SuccessTextWidget (green)
  - InfoTextWidget (blue)

Use all in a sample application.

### Homework 6: Employee Management Classes
**Time:** 90 minutes

Create employee hierarchy.

**Requirements:**
- Base class: Employee
  - Properties: name, id, baseSalary
  - Method: calculateSalary() (returns baseSalary)
  - Method: describe()

- Derived classes:
  - Manager : Employee
    - Additional: teamSize
    - Override calculateSalary() (base + 1000 * teamSize)
  
  - Developer : Employee
    - Additional: programmingLanguage
    - Override calculateSalary() (base + skillBonus)
  
  - Intern : Employee
    - Additional: mentor
    - Override calculateSalary() (base * 0.6)

- Create GUI to display employee list with details

---

## LESSON 7-8 EXERCISES

### Exercise 7.1: Polymorphic Array (Easy)
**Time:** 20 minutes

Use polymorphism with animal array.

**Requirements:**
```d
import std.stdio;

// Use Animal, Dog, Cat from Lesson 6

void main() {
    // Create polymorphic array
    Animal[] animals;
    animals ~= new Dog("Rex");
    animals ~= new Cat("Whiskers");
    animals ~= new Dog("Buddy");
    animals ~= new Bird("Tweety");
    
    // Call methods polymorphically
    foreach(animal; animals) {
        animal.makeSound();  // Different sound for each!
        animal.eat();
    }
}
```

**Questions:**
1. Why can we store Dog, Cat, Bird in Animal array?
2. How does the computer know which makeSound() to call?

### Exercise 7.2: Widget Factory (Medium)
**Time:** 25 minutes

Create widget factory using polymorphism.

**Requirements:**
```d
import dlangui;

Widget createWidget(string type, string id, dstring text) {
    if (type == "button")
        return new Button(id, text);
    else if (type == "text")
        return new TextWidget(id, text);
    else if (type == "checkbox")
        return new CheckBox(id, text);
    return null;
}

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // TODO: Create layout
    // TODO: Use factory to create widgets
    Widget w1 = createWidget("button", "btn1", "Click Me"d);
    Widget w2 = createWidget("text", "txt1", "Hello"d);
    // TODO: Add to layout
    // TODO: Apply common properties polymorphically
}
```

### Exercise 7.3: Abstract Shape (Medium)
**Time:** 30 minutes

Create abstract shape class.

**Requirements:**
```d
import std.stdio;

abstract class Shape {
    protected string color;
    
    this(string color) {
        this.color = color;
    }
    
    // Abstract methods - must implement in derived classes
    abstract double area();
    abstract double perimeter();
    
    // Concrete method - shared implementation
    void describe() {
        writefln("%s shape - Area: %.2f, Perimeter: %.2f",
                 color, area(), perimeter());
    }
}

// TODO: Implement Circle
class Circle : Shape {
    private double radius;
    // TODO: Constructor
    // TODO: Override area() and perimeter()
}

// TODO: Implement Rectangle
// TODO: Implement Triangle

void main() {
    // Cannot do: auto s = new Shape("red");  // ERROR - abstract!
    
    Shape[] shapes = [
        new Circle("red", 5),
        new Rectangle("blue", 4, 6),
        new Triangle("green", 3, 4, 5)
    ];
    
    foreach(shape; shapes) {
        shape.describe();  // Polymorphism!
    }
}
```

### Exercise 7.4: Abstract DataWidget (Hard)
**Time:** 40 minutes

Create abstract widget for displaying data.

**Requirements:**
```d
import dlangui;
import std.conv;

abstract class DataDisplayWidget : VerticalLayout {
    protected string[] data;
    
    this(string id) {
        super(id);
    }
    
    void setData(string[] newData) {
        data = newData;
        refresh();
    }
    
    // Abstract method - each implementation displays differently
    abstract void refresh();
}

// TODO: Implement ListDataWidget - shows as vertical list
class ListDataWidget : DataDisplayWidget {
    // TODO: Constructor
    // TODO: Override refresh() to display as list
}

// TODO: Implement TableDataWidget - shows as simple table
class TableDataWidget : DataDisplayWidget {
    // TODO: Constructor
    // TODO: Override refresh() to display as table
}

// TODO: Create app that lets user switch between displays
```

### Homework 7-8: Game Character System
**Time:** 120 minutes

Create RPG character system using polymorphism.

**Requirements:**
- Abstract base class: GameCharacter
  - Properties: name, health, level
  - Abstract methods: attack(), defend(), special()
  - Concrete method: isAlive()

- Derived classes:
  - Warrior (high health, medium attack)
  - Mage (low health, high special)
  - Rogue (medium health, high speed)

- Create GUI showing:
  - Character selection
  - Character stats display
  - Action buttons (attack, defend, special)
  - Battle log

**Bonus:** Add simple battle simulation

---

## LESSON 9 EXERCISES

### Exercise 9.1: Basic Interfaces (Easy)
**Time:** 20 minutes

Create and implement basic interfaces.

**Requirements:**
```d
import std.stdio;

interface Drawable {
    void draw();
}

interface Movable {
    void move(int x, int y);
}

// Implement a class with both interfaces
class Sprite : Drawable, Movable {
    private int x, y;
    private string name;
    
    this(string name) {
        this.name = name;
        this.x = 0;
        this.y = 0;
    }
    
    // TODO: Implement draw()
    override void draw() {
        writefln("Drawing %s at (%d, %d)", name, x, y);
    }
    
    // TODO: Implement move()
    override void move(int newX, int newY) {
        // ...
    }
}

void main() {
    auto sprite = new Sprite("Hero");
    sprite.draw();
    sprite.move(10, 20);
    sprite.draw();
}
```

### Exercise 9.2: Form Handler Interface (Medium)
**Time:** 30 minutes

Create event handler using interfaces.

**Requirements:**
```d
import dlangui;

class FormController : OnClickHandler {
    private Window window;
    private EditLine nameEdit;
    private EditLine emailEdit;
    
    this(Window win, EditLine name, EditLine email) {
        this.window = win;
        this.nameEdit = name;
        this.emailEdit = email;
    }
    
    // Implement OnClickHandler interface
    override bool onClick(Widget source) {
        if (source.id == "btnSubmit") {
            // TODO: Validate and show message
            window.showMessageBox(
                UIString.fromRaw("Form Data"d),
                UIString.fromRaw("Name: "d ~ nameEdit.text ~ 
                                "\nEmail: "d ~ emailEdit.text)
            );
            return true;
        } else if (source.id == "btnClear") {
            // TODO: Clear fields
            nameEdit.text = ""d;
            emailEdit.text = ""d;
            return true;
        }
        return false;
    }
}

// TODO: Create application using FormController
```

### Exercise 9.3: Multiple Handler Interfaces (Medium)
**Time:** 35 minutes

Implement multiple handler interfaces in one class.

**Requirements:**
Create class implementing:
- OnClickHandler (for buttons)
- OnCheckHandler (for checkboxes)
- OnFocusHandler (for edit fields)

Use in a complete form application.

### Homework 9: Media Player Interface System
**Time:** 90 minutes

Create media player using interfaces.

**Requirements:**
- Interface: `Playable`
  - Methods: play(), pause(), stop(), getDuration()

- Interface: `MediaInfo`
  - Methods: getTitle(), getArtist(), getFormat()

- Implementations:
  - MockAudioFile (implements both)
  - MockVideoFile (implements both)

- Create GUI with:
  - File list
  - Play/Pause/Stop buttons
  - Info display
  - Progress indicator (fake)

**Note:** Don't implement actual media playback, just simulate it

---

## LESSON 10 EXERCISES

### Exercise 10.1: Composition Example (Medium)
**Time:** 25 minutes

Create contact card using composition.

**Requirements:**
```d
import dlangui;

// Simple Contact data class
class Contact {
    string name;
    string phone;
    string email;
    
    this(string name, string phone, string email) {
        this.name = name;
        this.phone = phone;
        this.email = email;
    }
}

// Widget displaying contact - uses composition
class ContactCard : VerticalLayout {
    private Contact contact;  // HAS-A relationship
    private TextWidget nameLabel;
    private TextWidget phoneLabel;
    private TextWidget emailLabel;
    
    this(Contact contact) {
        super(null);
        this.contact = contact;
        
        // TODO: Create and add labels
        // TODO: Style the card
        // TODO: Add padding, margins, border
    }
}

// TODO: Use in application showing multiple contacts
```

### Exercise 10.2: Logger Composition (Medium)
**Time:** 30 minutes

Use composition instead of inheritance for logging.

**Requirements:**
```d
import std.stdio;
import std.datetime;

// Logger class
class Logger {
    void log(string message) {
        auto now = Clock.currTime();
        writefln("[%s] %s", now.toSimpleString(), message);
    }
}

// Service using logger - composition
class DataService {
    private Logger logger;  // Composition
    
    this(Logger logger) {
        this.logger = logger;
    }
    
    void saveData(string data) {
        logger.log("Saving data: " ~ data);
        // ... save logic ...
        logger.log("Data saved successfully");
    }
    
    void loadData() {
        logger.log("Loading data...");
        // ... load logic ...
        logger.log("Data loaded");
    }
}

void main() {
    auto logger = new Logger();
    auto service = new DataService(logger);
    service.saveData("Important info");
}
```

### Homework 10: Dashboard Widget System
**Time:** 120 minutes

Create dashboard using composition.

**Requirements:**
- Create `DashboardWidget` class composed of:
  - TitleBar widget (custom)
  - StatisticsPanel widget (custom)
  - ChartArea widget (custom - just colored rectangles)
  - ActionButtons panel

- Each component is self-contained
- Dashboard composes them together
- Can swap components easily

**This teaches:** Component-based architecture

---

## LESSON 11 EXERCISES

### Exercise 11.1: Simple DML Layout (Easy)
**Time:** 15 minutes

Convert code-based layout to DML.

**Code Version:**
```d
auto layout = new VerticalLayout();
layout.margins = Rect(10, 10, 10, 10);
layout.backgroundColor = 0xCCCCFF;
layout.addChild((new TextWidget()).text("Hello"d));
layout.addChild((new Button()).text("Click"d));
```

**DML Version:**
```d
auto layout = parseML(q{
    VerticalLayout {
        margins: 10
        backgroundColor: "#CCCCFF"
        TextWidget { text: "Hello" }
        Button { text: "Click" }
    }
});
```

**Your Task:** Convert your Lesson 3 login form to DML

### Exercise 11.2: DML with IDs (Medium)
**Time:** 25 minutes

Create DML layout and access widgets by ID.

**Requirements:**
```d
auto layout = parseML(q{
    VerticalLayout {
        TextWidget { text: "Calculator" ; fontSize: 24 }
        EditLine { id: display; readOnly: true }
        HorizontalLayout {
            Button { id: btn7; text: "7" }
            Button { id: btn8; text: "8" }
            Button { id: btn9; text: "9" }
        }
        // Add more rows...
    }
});

// Access widgets
auto display = layout.childById!EditLine("display");
auto btn7 = layout.childById!Button("btn7");

// Attach handlers
btn7.click = delegate(Widget w) {
    display.text = display.text ~ "7"d;
    return true;
};
```

### Exercise 11.3: Complex DML Form (Medium)
**Time:** 30 minutes

Create complex form entirely in DML.

**Requirements:**
- Registration form with:
  - Title
  - First name, last name fields
  - Email, phone fields
  - Address (multiline)
  - Gender radio buttons
  - Terms checkbox
  - Submit/Cancel buttons
- All in DML
- Access widgets and attach handlers in code

### Homework 11: Settings Dialog in DML
**Time:** 60 minutes

Create settings dialog using DML.

**Requirements:**
- Multiple sections (General, Appearance, Advanced)
- Various control types:
  - CheckBoxes
  - RadioButtons
  - EditLines
  - ComboBoxes
- Save/Cancel/Reset buttons
- Validate and apply settings

---

## LESSON 12-20 EXERCISES

*[Continue with similar detailed exercises for remaining lessons]*

---

## LESSON 20: FINAL PROJECT

### Final Project Options

Choose ONE of these projects to implement:

#### Option 1: Personal Finance Manager
**Features:**
- Track income and expenses
- Category management
- Monthly reports
- Data visualization (simple charts)
- Export to file

**Classes Required:**
- Transaction (base class)
- Income, Expense (derived)
- Category
- Account
- TransactionManager

#### Option 2: Student Management System
**Features:**
- Student records (CRUD)
- Course management
- Grade tracking
- GPA calculation
- Search and filter

**Classes Required:**
- Student
- Course
- Grade
- Semester
- StudentManager

#### Option 3: Task Manager
**Features:**
- Create/edit/delete tasks
- Priority levels
- Due dates
- Categories
- Progress tracking
- Statistics

**Classes Required:**
- Task (abstract or base)
- Priority Task, Recurring Task (derived)
- Category
- TaskManager

#### Option 4: Recipe Organizer
**Features:**
- Recipe library
- Ingredient lists
- Instructions
- Search by ingredient
- Shopping list generator

**Classes Required:**
- Recipe
- Ingredient
- Category
- RecipeManager

### Project Requirements

**Must Include:**
1. Minimum 5 custom classes showing OOP principles
2. Use of inheritance (at least 2 levels)
3. Interface implementation
4. Encapsulation (private/public)
5. Polymorphism example
6. DML layouts
7. Custom widgets (at least 2)
8. Event handling
9. Resource management
10. Professional UI design

**Deliverables:**
1. Source code
2. README explaining architecture
3. Class diagram
4. Demo video or presentation
5. User manual

**Grading Rubric:** (100 points)
- OOP Principles (30 pts)
- Functionality (25 pts)
- Code Quality (20 pts)
- UI/UX (15 pts)
- Documentation (10 pts)

---

## BONUS PROJECTS

### Bonus 1: Mini Text Editor
- Open/save files
- Basic editing
- Find/replace
- Multiple documents (tabs)

### Bonus 2: Drawing Application
- Canvas widget
- Drawing tools (line, rectangle, circle)
- Color picker
- Save as image

### Bonus 3: Chat Application UI
- Contact list
- Message history
- Send messages
- Emoji picker
- (No networking - just UI)

### Bonus 4: Music Library Manager
- Track metadata
- Playlists
- Search/filter
- Genre categorization
- (No actual playback)

### Bonus 5: Game: Tic-Tac-Toe
- 3x3 grid
- Two player
- Win detection
- Score tracking
- Restart option

---

## Exercise Submission Guidelines

### For Each Exercise:
1. **Code** - Well-commented and formatted
2. **Screenshot** - Show running application
3. **Questions Answered** - If exercise includes questions
4. **Challenges Attempted** - Document bonus attempts

### Naming Convention:
```
StudentName_Lesson_Exercise.d
Example: Alice_Johnson_Lesson3_Exercise2.d
```

### Code Style:
- Proper indentation (4 spaces)
- Meaningful variable names
- Comments explaining complex logic
- TODO markers removed
- No compiler warnings

---

## Getting Help

### When Stuck:
1. Read the lesson material again
2. Check example code in dlangui/examples/
3. Review previous exercises
4. Ask classmates (collaboration OK for understanding)
5. Ask instructor

### Debugging Tips:
```d
import dlangui;

// Add logging
Log.d("Debug: variable = ", variable);

// Check widget creation
assert(widget !is null, "Widget not created!");

// Verify layout
layout.dump();  // Prints widget tree
```

### Common Errors:
- Forgot 'd' suffix: `"text"d` not `"text"`
- Didn't call `.show()` on window
- Wrong color format: Use `0xFF0000` not `"#FF0000"`
- Forgot to add widget to layout
- Margins vs padding confusion

---

**Remember:** Programming is learned by doing. Complete every exercise, experiment with variations, and don't be afraid to break things - that's how you learn!

**Good luck with your OOP journey!** 🚀


