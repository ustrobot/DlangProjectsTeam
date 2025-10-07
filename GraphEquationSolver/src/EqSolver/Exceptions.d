module EqSolver.Exceptions;

/**
 * Base exception for GraphEquationSolver errors
 */
class GraphEquationSolverException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

/**
 * Exception thrown when a mathematical formula is invalid
 */
class InvalidFormulaException : GraphEquationSolverException
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super("Invalid formula: " ~ msg, file, line);
    }
}

/**
 * Exception thrown when function evaluation fails
 */
class EvaluationException : GraphEquationSolverException
{
    this(string msg, double x, string file = __FILE__, size_t line = __LINE__)
    {
        import std.format : format;
        super(format("Cannot evaluate at x=%g: %s", x, msg), file, line);
    }
}

/**
 * Exception thrown when invalid parameters are provided
 */
class InvalidParameterException : GraphEquationSolverException
{
    this(string paramName, string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super("Invalid parameter '" ~ paramName ~ "': " ~ msg, file, line);
    }
}

/**
 * Exception thrown when a range is invalid
 */
class InvalidRangeException : GraphEquationSolverException
{
    this(double from, double to, string file = __FILE__, size_t line = __LINE__)
    {
        import std.format : format;
        super(format("Invalid range [%g, %g]: start must be less than end", from, to), file, line);
    }
}

/**
 * Exception thrown when numerical computation fails
 */
class NumericalException : GraphEquationSolverException
{
    this(string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super("Numerical error: " ~ msg, file, line);
    }
}

