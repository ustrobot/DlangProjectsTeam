module EqSolver.ValidationTests;

import std;
import EqSolver;

/**
 * Unit tests demonstrating input validation
 * Run with: dub test
 */

// Test Polinom validation
unittest
{
    import std.exception : assertThrown;
    
    writeln("Testing Polinom validation...");
    
    // Test 1: Empty coefficient array
    assertThrown!InvalidParameterException(new Polinom([]));
    writeln("  ✓ Empty coefficient array rejected");
    
    // Test 2: NaN coefficients
    assertThrown!InvalidParameterException(new Polinom([1.0, double.nan, 3.0]));
    writeln("  ✓ NaN coefficient rejected");
    
    // Test 3: Infinite coefficients
    assertThrown!InvalidParameterException(new Polinom([1.0, double.infinity, 3.0]));
    writeln("  ✓ Infinite coefficient rejected");
    
    // Test 4: Valid polynomial
    auto p = new Polinom([1.0, 2.0, 3.0]);
    assert(p.eval(0) == 1.0);
    writeln("  ✓ Valid polynomial created");
    
    // Test 5: Invalid range for getRoots
    assertThrown!InvalidRangeException(p.getRoots(5.0, 2.0));
    writeln("  ✓ Invalid range rejected");
    
    // Test 6: NaN input to eval
    assertThrown!EvaluationException(p.eval(double.nan));
    writeln("  ✓ NaN input rejected");
    
    writeln("Polinom validation tests passed!");
}

// Test ScriptFunction validation
unittest
{
    import std.exception : assertThrown;
    
    writeln("Testing ScriptFunction validation...");
    
    // Test 1: Empty formula
    assertThrown!InvalidFormulaException(new ScriptFunction(""));
    writeln("  ✓ Empty formula rejected");
    
    // Test 2: Whitespace-only formula
    assertThrown!InvalidFormulaException(new ScriptFunction("   "));
    writeln("  ✓ Whitespace-only formula rejected");
    
    // Test 3: Dangerous imports
    assertThrown!InvalidFormulaException(
        new ScriptFunction("import std.file; readText(\"/etc/passwd\")")
    );
    writeln("  ✓ Dangerous formula rejected");
    
    // Test 4: Valid formula (may take time to initialize)
    // Commented out to avoid spawning processes in unit tests
    // auto sf = new ScriptFunction("x * 2");
    // assert(sf.eval(5.0) == 10.0);
    // writeln("  ✓ Valid formula accepted");
    
    writeln("ScriptFunction validation tests passed!");
}

// Test GraphPanel validation
unittest
{
    import std.exception : assertThrown;
    
    writeln("Testing GraphPanel validation...");
    
    auto panel = new GraphPanel();
    
    // Test 1: Null function
    assertThrown!InvalidParameterException(panel.addFunction(null));
    writeln("  ✓ Null function rejected");
    
    // Test 2: Invalid viewport range
    assertThrown!InvalidRangeException(panel.setFrom(10.0, 5.0));
    writeln("  ✓ Invalid viewport range rejected");
    
    // Test 3: NaN viewport
    assertThrown!InvalidParameterException(panel.setFrom(double.nan, 5.0));
    writeln("  ✓ NaN viewport rejected");
    
    // Test 4: Extreme zoom (too small)
    assertThrown!InvalidParameterException(panel.setFrom(0.0, 1e-11));
    writeln("  ✓ Extreme zoom (too small) rejected");
    
    // Test 5: Extreme zoom (too large)
    assertThrown!InvalidParameterException(panel.setFrom(-1e11, 1e11));
    writeln("  ✓ Extreme zoom (too large) rejected");
    
    // Test 6: Valid viewport
    panel.setFrom(-10.0, 10.0);
    writeln("  ✓ Valid viewport accepted");
    
    writeln("GraphPanel validation tests passed!");
}

// Test exception hierarchy
unittest
{
    writeln("Testing exception hierarchy...");
    
    auto e1 = new GraphEquationSolverException("test");
    assert(cast(Exception) e1 !is null);
    
    auto e2 = new InvalidFormulaException("test");
    assert(cast(GraphEquationSolverException) e2 !is null);
    
    auto e3 = new EvaluationException("test", 1.0);
    assert(cast(GraphEquationSolverException) e3 !is null);
    
    auto e4 = new InvalidParameterException("param", "test");
    assert(cast(GraphEquationSolverException) e4 !is null);
    
    auto e5 = new InvalidRangeException(1.0, 0.0);
    assert(cast(GraphEquationSolverException) e5 !is null);
    
    auto e6 = new NumericalException("test");
    assert(cast(GraphEquationSolverException) e6 !is null);
    
    writeln("  ✓ All exception types properly inherit");
    writeln("Exception hierarchy tests passed!");
}

