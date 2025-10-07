module eqsolver.ScriptFunction;
import std;
import core.sys.posix.fcntl;
import core.thread : Thread;
import core.time : dur;

public
{
    import eqsolver.Function;
    import eqsolver.Exceptions;
}

class ScriptFunction : Function
{
public:

    this(string f)
    {
        setFormula(f);
    }

    /**
     * Destructor - ensures process cleanup when object is destroyed
     */
    ~this()
    {
        cleanup();
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
            return to!double(strip(sr));
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

    bool isValid()
    {
        return _pipes.pid !is null &&
            _pipes.stdin.isOpen && _pipes.stdout.isOpen;
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
            // Clean up any existing process
            cleanup();

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
                _processActive = true;

                // Set stderr to non-blocking mode
                fcntl(_pipes.stderr.fileno, F_SETFL, fcntl(_pipes.stderr.fileno, F_GETFL) | O_NONBLOCK);
            }
            catch (Exception e)
            {
                _processActive = false;
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
                cleanup();
                throw new InvalidFormulaException(
                    "Formula has syntax or evaluation errors: " ~ e.msg);
            }
        }
    }

private:

    /**
     * Clean up the spawned process
     * This method is safe to call multiple times
     */
    void cleanup()
    {
        if (!_processActive)
        {
            return; // No active process to clean up
        }

        if (_pipes.pid is null)
        {
            _processActive = false;
            return; // Process already cleaned up
        }

        try
        {
            // First, try to close stdin to signal the process to exit gracefully
            try
            {
                _pipes.stdin.close();
            }
            catch (Exception e)
            {
                // Stdin might already be closed
            }

            // Wait briefly for graceful exit
            import core.thread : Thread;
            import core.time : msecs;

            Thread.sleep(10.msecs);

            // Check if process is still running
            auto result = tryWait(_pipes.pid);
            if (result.terminated)
            {
                // Process exited gracefully
                _processActive = false;
                return;
            }

            // Process still running, send SIGTERM
            kill(_pipes.pid, 15); // SIGTERM
            Thread.sleep(50.msecs);

            // Check again
            result = tryWait(_pipes.pid);
            if (result.terminated)
            {
                _processActive = false;
                return;
            }

            // Still running, force kill with SIGKILL
            kill(_pipes.pid, 9); // SIGKILL
            wait(_pipes.pid);
            _processActive = false;
        }
        catch (Exception e)
        {
            stderr.writeln("Warning: Error during process cleanup: ", e.msg);
            // Mark as inactive even if cleanup failed to prevent repeated attempts
            _processActive = false;
        }
    }

    string requestScript(string message)
    {
        if (!_processActive || _pipes.pid is null)
        {
            throw new NumericalException("Evaluation process is not active");
        }

        try
        {
            _pipes.stdin.writeln(message);
            _pipes.stdin.flush();
        }
        catch (Exception e)
        {
            _processActive = false;
            throw new NumericalException("Failed to send data to evaluation process: " ~ e.msg);
        }

        string output;
        try
        {
            output = strip(_pipes.stdout.readln());

            // Check if we got valid output
            if (output.length == 0)
            {
                _processActive = false;
                throw new NumericalException("Evaluation process returned empty output");
            }
        }
        catch (Exception e)
        {
            _processActive = false;
            throw new NumericalException("Failed to read from evaluation process: " ~ e.msg);
        }

        // Read any stderr output (non-blocking)
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
            // Non-blocking read may throw when no data available
        }

        //writefln("f(%s) = %s", message, output);
        //stdout.flush();
        return output;
    }

    string _f;
    ProcessPipes _pipes;
    bool _processActive = false; // Track if process is running
}
