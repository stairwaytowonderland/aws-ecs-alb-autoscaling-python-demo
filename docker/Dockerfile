ARG PARENT_IMAGE=ubuntu
ARG PYTHON_VERSION=latest
ARG INSTALL_TOOLS=false
ARG PYTHON_INSTALL_PATH=/usr/local/python
ARG LOGGER=/usr/local/bin/logger.sh
ARG PIP_INSTALL=/usr/local/bin/pip-install.sh
ARG INSTALL_HELPER=/usr/local/bin/install-helper.sh
FROM $PARENT_IMAGE AS pybuilder

ARG PARENT_IMAGE
ARG PYTHON_VERSION
ARG INSTALL_TOOLS
ARG PYTHON_INSTALL_PATH
ARG LOGGER
ARG PIP_INSTALL
ARG INSTALL_HELPER

ARG PACKAGE_CLEANUP=true
ARG REMOVE_ONLY=true
ARG PIP_INSTALL_FLAGS="--no-cache-dir --disable-pip-version-check --ignore-installed --break-system-packages --root-user-action=ignore"

ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALL_PATH=$PYTHON_INSTALL_PATH/$PYTHON_VERSION
ENV PATH=$INSTALL_PATH/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Prevent Python from writing .pyc files (keeps source code directories free of __pycache__ folders and .pyc files)
ENV PYTHONDONTWRITEBYTECODE=1
# Ensure Python output is sent straight to the terminal without buffering (important for logging)
ENV PYTHONUNBUFFERED=1

# Copy library scripts, utilities, and helpers for installing Python and dependencies.
# These will be used in this builder stage to install Python, and then copied to subsequent stages as needed.
COPY --chmod=755 docker/lib-scripts/python-install.sh /tmp/lib-scripts/
COPY --chmod=755 docker/utils/logger.sh $LOGGER
COPY docker/helpers/install-helper.sh $INSTALL_HELPER

USER root

RUN /tmp/lib-scripts/python-install.sh \
  # Cleanup build dependencies but keep the Python installation
  && rm -rf $INSTALL_PATH/include/* \
  && apt-get clean -y \
  && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/*

RUN touch $PIP_INSTALL \
    && chmod +x $PIP_INSTALL \
    && cat > $PIP_INSTALL <<EOF
#!/bin/sh
set -e
VERSION="\$(cat "${INSTALL_PATH}/.manifest" | jq -r '.version')"
pip_install() {
  "$INSTALL_PATH/bin/python\${VERSION%.*}" -m pip install $PIP_INSTALL_FLAGS "\$@"
}
pip_install "\$@"
EOF


FROM ubuntu AS pybase

ARG PYTHON_VERSION \
    INSTALL_TOOLS \
    PYTHON_INSTALL_PATH \
    LOGGER \
    PIP_INSTALL \
    INSTALL_HELPER

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=$PYTHON_INSTALL_PATH/$PYTHON_VERSION/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    # Prevent Python from writing .pyc files (keeps source code directories free of __pycache__ folders and .pyc files)
    PYTHONDONTWRITEBYTECODE=1 \
    # Ensure Python output is sent straight to the terminal without buffering (important for logging)
    PYTHONUNBUFFERED=1

COPY --chmod=755 docker/lib-scripts/python-configure.sh /tmp/lib-scripts/
COPY --from=pybuilder $LOGGER $PIP_INSTALL $INSTALL_HELPER /usr/local/bin/
COPY --from=pybuilder $PYTHON_INSTALL_PATH/$PYTHON_VERSION $PYTHON_INSTALL_PATH/$PYTHON_VERSION

USER root

# Configure Python and install tools in the base image so they're available for all subsequent stages
RUN apt-get update \
  && apt-get install -y --no-install-recommends jq \
  && apt-get -s dist-upgrade | grep "^Inst" | grep -i securi | cut -d " " -f 2 | xargs apt-get install -y --no-install-recommends \
  && INSTALL_PATH=$PYTHON_INSTALL_PATH/$PYTHON_VERSION /tmp/lib-scripts/python-configure.sh \
  && apt-get clean -y \
  && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/*


FROM pybase AS builder

USER root

WORKDIR /src

# Copy application requirements
COPY src/requirements/ .

# Install application dependencies
RUN $PIP_INSTALL -r requirements-api.txt


FROM $PARENT_IMAGE AS base

ARG PARENT_IMAGE \
    PYTHON_VERSION \
    INSTALL_TOOLS \
    PYTHON_INSTALL_PATH \
    LOGGER \
    PIP_INSTALL \
    INSTALL_HELPER \
    TIMEZONE=UTC \
    USERNAME=appuser \
    USER_UID=1000 \
    USER_GID=1000 \
    DEBUG=false \
    BIND_ADDR=0.0.0.0:8000

ENV PYTHON_VERSION=${PYTHON_VERSION} \
    TZ=$TIMEZONE \
    DEBIAN_FRONTEND=noninteractive \
    PATH=$PYTHON_INSTALL_PATH/$PYTHON_VERSION/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    # Prevent Python from writing .pyc files (keeps source code directories free of __pycache__ folders and .pyc files)
    PYTHONDONTWRITEBYTECODE=1 \
    # Ensure Python output is sent straight to the terminal without buffering (important for logging)
    PYTHONUNBUFFERED=1 \
    # Default to Candidates table if not specified at runtime
    TC_DYNAMO_TABLE=Candidates

COPY --chmod=755 docker/lib-scripts/python-configure.sh docker/lib-scripts/libssh-install.sh /tmp/lib-scripts/
COPY --from=pybuilder $LOGGER $PIP_INSTALL $INSTALL_HELPER /usr/local/bin/
COPY --from=builder $PYTHON_INSTALL_PATH/$PYTHON_VERSION $PYTHON_INSTALL_PATH/$PYTHON_VERSION

USER root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    jq \
		tini \
  && if [ "$PARENT_IMAGE" = "ubuntu" ]; then \
    apt-get install -y --no-install-recommends software-properties-common \
      && add-apt-repository -y ppa:libreoffice/ppa && apt-get update \
      && apt-get -y remove software-properties-common; \
  fi \
  && apt-get install -y --no-install-recommends \
    libreoffice-common \
    # ! CVE-2026-3731: libssh-4
    libreoffice-writer \
  && apt-get update \
  && INSTALL_PATH=$PYTHON_INSTALL_PATH/$PYTHON_VERSION /tmp/lib-scripts/python-configure.sh \
	# Cleanup
  && rm -rf /tmp/* \
	&& apt-get clean -y \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/* \
  # As of Ubuntu 24 (Noble Numbat), the Ubuntu base image comes with a non-root user ubuntu with UID 1000.
  # Delete this user to avoid conflicts when creating our own non-root user.
  # Use 'userdel' to perform a shallow delete, and preserve htpasswd/group integrity for UID and GID.
  && if [ "$PARENT_IMAGE" = "ubuntu" ] && id "ubuntu" >/dev/null 2>&1; then \
    $LOGGER "Deleting user 'ubuntu' for $PARENT_IMAGE" \
      && userdel -r -f ubuntu > /dev/null 2>&1 \
      || LEVEL=error $LOGGER "Failed to delete ubuntu user for $PARENT_IMAGE"; \
  else \
    $LOGGER "User 'ubuntu' does not exist for $PARENT_IMAGE"; \
  fi \
	# Create a non-root user to run the application, if it doesn't already exist
	&& id "$USERNAME" >/dev/null 2>&1 || { \
		groupadd --gid "$USER_GID" "$USERNAME" \
		&& useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME" -s /bin/bash; \
	} || true


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
