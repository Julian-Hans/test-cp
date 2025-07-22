#!/bin/bash -eu
# Copyright 2025 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# Change to cloned repository directory
cd $SRC/test-cp

# Build the main project using Maven
$MVN clean compile -Dmaven.repo.local=$OUT/m2

# Create test-classes directory
mkdir -p target/test-classes

# Build the fuzzer classes (TestFuzzer.java is in the OSS-Fuzz directory)
javac -cp "$JAZZER_API_PATH:target/classes" \
  -d target/test-classes/ \
  $SRC/TestFuzzer.java

# Create classpath with all dependencies
CLASSPATH="target/classes:target/test-classes"

# Build the fuzzer using the standard OSS-Fuzz approach
# Create the fuzzer executable script
echo "#!/bin/bash
this_dir=\$(dirname \"\$0\")
LD_LIBRARY_PATH=\"\$JVM_LD_LIBRARY_PATH\":\$this_dir \
\$this_dir/jazzer_driver --agent_path=\$this_dir/jazzer_agent_deploy.jar \
--cp=target/classes:target/test-classes \
--target_class=TestFuzzer \
--jvm_args=\"-Xmx2048m\" \
\$@" > $OUT/TestFuzzer
chmod +x $OUT/TestFuzzer

# Copy compiled classes to output directory
cp -r target/classes/* $OUT/ 2>/dev/null || true
cp -r target/test-classes/* $OUT/ 2>/dev/null || true