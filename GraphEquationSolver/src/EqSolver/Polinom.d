module EqSolver.Polinom;
import std;

public
{
    import EqSolver.Function;
    import EqSolver.Exceptions;
}

class Polinom : Function
{
    // Numerical computation constants
    enum PolynomialConstants
    {
        EPSILON = 1e-15, // Tolerance for root existence check
        ZERO_THRESHOLD = 1e-300, // Threshold for considering value as zero
        DEFAULT_TOLERANCE = 0.0 // Default tolerance for bisection
    }

    public this(double[] a)
    {
        // Validate input
        if (a.length == 0)
        {
            throw new InvalidParameterException("a", "Coefficient array cannot be empty");
        }
        
        // Check for NaN or Inf values
        foreach (i, coeff; a)
        {
            if (isNaN(coeff))
            {
                throw new InvalidParameterException("a", 
                    format("Coefficient at index %d is NaN", i));
            }
            if (isInfinity(coeff))
            {
                throw new InvalidParameterException("a", 
                    format("Coefficient at index %d is infinite", i));
            }
        }
        
        this._a = a.idup;
    }

    public override double eval(double x)
    {
        // Validate input
        if (isNaN(x))
        {
            throw new EvaluationException("Input x is NaN", x);
        }
        
        double res = 0;
        double xp = 1;
        for (int i = 0; i < _a.length; i++)
        {
            res += xp * _a[i];
            xp *= x;
            
            // Check for overflow
            if (isInfinity(res))
            {
                throw new EvaluationException("Result overflow (infinite value)", x);
            }
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
        // Validate range
        if (a >= b)
        {
            throw new InvalidRangeException(a, b);
        }
        if (isNaN(a) || isNaN(b))
        {
            throw new InvalidParameterException("range", "Range bounds cannot be NaN");
        }
        
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
        switch (i)
        {
        case 1:
            return "";
        case 2:
            return "²";
        case 3:
            return "³";
        case 4:
            return "⁴";
        case 5:
            return "⁵";
        case 6:
            return "⁶";
        case 7:
            return "⁷";
        case 8:
            return "⁸";
        case 9:
            return "⁹";
        default:
            return format("^^%d", i);
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
                }
                else if (_a[i] < 0)
                {
                    result ~= " - ";
                }
            }
            if (_a[i] != 0)
            {
                if (i == 0)
                {
                    result ~= format("%g", _a[i]);
                }
                else if (_a[i] == 1 || _a[i] == -1)
                {
                    result ~= "x" ~ powerString(i);
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
        // Validate input (same as constructor)
        if (a.length == 0)
        {
            throw new InvalidParameterException("a", "Coefficient array cannot be empty");
        }
        
        foreach (i, coeff; a)
        {
            if (isNaN(coeff))
            {
                throw new InvalidParameterException("a", 
                    format("Coefficient at index %d is NaN", i));
            }
            if (isInfinity(coeff))
            {
                throw new InvalidParameterException("a", 
                    format("Coefficient at index %d is infinite", i));
            }
        }
        
    	_a = a.idup;
    	_roots = null;
    }

private:
    public double doBisection(double a, double b, double tol)
    {
        // Validate inputs
        if (a >= b)
        {
            throw new InvalidRangeException(a, b);
        }
        if (isNaN(a) || isNaN(b) || isNaN(tol))
        {
            throw new InvalidParameterException("bisection parameters", 
                "Parameters cannot be NaN");
        }
        if (tol < 0)
        {
            throw new InvalidParameterException("tol", 
                "Tolerance must be non-negative");
        }

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
            if (fa * fb > PolynomialConstants.EPSILON)
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
        while (abs(a - b) / 2 >= tol && abs(fmid) > PolynomialConstants.DEFAULT_TOLERANCE);

        return c;
    }

    double[] solve(double a, double b)
    {
        // Validate range
        if (a >= b)
        {
            throw new InvalidRangeException(a, b);
        }
        if (isNaN(a) || isNaN(b))
        {
            throw new InvalidParameterException("range", "Range bounds cannot be NaN");
        }
        
        double[] result = [];

        if (order() == 0)
        {
            return new double[0];
        }
        else if (order() == 1)
        {
            return [-this._a[0] / this._a[1]];
        }

        Polinom derivative = derivate();

        double[] derivativeRoots = derivative.solve(a, b);
        double[] ranges = new double[derivativeRoots.length + 2];
        ranges[0] = a;
        ranges[ranges.length - 1] = b;
        for (int i = 0; i < derivativeRoots.length; i++)
        {
            ranges[i + 1] = derivativeRoots[i];
        }

        for (int i = 0; i < ranges.length - 1; i++)
        {
            double val1 = eval(ranges[i]);
            double val2 = eval(ranges[i + 1]);
            if (abs(val1) < PolynomialConstants.ZERO_THRESHOLD)
            {
                result ~= ranges[i];
            }

            if (abs(val2) < PolynomialConstants.ZERO_THRESHOLD)
            {
                result ~= ranges[i + 1];
            }

            if (val1 * val2 < 0)
            {
                double root = doBisection(ranges[i],
                    ranges[i + 1], PolynomialConstants.DEFAULT_TOLERANCE);
                result ~= root;
            }
        }

        return result;
    }

private:

    immutable(double)[] _a;
    double[] _roots;
    double _rootsFrom;
    double _rootsTo;
}
