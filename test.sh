#!/bin/bash
set -e

# OSS-Fuzz project directory
OSS_FUZZ_PROJECT_DIR="/Users/julian.hans/repos/oss-fuzz/projects/test-cp"
LOCAL_OSS_FUZZ_DIR="oss-fuzz"
OSS_FUZZ_MAIN_SCRIPT="/Users/julian.hans/repos/oss-fuzz/scripts/main.sh"

echo "=== OSS-Fuzz Test Script ==="

# Check if OSS-Fuzz directory exists
if [ ! -d "/Users/julian.hans/repos/oss-fuzz" ]; then
    echo "ERROR: OSS-Fuzz directory not found at /Users/julian.hans/repos/oss-fuzz"
    echo "Please clone OSS-Fuzz repository first:"
    echo "  git clone https://github.com/google/oss-fuzz.git /Users/julian.hans/repos/oss-fuzz"
    exit 1
fi

# Check if local oss-fuzz directory exists
if [ ! -d "$LOCAL_OSS_FUZZ_DIR" ]; then
    echo "ERROR: Local oss-fuzz directory not found"
    echo "Make sure you're running this from the project root directory"
    exit 1
fi

echo "1. Removing existing content from $OSS_FUZZ_PROJECT_DIR"
if [ -d "$OSS_FUZZ_PROJECT_DIR" ]; then
    rm -rf "$OSS_FUZZ_PROJECT_DIR"
fi

echo "2. Creating OSS-Fuzz project directory"
mkdir -p "$OSS_FUZZ_PROJECT_DIR"

echo "3. Copying oss-fuzz content to OSS-Fuzz projects directory"
cp -r "$LOCAL_OSS_FUZZ_DIR"/* "$OSS_FUZZ_PROJECT_DIR/"

echo "4. Listing copied files:"
ls -la "$OSS_FUZZ_PROJECT_DIR"

echo "5. Running OSS-Fuzz main script"
cd /Users/julian.hans/repos/oss-fuzz
bash scripts/main.sh

echo "=== OSS-Fuzz Test Complete ==="