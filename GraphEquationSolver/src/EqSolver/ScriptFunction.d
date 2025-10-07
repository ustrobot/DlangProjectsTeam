module EqSolver.ScriptFunction;
import std;
import core.sys.posix.fcntl;

public
{
    import EqSolver.Function;
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
        string sr = requestScript(format("%f", x));
        double result = to!double(strip(sr));
        return result;
    }

    override string toString() const
    {
        return _f;
    }

    void setFormula(string f)
    {
        if (!equal(f, _f))
        {
            if (_pipes.pid !is null)
            {
                kill(_pipes.pid);
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

            _pipes = pipeProcess(runScript, Redirect.stdout | Redirect.stderr | Redirect.stdin);

            fcntl(_pipes.stderr.fileno, F_SETFL, fcntl(_pipes.stderr.fileno, F_GETFL) | O_NONBLOCK);
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
