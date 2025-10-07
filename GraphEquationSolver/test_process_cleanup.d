/**
 * Test program to verify process cleanup in ScriptFunction
 *
 * This test suite validates that ScriptFunction properly manages
 * and terminates its spawned evaluation processes. The test is particularly
 * important because:
 *
 * 1. ScriptFunction spawns rdmd --eval processes to evaluate mathematical expressions
 * 2. These processes must be properly terminated when the ScriptFunction object is destroyed
 * 3. In D, object destruction timing is non-deterministic due to garbage collection
 * 4. We must explicitly trigger cleanup and verify process termination
 *
 * The test covers three scenarios:
 * - Basic creation/destruction cycle
 * - Multiple creation/destruction cycles
 * - Formula changes (which should cleanup old processes)
 */
module testprocesscleanup;

import std.stdio;
import std.process;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import core.thread;
import core.time;
import core.memory;
import eqsolver.ScriptFunction;

/**
 * Helper function to create, test, and return a ScriptFunction with the given formula.
 * This function handles the common pattern of creating a function, evaluating it,
 * and verifying it works correctly.
 *
 * Params:
 *   formula = The mathematical formula to evaluate (e.g., "x * 2")
 *   testValue = The value to test the function with
 *   expectedResult = The expected result of the evaluation
 *
 * Returns: The created ScriptFunction object, or null if creation/evaluation failed
 */
ScriptFunction createAndTestFunction(string formula, double testValue, double expectedResult)
{
    writeln("  Creating ScriptFunction with formula: ", formula);

    try
    {
        ScriptFunction sf = new ScriptFunction(formula);

        writeln("  Formula compiled successfully");

        // Test the function with the provided value
        double result = sf.eval(testValue);
        writeln("  Evaluation result: f(", testValue, ") = ", result);

        if (result != expectedResult)
        {
            writeln("  ✗ ERROR: Expected ", expectedResult, " but got ", result);
            destroy(sf);
            return null;
        }

        writeln("  ✓ Function evaluation successful");
        return sf;
    }
    catch (Exception e)
    {
        writeln("  ✗ ERROR: Failed to create/test function: ", e.msg);
        return null;
    }
}

/**
 * Helper function to explicitly cleanup a ScriptFunction object.
 * This ensures deterministic cleanup in a garbage-collected environment.
 *
 * Params:
 *   sf = The ScriptFunction to cleanup (can be null)
 *   description = Description of what is being cleaned up (for logging)
 */
void explicitCleanup(ScriptFunction sf, string description = "ScriptFunction")
{
    if (sf !is null)
    {
        writeln("  Explicitly destroying ", description, "...");
        destroy(sf);

        // Force garbage collection to ensure destructor runs immediately
        writeln("  Forcing garbage collection...");
        GC.collect();
        GC.minimize();

        // Brief pause to allow cleanup to complete
        Thread.sleep(50.msecs);
        writeln("  Cleanup completed");
    }
}

/**
 * Helper function to check for process leaks by comparing process counts.
 * This validates that ScriptFunction properly terminated its spawned processes.
 *
 * Params:
 *   beforeCount = Process count before the operation
 *   afterCount = Process count after the operation
 *   expectedChange = Expected change in process count (0 for cleanup, >0 for creation)
 *   testName = Name of the test for error reporting
 *
 * Returns: true if the process count change matches expectations
 */
bool checkProcessCleanup(int beforeCount, int afterCount, int expectedChange, string testName)
{
    int actualChange = afterCount - beforeCount;
    writeln("  Process count: ", beforeCount, " → ", afterCount, " (Δ", actualChange, ")");

    if (actualChange == expectedChange)
    {
        writeln("  ✓ ", testName, " PASSED: Process count changed as expected");
        return true;
    }
    else
    {
        writeln("  ✗ ", testName, " FAILED: Expected Δ", expectedChange,
                " but got Δ", actualChange, " (", afterCount - beforeCount, " extra processes)");
        return false;
    }
}

