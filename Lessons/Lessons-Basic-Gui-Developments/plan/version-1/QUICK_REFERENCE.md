# Quick Reference Guide
## OOP with D Language and dlangui Framework

This is a quick reference for both instructors and students during the course.

---

## Table of Contents

- [D Language Quick Reference](#d-language-quick-reference)
- [OOP Concepts Cheatsheet](#oop-concepts-cheatsheet)
- [dlangui Widget Reference](#dlangui-widget-reference)
- [Common Layout Patterns](#common-layout-patterns)
- [Event Handling Reference](#event-handling-reference)
- [Color Reference](#color-reference)
- [DML Syntax Reference](#dml-syntax-reference)
- [Common Errors and Solutions](#common-errors-and-solutions)
- [Code Snippets Library](#code-snippets-library)

---

## D Language Quick Reference

### Basic Syntax

```d
// Imports
import std.stdio;
import dlangui;

// Variables
int x = 10;
string text = "Hello";
auto value = 42;  // Type inference

// Constants
const int MAX_SIZE = 100;
immutable PI = 3.14159;

// Arrays
int[] numbers = [1, 2, 3, 4, 5];
numbers ~= 6;  // Append

// Strings
string str = "UTF-8 string";
dstring dstr = "UTF-32 string"d;  // Note the 'd' suffix
wstring wstr = "UTF-16 string"w;

// Loops
foreach (num; numbers) {
    writeln(num);
}

for (int i = 0; i < 10; i++) {
    // ...
}

// Conditionals
if (x > 5) {
    // ...
} else if (x < 0) {
    // ...
} else {
    // ...
}

// Functions
int add(int a, int b) {
    return a + b;
}

// Lambda/Delegates
auto lambda = (int x) => x * 2;
auto delegate1 = delegate(int x) { return x * 2; };
```

### Classes

```d
class MyClass {
    // Fields
    private int _value;
    public string name;
    
    // Constructor
    this(string name) {
        this.name = name;
        this._value = 0;
    }
    
    // Properties
    @property int value() const { return _value; }
    @property void value(int v) { _value = v; }
    
    // Methods
    void doSomething() {
        // ...
    }
    
    // Static method
    static void classMethod() {
        // ...
    }
}

// Inheritance
class Derived : Base {
    this() {
        super();  // Call base constructor
    }
    
    override void method() {
        // ...
    }
}

// Interface
interface IMyInterface {
    void method();
}

class Implementation : IMyInterface {
    override void method() {
        // ...
    }
}
```

---

## OOP Concepts Cheatsheet

### Encapsulation

```d
class BankAccount {
    private double _balance;  // Hidden
    
    @property double balance() const { return _balance; }
    
    void deposit(double amount) {
        if (amount > 0)
            _balance += amount;
    }
}
```

**Key Points:**
- Hide internal details
- Provide public interface
- Validate in setters
- Use private/protected/public

### Inheritance

```d
class Animal {
    string name;
    this(string name) { this.name = name; }
    void makeSound() { }
}

class Dog : Animal {
    this(string name) { super(name); }
    override void makeSound() { writeln("Woof!"); }
}
```

**Key Points:**
- IS-A relationship
- Code reuse
- Specialization
- Use `override` keyword
- Call `super()` in constructor

### Polymorphism

```d
Animal[] animals = [
    new Dog("Rex"),
    new Cat("Whiskers"),
    new Bird("Tweety")
];

foreach (animal; animals) {
    animal.makeSound();  // Different for each type!
}
```

**Key Points:**
- Base class references
- Runtime type determination
- Virtual method dispatch
- "Many forms"

### Abstraction

```d
abstract class Shape {
    abstract double area();
    abstract double perimeter();
    
    void describe() {  // Concrete method
        writeln("Area: ", area());
    }
}

class Circle : Shape {
    double radius;
    override double area() { return PI * radius * radius; }
    override double perimeter() { return 2 * PI * radius; }
}
```

**Key Points:**
- Cannot instantiate abstract classes
- Must implement abstract methods
- Can have concrete methods
- Defines contracts

### Composition

```d
class Engine {
    void start() { }
}

class Car {
    private Engine engine;  // HAS-A
    
    this() {
        engine = new Engine();
    }
    
    void start() {
        engine.start();
    }
}
```

**Key Points:**
- HAS-A relationship
- More flexible than inheritance
- "Favor composition over inheritance"

---

## dlangui Widget Reference

### Common Widgets

```d
// Button
auto button = new Button("id", "Label"d);
button.textColor = 0xFF0000;
button.click = delegate(Widget w) { return true; };

// TextWidget (static text)
auto text = new TextWidget("id", "Display text"d);
text.fontSize = 24;
text.textColor = 0x000000;

// EditLine (single-line input)
auto edit = new EditLine("id", "initial text"d);
edit.text = "new text"d;
dstring value = edit.text;

// EditBox (multi-line editor)
auto editor = new EditBox("id");
editor.text = "Multi-line\ntext"d;

// CheckBox
auto checkbox = new CheckBox("id", "Label"d);
checkbox.checked = true;
bool isChecked = checkbox.checked;

// RadioButton
auto radio = new RadioButton("id", "Option"d);

// ComboBox
auto combo = new ComboBox("id", ["Item 1"d, "Item 2"d]);
combo.selectedItemIndex = 0;

// ImageWidget
auto image = new ImageWidget("id", "resource_id");

// ImageButton
auto imgBtn = new ImageButton("id", "icon_id");

// ImageTextButton
auto itBtn = new ImageTextButton("id", "icon_id", "Label"d);
```

### Layout Widgets

```d
// VerticalLayout - stacks children vertically
auto vlayout = new VerticalLayout("id");
vlayout.addChild(widget1);
vlayout.addChild(widget2);

// HorizontalLayout - arranges children horizontally
auto hlayout = new HorizontalLayout("id");
hlayout.addChild(widget1);
hlayout.addChild(widget2);

// TableLayout - grid layout
auto table = new TableLayout("id");
table.colCount = 2;  // Important!
table.addChild(label1);  // Row 1, Col 1
table.addChild(edit1);   // Row 1, Col 2
table.addChild(label2);  // Row 2, Col 1
table.addChild(edit2);   // Row 2, Col 2

// FrameLayout - overlapping widgets
auto frame = new FrameLayout("id");
frame.addChild(background);
frame.addChild(foreground);
```

### Widget Properties

```d
// Common properties
widget.id = "myWidget";
widget.text = "Display text"d;
widget.margins = Rect(10, 10, 10, 10);  // left, top, right, bottom
widget.padding = Rect(5, 5, 5, 5);
widget.backgroundColor = 0xFFFFCC;
widget.textColor = 0x000000;
widget.fontSize = 18;
widget.minWidth = 100;
widget.minHeight = 50;
widget.layoutWidth = FILL_PARENT;  // or WRAP_CONTENT
widget.layoutHeight = WRAP_CONTENT;
widget.alignment = Align.Center;  // or Align.Left, Align.Right, etc.
widget.visibility = Visibility.Visible;  // or Visibility.Gone, Visibility.Hidden
```

### Finding Widgets

```d
// By ID
Widget widget = layout.childById("widgetId");
Button button = layout.childById!Button("btnId");
EditLine edit = layout.childById!EditLine("editId");

// Check if found
if (widget !is null) {
    // Widget found
}
```

---

## Common Layout Patterns

### Form Layout (Label + Input)

```d
auto form = new TableLayout();
form.colCount = 2;
form.margins = Rect(20, 20, 20, 20);

form.addChild(new TextWidget(null, "Name:"d));
form.addChild(new EditLine("edName"));

form.addChild(new TextWidget(null, "Email:"d));
form.addChild(new EditLine("edEmail"));

form.addChild(new TextWidget(null, "Phone:"d));
form.addChild(new EditLine("edPhone"));
```

### Button Row

```d
auto buttons = new HorizontalLayout();
buttons.margins = Rect(10, 10, 10, 10);

buttons.addChild(new Button("btnOk", "OK"d));
buttons.addChild(new Button("btnCancel", "Cancel"d));
buttons.addChild(new Button("btnApply", "Apply"d));
```

### Title + Content + Actions

```d
auto main = new VerticalLayout();

// Title
auto title = new TextWidget(null, "My Application"d);
title.fontSize = 24;
title.alignment = Align.Center;
main.addChild(title);

// Content area
auto content = new VerticalLayout();
content.layoutHeight = FILL_PARENT;
// Add content widgets...
main.addChild(content);

// Action buttons
auto actions = new HorizontalLayout();
actions.addChild(new Button("btnSave", "Save"d));
actions.addChild(new Button("btnClose", "Close"d));
main.addChild(actions);
```

### Sidebar + Main Area

```d
auto main = new HorizontalLayout();

// Sidebar
auto sidebar = new VerticalLayout();
sidebar.minWidth = 200;
sidebar.backgroundColor = 0xF0F0F0;
// Add sidebar items...
main.addChild(sidebar);

// Main content
auto content = new VerticalLayout();
content.layoutWidth = FILL_PARENT;
content.layoutHeight = FILL_PARENT;
// Add content...
main.addChild(content);
```

---

## Event Handling Reference

### Click Event

```d
button.click = delegate(Widget source) {
    // Handle click
    return true;  // Event handled
};

// Or using class method
class MyHandler : OnClickHandler {
    override bool onClick(Widget source) {
        // Handle click
        return true;
    }
}

button.click = new MyHandler();
```

### Check Change Event

```d
checkbox.checkChange = delegate(Widget source, bool checked) {
    if (checked) {
        // Checkbox is now checked
    } else {
        // Checkbox is now unchecked
    }
    return true;
};
```

### Focus Change Event

```d
editLine.focusChange = delegate(Widget source, bool focused) {
    if (focused) {
        // Widget gained focus
    } else {
        // Widget lost focus
    }
    return true;
};
```

### Key Event

```d
widget.keyEvent = delegate(Widget source, KeyEvent event) {
    if (event.action == KeyAction.KeyDown) {
        if (event.keyCode == KeyCode.KEY_ENTER) {
            // Enter key pressed
            return true;
        }
    }
    return false;
};
```

### Mouse Event

```d
widget.mouseEvent = delegate(Widget source, MouseEvent event) {
    if (event.action == MouseAction.ButtonDown) {
        // Mouse button pressed
        int x = event.x;
        int y = event.y;
        return true;
    }
    return false;
};
```

---

## Color Reference

### Color Format

Colors in dlangui use 32-bit ARGB format: `0xAARRGGBB`

```d
// Fully opaque colors (alpha = FF)
0xFF000000  // Black
0xFFFFFFFF  // White
0xFFFF0000  // Red
0xFF00FF00  // Green
0xFF0000FF  // Blue
0xFFFFFF00  // Yellow
0xFFFF00FF  // Magenta
0xFF00FFFF  // Cyan

// Semi-transparent (alpha = 80)
0x80FF0000  // Semi-transparent red

// Common UI colors
0xFFF0F0F0  // Light gray (background)
0xFF333333  // Dark gray (text)
0xFF0080FF  // Light blue (accent)
0xFFFFCCCC  // Light red (error)
0xFFCCFFCC  // Light green (success)
0xFFFFFFCC  // Light yellow (warning)
0xFFCCCCFF  // Light blue (info)
```

### Using Colors

```d
widget.textColor = 0xFF0000;  // Red text
widget.backgroundColor = 0xFFFFCC;  // Light yellow background

// In DML
TextWidget {
    textColor: "#FF0000"
    backgroundColor: "#FFFFCC"
}
```

---

## DML Syntax Reference

### Basic Structure

```d
auto widget = parseML(q{
    WidgetType {
        property: value
        property: value
        
        ChildWidget {
            // ...
        }
    }
});
```

### Complete Example

```d
auto layout = parseML(q{
    VerticalLayout {
        id: mainLayout
        margins: 20
        padding: 10
        backgroundColor: "#F0F0F0"
        layoutWidth: fill
        layoutHeight: fill
        
        // Title
        TextWidget {
            text: "My Application"
            fontSize: 28
            textColor: "#333333"
            alignment: Center
        }
        
        // Form
        TableLayout {
            colCount: 2
            margins: [10, 20, 10, 10]
            
            TextWidget { text: "Name:" }
            EditLine { 
                id: edName
                layoutWidth: fill
            }
            
            TextWidget { text: "Email:" }
            EditLine {
                id: edEmail
                layoutWidth: fill
            }
        }
        
        // Buttons
        HorizontalLayout {
            margins: 10
            
            Button {
                id: btnOk
                text: "OK"
                minWidth: 80
            }
            
            Button {
                id: btnCancel
                text: "Cancel"
                minWidth: 80
            }
        }
    }
});

// Access widgets
auto name = layout.childById!EditLine("edName");
auto email = layout.childById!EditLine("edEmail");
auto btnOk = layout.childById!Button("btnOk");
```

### Property Values

```d
// Strings
text: "Simple string"
text: MY_RESOURCE_ID  // From i18n resources

// Numbers
fontSize: 24
minWidth: 100

// Colors
textColor: "#FF0000"
backgroundColor: "#FFFFCC"

// Dimensions
margins: 10          // All sides
margins: [10, 20]    // Vertical, Horizontal
margins: [10, 20, 30, 40]  // Left, Top, Right, Bottom

// Alignment
alignment: Center
alignment: Left
alignment: Right | VCenter

// Layout size
layoutWidth: fill
layoutWidth: wrap
layoutHeight: fill

// Arrays
items: ["Item 1", "Item 2", "Item 3"]
```

---

## Common Errors and Solutions

### Error: Cannot convert string to dstring

**Problem:**
```d
widget.text = "Hello";  // ERROR
```

**Solution:**
```d
widget.text = "Hello"d;  // Add 'd' suffix for dstring
```

### Error: Window doesn't appear

**Problem:**
```d
Window window = Platform.instance.createWindow("Title", null);
window.mainWidget = widget;
return Platform.instance.enterMessageLoop();  // Forgot show()
```

**Solution:**
```d
Window window = Platform.instance.createWindow("Title", null);
window.mainWidget = widget;
window.show();  // Don't forget this!
return Platform.instance.enterMessageLoop();
```

### Error: Widget not found by ID

**Problem:**
```d
auto widget = layout.childById("myWidget");
widget.text = "Hello"d;  // Crash if widget is null
```

**Solution:**
```d
auto widget = layout.childById!TextWidget("myWidget");
if (widget !is null) {
    widget.text = "Hello"d;
} else {
    Log.e("Widget 'myWidget' not found!");
}
```

### Error: Layout doesn't show all widgets

**Problem:**
```d
// For TableLayout - forgot to set colCount
auto table = new TableLayout();
table.addChild(label1);
table.addChild(edit1);
// Widgets don't appear correctly
```

**Solution:**
```d
auto table = new TableLayout();
table.colCount = 2;  // Essential for TableLayout!
table.addChild(label1);
table.addChild(edit1);
```

### Error: Click handler doesn't work

**Problem:**
```d
button.click = delegate(Widget w) {
    doSomething();
    return false;  // Should return true!
};
```

**Solution:**
```d
button.click = delegate(Widget w) {
    doSomething();
    return true;  // Signal handled
};
```

### Error: Margins vs Padding confusion

**Concept:**
- **Margins:** Space OUTSIDE widget (between widgets)
- **Padding:** Space INSIDE widget (around content)

```
┌─────────────────────────┐ ← Margins
│ ┌─────────────────────┐ │
│ │  ┌───────────────┐  │ │ ← Padding
│ │  │   Content     │  │ │
│ │  └───────────────┘  │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

---

## Code Snippets Library

### Minimal Application Template

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("App Title", null);
    
    // Create your UI here
    auto layout = new VerticalLayout();
    layout.addChild(new TextWidget(null, "Hello World"d));
    
    window.mainWidget = layout;
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

### Application with Resources

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // Load embedded resources
    embeddedResourceList.addResources(embedResourcesFromList!("resources.list")());
    
    // Set theme
    Platform.instance.uiTheme = "theme_default";
    
    // Set language
    Platform.instance.uiLanguage = "en";
    
    Window window = Platform.instance.createWindow("My App", null);
    
    // Your UI code...
    
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

### Message Box

```d
window.showMessageBox(
    UIString.fromRaw("Title"d),
    UIString.fromRaw("Message text"d)
);

// With callbacks
window.showMessageBox(
    UIString.fromRaw("Confirm"d),
    UIString.fromRaw("Are you sure?"d),
    [ACTION_YES, ACTION_NO],
    0,  // Default action index
    delegate(const Action result) {
        if (result.id == StandardAction.Yes) {
            // User clicked Yes
        }
        return true;
    }
);
```

### File Dialog

```d
FileDialog dlg = new FileDialog(
    UIString.fromRaw("Open File"d),
    window
);

dlg.allowMultipleFiles = false;
dlg.filePath = "~/"d;

dlg.dialogResult = delegate(Dialog dlg, const Action result) {
    if (result.id == ACTION_OPEN.id) {
        string[] files = (cast(FileDialog)dlg).filenames;
        // Process files...
    }
};

dlg.show();
```

### Custom Widget Template

```d
class MyCustomWidget : VerticalLayout {
    private TextWidget _label;
    private Button _button;
    
    this(string id) {
        super(id);
        
        _label = new TextWidget(null, "Label"d);
        _button = new Button(null, "Click"d);
        
        addChild(_label);
        addChild(_button);
        
        _button.click = &onButtonClick;
    }
    
    private bool onButtonClick(Widget source) {
        _label.text = "Clicked!"d;
        return true;
    }
    
    @property dstring labelText() const {
        return _label.text;
    }
    
    @property void labelText(dstring text) {
        _label.text = text;
    }
}
```

### DML with Event Handlers

```d
auto layout = parseML(q{
    VerticalLayout {
        EditLine { id: input }
        Button { id: submit; text: "Submit" }
        TextWidget { id: result }
    }
});

auto input = layout.childById!EditLine("input");
auto result = layout.childById!TextWidget("result");

layout.childById("submit").click = delegate(Widget w) {
    result.text = "You entered: "d ~ input.text;
    return true;
};
```

---

## Quick Tips

### Performance

- Don't create widgets in loops unnecessarily
- Reuse widgets when possible
- Use `ListWidget` with adapter for large lists
- Minimize layout nesting

### Best Practices

```d
// Good: Use meaningful IDs
auto saveButton = new Button("btnSave", "Save"d);

// Good: Use consistent naming
private Widget _myWidget;  // Private fields with underscore
public Widget myWidget;    // Public fields without

// Good: Chain property calls
widget
    .text("Hello"d)
    .textColor(0xFF0000)
    .margins(Rect(10, 10, 10, 10));

// Good: Check for null
auto widget = layout.childById("id");
if (widget !is null) {
    // Use widget
}

// Good: Use constants for repeated values
const uint COLOR_PRIMARY = 0x0080FF;
const uint COLOR_ERROR = 0xFF0000;
```

### Debugging

```d
import dlangui;

// Enable debug logging
Log.setLogLevel(LogLevel.Debug);

// Log messages
Log.d("Debug message: ", value);
Log.i("Info message");
Log.w("Warning message");
Log.e("Error message");

// Dump widget tree
layout.dump();

// Check widget state
writeln("Widget bounds: ", widget.pos);
writeln("Widget visibility: ", widget.visibility);
```

---

## Keyboard Shortcuts (Common)

During development with DlangUI apps:

- **Alt + F4** - Close window (Windows/Linux)
- **Cmd + Q** - Quit application (macOS)
- **Tab** - Move focus to next widget
- **Shift + Tab** - Move focus to previous widget
- **Enter** - Activate focused button
- **Space** - Toggle focused checkbox

---

## Useful Resources

### Documentation
- dlangui Wiki: `externals/dlangui.wiki/`
- D Language Docs: https://dlang.org/
- DUB Package Manager: https://code.dlang.org/

### Example Projects
- `externals/dlangui/examples/helloworld/`
- `externals/dlangui/examples/example1/`
- `externals/dlangui/examples/tetris/`

### Getting Help
1. Check this reference guide
2. Look at example code
3. Read dlangui wiki
4. Ask instructor
5. Collaborate with classmates

---

## Course Schedule Quick View

| Lesson | Topics | Key Deliverable |
|--------|--------|-----------------|
| 1 | D Basics, First GUI | Hello World app |
| 2 | Classes & Objects | Person class + GUI |
| 3 | Layouts | Form layouts |
| 4 | Encapsulation | Custom widgets |
| 5 | Methods & Events | Calculator |
| 6 | Inheritance | Widget hierarchy |
| 7-8 | Polymorphism | Abstract widgets |
| 9 | Interfaces | Event handlers |
| 10 | Composition | Component system |
| 11 | DML | DML-based UI |
| 12 | Styling | Custom theme |
| 13 | Resources | Image app |
| 14 | Events | Event system |
| 15 | Lists | Todo list |
| 16 | Grids | Data table |
| 17 | Trees | File browser |
| 18 | Dialogs | Multi-window app |
| 19 | Templates | Generic widgets |
| 20 | Final Project | Complete application |

---

## Assessment Checklist

### For Each Exercise:
- [ ] Code compiles without errors
- [ ] Code runs without crashes
- [ ] All requirements met
- [ ] Code is well-commented
- [ ] Proper naming conventions
- [ ] Consistent indentation
- [ ] No compiler warnings
- [ ] Screenshot provided (if applicable)

### For Final Project:
- [ ] Minimum 5 custom classes
- [ ] Demonstrates inheritance
- [ ] Uses interfaces
- [ ] Proper encapsulation
- [ ] Shows polymorphism
- [ ] Uses DML
- [ ] Custom widgets (2+)
- [ ] Event handling
- [ ] Professional UI
- [ ] Documentation complete

---

**Last Updated:** October 2025

**Note:** Keep this guide handy during all lessons for quick reference!


