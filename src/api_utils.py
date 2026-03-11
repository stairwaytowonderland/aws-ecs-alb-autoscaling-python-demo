import os

from enum import Enum
import urllib, urllib.request

health_check_timeout = os.environ.get(
    "APP_HEALTH_CHECK_TIMEOUT", os.environ.get("TF_VAR_app_health_check_timeout", 30)
)


def _get_token(timeout: int = 30) -> str | None:
    url = "http://169.254.169.254/latest/api/token"
    headers = {"X-aws-ec2-metadata-token-ttl-seconds": "60"}

    req = urllib.request.Request(url, headers=headers, method="PUT")

    try:
        response = urllib.request.urlopen(req, timeout=timeout)
        token = response.read().decode()
        return token
    except urllib.error.HTTPError as e:
        print(f"HTTPError: {e.code} - {e.reason}")
    except urllib.error.URLError as e:
        print(f"URLError: {e.reason}")
        if str(e.reason).lower() == "timed out":
            # Dumb hack to throw an error with a code
            # https://docs.python.org/3/library/urllib.error.html
            msg = f"{e.reason} -- probably not connected to EC2"
            raise urllib.error.HTTPError(
                url=url, hdrs=headers, msg=msg, code=504, fp=None
            )  # No need for fp when exeption is re-raised
        else:
            raise Exception({"details": {"reason": str(e.reason), "code": 500}})
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def _get_instance_id(token: str) -> str | None:
    url = "http://169.254.169.254/latest/meta-data/instance-id"
    headers = {"X-aws-ec2-metadata-token": token}

    req = urllib.request.Request(url, headers=headers)

    try:
        response = urllib.request.urlopen(req)
        instance_id = response.read().decode()
        return instance_id
    except urllib.error.HTTPError as e:
        print(f"HTTPError: {e.code} - {e.reason}")
    except urllib.error.URLError as e:
        print(f"URLError: {e.reason}")


def get_instance_id(timeout: int) -> str:
    """Helper to get the instance id

    Args:
        timeout: (int) The request timeout in seconds
    """
    token = _get_token(timeout)
    instance_id = _get_instance_id(token)
    return instance_id
