ARG BASE_NAME=ubuntu
ARG VARIANT=${VARIANT:-latest}
ARG PYTHON_VERSION=3.14
ARG PYTHON_INSTALL_PATH=/usr/local/lib/python$PYTHON_VERSION
ARG LOGGER=/usr/local/bin/logger.sh
ARG PIP_INSTALL=/usr/local/bin/pip-install.sh
FROM ghcr.io/stairwaytowonderland/cpython:${PYTHON_VERSION}-${BASE_NAME}-${VARIANT} AS builder

ARG PYTHON_VERSION \
    PYTHON_INSTALL_PATH \
    LOGGER \
    PIP_INSTALL

USER root

WORKDIR /src

# Copy application requirements
COPY src/requirements/ .

# Install application dependencies
RUN $PIP_INSTALL -r requirements-api.txt


FROM ghcr.io/stairwaytowonderland/cpython:${PYTHON_VERSION}-${BASE_NAME}-${VARIANT} AS base

ARG PYTHON_VERSION \
    PYTHON_INSTALL_PATH \
    LOGGER \
    PIP_INSTALL \
    TIMEZONE=UTC \
    USERNAME=appuser \
    USER_UID=1000 \
    USER_GID=1000 \
    DEBUG=false \
    BIND_ADDR=0.0.0.0:8000

ENV TZ=$TIMEZONE \
    DEBIAN_FRONTEND=noninteractive \
    # Prevent Python from writing .pyc files (keeps source code directories free of __pycache__ folders and .pyc files)
    PYTHONDONTWRITEBYTECODE=1 \
    # Ensure Python output is sent straight to the terminal without buffering (important for logging)
    PYTHONUNBUFFERED=1 \
    # Default to Candidates table if not specified at runtime
    TC_DYNAMO_TABLE=Candidates

COPY --from=builder /usr/local/bin /usr/local/bin/
COPY --from=builder $PYTHON_INSTALL_PATH/site-packages/ $PYTHON_INSTALL_PATH/site-packages

USER root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
		tini \
  && if [ "$BASE_NAME" = "ubuntu" ]; then \
    apt-get install -y --no-install-recommends software-properties-common \
      && add-apt-repository -y ppa:libreoffice/ppa && apt-get update \
      && apt-get -y remove software-properties-common; \
  fi \
  && apt-get install -y --no-install-recommends \
    libreoffice-common \
    # ! CVE-2026-3731: libssh-4
    libreoffice-writer \
	# Cleanup
  && rm -rf /tmp/* \
	&& apt-get clean -y \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/*

USER $USERNAME
WORKDIR /home/$USERNAME


FROM base AS devcontainer

ARG USERNAME=vscode

USER root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends sudo \
	&& mkdir -p /opt/venv \
	&& chown $USERNAME:$USERNAME /opt/venv \
	# Cleanup
  && rm -rf /tmp/* \
	&& apt-get clean -y \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/* \
	# Add the user to the sudo group with passwordless sudo permissions
	&& echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME" \
	&& chmod 0440 "/etc/sudoers.d/$USERNAME" \
	# Create a post-create script to set permissions on the /app directory for the non-root user
	&& touch /usr/local/bin/post-start \
	&& chmod +x /usr/local/bin/post-start \
	&& cat >> /usr/local/bin/post-start <<'EOF'
#!/bin/sh
set -e
aws --version
terraform --version
EOF

USER $USERNAME
WORKDIR /home/$USERNAME

COPY --chown=$USERNAME:$USERNAME . .

RUN python3 -m venv /opt/venv \
	&& . /opt/venv/bin/activate \
	&& python3 -m pip install --upgrade --no-cache-dir -r src/requirements/requirements-dev.txt \
	&& echo '. /opt/venv/bin/activate' >> /home/$USERNAME/.bashrc


FROM base AS app

USER $USERNAME
WORKDIR /app

# Copy application code
COPY --chown=$USERNAME:$USERNAME src/ .

# Expose the application port
# dockerfile-utils: ignore
EXPOSE "${BIND_ADDR##*:}"

# dockerfile-utils: ignore
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
	CMD curl -f http://localhost/"${BIND_ADDR##*:}"/gtg || exit 1

ENTRYPOINT ["/usr/bin/tini", "--"]

# Run the application with gunicorn
CMD ["gunicorn", "-c", "gunicorn.py", "api:resume_app"]
