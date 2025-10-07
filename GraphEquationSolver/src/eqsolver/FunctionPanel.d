module eqsolver.FunctionPanel;

import std;
import dlangui;

public
{
    import eqsolver.Polinom;
    import eqsolver.ScriptFunction;
}

class FunctionPanel : VerticalLayout
{
    this(Function f)
    {
        _f = f;
    }

    alias OnFunctionChangedHandler = void delegate(Function f);

    void onChangeHandler(OnFunctionChangedHandler h)
    {
        _h = h;
    }

private:
    Function _f;
    OnFunctionChangedHandler _h;
};

class PolinomFunctionPanel : FunctionPanel
{
    this(Polinom p)
    {
        super(p);

        minWidth = 1;
        layoutHeight = 0;
        backgroundColor(Color.dark_gray); // Dark background for polynomial function panel
        _a = p.coefficients().dup;
        for (int i = 0; i < _a.length; i++)
        {
            HorizontalLayout h = new HorizontalLayout();

            TextWidget label = new TextWidget(null);
            label.text = to!dstring(i) ~ " : "d;
            h.addChild(label);

            EditLine edit = new EditLine();
            edit.text = format("%.15g"d, _a[i]);
            edit.layoutWidth = 200;
            h.addChild(edit);

            edit.enterKey = () {
                int icopy = i;
                return delegate(EditWidgetBase editor) {
                    dstring df = strip(editor.text);
                    double ai = to!double(df);
                    _a[icopy] = ai;
                    (cast(Polinom) _f).setCoefficients(_a);

                    if (_h !is null)
                    {
                        _h(_f);
                    }
                    return true;
                };
            }();

            addChild(h);
        }
    }

private:

    double[] _a;
};

class ScriptFunctionPanel : FunctionPanel
{
    this(ScriptFunction f)
    {
        super(f);

        layoutHeight(FILL_PARENT);
        backgroundColor(Color.dark_gray); // Dark background for script function panel

        EditLine textWidget = new EditLine();
        textWidget.text(to!dstring(f));
        textWidget.enabled = true;
        addChild(textWidget);

        textWidget.enterKey = delegate(EditWidgetBase editor) {
            dstring df = strip(editor.text);
            string ss = to!string(df);
            f.setFormula(ss);

            if (_h !is null)
            {
                _h(_f);
            }

            return true;
        };
    }
};
