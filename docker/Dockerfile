ARG PYTHON_VERSION=3.12
FROM ghcr.io/stairwaytowonderland/starter-project:builder-ubuntu-latest AS builder

USER root

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /src

# Install system dependencies for security
RUN apt-get update && \
    apt-get install -y \
		python3 \
        python3-pip \
		tini \
	# Cleanup is redundant since we don't inherit the builder stage, but it's good practice
    && rm -rf /var/lib/apt/lists/* \
	&& apt-get clean

# Copy application code
COPY src/ .

# Install application dependencies
RUN pip3 install --break-system-packages --ignore-installed --no-cache-dir --user -r requirements/requirements-api.txt


FROM ghcr.io/stairwaytowonderland/starter-project:builder-ubuntu-latest AS app
ARG PYTHON_VERSION

ARG USERNAME=appuser
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid "$USER_GID" "$USERNAME" \
  && useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME" -s /bin/bash
#   && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME" \
#   && chmod 0440 "/etc/sudoers.d/$USERNAME"

WORKDIR /app
USER $USERNAME

# Copy installed dependencies from the builder stage
COPY --from=builder /usr/bin/tini /usr/bin/tini
COPY --from=builder /root/.local/lib/python${PYTHON_VERSION}/site-packages /usr/local/lib/python${PYTHON_VERSION}/dist-packages
COPY --from=builder /root/.local/bin/* /usr/local/bin/
COPY --from=builder /src .

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Default to Candidates table if not specified at runtime
ENV TC_DYNAMO_TABLE=Candidates

# Expose the application port
EXPOSE 8000

ENTRYPOINT ["/usr/bin/tini", "--"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
	CMD [ "curl", "-fsSL", "http://0.0.0.0:8000/gtg" ] || exit 1

# Run the application with gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:8000", "api:resume_app"]
