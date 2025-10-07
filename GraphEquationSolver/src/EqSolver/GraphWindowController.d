module EqSolver.GraphWindowController;
import std;
import dlangui;
import EqSolver.GraphPanel;
import EqSolver.FunctionPanel;
import EqSolver.Exceptions;

class GraphWindowController
{
    this(dstring title)
    {
        w = Platform.instance.createWindow(title, null, WindowFlag.Resizable, 1200, 900);

        //Function os = new Oscillator();
        //Function x2 = new X2();
        //Function p1 = new Polinom([0, 1]); // y = x    y = 0*x^^0 + 1*x^^1
        //Polinom p3 = new Polinom([0, 0, -1, 0.1]); // y = 0.001*x^^3    y = 0*x^^0 + 0*x^^1 + 0*x^^2 + 1*x^^3
        //Polinom p4 = new Polinom([0.0442, -0.213, -2.27, -0.3, 1]);
        //Polinom p5 = new Polinom([-3.23323, -0.5631, 6.550, -1.30, -2.7, 1]);
        //Function tg = new Tg();

        g = new GraphPanel();
        g.backgroundColor = Color.white;
        //g.addFunction(x2);
        //g.addFunction(os);
        //g.addFunction(tg);
        //g.addFunction(p1);
        //g.addFunction(p3);
        //g.addFunction(p4);
        //g.addFunction(p5);

        HorizontalLayout mainWidget = new HorizontalLayout();
        mainWidget.layoutWidth = FILL_PARENT;

        VerticalLayout sidebarLayout = createSidebar();
        g.minWidth = 1; // ????
        g.layoutWidth = FILL_PARENT;
        g.layoutHeight = FILL_PARENT;

        mainWidget.addChild(sidebarLayout);
        mainWidget.addChild(g);

        w.mainWidget(mainWidget);
    }

    void addScriptFunction(string fs)
    {
        // Validate formula string
        if (fs.length == 0)
        {
            stderr.writeln("Error: Cannot add empty formula");
            return;
        }
        
        ScriptFunction scriptFunc;
        try
        {
            scriptFunc = new ScriptFunction(fs);
        }
        catch (InvalidFormulaException e)
        {
            stderr.writeln("Error creating function: ", e.msg);
            return;
        }
        catch (Exception e)
        {
            stderr.writeln("Unexpected error creating function: ", e.msg);
            return;
        }
        
        string functionID = to!string(cast(void*) scriptFunc);

        functions[functionID] = scriptFunc;

        g.addFunction(scriptFunc);

        dstring label = to!dstring(fs);
        TextWidget tw = new TextWidget(functionID);
        tw.text(label);
        tw.styleId("LIST_ITEM");
        tw.backgroundColor(Color.antique_white);

        functionListAdapter.add(tw);

        ScriptFunctionPanel panel = new ScriptFunctionPanel(scriptFunc);
        panel.id = functionID;
        panel.visibility = Visibility.Invisible;
        panel.onChangeHandler = delegate(Function f) { tw.text(to!dstring(f)); };

        functionsPanel.addChild(panel);
    }

    void addPolinomFunction(double[] a)
    {
        // Validate coefficients
        if (a.length == 0)
        {
            stderr.writeln("Error: Cannot create polynomial with empty coefficients");
            return;
        }
        
        Polinom polinom;
        try
        {
            polinom = new Polinom(a);
        }
        catch (InvalidParameterException e)
        {
            stderr.writeln("Error creating polynomial: ", e.msg);
            return;
        }
        catch (Exception e)
        {
            stderr.writeln("Unexpected error creating polynomial: ", e.msg);
            return;
        }
        
        string functionID = to!string(cast(void*) polinom);

        functions[functionID] = polinom;

        g.addFunction(polinom);

        dstring label = to!dstring(polinom);
        TextWidget tw = new TextWidget(functionID);
        tw.text(label);
        tw.styleId("LIST_ITEM");

        functionListAdapter.add(tw);

        PolinomFunctionPanel panel = new PolinomFunctionPanel(polinom);
        panel.id = functionID;
        panel.visibility = Visibility.Invisible;
        panel.onChangeHandler = delegate(Function f) { tw.text(to!dstring(f)); };

        functionsPanel.addChild(panel);
    }

    void removeFunction(int itemIndex)
    {
        string functionID = list.itemWidget(itemIndex).id;
        Function* f = functionID in functions;
        if (f !is null)
        {
            list.selectItem(-1);
            functionListAdapter.remove(itemIndex);
            g.removeFunction(*f);
            functions.remove(functionID);
        }
    }

