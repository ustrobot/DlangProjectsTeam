# Course Plan: Learning OOP Through GUI Development
## D Language and dlangui Framework - Version 2

**Course Duration:** 20 lessons × 2 parts × 40 minutes = ~26.5 hours  
**Approach:** Discovery-based learning - OOP emerges from practical needs  
**Focus:** 70% hands-on coding, 30% theory  
**Method:** Programmatic UI only (no DML)

---

## Course Philosophy

Students discover OOP concepts by encountering real problems that OOP solves. Each lesson presents challenges that become increasingly difficult without object-oriented approaches, naturally motivating the introduction of classes, inheritance, polymorphism, and other OOP concepts.

---

## PHASE 1: PURE UI DEVELOPMENT (No OOP Yet)

Students build GUIs using only basic D features they already know: functions, variables, and built-in types. This phase establishes UI fundamentals while creating frustration with code repetition and complexity that OOP will later solve.

---

## **LESSON 1: First Windows and Widgets**

### Part 1: Creating Your First GUI Window (40 min)

**Objectives:**
- Create and display a window
- Add basic widgets (Button, TextWidget)
- Understand widget properties
- Use method chaining

**Topics:**
- `mixin APP_ENTRY_POINT` and `UIAppMain`
- `Platform.instance.createWindow`
- Widget creation with `new`
- Properties: text, margins, padding, colors
- `window.show()` and message loop

**Demo Code:**
```d
import dlangui;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args) {
    // Create window
    Window window = Platform.instance.createWindow("My First GUI"d, null);
    
    // Create a button
    auto button = new Button();
    button.text = "Click Me!"d;
    button.margins = Rect(20, 20, 20, 20);
    button.textColor = 0xFF0000;  // Red
    button.fontSize = 24;
    
    // Set as window content
    window.mainWidget = button;
    
    // Show and run
    window.show();
    return Platform.instance.enterMessageLoop();
}
```

### Part 2: Widget Properties and Styling (40 min)

**Objectives:**
- Experiment with all widget properties
- Use property chaining
- Create multiple widget types
- Understand color format

**Practical Exercise:**
Create windows with different widgets:
- Buttons with various styles
- TextWidgets with different fonts and colors
- Experiment with margins and padding
- Try different window sizes

**Student Task:**
Build a "Widget Showcase" with 5 different buttons, each with unique:
- Text
- Color (textColor and backgroundColor)
- Font size
- Margins
- Padding

---

## **LESSON 2: Layouts - Arranging Multiple Widgets**

### Part 1: VerticalLayout and HorizontalLayout (40 min)

**Objectives:**
- Understand layout containers
- Use VerticalLayout to stack widgets
- Use HorizontalLayout to arrange side-by-side
- Nest layouts

