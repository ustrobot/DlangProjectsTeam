module EqSolver.ScriptFunction;
import std;
import core.sys.posix.fcntl;

public
{
    import EqSolver.Function;
    import EqSolver.Exceptions;
}

class ScriptFunction : Function
{
public:

    this(string f)
    {
        setFormula(f);
    }

    override double eval(double x)
    {
        // Validate input
        if (isNaN(x))
        {
            throw new EvaluationException("Input x is NaN", x);
        }
        
        try
        {
            string sr = requestScript(format("%f", x));
            double result = to!double(strip(sr));
            
            // Validate result
            if (isNaN(result))
            {
                throw new EvaluationException("Function returned NaN", x);
            }
            
            return result;
        }
        catch (ConvException e)
        {
            throw new EvaluationException("Script returned non-numeric value", x);
        }
        catch (Exception e)
        {
            throw new EvaluationException("Script execution failed: " ~ e.msg, x);
        }
    }

    override string toString() const
    {
        return _f;
    }

    void setFormula(string f)
    {
        // Validate formula
        if (f.length == 0)
        {
            throw new InvalidFormulaException("Formula cannot be empty");
        }
        
        string trimmed = strip(f);
        if (trimmed.length == 0)
        {
            throw new InvalidFormulaException("Formula cannot be whitespace only");
        }
        
        // Basic sanitization - check for obviously dangerous patterns
        if (trimmed.canFind("import") && (trimmed.canFind("std.file") || 
            trimmed.canFind("std.process") || trimmed.canFind("core.sys")))
        {
            throw new InvalidFormulaException(
                "Formula contains potentially dangerous imports (file/process operations)");
        }
        
        if (!equal(f, _f))
        {
        	if (_pipes.pid !is null)
        	{
        		try
        		{
	        		kill(_pipes.pid);
	        		wait(_pipes.pid);
	        	}
	        	catch (Exception e)
	        	{
	        		stderr.writeln("Warning: Failed to cleanup previous process: ", e.msg);
	        	}
        	}
            _f = f.dup();

            string writeFormat = "%f";
            string script = q{  
        	import std;
        	do
        	{
        	string s = readln();
        	double x = to!double(strip(s));
        	double y = %s;
        	writefln("%s",y);
        	stdout.flush();
        	stderr.flush();
        	}while(true);
        };

            script = format(script, f, writeFormat);

            writeln(script);

            string[] runScript = ["rdmd", "--eval", script];

            try
            {
                _pipes = pipeProcess(runScript, Redirect.stdout | Redirect.stderr | Redirect.stdin);
                fcntl(_pipes.stderr.fileno, F_SETFL, fcntl(_pipes.stderr.fileno, F_GETFL) | O_NONBLOCK);
            }
            catch (Exception e)
            {
                throw new InvalidFormulaException("Failed to start evaluation process: " ~ e.msg);
            }
            
            // Test the formula with a simple value to catch syntax errors early
            try
            {
                eval(0.0);
            }
            catch (EvaluationException e)
            {
                // Clean up the failed process
                if (_pipes.pid !is null)
                {
                    try { kill(_pipes.pid); wait(_pipes.pid); } catch (Exception) {}
                }
                throw new InvalidFormulaException("Formula has syntax or evaluation errors: " ~ e.msg);
            }
        }
    }

private:

    string requestScript(string message)
    {
        _pipes.stdin.writeln(message);
        _pipes.stdin.flush();

        string output = strip(_pipes.stdout.readln());

        try
        {
            do
            {
                auto buf = _pipes.stderr.readln();
                if (buf.length > 1)
                {
                    stderr.write(buf);
                }
            }
            while (!_pipes.stderr.eof);
        }
        catch (Exception ex)
        {

        }

        //writefln("f(%s) = %s", message, output);
        //stdout.flush();
        return output;
    }

    string _f;
    ProcessPipes _pipes;
}