    void clearFunctions()
    {
        while (functionListAdapter.itemCount > 0)
        {
            removeFunction(0);
        }
    }

    void show()
    {
        w.show();
    }

private:

    VerticalLayout createSidebar()
    {
        VerticalLayout sidebarWidget = new VerticalLayout();
        sidebarWidget.layoutHeight(FILL_PARENT);

        list = new ListWidget("list1", Orientation.Vertical);
        functionListAdapter = new WidgetListAdapter();

        list.layoutHeight(FILL_PARENT);
        list.backgroundColor = Color.bisque;
        list.selectItem(0);
        list.ownAdapter = functionListAdapter;

        class ListItemSelectionHandler : OnItemSelectedHandler
        {
            alias theHandler = bool delegate(Widget source, int itemIndex);

            this(theHandler h)
            {
                _h = h;
            }

            bool onItemSelected(Widget source, int itemIndex)
            {
                return _h(source, itemIndex);
            }

        private:

            theHandler _h;
        }

        auto dd = delegate(Widget source, int itemIndex) {
            ListWidget list = (cast(ListWidget) source);
            Widget functionWidget = list.itemWidget(itemIndex);
            string fuctionID = functionWidget.id;
            writefln("Selected: %d %s", itemIndex, fuctionID);
            stdout.flush();

            doForEachFunctionPanel(delegate(FunctionPanel p) {
                writeln("p = ", p);
                writeln("fuctionID = ", fuctionID);
                stdout.flush();
                if (equal(p.id, fuctionID))
                {
                    p.layoutHeight = FILL_PARENT;
                }
                else
                {
                    p.layoutHeight = 1;
                }
            });

            functionsPanel.showChild(fuctionID);

            return true;
        };

        list.itemSelected = new ListItemSelectionHandler(dd);

        sidebarWidget.addChild(list);

        VerticalLayout emptyPanel = new VerticalLayout("EMPTY_PANEL");
        emptyPanel.layoutHeight(FILL_PARENT);
        emptyPanel.backgroundColor(Color.aqua);
        emptyPanel.addChild(new VSpacer().backgroundColor(Color.corn_silk)
                .layoutHeight(FILL_PARENT));

        VerticalLayout functionsPanelContainer = new VerticalLayout();
        functionsPanel = new FrameLayout();
        functionsPanel.layoutHeight(FILL_PARENT);
        functionsPanel.backgroundColor(Color.chocolate);
        functionsPanel.addChild(emptyPanel);
        functionsPanel.showChild("EMPTY_PANEL", Visibility.Invisible, true);
        functionsPanel.minHeight = 20;

        functionsPanelContainer.addChild(functionsPanel);
        functionsPanelContainer.backgroundColor(Color.red);
        sidebarWidget.addChild(functionsPanelContainer);

        Button removeAllButton = new Button(null, "Очистить все"d);
        removeAllButton.click = delegate(Widget source) {
            stdout.flush();
            clearFunctions();
            functionsPanel.showChild("EMPTY_PANEL", Visibility.Invisible, true);
            return true;
        };

        Button removeSelectedButton = new Button(null, "Удалить функцию"d);
        removeSelectedButton.click = delegate(Widget source) {
            stdout.flush();
            int itemIndex = list.selectedItemIndex();
            removeFunction(itemIndex);

            functionsPanel.showChild("EMPTY_PANEL", Visibility.Invisible, true);
            return true;
        };

        Button addNew = new Button(null, "Добавить"d);
        addNew.click = delegate(Widget source) { stdout.flush(); return true; };

        sidebarWidget.addChild(addNew);
        sidebarWidget.addChild(removeSelectedButton);
        sidebarWidget.addChild(removeAllButton);

        return sidebarWidget;
    }

    void doForEachFunctionPanel(void delegate(FunctionPanel p) doer)
    {
        const auto n = functionsPanel.childCount();

        for (int i = 0; i < n; i++)
        {
            FunctionPanel fp = cast(FunctionPanel) functionsPanel.child(i);
            if (fp !is null)
            {
                doer(fp);
            }
        }
    }

private:

    // Модель
    Function[string] functions;

    Window w;

    GraphPanel g;
    ListWidget list;
    WidgetListAdapter functionListAdapter;
    FrameLayout functionsPanel;
};