void main()
{
    writeln("=== ScriptFunction Process Cleanup Test ===\n");

    // Get initial eval process count (processes created by ScriptFunction)
    int initialCount = subprocessProcessCount();
    writeln("Initial eval process count: ", initialCount);

    // ============================================================================
    // ============================================================================
    // Test 1: Basic Creation and Destruction Cycle
    // ============================================================================
    // This test verifies the fundamental cleanup mechanism: when a ScriptFunction
    // object is destroyed, its associated evaluation process should also terminate.
    writeln("\n" ~ replicate("=", 70));
    writeln("TEST 1: Basic Creation and Destruction Cycle");
    writeln(replicate("=", 70));
    writeln("Purpose: Verify that a single ScriptFunction properly cleans up its process");
    writeln("Expected behavior: Process count should return to initial level after cleanup");

    // Create and test a simple function
    ScriptFunction sf = createAndTestFunction("x * 2", 5.0, 10.0);

    if (sf is null)
    {
        writeln("✗ Test 1 FAILED: Could not create function");
    }
    else
    {
        // Verify process was created during execution
        int duringCount = subprocessProcessCount();
        if (!checkProcessCleanup(initialCount, duringCount, 1, "Process Creation Check"))
        {
            writeln("✗ Test 1 FAILED: Process was not created during execution");
            explicitCleanup(sf, "failed function");
        }
        else
        {
            // Perform explicit cleanup and verify process termination
            explicitCleanup(sf, "test function");

            int afterCount = subprocessProcessCount();
            if (!checkProcessCleanup(duringCount, afterCount, -1, "Process Cleanup Check"))
            {
                writeln("✗ Test 1 FAILED: Process was not properly cleaned up");
            }
            else
            {
                writeln("✓ Test 1 PASSED: Complete cycle successful");
            }
        }
    }

    // ============================================================================
    // Test 2: Multiple Creation/Destruction Cycles
    // ============================================================================
    // This test validates that repeated creation and destruction of ScriptFunction
    // objects doesn't result in process leaks over time. Each cycle should:
    // 1. Create a new process for the new function
    // 2. Properly cleanup the old process when the function is destroyed
    // 3. Leave no lingering processes
    writeln("\n" ~ replicate("=", 70));
    writeln("TEST 2: Multiple Creation/Destruction Cycles");
    writeln(replicate("=", 70));
    writeln("Purpose: Verify that repeated create/destroy cycles don't accumulate processes");
    writeln("Expected behavior: Process count should remain stable across multiple cycles");

    bool test2Passed = true;
    int previousCount = initialCount;

    foreach (i; 0 .. 3)
    {
        writeln("\n--- Cycle ", i + 1, " of 3 ---");

        // Create function with formula that varies by cycle
        auto formula = format("x + %d", i);
        auto expectedResult = 1.0 + i;  // f(1) should equal 1 + i

        ScriptFunction sf_cycle = createAndTestFunction(formula, 1.0, expectedResult);

        if (sf_cycle is null)
        {
            writeln("✗ Cycle ", i, " FAILED: Could not create function");
            test2Passed = false;
            continue;
        }

        // Verify process was created
        int duringCount = subprocessProcessCount();
        if (!checkProcessCleanup(previousCount, duringCount, 1, format("Cycle %d Process Creation", i)))
        {
            test2Passed = false;
        }

        // Cleanup and verify process termination
        explicitCleanup(sf_cycle, format("cycle %d function", i));

        int afterCount = subprocessProcessCount();
        if (!checkProcessCleanup(duringCount, afterCount, -1, format("Cycle %d Process Cleanup", i)))
        {
            test2Passed = false;
        }

        previousCount = afterCount;
        Thread.sleep(100.msecs);
    }

    // Final verification - should be back to initial count
    writeln("\n--- Final Verification ---");
    int finalCount = subprocessProcessCount();
    if (!checkProcessCleanup(previousCount, finalCount, 0, "Final Process Count Check"))
    {
        test2Passed = false;
    }

    if (test2Passed)
    {
        writeln("✓ Test 2 PASSED: All cycles completed without process leaks");
    }
    else
    {
        writeln("✗ Test 2 FAILED: Process leaks detected during cycles");
    }

    // ============================================================================
    // Test 3: Formula Change and Process Replacement
    // ============================================================================
    // This test validates that when a ScriptFunction's formula is changed,
    // the old evaluation process is properly terminated and replaced with a new one.
    // This is a critical test because setFormula() must cleanup the existing process
    // before creating a new one.
    writeln("\n" ~ replicate("=", 70));
    writeln("TEST 3: Formula Change and Process Replacement");
    writeln(replicate("=", 70));
    writeln("Purpose: Verify that changing a formula properly cleans up the old process");
    writeln("Expected behavior: Process count should remain stable during formula change");

    writeln("\n--- Creating Initial Function ---");
    ScriptFunction sf_local = createAndTestFunction("x * 2", 3.0, 6.0);

    if (sf_local is null)
    {
        writeln("✗ Test 3 FAILED: Could not create initial function");
    }
    else
    {
        int beforeChange = subprocessProcessCount();
        writeln("\n--- Changing Formula ---");
        writeln("This should terminate the old process and create a new one");

        try
        {
            // Change formula - this should cleanup old process internally
            sf_local.setFormula("x * 3");
            writeln("✓ Formula changed successfully");

            // Brief pause to allow process replacement to complete
            Thread.sleep(100.msecs);

            int afterChange = subprocessProcessCount();

            // Process count should remain the same (old process cleaned up, new process created)
            if (checkProcessCleanup(beforeChange, afterChange, 0, "Formula Change Process Check"))
            {
                writeln("✓ Test 3 PASSED: Formula change properly managed processes");
            }
            else
            {
                writeln("✗ Test 3 FAILED: Process count changed unexpectedly during formula change");
            }
        }
        catch (Exception e)
        {
            writeln("✗ Test 3 FAILED: Error during formula change: ", e.msg);
        }

        // Cleanup the function object
        explicitCleanup(sf_local, "formula change test function");
    }

    // ============================================================================
    // Final Cleanup Verification
    // ============================================================================
    // Final comprehensive check to ensure all processes have been properly cleaned up.
    // This is critical because any lingering processes indicate a fundamental flaw
    // in the ScriptFunction destructor or process management.
    writeln("\n" ~ replicate("=", 70));
    writeln("FINAL CLEANUP VERIFICATION");
    writeln(replicate("=", 70));
    writeln("Performing final garbage collection and process count verification...");
    writeln("This ensures no processes were leaked during the entire test suite.");

    // Force final garbage collection to ensure any remaining objects are cleaned up
    writeln("\n--- Forcing Final Garbage Collection ---");
    GC.collect();
    GC.minimize();
    Thread.sleep(200.msecs);

    writeln("\n--- Final Process Count Check ---");
    int veryFinalCount = subprocessProcessCount();
    writeln("Final eval process count: ", veryFinalCount);

    writeln("\n--- Test Suite Results ---");
    if (veryFinalCount == initialCount)
    {
        writeln("✓✓✓ ALL TESTS PASSED: No process leaks detected ✓✓✓");
        writeln("The ScriptFunction class properly manages process lifecycle.");
    }
    else
    {
        writeln("✗✗✗ SOME TESTS FAILED: ", veryFinalCount - initialCount, " processes leaked ✗✗✗");
        writeln("This indicates a serious issue with process cleanup in ScriptFunction.");
    }
}

