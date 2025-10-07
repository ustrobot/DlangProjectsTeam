module eqsolver.RectD;
public
{
    import eqsolver.PointD;
}

struct RectD
{
    /// x coordinate of top left corner
    double left;
    /// y coordinate of top left corner
    double top;
    /// x coordinate of bottom right corner (non-inclusive)
    double right;
    /// y coordinate of bottom right corner (non-inclusive)
    double bottom;

    /// returns average of left, right
    @property double middlex() const
    {
        return (left + right) / 2;
    }
    /// returns average of top, bottom
    @property double middley() const
    {
        return (top + bottom) / 2;
    }
    /// returns middle point
    @property PointD middle() const
    {
        return PointD(middlex, middley);
    }

    /// returns top left point of rectangle
    @property PointD topLeft() const
    {
        return PointD(left, top);
    }
    /// returns bottom right point of rectangle
    @property PointD bottomRight() const
    {
        return PointD(right, bottom);
    }
    /// returns top right point of rectangel
    @property PointD topRight() const
    {
        return PointD(right, top);
    }
    /// returns bottom left point of rectangle
    @property PointD bottomLeft() const
    {
        return PointD(left, bottom);
    }

    /// returns size (width, height) in Point
    @property PointD size() const
    {
        return PointD(right - left, bottom - top);
    }

    /// returns width of rectangle (right - left)
    @property double width() const
    {
        return right - left;
    }
    /// returns height of rectangle (bottom - top)
    @property double height() const
    {
        return bottom - top;
    }
    /// constructs rectangle using left, top, right, bottom coordinates
    this(double x0, double y0, double x1, double y1)
    {
        left = x0;
        top = y0;
        right = x1;
        bottom = y1;
    }
    /// constructs rectangle using two points - (left, top), (right, bottom) coordinates
    this(PointD pt0, PointD pt1)
    {
        this(pt0.x, pt0.y, pt1.x, pt1.y);
    }
    /// returns true if rectangle is empty (right <= left || bottom <= top)
    @property bool empty() const
    {
        return right <= left || bottom <= top;
    }

};
