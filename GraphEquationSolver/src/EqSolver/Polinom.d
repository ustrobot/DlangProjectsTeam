module EqSolver.Polinom;
import std;

public
{
    import EqSolver.Function;
}

class Polinom : Function
{
    public this(double[] a)
    {
        this._a = a.idup;
    }

    public override double eval(double x)
    {
        double res = 0;
        double xp = 1;
        for (int i = 0; i < _a.length; i++)
        {
            res += xp * _a[i];
            xp *= x;
        }
        return res;
    }

    long order()
    {
        long i = _a.length - 1;
        do
        {
            if (_a[i] != 0)
                return i;
        }
        while (--i >= 0);
        return 0;
    }

    Polinom derivate()
    {
        double[] c = new double[_a.length - 1];

        for (int i = 0; i < c.length; i++)
        {
            c[i] = _a[i + 1] * (i + 1);
        }

        return new Polinom(c);
    }

    double[] getRoots(double a, double b)
    {
        if (!_roots || _rootsFrom > a || _rootsTo < b)
        {
            double from = min(a, _rootsFrom);
            double to = max(b, _rootsTo);
            _roots = solve(from, to);
            _rootsFrom = from;
            _rootsTo = to;

        }
        return _roots;
    }
    
    static string powerString(int i)
    {
    	switch(i)
    	{
    		case 1: return "";
    		case 2: return "²";
    		case 3: return "³";
    		case 4: return "⁴";
    		case 5: return "⁵";
    		case 6: return "⁶";
    		case 7: return "⁷";
    		case 8: return "⁸";
    		case 9: return "⁹";
    		default: return format("^^%d", i);
    	}
    	
    	return "";
    }

    override string toString()
    {
        string result = "";
        for (int i = 0; i < _a.length; i++)
        {
            if (result.length > 0)
            {
            	if (_a[i] > 0)
            	{
	                result ~= " + ";
            	}else if (_a[i] < 0)
            	{
            		result ~= " - ";
            	}
            }
            if (_a[i] != 0)
            {
            	if (i==0)
            	{
            		result ~= format("%g", _a[i]);
            	}else if (_a[i] == 1 || _a[i] == -1)
                {
                    result ~= "x"~powerString(i);
                }
                else
                {
                    result ~= format("%gx%s", abs(_a[i]), powerString(i));
                }
            }
        }
        return "y = " ~ result;
    }
    
    double[] coefficients()
    {
    	return _a.dup;
    }
    
    void setCoefficients(double[] a)
    {
    	_a = a.idup;
    	_roots = null;
    }

private:
    public double doBisection(double a, double b, double tol)
    {

        //System.out.println("Ищем корни функции " + this + " на интервале (" + a +", "+ b + ")");

        if (eval(a) * eval(b) >= 0)
            return double.nan;

        int iterations = 1;
        double fa, fb, fmid, c = 0;

        //writeln("Итерация" + space + "A" + space + "B" + space + "C" + space + "F(C)");

        do
        {
            fa = eval(a);
            fb = eval(b);
            if (fa * fb > 1e-15)
            {
                return double.nan;
                //throw new Exception("Нет корня на интервале (" + a + "," + b + ")");
            }
            c = (a + b) / 2;

            if (c <= a || c >= b)
            {
                break;
            }

            fmid = eval(c);
            //System.out.println(iterations + space + "  " + df.format(a) + "  " + df.format(b) + "  " + df.format(c)
            //		+ "  " + df.format(fmid));
            if (fmid * fa < 0)
                b = c;
            else
                a = c;
            iterations++;
        }
        while (abs(a - b) / 2 >= tol && abs(fmid) > 0.0);

        return c;
    }

    double[] solve(double a, double b)
    {
        double[] результат = [];

        if (order() == 0)
        {
            return new double[0];
        }
        else if (order() == 1)
        {
            return [-this._a[0] / this._a[1]];
        }

        Polinom производная = derivate();

        double[] корниПроизводной = производная.solve(a, b);
        double[] диапазоны = new double[корниПроизводной.length + 2];
        диапазоны[0] = a;
        диапазоны[диапазоны.length - 1] = b;
        for (int i = 0; i < корниПроизводной.length; i++)
        {
            диапазоны[i + 1] = корниПроизводной[i];
        }

        for (int i = 0; i < диапазоны.length - 1; i++)
        {
            double val1 = eval(диапазоны[i]);
            double val2 = eval(диапазоны[i + 1]);
            if (abs(val1) < 1e-300)
            {
                результат ~= диапазоны[i];
            }

            if (abs(val2) < 1e-300)
            {
                результат ~= диапазоны[i + 1];
            }

            if (val1 * val2 < 0)
            {
                double корень = doBisection(диапазоны[i],
                        диапазоны[i + 1], 0);
                результат ~= корень;
            }
        }

        return результат;
    }

private:

    immutable(double)[] _a;
    double[] _roots;
    double _rootsFrom;
    double _rootsTo;
}
