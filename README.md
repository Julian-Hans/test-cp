# Fuzzer Test Project

A Java Maven project designed for testing LLM-based fuzzing with OSS-Fuzz. Contains a deliberately vulnerable branching puzzle for security research purposes.

## Quick Start

### Build and Run Demo
```bash
mvn compile
java -cp target/classes com.example.Main
```

### Run with Docker
```bash
docker build -t fuzzer-test .
docker run fuzzer-test
```

## Project Structure
```
├── src/main/java/com/example/
│   ├── BranchingPuzzle.java    # Main puzzle with vulnerability
│   └── Main.java               # Demo application
├── Dockerfile                  # Container configuration
├── docker-compose.yml         # Container setup
└── pom.xml                     # Maven configuration
```

## Security Note

⚠️ This project contains intentional security vulnerabilities for research and testing purposes. Do not use in production environments.