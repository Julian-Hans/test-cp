FROM gcr.io/oss-fuzz-base/base-builder-jvm

# Install Maven
RUN apt-get update && apt-get install -y maven

# Copy the project source
COPY . $SRC/
WORKDIR $SRC/

COPY build.sh $SRC/