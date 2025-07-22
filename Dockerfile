FROM openjdk:11-jdk-slim

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy project files
COPY pom.xml .
COPY src ./src

# Build the project
RUN mvn clean compile

# Create a script to run the demo
RUN echo '#!/bin/bash\n\
echo "Running demo application..."\n\
java -cp /app/target/classes com.example.Main' > /app/run-demo.sh && \
    chmod +x /app/run-demo.sh

# Default command
CMD ["./run-demo.sh"]