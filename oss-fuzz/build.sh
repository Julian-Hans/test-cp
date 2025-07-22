#!/bin/bash -eu

# Change to project root directory 
cd $SRC

# Build the main project
mvn clean compile -Dmaven.repo.local=$OUT/m2

# Create test-classes directory
mkdir -p target/test-classes

# Build the fuzzer classes (TestFuzzer.java is in the same directory as this script)
javac -cp "$JAZZER_API_PATH/jazzer-api-$JAZZER_API_VERSION.jar:target/classes" \
  -d target/test-classes/ \
  $SRC/oss-fuzz/TestFuzzer.java

# Create classpath with all dependencies
CLASSPATH="target/classes:target/test-classes"

# Build the fuzzer
$JAZZER_API_PATH/jazzer_driver \
  --cp=$CLASSPATH \
  --target_class=TestFuzzer \
  --jvm_args=-Djava.awt.headless=true \
  --output=$OUT/TestFuzzer

# Also create a standalone JAR version
mkdir -p $OUT/TestFuzzer_deploy
cp -r target/classes/* $OUT/TestFuzzer_deploy/ 2>/dev/null || true
cp -r target/test-classes/* $OUT/TestFuzzer_deploy/ 2>/dev/null || true