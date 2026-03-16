"""Gunicorn configuration file for the API application.

Usage:
    gunicorn --config gunicorn.py api:resume_app
"""

import os

os.environ.setdefault("API_CONFIG_FILE", "api_config.yaml")
default_bind_address = os.getenv("BIND_ADDRESS", "0.0.0.0:8000")
bind_address = os.getenv("GUNICORN_BIND_ADDRESS", default_bind_address)
bind = bind_address