/**
 * Count the number of evaluation processes currently running.
 *
 * ScriptFunction creates evaluation processes using 'rdmd --eval' with unique
 * identifiers. These processes have names starting with "eval." followed by
 * a unique identifier. This function counts how many such processes are
 * currently active.
 *
 * Returns:
 *   - The number of eval processes if successful
 *   - 0 if no processes are found (pgrep returns status 1)
 *   - -1 if there's an error (pgrep fails or exception occurs)
 */
int subprocessProcessCount()
{
    try
    {
        // Use pgrep to count processes whose names start with "eval."
        // These are the evaluation processes created by ScriptFunction using rdmd --eval
        writeln("  Counting eval processes...");
        auto result = execute(["pgrep", "-c", "eval."]);

        if (result.status == 0)
        {
            // Successfully found and counted processes
            int count = to!int(strip(result.output));
            writeln("  Found ", count, " eval process(es)");
            return count;
        }
        else if (result.status == 1)
        {
            // pgrep returns status 1 when no processes match the pattern
            writeln("  No eval processes found");
            return 0;
        }
        else
        {
            // pgrep failed for some other reason
            writeln("  Warning: pgrep failed with status ", result.status, ": ", result.output);
            return -1;
        }
    }
    catch (Exception e)
    {
        writeln("  Warning: Could not count processes: ", e.msg);
        return -1;
    }
}
