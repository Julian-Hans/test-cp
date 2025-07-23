import com.example.BranchingPuzzle;
import java.nio.file.Files;
import java.nio.file.Paths;

public class VulnTest {
    public static void main(String[] args) throws Exception {
        BranchingPuzzle puzzle = new BranchingPuzzle();
        byte[] vulnBytes = Files.readAllBytes(Paths.get("vulnerable_bytes.txt"));
        
        System.out.println("Testing vulnerable input:");
        System.out.println("Input length: " + vulnBytes.length + " bytes");
        String result = puzzle.processPuzzleInput(vulnBytes);
        System.out.println("Result: " + result);
    }
}