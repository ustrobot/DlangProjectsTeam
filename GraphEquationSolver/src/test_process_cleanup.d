
/**
 * Test script to verify process cleanup in ScriptFunction
 * This tests that processes are properly terminated when ScriptFunction objects are destroyed
 */
module test_process_cleanup;

import std.stdio;
import std.process;
import std.string;
import std.conv;
import std.algorithm;
import core.thread;
import core.time;
import dlangui;

void main()
{
    writeln("=== ScriptFunction Process Cleanup Test ===\n");
    
    // Get initial rdmd process count
    int initialCount = getRdmdProcessCount();
    writeln("Initial rdmd process count: ", initialCount);
    
    // Test 1: Create and destroy ScriptFunction
    writeln("\nTest 1: Creating ScriptFunction...");
    {
        import eqsolver;
        
        try
        {
            auto sf = new ScriptFunction("x * 2");
            writeln("  Formula set successfully");
            
            // Use it a few times
            double result = sf.eval(5.0);
            writeln("  Evaluated: f(5) = ", result);
            assert(result == 10.0, "Evaluation failed");
            
            int duringCount = getRdmdProcessCount();
            writeln("  During execution rdmd count: ", duringCount);
            assert(duringCount > initialCount, "Process should be running");
            
            // sf will be destroyed at end of scope
        }
        catch (Exception e)
        {
            writeln("  Error: ", e.msg);
        }
    }
    
    // Wait a moment for cleanup
    Thread.sleep(200.msecs);
    
    int afterCount = getRdmdProcessCount();
    writeln("After destruction rdmd count: ", afterCount);
    
    if (afterCount == initialCount)
    {
        writeln("✓ Test 1 PASSED: Process cleaned up correctly");
    }
    else
    {
        writeln("✗ Test 1 FAILED: Process leak detected (", afterCount - initialCount, " extra processes)");
    }
    
    // Test 2: Multiple create/destroy cycles
    writeln("\nTest 2: Multiple create/destroy cycles...");
    foreach (i; 0..3)
    {
        import EqSolver;
        
        try
        {
            auto sf = new ScriptFunction(format("x + %d", i));
            double result = sf.eval(1.0);
            writeln("  Cycle ", i, ": f(1) = ", result);
        }
        catch (Exception e)
        {
            writeln("  Cycle ", i, " error: ", e.msg);
        }
        
        Thread.sleep(100.msecs);
    }
    
    Thread.sleep(200.msecs);
    int finalCount = getRdmdProcessCount();
    writeln("Final rdmd count: ", finalCount);
    
    if (finalCount == initialCount)
    {
        writeln("✓ Test 2 PASSED: No process leaks after multiple cycles");
    }
    else
    {
        writeln("✗ Test 2 FAILED: Process leaks detected (", finalCount - initialCount, " extra processes)");
    }
    
    // Test 3: Formula change (should cleanup old process)
    writeln("\nTest 3: Formula change cleanup...");
    {
        import EqSolver;
        
        try
        {
            auto sf = new ScriptFunction("x * 2");
            writeln("  Initial formula set");
            
            int before = getRdmdProcessCount();
            writeln("  Process count before change: ", before);
            
            // Change formula (should cleanup old process)
            sf.setFormula("x * 3");
            writeln("  Formula changed");
            
            Thread.sleep(100.msecs);
            
            int after = getRdmdProcessCount();
            writeln("  Process count after change: ", after);
            
            // Should still have one process (the new one)
            if (after == before)
            {
                writeln("✓ Test 3 PASSED: Old process cleaned up on formula change");
            }
            else
            {
                writeln("✗ Test 3 FAILED: Process leak on formula change");
            }
        }
        catch (Exception e)
        {
            writeln("  Error: ", e.msg);
        }
    }
    
    Thread.sleep(200.msecs);
    
    writeln("\n=== All Tests Complete ===");
    writeln("Final cleanup check...");
    int veryFinalCount = getRdmdProcessCount();
    writeln("Very final rdmd count: ", veryFinalCount);
    
    if (veryFinalCount == initialCount)
    {
        writeln("\n✓✓✓ ALL TESTS PASSED: No process leaks detected ✓✓✓");
    }
    else
    {
        writeln("\n✗✗✗ SOME TESTS FAILED: ", veryFinalCount - initialCount, " processes leaked ✗✗✗");
    }
}

int getRdmdProcessCount()
{
    try
    {
        // Use pgrep to count rdmd processes (excluding this script)
        auto result = execute(["pgrep", "-c", "rdmd"]);
        if (result.status == 0)
        {
            return to!int(strip(result.output));
        }
        else if (result.status == 1)
        {
            // No processes found
            return 0;
        }
        else
        {
            writeln("Warning: pgrep failed: ", result.output);
            return -1;
        }
    }
    catch (Exception e)
    {
        writeln("Warning: Could not count processes: ", e.msg);
        return -1;
    }
}

