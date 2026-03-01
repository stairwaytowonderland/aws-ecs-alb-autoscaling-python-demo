FROM python:3.11-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /src

# Install system dependencies for security
RUN apt-get update && \
    apt-get install -y \
        gcc \
	# Cleanup is redundant since we don't inherit the builder stage, but it's good practice
    && rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

# Install dependencies
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ .

FROM python:3.11-slim AS app

WORKDIR /app

# Copy installed dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /src .

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Default to Candidates table if not specified at runtime
ENV TC_DYNAMO_TABLE=Candidates

# Expose the application port
EXPOSE 8000

# Run the application with gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:candidates_app"]
