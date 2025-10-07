module EqSolver.GraphPanel;
import dlangui;
import std;

import EqSolver.CoordinateMapper;

public
{
    import EqSolver.Polinom;
}

class GraphPanel : Widget
{
public:

    void addFunction(Function f)
    {
        _functions ~= f;
    }

    void removeFunction(Function f)
    {
        auto index = _functions.countUntil(f);
        _functions = remove(_functions, tuple(index, index + 1));
        invalidate();
    }

    void clearFunctions()
    {
        _functions = [];
        invalidate();
    }

    this()
    {
        _mapper = new CoordinateMapper();
        setFrom(-5, 5);
    }

private:

enum ЦветаДляФункций
{
	фиолетовый = 0x7E12A5
}

    static const uint[] funcColors = [
       ЦветаДляФункций.фиолетовый , Color.dark_green, Color.dark_red, Color.dark_blue, Color.dark_salmon,
        Color.orange, Color.magenta, Color.blue, Color.dark_orange
    ];

    const RectD fromRect = RectD(-5, -5, 5, 5);
    const double step = 0.005;

    CoordinateMapper _mapper;
    Function[] _functions;

    double _fromLeft;
    double _fromRight;
    Point _toOffset;

    double _step;
    int _stepNum = 500;
    double _stepX = 1;
    double _stepY = 1;

    Point _mouseDownPos;
    Point _mouseDownOffset;
    bool _inDrag = false;

protected:
    override void onDraw(DrawBuf buf)
    {
        super.onDraw(buf);

        RectD from = getFrom();
        _mapper.setFrom(from);
        _mapper.setTo(Rect(_pos.left + _toOffset.x, _pos.top + _toOffset.y,
                _pos.right + _toOffset.x, _pos.bottom + _toOffset.y));

        auto saver = ClipRectSaver(buf, _pos, alpha);
        buf.clipRect(_pos);

        drawAxes(buf);
        drawFunctions(buf);
    }

    override bool onMouseEvent(MouseEvent event)
    {
        MouseButton eventButton = event.button;
        MouseAction action = event.action;

		//writeln("EVENT ", event);
        switch (action)
        {
        case MouseAction.ButtonDown:
            if (eventButton == MouseButton.Left)
            {
                _inDrag = true;
                _mouseDownPos = event.pos;
                _mouseDownOffset = _toOffset;
            }
            break;
        case MouseAction.Move:
            if (_inDrag)
            {
                Point move = event.pos - _mouseDownPos;
                _toOffset = _mouseDownOffset + move;
                invalidate();
            }
            else
            {
                applyTooltip(event.pos);
            }
            break;
        case MouseAction.ButtonUp:
            if (eventButton == MouseButton.Left)
            {
                _inDrag = false;
                _mouseDownOffset = Point(0, 0);
            }
            break;
        case MouseAction.Wheel:
            //writeln(event.wheelDelta());
            zoom(event.wheelDelta());
            break;
        default:
            writeln("Unexpected ACTION:", event);
        }

        stdout.flush();

        return super.onMouseEvent(event);
    }

    override Widget createTooltip(int mouseX, int mouseY, ref uint alignment, ref int x, ref int y)
    {
        auto res = super.createTooltip(mouseX, mouseY, alignment, x, y);
        alignment = PopupAlign.Point;
        x = mouseX;
        y = mouseY;
        return res;
    }
    
    void applyTooltip(Point pt)
    {
        for (int i = 0; i < _functions.length; i++)
        {
            Polinom p = cast(Polinom) _functions[i];
            if (p)
            {
                PointD fromXm = _mapper.mapPointFrom(PointD(_pos.left, 0));
                PointD toXm = _mapper.mapPointFrom(PointD(_pos.right, 0));
                double[] roots = p.getRoots(fromXm.x, toXm.x);
                for (int j = 0; j < roots.length; j++)
                {
                    PointD rp = _mapper.mapPointTo(PointD(roots[j], 0));
                    //writefln("(%f,%f) (%f,%f)", pt.x, pt.y, rp.x, rp.y);
                    if (sqrt((pt.x - rp.x) ^^ 2 + (pt.y - rp.y) ^^ 2) < 10)
                    {
                        dstring t = format("%.12g"d, roots[j]);
                        //writeln("TOOLTIP:", t);
                        this.tooltipText = t;
                        return;
                    }
                }
            }
        }

        //writeln("EMPTY TOOLTIP");
        this.tooltipText = "";
    }

    void zoom(short delta)
    {
        double fromLeft = _fromLeft;
        double fromRight = _fromRight;

        double center = (fromRight + fromLeft) / 2;
        double width = fromRight - fromLeft;

        double k = delta > 0 ? 1.1 : 1 / 1.1;

        fromLeft = center - k * width / 2;
        fromRight = center + k * width / 2;

        setFrom(fromLeft, fromRight);
    }

    void drawFunctions(DrawBuf buf)
    {
        for (int i = 0; i < _functions.length; i++)
        {
            //writeln(_func[i]);
            //stdout.flush();
            Function f = _functions[i];
            drawFunction(buf, f, funcColors[i % funcColors.length]);
            if ((cast(Polinom) f) !is null)
            {
                drawRoots(buf, cast(Polinom) f, Color.red);
            }
        }
    }

