# Use official Ruby image as base
FROM ruby:3.4.2-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy Gemfile and Gemfile.lock (if it exists)
COPY Gemfile Gemfile.lock* ./

# Copy the rest of the application code
COPY . .

# Install Ruby dependencies and build the application
RUN chmod +x ./build.sh
RUN chmod +x ./run.sh
RUN ./build.sh

# Create a non-root user
RUN useradd -m -u 1000 app && chown -R app:app /app
USER app

# Expose port for Sinatra app served by Puma (default is 3000)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/healthcheck || exit 1

# Run the Sinatra app
CMD ["./run.sh"]
