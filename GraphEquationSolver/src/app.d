import std;
import dlangui;
import eqsolver;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args)
{
    GraphWindowController wc = new GraphWindowController("Графики функций 📈"d);
    wc.addScriptFunction("x^^3");
    wc.addScriptFunction("sin(x/3)*3");
    wc.addScriptFunction("sqrt(x)");
    wc.addPolinomFunction([0, -2, 1, 1, 1, -1]);
    wc.addPolinomFunction([0, 0, 1]);

    //    for(int i=0;i<30;i++)
    //    {
    //    	wc.addScriptFunction(format("x^^((%d+1)/5.0)", i));
    //    }

    wc.show();

    return Platform.instance.enterMessageLoop();
}
