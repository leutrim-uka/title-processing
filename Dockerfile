# Use a base image with jq and xz installed
FROM ubuntu:latest

# Install jq and xz
RUN apt-get update && apt-get install -y jq xz-utils parallel && rm -rf /var/lib/apt/lists/*

# Create a working directory
WORKDIR /app

# Copy the processing script into the container
COPY process_file.sh /app/

# Make the script executable
RUN chmod +x /app/process_file.sh

# Set the entrypoint to the script
ENTRYPOINT ["/app/process_file.sh"]
