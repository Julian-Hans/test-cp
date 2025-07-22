# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Java Maven project designed as a vulnerable test case for fuzzing. It contains a branching puzzle that leads to an OS command injection vulnerability when the correct input sequence is provided.

## Build Commands

```bash
# Compile the project
mvn compile

# Clean build artifacts
mvn clean

# Build JAR
mvn package
```

## Running the Demo

```bash
# Run locally
java -cp target/classes com.example.Main

# Run with Docker
docker build -t fuzzer-test .
docker run fuzzer-test

# Run with Docker Compose
docker-compose up
```

## Project Architecture

- **BranchingPuzzle**: Main vulnerability class with 4-layer validation:
  1. Magic bytes validation ("FUZZ")
  2. XOR checksum validation
  3. Command extraction from binary format
  4. OS command execution (vulnerability point)

- **Main**: Demo application showing different input scenarios

## Vulnerability Details

The puzzle requires input with:
- Magic bytes "FUZZ" at start (bytes 0-3)
- XOR checksum matching 0x37 (bytes 4-7)
- Length field (bytes 8-9, little endian)
- Command string (bytes 10+)

When command "jazzer" is provided, it triggers Runtime.exec() which creates the OS command injection vulnerability.

## OSS-Fuzz Integration

The `oss-fuzz/` directory contains the complete OSS-Fuzz integration:

- **project.yaml**: OSS-Fuzz configuration
- **Dockerfile**: Build environment setup  
- **build.sh**: Build script for fuzzer compilation
- **TestFuzzer.java**: Fuzzer harness in `oss-fuzz/`

The fuzzer harness feeds random data to `BranchingPuzzle.processPuzzleInput()` and will detect the OS command injection vulnerability when the correct input sequence is discovered.

## Testing OSS-Fuzz Integration

```bash
# Copy oss-fuzz directory to OSS-Fuzz projects
cp -r oss-fuzz /path/to/oss-fuzz/projects/fuzzer-test/

# Build and test (from OSS-Fuzz root)
python infra/helper.py build_image fuzzer-test
python infra/helper.py build_fuzzers fuzzer-test  
python infra/helper.py run_fuzzer fuzzer-test TestFuzzer
```