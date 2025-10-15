# Object-Oriented Programming with D Language and dlangui Framework
## Complete Course Materials

This repository contains comprehensive course materials for teaching Object-Oriented Programming (OOP) concepts using the D programming language and the dlangui GUI framework.

---

## 📚 Course Overview

**Duration:** 20 lessons × 2 parts × 40 minutes = ~26.5 hours total  
**Level:** Beginner to Intermediate  
**Prerequisites:** Basic programming knowledge  
**Target Audience:** Students learning OOP through practical GUI development

### What This Course Teaches

1. **Object-Oriented Programming Fundamentals**
   - Classes and Objects
   - Encapsulation
   - Inheritance
   - Polymorphism
   - Abstraction
   - Interfaces
   - Composition

2. **D Language Specifics**
   - Syntax and semantics
   - Properties and attributes
   - Templates and generics
   - Memory management
   - Module system

3. **GUI Development with dlangui**
   - Widget system
   - Layout managers
   - Event handling
   - Resource management
   - DML (DlangUI Markup Language)
   - Themes and styling

4. **Practical Application Development**
   - UI/UX design principles
   - Application architecture
   - Code organization
   - Best practices

---

## 📖 Course Materials

### Main Documents

1. **[COURSE_PLAN.md](COURSE_PLAN.md)** - Complete 20-lesson course structure
   - Detailed lesson objectives
   - Theory and practice balance
   - Progressive learning path
   - Assessment criteria
   - Teaching methodology

2. **[LESSON_DETAILS.md](LESSON_DETAILS.md)** - In-depth lesson breakdowns
   - Slide-by-slide content
   - Complete code examples
   - Demonstrations
   - Teaching notes
   - Common mistakes and solutions

3. **[EXERCISES_WORKBOOK.md](EXERCISES_WORKBOOK.md)** - Student practice materials
   - 100+ exercises
   - Homework assignments
   - Final project specifications
   - Bonus challenges
   - Submission guidelines

4. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick reference guide
   - D language syntax
   - OOP concepts cheatsheet
   - dlangui widget reference
   - Common patterns
   - Troubleshooting guide

### Additional Resources

