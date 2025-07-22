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

# Build the main project using Maven and create JAR
MAVEN_ARGS="-Dmaven.test.skip=true -Djavac.src.version=17 -Djavac.target.version=17"
$MVN clean package $MAVEN_ARGS -Dmaven.repo.local=$OUT/m2

# Debug: Show what was actually created
echo "Contents of target directory:"
ls -la target/

# Copy JAR to output (use known version from pom.xml)
if [ -f "target/fuzzer-test-1.0-SNAPSHOT.jar" ]; then
    cp "target/fuzzer-test-1.0-SNAPSHOT.jar" $OUT/fuzzer-test.jar
else
    echo "Expected JAR not found, copying any JAR files found:"
    find target/ -name "*.jar" -exec cp {} $OUT/fuzzer-test.jar \;
fi

ALL_JARS="fuzzer-test.jar"

# The classpath at build-time includes the project jars in $OUT as well as the Jazzer API
BUILD_CLASSPATH=$(echo $ALL_JARS | xargs printf -- "$OUT/%s:"):$JAZZER_API_PATH

# All .jar and .class files lie in the same directory as the fuzzer at runtime
RUNTIME_CLASSPATH=$(echo $ALL_JARS | xargs printf -- "\$this_dir/%s:"):\$this_dir

# Build the fuzzer class
javac -cp $BUILD_CLASSPATH $SRC/TestFuzzer.java
cp $SRC/TestFuzzer.class $OUT/

# Create an execution wrapper that executes Jazzer with the correct arguments
echo "#!/bin/bash
# LLVMFuzzerTestOneInput for fuzzer detection.
this_dir=\$(dirname \"\$0\")
if [[ \"\$@\" =~ (^| )-runs=[0-9]+($| ) ]]; then
  mem_settings='-Xmx1900m:-Xss900k'
else
  mem_settings='-Xmx2048m:-Xss1024k'
fi
LD_LIBRARY_PATH=\"$JVM_LD_LIBRARY_PATH\":\$this_dir \
\$this_dir/jazzer_driver --agent_path=\$this_dir/jazzer_agent_deploy.jar \
--cp=$RUNTIME_CLASSPATH \
--target_class=TestFuzzer \
--jvm_args=\"\$mem_settings\" \
\$@" > $OUT/TestFuzzer
chmod u+x $OUT/TestFuzzer