    void drawFunction(DrawBuf buf, Function f, uint color)
    {
        int iterationsCount = 0;

        PointD fromXm = _mapper.mapPointFrom(PointD(_pos.left, 0));
        PointD toXm = _mapper.mapPointFrom(PointD(_pos.right, 0));

        PointD prev = _mapper.mapPointTo(PointD(fromXm.x, f.eval(fromXm.x)));

        double yp = double.nan;
        double xp = double.nan;
        double k = 1;

        for (double x = fromXm.x + _step; x < toXm.x; x += abs(k) > 1 ? _step / min(100, abs(k))
                : _step)
        {
            double cs = abs(k) > 1 ? _step / min(100, abs(k)) : _step;
            double y = f.eval(x);

            iterationsCount += 1;

            PointD p = _mapper.mapPointTo(PointD(x, y));
            buf.drawLineF(prev.getF(), p.getF(), 2.5, color);

            if (!isNaN(yp))
            {
                if (_pos.isPointInside(prev.getI()) || _pos.isPointInside(p.getI()))
                {
                    k = (y - yp) / (x - xp);
                }
                else
                {
                    k = 1;
                }
            }

            prev = p;
            yp = y;
            xp = x;

            //writefln("f(%f)= %f", x, y);
            //stdout.flush();
        }

        //writefln("### Draw function %s iterations = %d", f, iterationsCount);
        stdout.flush();
    }

    void drawAxes(DrawBuf buf)
    {
        RectD from = getFrom();
        PointD fromXm = PointD(from.left, 0);
        PointD fromX = _mapper.mapPointTo(fromXm);
        fromX.x = _pos.left;

        PointD toXm = PointD(from.right, 0);
        PointD toX = _mapper.mapPointTo(toXm);
        toX.x = _pos.right;

        PointD fromYm = PointD(0, from.bottom);
        PointD fromY = _mapper.mapPointTo(fromYm);
        fromY.y = _pos.bottom;

        PointD toYm = PointD(0, from.top);
        PointD toY = _mapper.mapPointTo(toYm);
        toY.y = _pos.top;

        buf.drawLineF(PointF(fromX.x, fromX.y), PointF(toX.x, toX.y), 1, Color.dark_blue);

        fromXm = _mapper.mapPointFrom(fromX);
        toXm = _mapper.mapPointFrom(toX);
        for (double x = floor(fromXm.x / _stepX) * _stepX; x < toXm.x; x += _stepX)
        {
            PointD p = _mapper.mapPointTo(PointD(x, 0));
            buf.drawLineF(PointF(p.x, p.y), PointF(p.x, p.y - 5), 1, Color.dark_blue);
        }

        buf.drawLineF(PointF(fromY.x, fromY.y), PointF(toY.x, toY.y), 1, Color.dark_blue);

        fromYm = _mapper.mapPointFrom(fromY);
        toYm = _mapper.mapPointFrom(toY);
        for (double y = floor(fromYm.y / _stepY) * _stepY; y < toYm.y; y += _stepY)
        {
            PointD p = _mapper.mapPointTo(PointD(0, y));
            buf.drawLineF(PointF(p.x, p.y), PointF(p.x + 5, p.y), 1, Color.dark_blue);
        }
    }

    void drawLine(DrawBuf buf, double x1, double y1, double x2, double y2, uint color)
    {
        PointD p1 = _mapper.mapPointTo(PointD(x1, y1));
        PointD p2 = _mapper.mapPointTo(PointD(x2, y2));
        int px1 = cast(int) p1.x;
        int py1 = cast(int) p1.y;
        int px2 = cast(int) p2.x;
        int py2 = cast(int) p2.y;

        buf.drawLine(Point(px1, py1), Point(px2, py2), color);
    }

    void drawRoots(DrawBuf buf, Polinom f, Color c)
    {
        PointD fromXm = _mapper.mapPointFrom(PointD(_pos.left, 0));
        PointD toXm = _mapper.mapPointFrom(PointD(_pos.right, 0));

        double[] roots = f.getRoots(fromXm.x, toXm.x);
        //writeln("DRAW ", roots);
        for (int i = 0; i < roots.length; i++)
        {
            drawRoot(buf, PointD(roots[i], f.eval(roots[i])), c);
        }
    }

    void drawRoot(DrawBuf buf, PointD rp, Color c)
    {
        PointD p = _mapper.mapPointTo(rp);
        double radius = 1.5;
        buf.drawEllipseF(p.x - radius, p.y - radius, radius * 2, radius * 2, 1, c, c);
    }

    RectD getFrom()
    {
        double h = (_fromRight - _fromLeft) * (_pos.bottom - _pos.top) / (_pos.right - _pos.left);
        return RectD(_fromLeft, h / 2, _fromRight, -h / 2);
    }

    void setFrom(double fromLeft, double fromRight)
    {
        _fromLeft = fromLeft;
        _fromRight = fromRight;
        _step = (_fromRight - _fromLeft) / _stepNum;
        invalidate();
    }
}
