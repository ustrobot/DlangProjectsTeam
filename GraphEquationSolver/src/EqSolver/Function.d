module EqSolver.Function;
import std.math;

interface Function
{
    public double eval(double x);
};

class X2 : Function
{
    override double eval(double x)
    {
        return x * x;
    }

    override string toString()
    {
        return "y = x^^2";
    }
};

class Sin : Function
{
    override double eval(double x)
    {
        return sin(x);
    }

    override string toString()
    {
        return "y = sin(x)";
    }
};

class Oscillator : Function
{
    override double eval(double x)
    {
        return sin(1 / x);
    }

    override string toString()
    {
        return "y = sin(1/x)";
    }
};

class Tg : Function
{
    override double eval(double x)
    {
        return tan(x);
    }

    override string toString()
    {
        return "y = tg(x)";
    }
};
