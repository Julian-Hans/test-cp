package com.example;

import java.io.IOException;
import java.util.Arrays;

/**
 * A branching puzzle that requires specific input patterns to trigger OS command injection.
 * The puzzle uses multiple validation layers to make fuzzing more challenging.
 */
public class BranchingPuzzle {
    
    private static final String SECRET_PREFIX = "FUZZ";
    private static final int MAGIC_NUMBER = 0x1337;
    private static final String[] VALID_COMMANDS = {"ls", "pwd", "whoami", "jazzer"};
    
    /**
     * Main puzzle entry point - requires complex input structure to reach vulnerability
     */
    public String processPuzzleInput(byte[] input) {
        if (input == null || input.length < 20) {
            return "Input too short";
        }
        
        // First branch: Check magic bytes at start
        if (!validateMagicBytes(input)) {
            return "Invalid magic bytes";
        }
        
        // Second branch: Validate checksum
        if (!validateChecksum(input)) {
            return "Invalid checksum";
        }
        
        // Third branch: Extract and validate command section
        String command = extractCommand(input);
        if (command == null) {
            return "Could not extract command";
        }
        
        // Fourth branch: Command validation with vulnerability
        return executeCommand(command);
    }
    
    /**
     * First validation layer - checks for magic bytes "FUZZ" at start
     */
    private boolean validateMagicBytes(byte[] input) {
        if (input.length < 4) return false;
        
        String prefix = new String(input, 0, 4);
        return SECRET_PREFIX.equals(prefix);
    }
    
    /**
     * Second validation layer - simple XOR checksum
     */
    private boolean validateChecksum(byte[] input) {
        if (input.length < 8) return false;
        
        // Calculate XOR checksum of bytes 4-7
        int checksum = 0;
        for (int i = 4; i < 8; i++) {
            checksum ^= input[i] & 0xFF;
        }
        
        // Must equal magic number
        return checksum == (MAGIC_NUMBER & 0xFF);
    }
    
    /**
     * Third validation layer - extracts command from specific byte positions
     */
    private String extractCommand(byte[] input) {
        if (input.length < 16) return null;
        
        // Extract length from bytes 8-9 (little endian)
        int length = (input[8] & 0xFF) | ((input[9] & 0xFF) << 8);
        
        if (length < 1 || length > 20 || input.length < 10 + length) {
            return null;
        }
        
        // Extract command string from bytes 10 onwards
        String command = new String(input, 10, length).trim();
        
        // Additional validation - must contain specific patterns
        if (command.length() < 3 || !command.matches("[a-zA-Z]+")) {
            return null;
        }
        
        return command;
    }
    
    /**
     * Fourth validation layer with OS command injection vulnerability
     * This is where the Jazzer sanitizer should trigger
     */
    private String executeCommand(String command) {
        // Validate against allowed commands list
        boolean isValidCommand = Arrays.stream(VALID_COMMANDS)
                .anyMatch(cmd -> cmd.equals(command));
        
        if (!isValidCommand) {
            return "Command not in whitelist: " + command;
        }
        
        try {
            // VULNERABILITY: Direct command execution without proper sanitization
            // Jazzer should detect this when command starts with "jazzer"
            Process process = Runtime.getRuntime().exec(command);
            return "Command executed: " + command;
        } catch (IOException e) {
            return "Execution failed: " + e.getMessage();
        }
    }
    
    /**
     * Helper method to create a valid input that reaches the vulnerability
     */
    public static byte[] createValidInput(String command) {
        // Ensure minimum 20 bytes as required by processPuzzleInput
        int minSize = Math.max(20, 10 + command.length());
        byte[] result = new byte[minSize];
        
        // Magic bytes "FUZZ"
        System.arraycopy("FUZZ".getBytes(), 0, result, 0, 4);
        
        // Calculate checksum bytes to match MAGIC_NUMBER
        int targetChecksum = MAGIC_NUMBER & 0xFF;
        result[4] = (byte) targetChecksum;
        result[5] = 0;
        result[6] = 0;
        result[7] = 0;
        
        // Length (little endian)
        int length = command.length();
        result[8] = (byte) (length & 0xFF);
        result[9] = (byte) ((length >> 8) & 0xFF);
        
        // Command string
        System.arraycopy(command.getBytes(), 0, result, 10, length);
        
        return result;
    }
}