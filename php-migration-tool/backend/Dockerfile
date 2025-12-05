# Backend Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies including git
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set git environment variable for GitPython
ENV GIT_PYTHON_REFRESH=quiet
ENV GIT_PYTHON_GIT_EXECUTABLE=/usr/bin/git

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directories for uploads and outputs
RUN mkdir -p uploads outputs

# Verify git is accessible
RUN git --version

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
