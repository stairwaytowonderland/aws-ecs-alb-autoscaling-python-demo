"""Gunicorn configuration file for the API application.

Usage:
    gunicorn --config gunicorn.py api:resume_app
"""

import os

os.environ.setdefault("API_CONFIG_FILE", "api_config.yaml")
bind = "0.0.0.0:8000"
