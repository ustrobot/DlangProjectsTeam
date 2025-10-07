module EqSolver.CoordinateMapper;

import std;
import dlangui;

public
{
    import EqSolver.RectD;
}

class CoordinateMapper
{
    void setFrom(RectD from)
    {
        _from = from;
    }

    void setTo(RectD to)
    {
        _to = to;
    }

    void setTo(Rect to)
    {
        _to = RectD(to.left, to.top, to.right, to.bottom);
    }

    RectD getTo()
    {
        return _to;
    }

    RectD getFromTo()
    {
        return _to;
    }

    /*

		FROM

			Y			A(5,5)
			|
			|
			|
			|
			|
P-----------0----------->X
            |
            |
            |
            |
            |
 B(-5,-5)   |			
            

		TO

0----------------->X A(600,0)
|		
|
P        m0()
|
|
VB(0,400)					
Y
*/

    // from Math to Panel
    PointD mapPointTo(PointD p)
    {
        double dx = (p.x - _from.left) / _from.width * _to.width + _to.left;
        double dy = (p.y - _from.top) / _from.height * _to.height + _to.top;
        return PointD(dx, dy);
    }

    // from Panel to Math
    PointD mapPointFrom(PointD p)
    {
        double dx = (p.x - _to.left) / _to.width * _from.width + _from.left;
        double dy = (p.y - _to.top) / _to.height * _from.height + _from.top;
        return PointD(dx, dy);
    }

    override string toString() const
    {
        return format("CoordinateMapper(from=%s to=%s)", _from, _to);
    }

private:

    RectD _from;
    RectD _to;
}
