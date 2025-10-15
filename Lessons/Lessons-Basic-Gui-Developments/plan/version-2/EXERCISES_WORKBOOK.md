# Student Exercises Workbook - Version 2
## Learning OOP Through GUI Development

This workbook contains 120+ hands-on exercises organized by lesson. Each exercise builds practical skills while discovering OOP concepts naturally.

**Philosophy:** Type every line yourself. Break things. Experiment. Learn by doing.

---

## Table of Contents

- [Lesson 1: First Windows and Widgets](#lesson-1-exercises)
- [Lesson 2: Layouts](#lesson-2-exercises)
- [Lesson 3: Events and Interactivity](#lesson-3-exercises)
- [Lesson 4: Building Complex UIs](#lesson-4-exercises)
- [Lesson 5: Custom Widgets - Why Classes](#lesson-5-exercises)
- [Lesson 6: Encapsulation](#lesson-6-exercises)
- [Lesson 7: Methods and Behavior](#lesson-7-exercises)
- [Lesson 8: Multiple Instances](#lesson-8-exercises)
- [Lesson 9: Inheritance](#lesson-9-exercises)
- [Lesson 10: Polymorphism](#lesson-10-exercises)
- [Lesson 11: Abstract Classes](#lesson-11-exercises)
- [Lesson 12: Interfaces](#lesson-12-exercises)
- [Lesson 13: Composition](#lesson-13-exercises)
- [Lesson 14: List Widgets](#lesson-14-exercises)
- [Lesson 15: Grid Widgets](#lesson-15-exercises)
- [Lesson 16: Tree Widgets](#lesson-16-exercises)
- [Lesson 17: Dialogs](#lesson-17-exercises)
- [Lesson 18: Event Architecture](#lesson-18-exercises)
- [Lesson 19: Advanced Patterns](#lesson-19-exercises)
- [Lesson 20: Final Project](#final-project)

---

## LESSON 1 EXERCISES

### Exercise 1.1: Hello Window (Easy, 10 min)

Create your first dlangui window with a button.

**Requirements:**
```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // TODO: Create window with title "Exercise 1.1 - [Your Name]"
    // TODO: Create a Button with text "Hello, GUI World!"
    // TODO: Set button as window's mainWidget
    // TODO: Show window and enter message loop
    
    return 0;  // Replace with proper return
}
```

**Expected:** A window with a button displays when you run `dub run`.

### Exercise 1.2: Button Properties (Easy, 15 min)

Experiment with button properties.

**Requirements:**
Create a button with:
- Text: "Styled Button"
- Text color: Blue (0x0000FF)
- Background color: Light yellow (0xFFFFCC)
- Font size: 20
- Margins: 30 pixels all sides
- Padding: 15 pixels all sides

**Questions to answer:**
1. What happens if you remove margins?
2. What happens if you remove padding?
3. Try `Rect(10, 20, 30, 40)` for margins - which number controls which side?

### Exercise 1.3: Multiple Widgets Experiment (Medium, 20 min)

**Challenge:** Try to display 3 different TextWidgets in a window.

```d
// TODO: Create 3 TextWidget objects
// TODO: Try to display all 3 (you'll discover you can't!)
// TODO: Document what happens
```

**Discovery:** You can only have ONE mainWidget. This sets up the need for Lesson 2!

### Exercise 1.4: Property Chaining Practice (Medium, 15 min)

Create a button using method chaining:

```d
window.mainWidget = (new Button())
    .text("Chained Properties"d)
    .textColor(0xFF0000)
    .backgroundColor(0xCCCCFF)
    .margins(Rect(20, 20, 20, 20))
    .padding(Rect(10, 10, 10, 10))
    .fontSize(18);
```

**Task:** Create 3 different styled buttons using chaining (only one will display).

### Exercise 1.5: Color Explorer (Medium, 20 min)

Create buttons with 5 different colors. Research hex color codes.

**Colors to try:**
- Red: 0xFF0000
- Green: 0x00FF00
- Blue: 0x0000FF
- Purple: 0x800080
- Orange: 0xFFA500

**Bonus:** What does the format 0xAARRGGBB mean? Try semi-transparent colors!

### Homework 1: Widget Showcase (Hard, 60 min)

Create a program that showcases different widget types (one at a time since no layouts yet):

**Try these widgets:**
1. `Button` with custom styling
2. `TextWidget` showing your name
3. `EditLine` (input field)
4. `CheckBox` with label
5. `RadioButton`

**Document:**
- Screenshot of each
- Code for each
- Notes on what properties each supports

---

## LESSON 2 EXERCISES

### Exercise 2.1: Vertical Stack (Easy, 15 min)

Create a VerticalLayout with 5 TextWidgets.

```d
auto layout = new VerticalLayout();
layout.backgroundColor = 0xF0F0F0;
layout.margins = Rect(10, 10, 10, 10);
layout.padding = Rect(5, 5, 5, 5);

// TODO: Add 5 TextWidgets with different texts
// TODO: Give each TextWidget a different background color

window.mainWidget = layout;
```

### Exercise 2.2: Button Row (Easy, 15 min)

Create a HorizontalLayout with 4 buttons representing actions: "New", "Open", "Save", "Exit".

**Requirements:**
- Use HorizontalLayout
- Style the layout
- Make buttons visually consistent

### Exercise 2.3: Simple Form (Medium, 30 min)

Create a form with TableLayout:

```d
auto form = new TableLayout();
form.colCount = 2;  // IMPORTANT!

// TODO: Add 3 rows:
// Row 1: "Name:" label and EditLine
// Row 2: "Email:" label and EditLine
// Row 3: "Age:" label and EditLine
```

### Exercise 2.4: Nested Layouts (Medium, 30 min)

Create this structure:

```
VerticalLayout (main)
  ├─ TextWidget (title)
  ├─ HorizontalLayout
  │   ├─ Button 1
  │   ├─ Button 2
  │   └─ Button 3
  └─ TableLayout (2 columns, 2 rows)
      ├─ Label + Input (row 1)
      └─ Label + Input (row 2)
```

### Exercise 2.5: Calculator Layout (Hard, 45 min)

Build a calculator button layout:

```
┌─────────────────┐
│ [  Display  ]   │
├─────────────────┤
│ [7] [8] [9] [/] │
│ [4] [5] [6] [*] │
│ [1] [2] [3] [-] │
│ [0] [.] [=] [+] │
└─────────────────┘
```

**Hints:**
- Use VerticalLayout as main container
- Display is a TextWidget or EditLine
- Each row of buttons is a HorizontalLayout
- Don't worry about functionality yet!

### Homework 2: Login Screen (Hard, 90 min)

Create a professional-looking login screen:

**Requirements:**
- Title: "Welcome"
- Username field (label + input)
- Password field (label + input)
- "Remember me" CheckBox
- Two buttons: "Login" and "Cancel"
- Proper spacing and colors
- Centered on window

**Bonus:** Add a "Forgot Password?" button styled as a link.

---

## LESSON 3 EXERCISES

### Exercise 3.1: Click Counter (Easy, 15 min)

Create a button that counts clicks:

```d
int count = 0;
auto button = new Button(null, "Clicks: 0"d);

button.click = delegate(Widget w) {
    count++;
    import std.conv;
    button.text = "Clicks: "d ~ to!dstring(count);
    return true;
};
```

**Task:** Add a "Reset" button that sets count back to 0.

### Exercise 3.2: Two-Way Counter (Easy, 20 min)

Create:
- A display showing the count
- An "Increment" button
- A "Decrement" button
- A "Reset" button

### Exercise 3.3: Simple Calculator (Medium, 45 min)

Build a working calculator with basic operations.

**Requirements:**
- Number buttons (0-9)
- Operator buttons (+, -, *, /)
- Equals button
- Clear button
- Display area

**Hint:**
```d
double firstNumber = 0;
dstring operation = ""d;
bool newNumber = true;

// On number button click:
if (newNumber) {
    display.text = numberText;
    newNumber = false;
} else {
    display.text = display.text ~ numberText;
}

// On operator click:
firstNumber = to!double(display.text);
operation = operatorText;
newNumber = true;

// On equals click:
// Calculate based on operation
```

### Exercise 3.4: Text Input Mirror (Easy, 15 min)

Create two EditLine widgets. When user types in the first, update the second automatically.

```d
auto edit1 = new EditLine();
auto edit2 = new EditLine();

// TODO: Add event handler to mirror text
```

### Exercise 3.5: Color Mixer (Medium, 35 min)

Create RGB color mixer:

**Requirements:**
- 3 EditLine widgets for R, G, B (0-255)
- A preview widget showing the color
- Update preview when any value changes
- Validate input (must be 0-255)

```d
uint getColorValue() {
    import std.conv;
    int r = to!int(redEdit.text);
    int g = to!int(greenEdit.text);
    int b = to!int(blueEdit.text);
    
    // Validate range
    if (r < 0) r = 0; if (r > 255) r = 255;
    if (g < 0) g = 0; if (g > 255) g = 255;
    if (b < 0) b = 0; if (b > 255) b = 255;
    
    return 0xFF000000 | (r << 16) | (g << 8) | b;
}
```

### Homework 3: Quiz Application (Hard, 120 min)

Create a simple quiz app:

**Requirements:**
- Display question text
- 4 answer buttons (or radio buttons)
- "Next Question" button
- Score display
- At least 5 questions
- Show final score at end

**Example questions:**
1. "What does OOP stand for?" 
   - Object Oriented Programming ✓
   - Only One Program
   - Open Operating Protocol
   - Optimized Output Process

**Bonus:** 
- Highlight correct/incorrect answers
- Timer for each question
- Restart quiz button

---

## LESSON 4 EXERCISES

### Exercise 4.1: Form Validator (Medium, 30 min)

Create a form that validates before submission:

```d
auto nameEdit = new EditLine();
auto emailEdit = new EditLine();
auto submitBtn = new Button(null, "Submit"d);

submitBtn.click = delegate(Widget w) {
    // TODO: Validate name is not empty
    // TODO: Validate email contains '@'
    // TODO: Show error if invalid
    // TODO: Show success if valid
    return true;
};
```

### Exercise 4.2: Multi-Field Converter (Medium, 40 min)

Create temperature converter with all three units:

```d
auto celsiusEdit = new EditLine();
auto fahrenheitEdit = new EditLine();
auto kelvinLabel = new TextWidget();  // Read-only

// TODO: When celsius changes, update fahrenheit and kelvin
// TODO: When fahrenheit changes, update celsius and kelvin
```

### Exercise 4.3: Dynamic Widget Creator (Hard, 45 min)

Create an app that adds widgets dynamically:

```d
auto container = new VerticalLayout();
auto addButton = new Button(null, "Add Text Widget"d);

addButton.click = delegate(Widget w) {
    // TODO: Create new TextWidget
    // TODO: Add to container
    // TODO: Increment counter
    return true;
};
```

### Exercise 4.4: Settings Panel (Hard, 50 min)

Build a settings panel with multiple sections:

**Requirements:**
- General settings (3-4 checkboxes)
- Appearance settings (color choices)
- Advanced settings (text inputs)
- Save and Cancel buttons
- Apply changes button

### Homework 4: Contact Form (Hard, 90 min)

Create a complete contact form application:

**Requirements:**
- First name, last name, email, phone, address, city, zip
- All fields in TableLayout
- Validate email format
- Validate phone format
- Submit button
- Clear button
- Show summary on submit

**Validation:**
```d
bool isValidEmail(dstring email) {
    import std.string;
    return indexOf(email, '@') > 0;
}

bool isValidPhone(dstring phone) {
    // Check if contains only digits and dashes
    // At least 10 digits
}
```

---

## LESSON 5 EXERCISES

### Exercise 5.1: First Custom Widget (Easy, 20 min)

Create `LabeledInput` class:

```d
class LabeledInput : HorizontalLayout {
    TextWidget label;
    EditLine input;
    
    this(dstring labelText) {
        super();
        
        // TODO: Create label widget
        // TODO: Create input widget
        // TODO: Add both to layout
    }
}

// Usage:
layout.addChild(new LabeledInput("Name:"d));
```

### Exercise 5.2: Reusable Button (Easy, 20 min)

Create `ColoredButton` class:

```d
class ColoredButton : Button {
    this(dstring text, uint color) {
        super(null, text);
        // TODO: Set background color
        // TODO: Set text color to white
        // TODO: Set padding
    }
}
```

### Exercise 5.3: Labeled Checkbox (Medium, 25 min)

Create custom checkbox with label:

```d
class LabeledCheckBox : HorizontalLayout {
    CheckBox checkbox;
    TextWidget label;
    
    this(dstring labelText) {
        // TODO: Implement
    }
    
    bool isChecked() {
        return checkbox.checked;
    }
    
    void setChecked(bool value) {
        checkbox.checked = value;
    }
}
```

### Exercise 5.4: Icon Button (Medium, 30 min)

Create button with icon and text:

```d
class StyledButton : HorizontalLayout {
    TextWidget icon;  // Use unicode symbols as "icons"
    TextWidget label;
    
    this(dstring iconText, dstring labelText) {
        // TODO: Implement
        // Icons could be: ✓ ✗ ➕ ➖ ⚙ 🏠
    }
}
```

### Exercise 5.5: Number Spinner (Hard, 45 min)

Create a number input with up/down buttons:

```d
class NumberSpinner : HorizontalLayout {
    TextWidget valueDisplay;
    Button upBtn;
    Button downBtn;
    int value;
    
    this(int initialValue) {
        // TODO: Create widgets
        // TODO: Wire up buttons to increment/decrement
        // TODO: Update display
    }
}
```

### Homework 5: Widget Library (Hard, 120 min)

Create a library of at least 5 custom widgets:

1. `LabeledInput` - label + input field
2. `LabeledCheckBox` - checkbox + label
3. `ColorPicker` - R/G/B inputs + preview
4. `PasswordInput` - input + show/hide button
5. `TitleBar` - styled title widget

**Then:** Build a complete form using ONLY your custom widgets.

---

## LESSON 6 EXERCISES

### Exercise 6.1: Private Members (Easy, 20 min)

Add encapsulation to `LabeledInput`:

```d
class LabeledInput : HorizontalLayout {
    private TextWidget _label;    // Private!
    private EditLine _input;      // Private!
    
    this(dstring labelText) {
        super();
        _label = new TextWidget(null, labelText);
        _input = new EditLine();
        addChild(_label);
        addChild(_input);
    }
    
    // Public interface
    dstring getValue() {
        return _input.text;
    }
    
    void setValue(dstring value) {
        _input.text = value;
    }
}
```

### Exercise 6.2: Properties (Medium, 30 min)

Convert to properties:

```d
class LabeledInput : HorizontalLayout {
    private TextWidget _label;
    private EditLine _input;
    
    this(dstring labelText) {
        // ... initialization ...
    }
    
    @property dstring value() {
        return _input.text;
    }
    
    @property void value(dstring v) {
        _input.text = v;
    }
    
    @property dstring label() {
        return _label.text;
    }
    
    @property void label(dstring v) {
        _label.text = v;
    }
}

// Usage:
auto input = new LabeledInput("Name:"d);
input.value = "John"d;  // Uses property setter
writeln(input.value);   // Uses property getter
```

### Exercise 6.3: Validated Input (Medium, 35 min)

Create input with validation:

```d
class ValidatedInput : VerticalLayout {
    private TextWidget _label;
    private EditLine _input;
    private TextWidget _errorMsg;
    private bool _isValid;
    
    this(dstring labelText) {
        super();
        // TODO: Create widgets
        // _errorMsg is initially hidden or empty
    }
    
    @property dstring value() {
        return _input.text;
    }
    
    @property void value(dstring v) {
        _input.text = v;
        validate();
    }
    
    void validate() {
        // TODO: Override in derived classes
        _isValid = _input.text.length > 0;
        if (!_isValid) {
            _errorMsg.text = "Required field"d;
            _errorMsg.textColor = 0xFF0000;
        } else {
            _errorMsg.text = ""d;
        }
    }
    
    @property bool isValid() {
        return _isValid;
    }
}
```

### Exercise 6.4: Range-Validated Number (Hard, 40 min)

Create number input with min/max validation:

```d
class NumberInput : HorizontalLayout {
    private TextWidget _label;
    private EditLine _input;
    private int _value;
    private int _minValue;
    private int _maxValue;
    private TextWidget _errorLabel;
    
    this(dstring labelText, int min, int max) {
        // TODO: Implement full validation
    }
    
    @property int value() {
        // TODO: Parse and validate input
        // Return _value if valid, or last valid value
    }
    
    @property void value(int v) {
        // TODO: Validate range and set
    }
    
    @property bool isValid() {
        // TODO: Check if current input is valid
    }
}
```

### Homework 6: Password Strength Checker (Hard, 90 min)

Create password input with strength validation:

```d
class PasswordInput : VerticalLayout {
    private EditLine _passwordField;
    private TextWidget _strengthLabel;
    private Widget _strengthBar;  // Colored bar showing strength
    private bool _showPassword;
    private Button _toggleButton;
    
    this() {
        // TODO: Implement all features
    }
    
    @property dstring password() {
        // TODO: Return password
    }
    
    @property int strength() {
        // TODO: Calculate strength (0-100)
        // Check: length, uppercase, lowercase, numbers, symbols
    }
    
    private void updateStrength() {
        // TODO: Update strength display
        // Weak (red), Medium (yellow), Strong (green)
    }
    
    void toggleVisibility() {
        // TODO: Show/hide password
    }
}
```

**Requirements:**
- Password strength calculation
- Visual strength indicator
- Show/hide password toggle
- Minimum length requirement
- Must contain uppercase, lowercase, number

---

## LESSON 7 EXERCISES

### Exercise 7.1: Counter Widget (Easy, 20 min)

Create self-contained counter:

```d
class Counter : VerticalLayout {
    private int _count;
    private TextWidget _display;
    private Button _incBtn;
    private Button _decBtn;
    private Button _resetBtn;
    
    this() {
        super();
        _count = 0;
        
        _display = new TextWidget(null, "Count: 0"d);
        _incBtn = new Button(null, "+"d);
        _decBtn = new Button(null, "-"d);
        _resetBtn = new Button(null, "Reset"d);
        
        // Wire up events
        _incBtn.click = &onIncrement;
        _decBtn.click = &onDecrement;
        _resetBtn.click = &onReset;
        
        addChild(_display);
        auto buttons = new HorizontalLayout();
        buttons.addChild(_incBtn);
        buttons.addChild(_decBtn);
        buttons.addChild(_resetBtn);
        addChild(buttons);
    }
    
    private bool onIncrement(Widget w) {
        _count++;
        updateDisplay();
        return true;
    }
    
    private bool onDecrement(Widget w) {
        _count--;
        updateDisplay();
        return true;
    }
    
    private bool onReset(Widget w) {
        _count = 0;
        updateDisplay();
        return true;
    }
    
    private void updateDisplay() {
        import std.conv;
        _display.text = "Count: "d ~ to!dstring(_count);
    }
    
    @property int count() { return _count; }
}
```

### Exercise 7.2: Todo Item (Medium, 30 min)

Create todo item widget:

```d
class TodoItem : HorizontalLayout {
    private CheckBox _checkbox;
    private TextWidget _text;
    private Button _deleteBtn;
    
    // Callback for when delete is clicked
    private bool delegate() _onDelete;
    
    this(dstring todoText) {
        // TODO: Create widgets
        // TODO: Wire checkbox to updateStyle()
        // TODO: Wire delete button to handleDelete()
    }
    
    void setOnDelete(bool delegate() handler) {
        _onDelete = handler;
    }
    
    bool isCompleted() {
        return _checkbox.checked;
    }
    
    void markCompleted() {
        _checkbox.checked = true;
        updateStyle();
    }
    
    private void updateStyle() {
        // TODO: Gray out text if completed
    }
    
    private bool handleDelete(Widget w) {
        if (_onDelete !is null) {
            return _onDelete();
        }
        return true;
    }
}
```

### Exercise 7.3: Color Picker Widget (Medium, 40 min)

Self-contained color picker:

```d
class ColorPicker : VerticalLayout {
    private EditLine _redInput;
    private EditLine _greenInput;
    private EditLine _blueInput;
    private Widget _preview;
    private uint _currentColor;
    
    // Callback for color changes
    private void delegate(uint color) _onColorChange;
    
    this() {
        // TODO: Create all widgets
        // TODO: Wire inputs to updateColor()
        // TODO: Show preview
    }
    
    void setOnColorChange(void delegate(uint) handler) {
        _onColorChange = handler;
    }
    
    @property uint color() {
        return _currentColor;
    }
    
    @property void color(uint c) {
        _currentColor = c;
        updateInputs();
        updatePreview();
    }
    
    private void updateColor() {
        // Parse RGB values
        // Calculate color
        // Update preview
        // Call callback
    }
    
    private void updateInputs() {
        // Set input values from _currentColor
    }
    
    private void updatePreview() {
        _preview.backgroundColor = _currentColor;
    }
}
```

### Homework 7: Calculator Widget (Hard, 120 min)

Create complete calculator as a single widget class:

```d
class Calculator : VerticalLayout {
    private TextWidget _display;
    private Button[10] _numberButtons;
    private Button[5] _operatorButtons;  // +, -, *, /, =
    private Button _clearButton;
    
    private double _firstNumber;
    private dstring _operator;
    private bool _startNewNumber;
    
    this() {
        // TODO: Create all widgets
        // TODO: Organize layout
        // TODO: Wire all button events
    }
    
    private bool onNumberClick(int number) {
        // TODO: Handle number button
    }
    
    private bool onOperatorClick(dstring op) {
        // TODO: Handle operator button
    }
    
    private bool onEquals(Widget w) {
        // TODO: Calculate result
    }
    
    private bool onClear(Widget w) {
        // TODO: Clear everything
    }
    
    private double calculate(double a, double b, dstring op) {
        // TODO: Perform calculation
    }
}
```

---

## LESSON 8 EXERCISES

### Exercise 8.1: Multiple Counters (Easy, 20 min)

Create 5 independent Counter widgets:

```d
auto layout = new VerticalLayout();

for (int i = 0; i < 5; i++) {
    layout.addChild(new Counter());
}
```

**Observe:** Each counter has independent state!

### Exercise 8.2: Contact List Array (Medium, 30 min)

```d
class ContactDisplay : HorizontalLayout {
    private TextWidget _name;
    private TextWidget _phone;
    
    this(dstring name, dstring phone) {
        super();
        _name = new TextWidget(null, name);
        _phone = new TextWidget(null, phone);
        addChild(_name);
        addChild(_phone);
    }
}

// Create array of contacts
ContactDisplay[] contacts;
contacts ~= new ContactDisplay("Alice"d, "555-1234"d);
contacts ~= new ContactDisplay("Bob"d, "555-5678"d);
contacts ~= new ContactDisplay("Carol"d, "555-9012"d);
```

### Exercise 8.3: Dynamic Todo List (Hard, 45 min)

Build todo list with add/remove:

```d
class TodoList : VerticalLayout {
    private TodoItem[] _items;
    private VerticalLayout _itemContainer;
    private EditLine _newTodoInput;
    private Button _addButton;
    
    this() {
        super();
        _items = [];
        _itemContainer = new VerticalLayout();
        _newTodoInput = new EditLine();
        _addButton = new Button(null, "Add"d);
        
        _addButton.click = &onAdd;
        
        addChild(_newTodoInput);
        addChild(_addButton);
        addChild(_itemContainer);
    }
    
    private bool onAdd(Widget w) {
        if (_newTodoInput.text.length > 0) {
            auto item = new TodoItem(_newTodoInput.text);
            
            // Capture current item for deletion
            item.setOnDelete(delegate() {
                removeItem(item);
                return true;
            });
            
            _items ~= item;
            _itemContainer.addChild(item);
            _newTodoInput.text = ""d;
        }
        return true;
    }
    
    private void removeItem(TodoItem item) {
        // TODO: Remove from array
        // TODO: Remove from container
        _itemContainer.removeChild(item);
        
        // Rebuild array without item
        TodoItem[] newItems;
        foreach (i; _items) {
            if (i !is item) {
                newItems ~= i;
            }
        }
        _items = newItems;
    }
    
    void clearCompleted() {
        // TODO: Remove all completed items
    }
    
    int getTotalCount() {
        return cast(int)_items.length;
    }
    
    int getCompletedCount() {
        int count = 0;
        foreach (item; _items) {
            if (item.isCompleted()) count++;
        }
        return count;
    }
}
```

### Homework 8: Contact Manager (Hard, 150 min)

Build complete contact manager:

```d
class Contact {
    dstring name;
    dstring email;
    dstring phone;
    
    this(dstring n, dstring e, dstring p) {
        name = n;
        email = e;
        phone = p;
    }
}

class ContactCard : VerticalLayout {
    private Contact _contact;
    private TextWidget _nameLabel;
    private TextWidget _emailLabel;
    private TextWidget _phoneLabel;
    private Button _editBtn;
    private Button _deleteBtn;
    
    this(Contact contact) {
        // TODO: Display contact info
        // TODO: Add edit/delete buttons
    }
    
    @property Contact contact() { return _contact; }
}

class ContactManager : VerticalLayout {
    private Contact[] _contacts;
    private VerticalLayout _contactList;
    private EditLine _searchBox;
    private Button _addButton;
    
    this() {
        // TODO: Implement full contact manager
        // - Add contacts
        // - Remove contacts
        // - Search contacts
        // - Edit contacts
    }
}
```

---

## LESSON 9 EXERCISES

### Exercise 9.1: Button Hierarchy (Easy, 25 min)

Create button family:

```d
class ColoredButton : Button {
    this(dstring text, uint color) {
        super(null, text);
        backgroundColor = color;
        textColor = 0xFFFFFF;
        padding = Rect(15, 8, 15, 8);
    }
}

class PrimaryButton : ColoredButton {
    this(dstring text) {
        super(text, 0x007BFF);  // Blue
    }
}

class DangerButton : ColoredButton {
    this(dstring text) {
        super(text, 0xDC3545);  // Red
    }
}

class SuccessButton : ColoredButton {
    this(dstring text) {
        super(text, 0x28A745);  // Green
    }
}

// Usage:
layout.addChild(new PrimaryButton("Save"d));
layout.addChild(new DangerButton("Delete"d));
layout.addChild(new SuccessButton("Confirm"d));
```

### Exercise 9.2: Text Widget Family (Easy, 25 min)

Create text widget hierarchy:

```d
class StyledText : TextWidget {
    this(dstring text) {
        super(null, text);
        // Common styling
    }
}

class TitleText : StyledText {
    this(dstring text) {
        super(text);
        fontSize = 28;
        // TODO: Add bold styling if possible
    }
}

class SubtitleText : StyledText {
    this(dstring text) {
        super(text);
        fontSize = 20;
        textColor = 0x666666;
    }
}

class ErrorText : StyledText {
    this(dstring text) {
        super(text);
        textColor = 0xFF0000;
    }
}
```

### Exercise 9.3: Input Validation Hierarchy (Medium, 40 min)

```d
class ValidatedInput : LabeledInput {
    protected bool _isValid;
    protected TextWidget _errorMsg;
    
    this(dstring label) {
        super(label);
        _isValid = true;
        _errorMsg = new TextWidget();
        _errorMsg.textColor = 0xFF0000;
        addChild(_errorMsg);
    }
    
    // Subclasses override this
    void validate() {
        _isValid = value.length > 0;
    }
    
    @property bool isValid() {
        validate();
        return _isValid;
    }
}

class EmailInput : ValidatedInput {
    this() {
        super("Email:"d);
    }
    
    override void validate() {
        import std.string;
        _isValid = indexOf(value, '@') > 0;
        if (!_isValid) {
            _errorMsg.text = "Invalid email format"d;
        } else {
            _errorMsg.text = ""d;
        }
    }
}

class PhoneInput : ValidatedInput {
    this() {
        super("Phone:"d);
    }
    
    override void validate() {
        // TODO: Validate phone format
    }
}
```

### Homework 9: Complete Widget Library (Hard, 180 min)

Create comprehensive widget library with inheritance:

**Base widgets:**
- `StyledButton` - base for all buttons
- `StyledText` - base for all text
- `StyledInput` - base for all inputs

**Derived widgets:**
At least 3 variants of each base type.

**Application:**
Build a complete form using only your library widgets.

---

## LESSON 10-20 EXERCISES

*[Exercises for remaining lessons follow similar progressive pattern]*

*[Each lesson builds on previous, introducing new concepts through practical needs]*

---

## FINAL PROJECT

### Project Requirements

Build a complete application demonstrating all learned concepts:

**Minimum Requirements:**
1. At least 5 custom widget classes
2. Class hierarchy (minimum 2 levels deep)
3. Use of encapsulation (private members)
4. Properties for clean APIs
5. Event handling
6. Multiple windows or dialogs
7. Data management (arrays of objects)
8. Professional UI design

**Project Ideas:**

1. **Personal Expense Tracker**
   - Add expenses with category
   - View by category
   - Monthly summaries
   - Charts (simple bar representations)

2. **Student Grade Manager**
   - Add students
   - Add grades
   - Calculate averages
   - Display in grid

3. **Recipe Organizer**
   - Add recipes
   - Ingredients list
   - Search recipes
   - Category organization

4. **Task Manager**
   - Add tasks
   - Priority levels
   - Due dates
   - Filter by status

5. **Contact Manager**
   - Add/edit/delete contacts
   - Search functionality
   - Categories
   - Export data

### Evaluation Criteria

- **Architecture (30%):** Clean class design, proper inheritance
- **Functionality (30%):** Works as intended, no crashes
- **Code Quality (20%):** Readable, well-organized, commented
- **UI/UX (20%):** Professional appearance, intuitive

---

**Remember:** The goal is not just to complete exercises, but to understand WHY OOP makes building GUIs easier and more maintainable!

*Version 2.0 - October 2025*