- **externals/dlangui/** - dlangui framework source code and examples
- **externals/dlangui.wiki/** - dlangui documentation
  - Getting-Started.md
  - Using-DML-to-create-layouts.md
  - Adding-Resources.md
  - Adding-New-Theme.md

---

## 🎯 Learning Path

### Phase 1: Foundations (Lessons 1-5)
**Goal:** Understand basic OOP and create simple GUI applications

- Lesson 1: Introduction and first GUI window
- Lesson 2: Classes and objects
- Lesson 3: Layouts and containers
- Lesson 4: Encapsulation principles
- Lesson 5: Methods and event handling

**Milestone:** Create a working calculator application

### Phase 2: Advanced OOP (Lessons 6-10)
**Goal:** Master inheritance, polymorphism, and design patterns

- Lesson 6: Inheritance basics
- Lesson 7-8: Polymorphism and abstract classes
- Lesson 9: Interfaces
- Lesson 10: Composition vs inheritance

**Milestone:** Build widget hierarchy with polymorphic behavior

### Phase 3: dlangui Mastery (Lessons 11-14)
**Goal:** Expert-level GUI development

- Lesson 11: DML (Declarative layouts)
- Lesson 12: Advanced styling and themes
- Lesson 13: Resource management
- Lesson 14: Event-driven architecture

**Milestone:** Create themed application with resources

### Phase 4: Complex Widgets (Lessons 15-18)
**Goal:** Handle complex data and interactions

- Lesson 15: List widgets and adapters
- Lesson 16: Grid widgets and tables
- Lesson 17: Tree widgets
- Lesson 18: Dialogs and multi-window apps

**Milestone:** Build data management application

### Phase 5: Advanced Topics & Project (Lessons 19-20)
**Goal:** Apply all concepts in complete project

- Lesson 19: Templates and generics
- Lesson 20: Final project development

**Milestone:** Complete, professional-quality application

---

## 🚀 Getting Started

### For Instructors

1. **Preparation**
   ```bash
   # Ensure D compiler and DUB are installed
   dmd --version
   dub --version
   
   # Clone this repository
   git clone [repository-url]
   cd Lessons-Basic-Gui-Developments
   
   # Review course materials
   cat COURSE_PLAN.md
   ```

2. **Before Each Lesson**
   - Read lesson details in LESSON_DETAILS.md
   - Test all code examples
   - Prepare visual aids
   - Set up demo environment
   - Review common student challenges

3. **Teaching Resources**
   - Use QUICK_REFERENCE.md for live coding
   - Reference example projects in externals/dlangui/examples/
   - Utilize provided code snippets
   - Adapt to class pace

### For Students

1. **Setup**
   ```bash
   # Install D compiler (DMD, LDC, or GDC)
   # Visit: https://dlang.org/download.html
   
   # Install DUB
   # Usually comes with D compiler
   
   # Verify installation
   dmd --version
   dub --version
   ```

2. **Starting a New Exercise**
   ```bash
   # Create new dlangui project
   dub init my-exercise dlangui
   cd my-exercise
   
   # Edit source/app.d
   # Build and run
   dub run
   ```

3. **Study Materials**
   - Follow COURSE_PLAN.md for structure
   - Complete exercises from EXERCISES_WORKBOOK.md
   - Reference QUICK_REFERENCE.md when stuck
   - Study example code in externals/

4. **Practice Routine**
   - Complete in-class exercises
   - Do homework assignments
   - Experiment with variations
   - Review previous lessons
   - Build mini-projects

---

## 📋 Course Structure

### Lesson Format

Each lesson consists of two 40-minute parts:

**Part 1: Theory + Demonstration (40 min)**
- Concept introduction (10-15 min)
- Live coding demonstration (15-20 min)
- Q&A and discussion (10-15 min)

**Part 2: Hands-on Practice (40 min)**
- Guided exercises (20 min)
- Independent work (15 min)
- Review and wrap-up (5 min)

### Weekly Schedule (Suggested)

**Option A: Intensive (4 lessons/week)**
- Monday: Lessons 1-2
- Wednesday: Lessons 3-4
- Friday: Review + Extra practice
- Duration: 5 weeks

**Option B: Regular (2 lessons/week)**
- Tuesday: 1 lesson (2 parts)
- Thursday: 1 lesson (2 parts)
- Duration: 10 weeks

**Option C: Slow-paced (1 lesson/week)**
- One 80-minute session per week
- Duration: 20 weeks

---

## 🎓 Assessment and Grading

### Components

1. **Weekly Exercises (40%)**
   - In-class participation
   - Homework completion
   - Code quality
   - Progressive improvement

2. **Mini-Projects (30%)**
   - 4-5 projects throughout course
   - Demonstrate cumulative knowledge
   - Creativity and problem-solving
   - Documentation

3. **Final Project (30%)**
   - Complete application
   - All OOP principles demonstrated
   - Professional quality
   - Presentation

### Grading Criteria

**A (90-100%):** Excellent understanding, creative solutions, best practices
**B (80-89%):** Good understanding, working solutions, mostly correct
**C (70-79%):** Basic understanding, functional code, some issues
**D (60-69%):** Minimal understanding, partial solutions
**F (<60%):** Insufficient understanding or effort

---

## 💡 Key Features of This Course

### Progressive Complexity
- Builds from simple to complex
- Each lesson reinforces previous concepts
- Continuous practice and review
- Clear milestones

### Practical Focus
- Every concept taught through GUI applications
- Real-world examples
- Hands-on coding from day one
- Minimal passive learning

### Comprehensive Materials
- Complete code examples
- 100+ exercises
- Multiple project ideas
- Detailed reference guides

### Flexible Structure
- Adaptable to different schedules
- Optional bonus content
- Self-paced learning support
- Multiple difficulty levels

---

## 🔧 Technical Requirements

### Software

**Required:**
- D Compiler (DMD 2.066+ or LDC 1.0+)
- DUB package manager
- Text editor or IDE
- Git (for version control)

**Recommended:**
- Visual Studio Code with D extension
- DlangIDE (for visual development)
- Terminal/Command prompt

### Operating Systems

- ✅ Linux (primary development platform)
- ✅ Windows (fully supported)
- ✅ macOS (supported with SDL2)

### Hardware

**Minimum:**
- 2 GB RAM
- 1 GHz processor
- 500 MB disk space
- Display: 1024×768

**Recommended:**
- 4+ GB RAM
- Multi-core processor
- 1 GB disk space
- Display: 1920×1080

---

## 📚 Learning Objectives

By the end of this course, students will be able to:

### OOP Knowledge
- ✅ Explain core OOP principles
- ✅ Design class hierarchies
- ✅ Apply encapsulation properly
- ✅ Use inheritance and composition
- ✅ Implement polymorphic behavior
- ✅ Create and use interfaces
- ✅ Understand abstract classes

### D Language Skills
- ✅ Write idiomatic D code
- ✅ Use properties and attributes
- ✅ Understand templates
- ✅ Work with modules
- ✅ Manage memory properly
- ✅ Use modern D features

### GUI Development
- ✅ Create complex layouts
- ✅ Handle user events
- ✅ Design custom widgets
- ✅ Apply themes and styles
- ✅ Manage resources
- ✅ Build multi-window applications
- ✅ Use DML for layouts

### Professional Skills
- ✅ Write clean, maintainable code
- ✅ Follow best practices
- ✅ Debug effectively
- ✅ Document code
- ✅ Plan application architecture
- ✅ Design user interfaces

---

## 🎯 Projects You'll Build

### Early Lessons (1-5)
- Hello World GUI
- Styled widgets showcase
- Form layouts
- Calculator
- Todo list

### Middle Lessons (6-14)
- Custom widget library
- Themed application
- Image viewer
- Quiz application
- Event-driven app

### Advanced Lessons (15-19)
- Data table application
- File browser
- Multi-document editor
- Generic components
- Task manager

### Final Project (Lesson 20)
Choose from:
- Personal Finance Manager
- Student Management System
- Recipe Organizer
- Project Tracker
- Contact Manager
- Or propose your own!

---

## 🤝 For Educators

### Customization

This course is designed to be flexible:

- **Adjust pacing** based on student level
- **Skip topics** if already covered
- **Add topics** relevant to your curriculum
- **Modify exercises** to match interests
- **Use different examples** from your domain

### Additional Resources

- Create video lectures using lesson materials
- Develop automated testing for exercises
- Set up continuous integration
- Create additional practice problems
- Build sample solution repositories

### Collaboration

We welcome:
- Feedback on course content
- Additional exercise ideas
- Example projects
- Teaching notes
- Improvements and corrections

---

## 📞 Support and Resources

### During the Course

**For Students:**
- Instructor office hours
- Peer study groups
- Online forums/chat
- Code review sessions

**For Instructors:**
- Teaching notes in lesson details
- Example solutions (separate repository)
- Common problem database
- Teaching community

### External Resources

**D Language:**
- Official website: https://dlang.org/
- D Programming Language book
- D forums: https://forum.dlang.org/

**dlangui:**
- GitHub: https://github.com/buggins/dlangui
- Documentation: Included in externals/
- Examples: externals/dlangui/examples/

**OOP Concepts:**
- Design Patterns books
- UML resources
- Software architecture guides

---

## 📝 License and Usage

### Course Materials
These course materials are provided for educational purposes.

**You may:**
- Use for teaching classes
- Adapt for your needs
- Share with students
- Modify exercises

**Please:**
- Credit original authors
- Share improvements
- Respect licenses of included code

### Included Software
- **dlangui:** Boost License
- **D Language:** Boost License
- See individual LICENSE files in externals/

---

## 🚀 Getting Help

### Common Issues

**Installation Problems:**
1. Check D compiler installation
2. Verify DUB is in PATH
3. Test with simple console app first
4. Consult dlangui wiki

**Compilation Errors:**
1. Check for 'd' suffix on strings
2. Verify import statements
3. Ensure proper widget hierarchy
4. Review error messages carefully

**Runtime Issues:**
1. Did you call window.show()?
2. Check for null widgets
3. Verify event handler returns
4. Test with simpler version

### Where to Ask

1. **Class instructor** (primary)
2. **Peer study groups** (encouraged)
3. **D Forums** (for D language questions)
4. **GitHub Issues** (for dlangui bugs)

---

## 🎉 Success Stories

Students who complete this course typically:

- ✅ Understand OOP deeply
- ✅ Can build GUI applications confidently
- ✅ Write cleaner, more maintainable code
- ✅ Apply design patterns effectively
- ✅ Continue learning independently
- ✅ Contribute to open source projects

---

## 📅 Course Timeline

### Week-by-Week (10-week schedule)

**Weeks 1-2:** Foundations
- Lessons 1-4
- Basic OOP concepts
- Simple GUI applications

**Weeks 3-4:** Intermediate OOP
- Lessons 5-8
- Inheritance and polymorphism
- Event handling

**Weeks 5-6:** Advanced Concepts
- Lessons 9-12
- Interfaces and composition
- DML and styling

**Weeks 7-8:** Complex Widgets
- Lessons 13-16
- Resources and data widgets
- Professional features

**Weeks 9-10:** Mastery and Project
- Lessons 17-20
- Advanced topics
- Final project development

---

## 🎖️ Certification

Upon successful completion, students will have:

- Portfolio of GUI applications
- Understanding of OOP principles
- Experience with real framework
- Foundation for further development
- Certificate of completion (if provided by institution)

---

## 🔄 Continuous Improvement

This course is continuously updated:

- Student feedback incorporated
- New examples added
- Better explanations developed
- Additional exercises created
- Technology updates integrated

**Version:** 1.0  
**Last Updated:** October 2025  
**Next Review:** Ongoing

---

## 👥 Contributors

**Course Design:** [Original Authors]  
**Technical Review:** D Community  
**Framework:** dlangui by Vadim Lopatin  

Special thanks to:
- D language community
- dlangui contributors
- Beta test instructors
- Student feedback

---

## 📧 Contact

For questions, suggestions, or contributions:

- Course Repository: [repository-url]
- Issues: [issues-url]
- Discussions: [discussions-url]

---

## 🌟 Final Notes

Teaching OOP through GUI development:
- Makes concepts concrete
- Provides immediate visual feedback
- Engages students more effectively
- Produces useful applications
- Builds practical skills

This course represents hundreds of hours of curriculum development, focusing on the best way to teach OOP concepts through practical, hands-on experience.

**Good luck to all instructors and students!**

*Let's build something amazing together!* 🚀

---

**Happy Teaching! Happy Learning! Happy Coding!** 💻✨