**Topics:**
- Why we need layouts (can't have multiple mainWidgets)
- `VerticalLayout` and `HorizontalLayout`
- `addChild()` method
- Layout properties (margins, padding, backgroundColor)
- Nested layouts

**Demo Code:**
```d
auto layout = new VerticalLayout();
layout.margins = Rect(10, 10, 10, 10);
layout.padding = Rect(5, 5, 5, 5);
layout.backgroundColor = 0xF0F0F0;

// Add widgets
layout.addChild(new TextWidget(null, "First Item"d));
layout.addChild(new TextWidget(null, "Second Item"d));
layout.addChild(new TextWidget(null, "Third Item"d));

window.mainWidget = layout;
```

### Part 2: TableLayout for Forms (40 min)

**Objectives:**
- Create form-like layouts with TableLayout
- Understand `colCount` property
- Build label+input pairs
- Create complex nested layouts

**Practical Exercise:**
Build a registration form with:
- Name field (label + EditLine)
- Email field
- Phone field
- Submit and Cancel buttons

**Student Task:**
Create a "Contact Information Form" with at least 5 fields using TableLayout.

---

## **LESSON 3: Events and Interactivity**

### Part 1: Button Click Events (40 min)

**Objectives:**
- Understand event handling
- Write click handlers using delegates
- Respond to user actions
- Modify UI in response to events

**Topics:**
- Signal/slot concept
- Delegate syntax in D
- `button.click = delegate(Widget w) { ... }`
- Returning `true` from handlers
- Capturing variables in closures

**Demo Code:**
```d
int clickCount = 0;
auto label = new TextWidget(null, "Clicks: 0"d);
auto button = new Button(null, "Click Me!"d);

button.click = delegate(Widget w) {
    clickCount++;
    import std.conv : to;
    label.text = "Clicks: "d ~ to!dstring(clickCount);
    return true;
};
```

### Part 2: Building Interactive Applications (40 min)

**Objectives:**
- Create multi-widget interactive apps
- Update multiple widgets from events
- Build simple calculator logic
- Manage application state

**Practical Exercise:**
Build a counter application:
- Display showing count
- Increment button
- Decrement button
- Reset button

**Student Task:**
Create a simple calculator with:
- Number buttons (0-9)
- Display area
- Basic operators (+, -, =, C)
- Working arithmetic

---

## **LESSON 4: Building Complex UIs**

### Part 1: Multi-Widget Applications (40 min)

**Objectives:**
- Combine all learned concepts
- Build complex layouts
- Handle multiple events
- Manage inter-widget communication

**Topics:**
- Complex nested layouts
- Finding widgets by ID
- `childById()` method
- Coordinating multiple widgets
- Code organization strategies

### Part 2: Practice Project (40 min)

**Practical Exercise:**
Build a "Color Picker" application:
- 3 EditLines for R, G, B values (0-255)
- Preview area showing the color
- Update preview when values change
- Reset button

**Student Task:**
Create a "Temperature Converter":
- Input for Celsius
- Input for Fahrenheit
- Input for Kelvin (read-only)
- Real-time conversion
- Validation (no below absolute zero)

**Key Realization:**
By end of Lesson 4, students should feel frustrated with:
- Repetitive code
- Difficulty reusing UI patterns
- Messy code organization
- Hard to modify and maintain

This frustration sets up the need for OOP!

---

## PHASE 2: DISCOVERING CLASSES

Students encounter problems that classes naturally solve, introducing OOP concepts when they're desperately needed.

---

## **LESSON 5: Custom Widgets - Why We Need Classes**

### Part 1: The Problem with Repetition (40 min)

**Challenge:**
Create a form with 10 label+input pairs using only what we know.

**Student Discovery:**
Code becomes extremely repetitive and hard to modify.

**Solution Introduction: Classes!**

**Objectives:**
- Understand what a class is (blueprint)
- Create first custom widget class
- Use constructor to initialize
- Create multiple instances

**Topics:**
- Class definition syntax
- Constructor (`this()`)
- Member variables
- Inheritance from existing widgets
- `super()` to call parent constructor

**Demo Code:**
```d
class LabeledInput : HorizontalLayout {
    TextWidget label;
    EditLine input;
    
    this(dstring labelText) {
        super();  // Call HorizontalLayout constructor
        
        label = new TextWidget(null, labelText);
        input = new EditLine();
        
        addChild(label);
        addChild(input);
    }
}

// Usage - so much cleaner!
auto form = new VerticalLayout();
form.addChild(new LabeledInput("Name:"d));
form.addChild(new LabeledInput("Email:"d));
form.addChild(new LabeledInput("Phone:"d));
```

### Part 2: Building Custom Widget Classes (40 min)

**Objectives:**
- Create multiple custom widget classes
- Add custom behavior
- Organize code better
- Practice class syntax

**Practical Exercise:**
Create custom classes:
1. `LabeledCheckbox` - checkbox with label
2. `ColoredButton` - button with preset color scheme
3. `TitleBar` - centered title with styling

**Student Task:**
Build a complete form using only custom widgets you create:
- At least 3 different custom widget types
- Each widget should encapsulate its styling
- Use in a complete application

**Key Learning:**
"Classes let me reuse UI patterns easily!"

---

## **LESSON 6: Encapsulation - Hiding Complexity**

### Part 1: Public vs Private (40 min)

**Challenge:**
Your custom widget's internals get messed up by users modifying them directly.

**Solution: Encapsulation**

**Objectives:**
- Understand `private` and `public`
- Hide internal implementation
- Provide clean public interface
- Protect widget state

**Topics:**
- Access modifiers: `private`, `public`, `protected`
- Private member variables (use `_` prefix convention)
- Public methods
- Getter/setter concept

**Demo Code:**
```d
class LabeledInput : HorizontalLayout {
    private TextWidget _label;      // Can't access from outside
    private EditLine _input;
    
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
    
    void setLabelWidth(int width) {
        _label.minWidth = width;
    }
}
```

### Part 2: Properties in D (40 min)

**Objectives:**
- Use `@property` for clean syntax
- Create read-only and read-write properties
- Implement validation in setters
- Build robust widgets

**Topics:**
- `@property` decorator
- Property getter and setter syntax
- Read-only properties
- Computed properties
- Validation in setters

**Demo Code:**
```d
class NumberInput : HorizontalLayout {
    private TextWidget _label;
    private EditLine _input;
    private int _minValue;
    private int _maxValue;
    
    this(dstring labelText, int min = 0, int max = 100) {
        super();
        _minValue = min;
        _maxValue = max;
        // ... widget creation ...
    }
    
    @property int value() {
        import std.conv;
        try {
            return to!int(_input.text);
        } catch (Exception e) {
            return _minValue;
        }
    }
    
    @property void value(int v) {
        import std.conv;
        if (v >= _minValue && v <= _maxValue) {
            _input.text = to!dstring(v);
        }
    }
}

// Usage
auto numInput = new NumberInput("Age:"d, 0, 120);
numInput.value = 25;  // Looks like direct access, but calls setter!
int age = numInput.value;  // Calls getter
```

**Practical Exercise:**
Create a `PasswordInput` class:
- Hides password (shows *)
- Validates minimum length
- Has "show/hide" toggle button
- Provides `isValid()` method

**Student Task:**
Build a `RangeSlider` widget class:
- Encapsulates min/max values
- Provides current value through property
- Validates input
- Has optional step size

---

## **LESSON 7: Methods - Widget Behavior**

### Part 1: Adding Behavior to Classes (40 min)

**Objectives:**
- Define methods in classes
- Understand `this` keyword
- Call methods from event handlers
- Organize logic in methods

**Topics:**
- Method definition
- `this` reference
- Method parameters and return values
- Private helper methods
- Public API methods

**Demo Code:**
```d
class TodoItem : HorizontalLayout {
    private CheckBox _checkbox;
    private TextWidget _text;
    private Button _deleteBtn;
    
    this(dstring todoText) {
        super();
        // ... create widgets ...
    }
    
    // Public methods
    bool isCompleted() {
        return _checkbox.checked;
    }
    
    void markCompleted() {
        _checkbox.checked = true;
        updateStyle();
    }
    
    dstring getText() {
        return _text.text;
    }
    
    // Private helper method
    private void updateStyle() {
        if (_checkbox.checked) {
            _text.textColor = 0x808080;  // Gray out completed
        } else {
            _text.textColor = 0x000000;  // Black for active
        }
    }
}
```

### Part 2: Event Handling in Classes (40 min)

**Objectives:**
- Handle events within custom classes
- Connect widgets internally
- Implement widget callbacks
- Build self-contained interactive widgets

**Practical Exercise:**
Create `CalculatorButton` class:
- Stores button value
- Has click handler
- Notifies parent through callback
- Highlights on hover

**Student Task:**
Build `ContactCard` class:
- Displays contact info (name, phone, email)
- Has "Edit" and "Delete" buttons
- Provides callbacks for button clicks
- Supports read-only mode

---

## **LESSON 8: Multiple Instances and Object Identity**

### Part 1: Creating Many Objects (40 min)

**Objectives:**
- Understand objects vs class distinction
- Create many instances from one class
- Each instance has independent state
- Use arrays of objects

**Topics:**
- Objects as instances
- Independent object state
- Arrays of class instances
- Object references
- `null` checking

**Demo Code:**
```d
// Create many instances
LabeledInput[] inputs;
inputs ~= new LabeledInput("Name:"d);
inputs ~= new LabeledInput("Email:"d);
inputs ~= new LabeledInput("Phone:"d);

// Each has independent state
inputs[0].value = "John"d;
inputs[1].value = "john@example.com"d;

// Add them all to layout
foreach(input; inputs) {
    form.addChild(input);
}
```

### Part 2: Managing Collections of Widgets (40 min)

**Practical Exercise:**
Build a dynamic todo list:
- Add new todo items
- Each is a `TodoItem` instance
- Store in array
- Remove items
- Clear all completed

**Student Task:**
Create a "Contact List Manager":
- Array of `ContactCard` objects
- Add new contacts button
- Remove individual contacts
- Search/filter contacts
- Display count

**Key Learning:**
"I can create infinite instances from one class definition!"

---

## PHASE 3: WIDGET HIERARCHIES

Students need widget variations and discover inheritance, polymorphism, and abstraction.

---

## **LESSON 9: Inheritance - Specialized Widgets**

### Part 1: Creating Widget Variants (40 min)

**Challenge:**
You need several button types (primary, danger, success) but they're mostly the same.

**Solution: Inheritance**

**Objectives:**
- Understand inheritance (IS-A relationship)
- Create derived classes
- Use `super` keyword
- Override behavior

**Topics:**
- Inheritance syntax (`:`)
- Base class and derived class
- `super()` in constructors
- Calling base methods
- Adding new functionality

**Demo Code:**
```d
// Base class
class ColoredButton : Button {
    this(dstring text, uint color) {
        super(null, text);
        this.backgroundColor = color;
        this.textColor = 0xFFFFFF;
        this.padding = Rect(15, 8, 15, 8);
    }
}

// Specialized buttons
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

// Usage
layout.addChild(new PrimaryButton("Save"d));
layout.addChild(new DangerButton("Delete"d));
layout.addChild(new SuccessButton("Confirm"d));
```

### Part 2: Building Widget Families (40 min)

**Objectives:**
- Create hierarchies of related widgets
- Share common functionality
- Specialize behavior
- Organize widget library

**Practical Exercise:**
Create text widget hierarchy:
- `StyledText` (base class with common styling)
- `TitleText` (large, bold)
- `SubtitleText` (medium, colored)
- `ErrorText` (red, maybe with icon)
- `SuccessText` (green)

**Student Task:**
Build input widget family:
- `ValidatedInput` (base class)
- `EmailInput` (validates email format)
- `PhoneInput` (validates phone format)
- `URLInput` (validates URLs)
- Each has appropriate validation logic

---

## **LESSON 10: Polymorphism - Flexible Collections**

### Part 1: Base Class References (40 min)

**Challenge:**
You have array of different button types but want to treat them uniformly.

**Solution: Polymorphism**

**Objectives:**
- Store derived objects in base class variables
- Call methods polymorphically
- Understand runtime type binding
- Use polymorphic collections

**Topics:**
- Base class references to derived objects
- Polymorphic method calls
- Arrays of base class type
- Runtime behavior selection

**Demo Code:**
```d
// Store different button types in one array
ColoredButton[] buttons;
buttons ~= new PrimaryButton("Save"d);
buttons ~= new DangerButton("Delete"d);
buttons ~= new SuccessButton("OK"d);

// Treat them all uniformly
foreach (btn; buttons) {
    btn.fontSize = 16;  // Works on all!
    btn.click = delegate(Widget w) {
        import std.stdio;
        writeln("Button clicked!");
        return true;
    };
    layout.addChild(btn);
}

// Yet each keeps its own color and behavior!
```

### Part 2: Widget Collections and Common Interfaces (40 min)

**Objectives:**
- Build flexible UI systems
- Apply common operations to different widgets
- Understand substitutability principle
- Create reusable frameworks

**Practical Exercise:**
Create a toolbar system:
- Define `ToolbarButton` base class
- Create various specialized buttons
- Store in array
- Apply common styling
- Handle events uniformly

**Student Task:**
Build a "Form Validator":
- Array of `ValidatedInput` objects
- Validate all at once
- Highlight errors
- Enable/disable submit based on validity
- Works with any ValidatedInput subclass

---

## **LESSON 11: Abstract Classes - Enforcing Contracts**

### Part 1: Common Patterns (40 min)

**Challenge:**
You want all data display widgets to implement `refresh()` but with different implementations.

**Solution: Abstract Classes**

**Objectives:**
- Understand abstract classes
- Define abstract methods
- Force derived classes to implement
- Share common code in base

**Topics:**
- `abstract` keyword for classes
- `abstract` keyword for methods
- Cannot instantiate abstract classes
- Must implement abstract methods in derived classes
- Template Method pattern

**Demo Code:**
```d
abstract class DataDisplay : VerticalLayout {
    protected string[] data;
    
    this(string id) {
        super(id);
    }
    
    // Abstract method - must implement in derived classes
    abstract void refresh();
    
    // Concrete method - shared by all
    void setData(string[] newData) {
        data = newData;
        refresh();  // Calls derived class implementation
    }
    
    int getItemCount() {
        return cast(int)data.length;
    }
}

class ListDisplay : DataDisplay {
    this(string id) {
        super(id);
    }
    
    override void refresh() {
        removeAllChildren();
        foreach (item; data) {
            import std.conv;
            addChild(new TextWidget(null, to!dstring(item)));
        }
    }
}

class TableDisplay : DataDisplay {
    this(string id) {
        super(id);
    }
    
    override void refresh() {
        // Different implementation - shows as table
        removeAllChildren();
        auto table = new TableLayout();
        table.colCount = 2;
        // ... populate table ...
        addChild(table);
    }
}
```

### Part 2: Building Framework Patterns (40 min)

**Practical Exercise:**
Create abstract `ConfigPanel`:
- Abstract methods: `loadSettings()`, `saveSettings()`, `validate()`
- Concrete methods: `applyChanges()`, `resetToDefaults()`
- Derived classes: `GeneralSettings`, `AppearanceSettings`, `AdvancedSettings`

**Student Task:**
Build abstract `Chart` class:
- Abstract: `drawChart()`, `calculatePoints()`
- Concrete: `setData()`, `setTitle()`, `setColors()`
- Derived: `LineChart`, `BarChart`, `PieChart`

---

## **LESSON 12: Interfaces - Multiple Contracts**

### Part 1: Interface Concept (40 min)

**Challenge:**
Some widgets need to be clickable, some need to be draggable, some need both.

**Solution: Interfaces**

**Objectives:**
- Understand interfaces
- Implement multiple interfaces
- Difference from abstract classes
- Interface references

**Topics:**
- `interface` keyword
- No implementation in interfaces
- Multiple interface implementation
- Interface as type

**Demo Code:**
```d
interface IClickable {
    bool handleClick(int x, int y);
}

interface IDraggable {
    void startDrag(int x, int y);
    void drag(int x, int y);
    void endDrag();
}

class DraggableButton : Button, IClickable, IDraggable {
    private int _dragStartX, _dragStartY;
    
    // IClickable implementation
    override bool handleClick(int x, int y) {
        import std.stdio;
        writeln("Button clicked at: ", x, ", ", y);
        return true;
    }
    
    // IDraggable implementation
    override void startDrag(int x, int y) {
        _dragStartX = x;
        _dragStartY = y;
    }
    
    override void drag(int x, int y) {
        // Update position
    }
    
    override void endDrag() {
        // Finalize position
    }
}
```

### Part 2: Event Handler Interfaces (40 min)

**Objectives:**
- Implement dlangui event interfaces
- Create organized event handling
- Use class-based handlers
- Build complex interactions

**Topics:**
- `OnClickHandler` interface
- `OnCheckHandler` interface
- `OnFocusHandler` interface
- Organizing events in controller classes

**Practical Exercise:**
Create `FormController` class:
- Implements `OnClickHandler` for buttons
- Implements `OnFocusHandler` for inputs
- Centralizes form logic
- Validates on submit

**Student Task:**
Build `DialogController`:
- Handles multiple button types
- Validates input fields
- Shows error messages
- Returns result to caller

---

## PHASE 4: ADVANCED PATTERNS

Students build professional applications using advanced widgets and patterns.

---

## **LESSON 13: Composition - Has-A Relationships**

### Part 1: Composition vs Inheritance (40 min)

**Challenge:**
Your widget needs features from multiple sources - inheritance limits you to one parent.

**Solution: Composition**

**Objectives:**
- Understand composition (HAS-A)
- Compare with inheritance (IS-A)
- "Favor composition over inheritance"
- Delegation pattern

**Topics:**
- Member objects
- Delegation
- Flexibility of composition
- When to use each approach

**Demo Code:**
```d
// Instead of inheriting multiple classes (can't in D)
// Use composition

class ImageTextPanel : VerticalLayout {
    private ImageWidget image;  // HAS-A image
    private TextWidget title;   // HAS-A title
    private TextWidget description;  // HAS-A description
    private HorizontalLayout buttons;  // HAS-A button container
    
    this(string imageId, dstring titleText) {
        super();
        
        image = new ImageWidget(null, imageId);
        title = new TextWidget(null, titleText);
        title.fontSize = 20;
        
        description = new TextWidget();
        
        buttons = new HorizontalLayout();
        
        addChild(image);
        addChild(title);
        addChild(description);
        addChild(buttons);
    }
    
    // Provide clean API
    void setDescription(dstring text) {
        description.text = text;
    }
    
    void addButton(Button btn) {
        buttons.addChild(btn);
    }
}
```

### Part 2: Building Composite Widgets (40 min)

**Practical Exercise:**
Create complex widgets using composition:
- `MessageBox` - icon + text + buttons
- `StatusBar` - multiple info sections
- `ToolPanel` - title bar + content + tool buttons

**Student Task:**
Build `ContactCard` using composition:
- Avatar image (or colored initial circle)
- Name, email, phone (TextWidgets)
- Action buttons
- Status indicator
- Edit/Delete functionality

---

## **LESSON 14: List Widgets and Data Management**

### Part 1: ListWidget and StringListAdapter (40 min)

**Objectives:**
- Use built-in ListWidget
- Understand adapters
- Display data collections
- Handle selection events

**Topics:**
- `ListWidget` class
- `StringListAdapter`
- Item selection
- Item click events
- Dynamic list updates

**Demo Code:**
```d
auto list = new ListWidget("myList");
list.ownAdapter = new StringListAdapter();

// Add items
auto adapter = list.adapter;
adapter.add("Item 1"d);
adapter.add("Item 2"d);
adapter.add("Item 3"d);

// Handle selection
list.itemSelected = delegate(Widget source, int itemIndex) {
    auto selected = adapter.items[itemIndex];
    import std.stdio;
    writeln("Selected: ", selected);
    return true;
};
```

### Part 2: Custom List Adapters and Widgets (40 min)

**Objectives:**
- Create custom list item widgets
- Understand MVC pattern basics
- Build data-driven UIs
- Implement add/remove functionality

**Practical Exercise:**
Build Todo List application:
- Custom `TodoItem` widget class
- List of todos
- Add new todos
- Remove completed todos
- Mark as complete

**Student Task:**
Create "Contact List" application:
- Custom `ContactListItem` widget
- Display array of contacts
- Add new contacts
- Remove contacts
- Click to edit

---

## **LESSON 15: Grid Widgets and Tables**

### Part 1: StringGridWidget Basics (40 min)

**Objectives:**
- Use `StringGridWidget`
- Create table data
- Handle cell selection
- Update cells

**Topics:**
- `StringGridWidget` class
- Rows and columns
- Cell data
- Headers
- Selection model

**Demo Code:**
```d
auto grid = new StringGridWidget("grid");
grid.showColHeaders = true;
grid.showRowHeaders = true;
grid.resize(5, 3);  // 5 rows, 3 columns

// Set headers
grid.setColTitle(0, "Name"d);
grid.setColTitle(1, "Age"d);
grid.setColTitle(2, "City"d);

// Set data
grid.setCellText(0, 0, "Alice"d);
grid.setCellText(0, 1, "25"d);
grid.setCellText(0, 2, "New York"d);
```

### Part 2: Data Table Application (40 min)

**Practical Exercise:**
Build "Student Grades" table:
- Student names in first column
- Subject scores in other columns
- Calculate averages
- Highlight failing grades

**Student Task:**
Create "Expense Tracker":
- Date, description, amount, category columns
- Add new expenses
- Calculate totals
- Category summaries
- Monthly breakdown

---

## **LESSON 16: Tree Widgets and Hierarchical Data**

### Part 1: TreeWidget Basics (40 min)

**Objectives:**
- Use `TreeWidget`
- Create tree nodes
- Handle expand/collapse
- Respond to selection

**Topics:**
- `TreeWidget` class
- `TreeItem` nodes
- Parent-child relationships
- Icons in trees
- Selection events

**Demo Code:**
```d
auto tree = new TreeWidget("tree");

auto root = tree.items.newChild("root", "Root"d, "folder");
auto child1 = root.newChild("c1", "Child 1"d, "document");
auto child2 = root.newChild("c2", "Child 2"d, "folder");
child2.newChild("c2_1", "Subchild"d, "document");

tree.itemSelected = delegate(Widget source, int itemIndex) {
    // Handle selection
    return true;
};
```

### Part 2: Hierarchical Data Applications (40 min)

**Practical Exercise:**
Build file browser UI:
- Folder tree
- Expand/collapse folders
- Show files
- Handle clicks

**Student Task:**
Create "Organization Chart":
- Company/department hierarchy
- Employee nodes
- Expand/collapse departments
- Show employee details on click

---

## PHASE 5: MASTERY

Students build complete, professional applications.

---

## **LESSON 17: Dialogs and Multi-Window Applications**

### Part 1: Dialog Basics (40 min)

**Objectives:**
- Create modal dialogs
- Show message boxes
- Get user input
- Handle dialog results

**Topics:**
- `Dialog` class
- Modal vs modeless
- `window.showMessageBox`
- Dialog result handling
- Custom dialog creation

**Demo Code:**
```d
// Simple message box
window.showMessageBox(
    UIString.fromRaw("Title"d),
    UIString.fromRaw("Message"d)
);

// Custom dialog
class SettingsDialog : Dialog {
    this(Window parent) {
        super(UIString.fromRaw("Settings"d), parent, 
              DialogFlag.Modal | DialogFlag.Resizable);
        
        // Create content
        // ...
    }
}

auto dlg = new SettingsDialog(window);
dlg.show();
```

### Part 2: Multi-Window Applications (40 min)

**Practical Exercise:**
Build application with:
- Main window
- Settings dialog
- About dialog
- Confirm dialogs

**Student Task:**
Create "Text Editor" with:
- Main editor window
- File dialogs
- Find/Replace dialog
- Preferences dialog

---

## **LESSON 18: Event-Driven Architecture**

### Part 1: Advanced Event Handling (40 min)

**Objectives:**
- Master all event types
- Understand event propagation
- Create custom events
- Build reactive UIs

**Topics:**
- Mouse events
- Key events
- Focus events
- Event bubbling
- Custom event systems

### Part 2: Reactive UI Patterns (40 min)

**Practical Exercise:**
Build "Chat Interface":
- Message list
- Input area
- Send button
- Real-time updates (simulated)

**Student Task:**
Create "Dashboard":
- Multiple data panels
- Live updates
- Interactive charts
- Notification system

---

## **LESSON 19: Advanced OOP Patterns and Best Practices**

### Part 1: Design Patterns in GUI (40 min)

**Objectives:**
- Apply common design patterns
- Understand MVC/MVP
- Use observer pattern
- Implement factory pattern

**Topics:**
- Model-View-Controller
- Observer pattern
- Factory pattern
- Singleton pattern (Platform instance)
- Strategy pattern

### Part 2: Professional Code Organization (40 min)

**Objectives:**
- Organize large codebases
- Separate concerns
- Create reusable libraries
- Document code

**Practical Exercise:**
Refactor previous projects:
- Separate widget classes into modules
- Create controllers
- Organize data models
- Add documentation

---

## **LESSON 20: Final Project**

### Part 1: Project Planning and Architecture (40 min)

**Objectives:**
- Design complete application
- Plan class structure
- Identify OOP patterns to use
- Create project timeline

**Topics:**
- Requirements analysis
- Class diagram creation
- Module organization
- Architecture decisions

### Part 2: Implementation and Presentation (40 min)

**Objectives:**
- Implement designed application
- Apply all learned concepts
- Present to class
- Receive feedback

**Final Project Requirements:**
- Minimum 5 custom classes
- Use inheritance (at least 2 levels)
- Implement at least 1 interface
- Demonstrate encapsulation throughout
- Use composition where appropriate
- Multiple widgets types (list, grid, or tree)
- Event handling
- Multiple windows/dialogs
- Professional UI design
- Clean code organization

**Project Options:**
1. Personal Finance Tracker
2. Contact Manager
3. Student Grade Book
4. Recipe Organizer
5. Project/Task Manager
6. Note-Taking Application
7. Inventory System
8. Or propose your own!

---

## Course Assessment

### Weekly Evaluation (40%):
- Exercise completion
- Code quality
- Participation
- Progress

### Mini-Projects (30%):
- 4 progressive projects (Lessons 8, 12, 16, 19)
- Complexity increases
- Cumulative skills

### Final Project (30%):
- Architecture (10%)
- Implementation (10%)
- OOP principles application (5%)
- Presentation (5%)

---

## Teaching Notes

### Key Pedagogical Principles

1. **Let students struggle** - Don't solve problems immediately
2. **Build motivation** - Always present the problem before the solution
3. **Type, don't paste** - Students must type all code
4. **Encourage experimentation** - Break things and learn
5. **Celebrate discoveries** - When students figure things out themselves

### Common Student Challenges

**Lesson 1-4:** 
- Forgetting `"text"d` notation
- Not calling `window.show()`
- Confusion about layout nesting

**Lesson 5-8:**
- Understanding object vs class
- Confusion about `this`
- When to use `super()`

**Lesson 9-12:**
- Choosing inheritance vs composition
- Understanding polymorphism
- Abstract vs interface

**Lesson 13-20:**
- Managing complexity
- Organizing large codebases
- Design decisions

---

## Success Indicators

Students successfully learned when they can:

1. **Explain WHY** OOP exists (not just how to use it)
2. **Design** class hierarchies before coding
3. **Choose** appropriate patterns for problems
4. **Refactor** procedural code into OOP
5. **Debug** object-oriented programs
6. **Extend** existing code cleanly
7. **Critique** class designs

---

**This course transforms programming knowledge into object-oriented thinking through practical, hands-on GUI development.**

*Version 2.0 - October 2025*
