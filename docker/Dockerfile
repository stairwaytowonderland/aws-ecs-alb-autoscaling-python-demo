ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim AS builder

ARG PYTHON_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
	PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
	# If pip install was using the --user option, we'd want to update the PATH
	PATH=/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

USER root

WORKDIR /src

# Update distro; Install Python and pip
RUN apt-get update \
	&& apt-get install -y --no-install-recommends libssl3 \
	&& apt-get -s dist-upgrade | grep "^Inst" | grep -i securi | cut -d " " -f 2 | xargs apt-get install -y --no-install-recommends \
	&& mkdir -p /usr/lib/aarch64-linux-gnu /usr/lib/x86_64-linux-gnu || true \
	&& { python${PYTHON_VERSION} -m ensurepip --upgrade || true; } \
	&& python${PYTHON_VERSION} -m pip install --upgrade --no-cache-dir --ignore-installed --break-system-packages --root-user-action=ignore pip \
	# The apt cleanup is redundant here since we don't inherit the builder stage, but it's good practice
	&& apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Copy application requirements
COPY src/requirements/ .

# Install application dependencies
RUN python${PYTHON_VERSION} -m pip install --no-cache-dir --ignore-installed --break-system-packages --root-user-action=ignore -r requirements-api.txt


FROM ghcr.io/stairwaytowonderland/starter-project:builder-ubuntu-latest AS base

ARG PYTHON_VERSION \
	TIMEZONE=UTC \
	USERNAME=appuser \
	USER_UID=1000 \
	USER_GID=1000 \
	DEBUG=false \
	BIND_ADDR=0.0.0.0:8000

ENV PYTHON_VERSION=${PYTHON_VERSION} \
	TZ=$TIMEZONE \
	DEBIAN_FRONTEND=noninteractive \
	# Prevent Python from writing .pyc files (keeps source code directories free of __pycache__ folders and .pyc files)
	PYTHONDONTWRITEBYTECODE=1 \
	# Ensure Python output is sent straight to the terminal without buffering (important for logging in Docker)
    PYTHONUNBUFFERED=1 \
	# Default to Candidates table if not specified at runtime
	TC_DYNAMO_TABLE=Candidates

USER root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libreoffice-common \
        libreoffice-writer \
		libssl3 \
		tini \
	# Cleanup
	&& apt-get clean -y \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/* \
	# Create a non-root user to run the application, if it doesn't already exist
	&& id "$USERNAME" >/dev/null 2>&1 || { \
		groupadd --gid "$USER_GID" "$USERNAME" \
		&& useradd --uid "$USER_UID" --gid "$USER_GID" -m "$USERNAME" -s /bin/bash; \
	} \
	&& mkdir -p /usr/lib/aarch64-linux-gnu /usr/lib/x86_64-linux-gnu || true

# Copy arch-specific ssl dependencies from the builder stage.
# Copy both arch directories (only one will exist in the builder depending on platform);
# delete the empty one after, and exclude Debian apt libs to avoid breaking Ubuntu's apt-get.
COPY --from=builder /usr/lib/aarch64-linux-gnu/ /tmp/builder-libs/aarch64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/ /tmp/builder-libs/x86_64-linux-gnu/
RUN for arch in aarch64 x86_64; do \
		src="/tmp/builder-libs/${arch}-linux-gnu"; \
		dest="/usr/lib/${arch}-linux-gnu"; \
		[ -d "$src" ] && [ "$(ls -A $src)" ] \
			&& find "$src" -maxdepth 1 -name 'libssl*' -o -name 'libcrypto*' \
				| xargs -I{} cp -P {} "$dest/" \
			|| rm -rf "$dest"; \
	done \
	&& rm -rf /tmp/builder-libs

# Copy installed dependencies from the builder stage
COPY --from=builder /usr/local/lib/ /usr/local/lib
COPY --from=builder /usr/local/bin/ /usr/local/bin


FROM base AS app

WORKDIR /app

USER $USERNAME

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


FROM base AS devcontainer

ARG USERNAME=vscode

USER root

RUN apt-get update \
	&& apt-get install -y --no-install-recommends sudo \
	&& mkdir -p /opt/venv \
	&& chown $USERNAME:$USERNAME /opt/venv \
	# Cleanup
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

RUN python${PYTHON_VERSION} -m venv /opt/venv \
	&& . /opt/venv/bin/activate \
	&& python${PYTHON_VERSION} -m pip install --upgrade --no-cache-dir pip \
	&& python${PYTHON_VERSION} -m pip install --upgrade --no-cache-dir -r src/requirements/requirements-dev.txt \
	&& echo '. /opt/venv/bin/activate' >> /home/$USERNAME/.bashrc
