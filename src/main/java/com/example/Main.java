package com.example;

/**
 * Main class for demonstrating the branching puzzle
 */
public class Main {
    public static void main(String[] args) {
        BranchingPuzzle puzzle = new BranchingPuzzle();
        
        System.out.println("=== Branching Puzzle Demo ===");
        
        // Test with invalid input
        System.out.println("\n1. Testing with invalid input:");
        String result1 = puzzle.processPuzzleInput("invalid".getBytes());
        System.out.println("Result: " + result1);
        
        // Test with valid input (safe command)
        System.out.println("\n2. Testing with valid input (safe command):");
        byte[] validInput = BranchingPuzzle.createValidInput("ls");
        String result2 = puzzle.processPuzzleInput(validInput);
        System.out.println("Result: " + result2);
        
        // Test with vulnerable input
        System.out.println("\n3. Testing with vulnerable input:");
        byte[] vulnerableInput = BranchingPuzzle.createValidInput("jazzer");
        String result3 = puzzle.processPuzzleInput(vulnerableInput);
        System.out.println("Result: " + result3);
        
        System.out.println("\n=== Demo Complete ===");
    }
}