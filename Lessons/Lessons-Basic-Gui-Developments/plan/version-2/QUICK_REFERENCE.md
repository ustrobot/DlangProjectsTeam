# Quick Reference Guide - Version 2
## OOP Through GUI Development

Fast lookup guide for D language, OOP concepts, and dlangui widgets (programmatic approach only - no DML).

---

## Table of Contents

- [D Language Basics](#d-language-basics)
- [OOP Concepts Quick Guide](#oop-concepts-quick-guide)
- [dlangui Core Concepts](#dlangui-core-concepts)
- [Common Widgets](#common-widgets)
- [Layout Widgets](#layout-widgets)
- [Event Handling](#event-handling)
- [Color Reference](#color-reference)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)
- [Code Snippets](#code-snippets)

---

## D Language Basics

### Essential Syntax

```d
// Imports
import dlangui;
import std.stdio;
import std.conv;  // For to!int, to!dstring

// Variables
int count = 0;
string text = "UTF-8";
dstring displayText = "UTF-32"d;  // Note the 'd' suffix!
auto value = 42;  // Type inference

// Arrays
int[] numbers = [1, 2, 3];
numbers ~= 4;  // Append

// Conditionals
if (count > 0) {
    // ...
} else {
    // ...
}

// Loops
foreach (item; array) {
    // ...
}

for (int i = 0; i < 10; i++) {
    // ...
}

// Functions
int add(int a, int b) {
    return a + b;
}

// Delegates (lambda functions)
auto handler = delegate(Widget w) {
    // code here
    return true;
};
```

### Type Conversion

```d
import std.conv;

// String to number
int num = to!int("42");
double d = to!double("3.14");

// Number to string (dstring for GUI)
dstring text = to!dstring(42);
dstring text = to!dstring(3.14);

// Check if valid before converting
import std.exception;
try {
    int num = to!int(userInput);
} catch (ConvException e) {
    // Handle invalid input
}
```

---

## OOP Concepts Quick Guide

### Classes

```d
class MyClass {
    // Private members (use _ prefix by convention)
    private int _value;
    private string _name;
    
    // Constructor
    this(string name) {
        _name = name;
        _value = 0;
    }
    
    // Properties
    @property int value() {
        return _value;
    }
    
    @property void value(int v) {
        _value = v;
    }
    
    // Methods
    void doSomething() {
        // ...
    }
    
    // Private helper methods
    private void helper() {
        // ...
    }
}

// Create instance
auto obj = new MyClass("example");
obj.value = 42;  // Uses property setter
int v = obj.value;  // Uses property getter
```

### Inheritance

```d
class Base {
    protected int _baseValue;
    
    this() {
        _baseValue = 0;
    }
    
    void baseMethod() {
        // ...
    }
}

class Derived : Base {
    private int _derivedValue;
    
    this() {
        super();  // Call base constructor
        _derivedValue = 0;
    }
    
    // Add new methods
    void derivedMethod() {
        // Can access _baseValue (protected)
    }
    
    // Override base methods
    override void baseMethod() {
        super.baseMethod();  // Call base implementation
        // Additional behavior
    }
}
```

### Interfaces

```d
interface IClickable {
    bool handleClick(int x, int y);
}

interface IDrawable {
    void draw();
}

class MyWidget : Widget, IClickable, IDrawable {
    override bool handleClick(int x, int y) {
        // Implementation
        return true;
    }
    
    override void draw() {
        // Implementation
    }
}
```

### Abstract Classes

```d
abstract class Shape {
    // Abstract method - must implement in derived classes
    abstract double area();
    
    // Concrete method - shared by all
    void describe() {
        import std.stdio;
        writeln("Area: ", area());
    }
}

class Circle : Shape {
    double radius;
    
    this(double r) {
        radius = r;
    }
    
    override double area() {
        return 3.14159 * radius * radius;
    }
}

// Cannot do: auto s = new Shape();  // Error - abstract!
auto c = new Circle(5.0);  // OK
```

---

## dlangui Core Concepts

### Application Template

```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // Create window
    Window window = Platform.instance.createWindow("My App"d, null);
    
    // Create UI
    auto layout = new VerticalLayout();
    layout.addChild(new TextWidget(null, "Hello"d));
    
    // Set as window content
    window.mainWidget = layout;
    
    // Show and run
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

### Window Creation Options

```d
// Basic window
Window window = Platform.instance.createWindow("Title"d, null);

// With specific size
Window window = Platform.instance.createWindow(
    "Title"d,           // Title
    null,               // Parent window
    WindowFlag.Resizable,  // Flags
    800,                // Width
    600                 // Height
);

// Window flags
WindowFlag.Resizable
WindowFlag.Fullscreen
WindowFlag.Modal
```

---

## Common Widgets

### Button

```d
// Simple button
auto btn = new Button();
btn.text = "Click Me"d;

// Button with constructor
auto btn = new Button("btnId", "Click Me"d);

// Styled button
auto btn = new Button("btnId", "Save"d);
btn.backgroundColor = 0x007BFF;
btn.textColor = 0xFFFFFF;
btn.fontSize = 16;
btn.margins = Rect(5, 5, 5, 5);
btn.padding = Rect(15, 8, 15, 8);

// With click handler
btn.click = delegate(Widget w) {
    import std.stdio;
    writeln("Clicked!");
    return true;
};
```

### TextWidget (Static Text)

```d
auto text = new TextWidget();
text.text = "Display Text"d;
text.fontSize = 20;
text.textColor = 0x000000;
text.alignment = Align.Center;

// Constructor form
auto text = new TextWidget("id", "Text"d);
```

### EditLine (Single-line Input)

```d
auto edit = new EditLine();
edit.text = "Initial value"d;

// Get value
dstring value = edit.text;

// Set value
edit.text = "New value"d;

// With placeholder (hint)
edit.hint = "Enter name..."d;

// Read-only
edit.readOnly = true;

// With constructor
auto edit = new EditLine("editId", "Initial"d);
```

### EditBox (Multi-line Editor)

```d
auto editor = new EditBox("editorId");
editor.text = "Line 1\nLine 2\nLine 3"d;
editor.layoutWidth = FILL_PARENT;
editor.layoutHeight = FILL_PARENT;

// Get/set text
dstring content = editor.text;
editor.text = "New content"d;
```

### CheckBox

```d
auto checkbox = new CheckBox("cbId", "Label text"d);

// Get/set state
bool isChecked = checkbox.checked;
checkbox.checked = true;

// Change event
checkbox.checkChange = delegate(Widget w, bool checked) {
    import std.stdio;
    writeln("Checked: ", checked);
    return true;
};
```

### RadioButton

```d
// Create radio buttons (only one in group can be selected)
auto radio1 = new RadioButton("r1", "Option 1"d);
auto radio2 = new RadioButton("r2", "Option 2"d);
auto radio3 = new RadioButton("r3", "Option 3"d);

// Check state
bool selected = radio1.checked;
```

### ComboBox (Dropdown)

```d
auto combo = new ComboBox("comboId", 
    ["Item 1"d, "Item 2"d, "Item 3"d]);

// Get selected index
int selected = combo.selectedItemIndex;

// Set selected
combo.selectedItemIndex = 1;

// Add items
combo.items = ["New 1"d, "New 2"d];

// Selection change event
combo.itemClick = delegate(Widget w, int index) {
    import std.stdio;
    writeln("Selected: ", index);
    return true;
};
```

---

## Layout Widgets

### VerticalLayout

```d
auto layout = new VerticalLayout();
layout.margins = Rect(10, 10, 10, 10);
layout.padding = Rect(5, 5, 5, 5);
layout.backgroundColor = 0xF0F0F0;

// Add children
layout.addChild(new TextWidget(null, "First"d));
layout.addChild(new TextWidget(null, "Second"d));
layout.addChild(new TextWidget(null, "Third"d));

// Widgets are stacked vertically
```

### HorizontalLayout

```d
auto layout = new HorizontalLayout();
layout.margins = Rect(10, 10, 10, 10);
layout.padding = Rect(5, 5, 5, 5);

// Add children
layout.addChild(new Button(null, "One"d));
layout.addChild(new Button(null, "Two"d));
layout.addChild(new Button(null, "Three"d));

// Widgets are arranged horizontally
```

### TableLayout

```d
auto table = new TableLayout();
table.colCount = 2;  // CRITICAL - must set column count!
table.margins = Rect(10, 10, 10, 10);

// Add pairs (label, input)
table.addChild(new TextWidget(null, "Name:"d));
table.addChild(new EditLine());

table.addChild(new TextWidget(null, "Email:"d));
table.addChild(new EditLine());

table.addChild(new TextWidget(null, "Phone:"d));
table.addChild(new EditLine());

// Arranges in table with specified columns
```

### FrameLayout (Overlapping)

```d
auto frame = new FrameLayout();

// Add layers (draw order)
frame.addChild(backgroundWidget);
frame.addChild(foregroundWidget);

// Widgets overlap, later additions draw on top
```

### Nested Layouts

```d
auto main = new VerticalLayout();

// Add title
main.addChild(new TextWidget(null, "Title"d));

// Add horizontal section
auto buttonRow = new HorizontalLayout();
buttonRow.addChild(new Button(null, "Save"d));
buttonRow.addChild(new Button(null, "Cancel"d));
main.addChild(buttonRow);

// Add table section
auto form = new TableLayout();
form.colCount = 2;
form.addChild(new TextWidget(null, "Field:"d));
form.addChild(new EditLine());
main.addChild(form);
```

---

## Event Handling

### Click Events

```d
button.click = delegate(Widget w) {
    // Handle click
    // w is the widget that was clicked
    return true;  // Signal handled
};

// Or use method reference
class MyHandler {
    bool handleClick(Widget w) {
        // Handle click
        return true;
    }
}

auto handler = new MyHandler();
button.click = &handler.handleClick;
```

### Check Change Events

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

### Focus Events

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

### Key Events

```d
widget.keyEvent = delegate(Widget source, KeyEvent event) {
    if (event.action == KeyAction.KeyDown) {
        if (event.keyCode == KeyCode.KEY_ENTER) {
            // Enter key pressed
            return true;
        }
    }
    return false;  // Not handled
};
```

### Mouse Events

```d
widget.mouseEvent = delegate(Widget source, MouseEvent event) {
    if (event.action == MouseAction.ButtonDown) {
        int x = event.x;
        int y = event.y;
        // Handle mouse down
        return true;
    }
    return false;
};
```

---

## Color Reference

### Color Format

Colors are 32-bit ARGB: `0xAARRGGBB`

```d
// Fully opaque colors (AA = FF)
0xFF000000  // Black
0xFFFFFFFF  // White
0xFFFF0000  // Red
0xFF00FF00  // Green
0xFF0000FF  // Blue
0xFFFFFF00  // Yellow
0xFFFF00FF  // Magenta
0xFF00FFFF  // Cyan

// Common UI colors
0xFFF0F0F0  // Light gray background
0xFF333333  // Dark gray text
0xFF007BFF  // Bootstrap blue
0xFF28A745  // Bootstrap green (success)
0xFFDC3545  // Bootstrap red (danger)
0xFFFFC107  // Bootstrap yellow (warning)
0xFF17A2B8  // Bootstrap cyan (info)

// Semi-transparent (AA = 80 = 50% opacity)
0x80FF0000  // Semi-transparent red
```

---

## Common Patterns

### Form with Validation

```d
class ValidatedForm : VerticalLayout {
    private EditLine _nameEdit;
    private EditLine _emailEdit;
    private Button _submitBtn;
    
    this() {
        super();
        
        auto table = new TableLayout();
        table.colCount = 2;
        
        table.addChild(new TextWidget(null, "Name:"d));
        _nameEdit = new EditLine();
        table.addChild(_nameEdit);
        
        table.addChild(new TextWidget(null, "Email:"d));
        _emailEdit = new EditLine();
        table.addChild(_emailEdit);
        
        addChild(table);
        
        _submitBtn = new Button(null, "Submit"d);
        _submitBtn.click = &onSubmit;
        addChild(_submitBtn);
    }
    
    private bool onSubmit(Widget w) {
        if (validate()) {
            // Process form
        }
        return true;
    }
    
    private bool validate() {
        if (_nameEdit.text.length == 0) {
            // Show error
            return false;
        }
        
        import std.string;
        if (indexOf(_emailEdit.text, '@') < 0) {
            // Show error
            return false;
        }
        
        return true;
    }
}
```

### Dynamic List

```d
class DynamicList : VerticalLayout {
    private Widget[] _items;
    private VerticalLayout _container;
    private EditLine _input;
    private Button _addBtn;
    
    this() {
        super();
        
        _container = new VerticalLayout();
        _input = new EditLine();
        _addBtn = new Button(null, "Add"d);
        
        _addBtn.click = &onAdd;
        
        auto inputRow = new HorizontalLayout();
        inputRow.addChild(_input);
        inputRow.addChild(_addBtn);
        
        addChild(inputRow);
        addChild(_container);
    }
    
    private bool onAdd(Widget w) {
        if (_input.text.length > 0) {
            auto item = new TextWidget(null, _input.text);
            _items ~= item;
            _container.addChild(item);
            _input.text = ""d;
        }
        return true;
    }
    
    void clear() {
        _container.removeAllChildren();
        _items = [];
    }
}
```

### Modal Confirmation

```d
void showConfirmation(Window window, dstring message, 
                      void delegate() onConfirm) {
    window.showMessageBox(
        UIString.fromRaw("Confirm"d),
        UIString.fromRaw(message),
        [ACTION_YES, ACTION_NO],
        0,
        delegate(const Action result) {
            if (result.id == StandardAction.Yes) {
                onConfirm();
            }
            return true;
        }
    );
}

// Usage:
showConfirmation(window, "Delete this item?"d, delegate() {
    // Perform deletion
});
```

---

## Troubleshooting

### Widget doesn't appear

**Check:**
1. Did you add it to a layout? `layout.addChild(widget)`
2. Did you set layout as mainWidget? `window.mainWidget = layout`
3. Did you call `window.show()`?
4. Is widget size zero? Try setting `layoutWidth = FILL_PARENT`

### Text shows as ??? or doesn't compile

**Problem:** Missing 'd' suffix on strings
```d
// WRONG
widget.text = "Hello";

// CORRECT
widget.text = "Hello"d;
```

### TableLayout shows widgets wrong

**Problem:** Forgot to set `colCount`
```d
auto table = new TableLayout();
table.colCount = 2;  // MUST SET THIS!
```

### Click handler doesn't work

**Problem:** Not returning `true`
```d
button.click = delegate(Widget w) {
    // Do something
    return true;  // MUST RETURN TRUE!
};
```

### Can't access widget properties

**Problem:** Widget might be null
```d
auto widget = layout.childById("myId");
if (widget !is null) {  // Check first!
    widget.text = "Safe"d;
}
```

### Layout doesn't fill window

**Problem:** Need to set layout sizes
```d
layout.layoutWidth = FILL_PARENT;
layout.layoutHeight = FILL_PARENT;
```

---

## Code Snippets

### Minimal App

```d
import dlangui;
mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    Window window = Platform.instance.createWindow("App"d, null);
    window.mainWidget = new Button(null, "Hello"d);
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

### Custom Widget Template

```d
class MyWidget : VerticalLayout {
    private TextWidget _label;
    private Button _button;
    
    this() {
        super();
        
        _label = new TextWidget(null, "Label"d);
        _button = new Button(null, "Click"d);
        _button.click = &onClick;
        
        addChild(_label);
        addChild(_button);
    }
    
    private bool onClick(Widget w) {
        _label.text = "Clicked!"d;
        return true;
    }
}
```

### Form Helper

```d
void addFormRow(TableLayout table, dstring label, EditLine edit) {
    table.addChild(new TextWidget(null, label));
    edit.layoutWidth = FILL_PARENT;
    table.addChild(edit);
}

// Usage:
auto table = new TableLayout();
table.colCount = 2;
addFormRow(table, "Name:"d, nameEdit);
addFormRow(table, "Email:"d, emailEdit);
```

### Widget Property Chaining

```d
auto widget = (new Button())
    .text("Styled"d)
    .textColor(0xFFFFFF)
    .backgroundColor(0x007BFF)
    .margins(Rect(5, 5, 5, 5))
    .padding(Rect(15, 8, 15, 8))
    .fontSize(16);
```

---

## Widget Properties Reference

### Common to All Widgets

```d
widget.id = "uniqueId";
widget.text = "Display text"d;
widget.margins = Rect(10, 10, 10, 10);  // left, top, right, bottom
widget.padding = Rect(5, 5, 5, 5);
widget.backgroundColor = 0xFFFFFF;
widget.textColor = 0x000000;
widget.fontSize = 16;
widget.minWidth = 100;
widget.minHeight = 50;
widget.layoutWidth = FILL_PARENT;  // or WRAP_CONTENT
widget.layoutHeight = WRAP_CONTENT;
widget.alignment = Align.Center;  // or Align.Left, Align.Right
widget.visibility = Visibility.Visible;  // or Gone, Hidden
```

### Rect Constructor

```d
Rect(10, 10, 10, 10)  // left, top, right, bottom
Rect(10)              // Same value for all sides
```

### Finding Widgets

```d
// By ID
Widget widget = layout.childById("widgetId");

// With type cast
Button btn = cast(Button)layout.childById("btnId");

// Template syntax (safer)
Button btn = layout.childById!Button("btnId");

// Always check for null!
if (btn !is null) {
    btn.text = "Found"d;
}
```

---

## Remember

1. **Always use `"text"d`** for widget strings (dstring type)
2. **Return `true`** from event handlers
3. **Call `window.show()`** before message loop
4. **Set `colCount`** for TableLayout
5. **Check for `null`** when finding widgets
6. **Type code yourself** - don't copy-paste!

---

*Version 2.0 - October 2025*  
*Programmatic UI Only - No DML*

