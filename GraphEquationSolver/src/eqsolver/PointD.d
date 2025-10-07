module eqsolver.PointD;
import dlangui;

/// 2D point
struct PointD
{
    double x;
    double y;

    PointD opBinary(string op)(Point v) const if (op == "+")
    {
        return PointD(x + v.x, y + v.y);
    }

    PointD opBinary(string op)(int n) const if (op == "*")
    {
        return PointD(x * n, y * n);
    }

    PointD opBinary(string op)(Point v) const if (op == "-")
    {
        return PointD(x - v.x, y - v.y);
    }

    PointD opUnary(string op)() const if (op == "-")
    {
        return PointD(-x, -y);
    }

    double opCmp(ref const PointD b) const
    {
        if (x == b.x)
            return y - b.y;
        return x - b.x;
    }

    double opCmp(const PointD b) const
    {
        if (x == b.x)
            return y - b.y;
        return x - b.x;
    }

    PointF getF()
    {
        return PointF(x, y);
    }

    Point getI()
    {
        return Point(cast(int) x, cast(int) y);
    }
}
