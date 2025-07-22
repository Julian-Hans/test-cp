import com.code_intelligence.jazzer.api.FuzzedDataProvider;
import com.example.BranchingPuzzle;

/**
 * Fuzzer harness for OSS-Fuzz to test the BranchingPuzzle vulnerability.
 * This class provides the entry point for Jazzer to fuzz the branching puzzle.
 */
public class TestFuzzer {
    
    private static final BranchingPuzzle puzzle = new BranchingPuzzle();
    
    /**
     * Main fuzzer entry point for OSS-Fuzz.
     * This method will be called by Jazzer with fuzzed input data.
     * 
     * @param data Fuzzed input data provided by Jazzer
     */
    public static void fuzzerTestOneInput(FuzzedDataProvider data) {
        // Get the raw bytes from the fuzzer
        byte[] input = data.consumeRemainingAsBytes();
        
        try {
            // Feed the fuzzed input to our vulnerable puzzle
            String result = puzzle.processPuzzleInput(input);
            
            // The fuzzer should eventually discover an input sequence that:
            // 1. Has magic bytes "FUZZ" at the start
            // 2. Has correct XOR checksum
            // 3. Has valid length and command extraction
            // 4. Contains "jazzer" as the command
            // 
            // When this happens, the puzzle will attempt to execute "jazzer"
            // as an OS command, triggering Jazzer's sanitizer detection
            
        } catch (Exception e) {
            // Let security-related exceptions propagate to trigger detection
            // but catch other exceptions to keep fuzzing stable
            if (e.getMessage() != null && 
                (e.getMessage().contains("jazzer") || 
                 e.getMessage().contains("Runtime.exec") ||
                 e.getMessage().contains("ProcessBuilder"))) {
                // This indicates we've hit the vulnerability
                throw new RuntimeException("OS Command Injection detected: " + e.getMessage(), e);
            }
            // Ignore other exceptions to continue fuzzing
        }
    }
    
    /**
     * Alternative entry point using raw byte array (for compatibility)
     */
    public static void fuzzerTestOneInput(byte[] input) {
        try {
            String result = puzzle.processPuzzleInput(input);
        } catch (Exception e) {
            // Same exception handling as above
            if (e.getMessage() != null && 
                (e.getMessage().contains("jazzer") || 
                 e.getMessage().contains("Runtime.exec") ||
                 e.getMessage().contains("ProcessBuilder"))) {
                throw new RuntimeException("OS Command Injection detected: " + e.getMessage(), e);
            }
        }
    }
}