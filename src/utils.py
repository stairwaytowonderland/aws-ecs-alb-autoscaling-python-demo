from enum import Enum
import urllib, urllib.request


class PartyEnum(str, Enum):
    INDEPENDENT = "Independent"
    DEMOCRATIC = "Democratic"
    REPUBLICAN = "Republican"
    YESPLEASE = "Yes Please"

    @classmethod
    def from_key(cls, key: str):
        key_map = {
            "ind": cls.INDEPENDENT,
            "dem": cls.DEMOCRATIC,
            "rep": cls.REPUBLICAN,
            "yes": cls.YESPLEASE,
        }
        return key_map.get(key.lower())


def get_token(timeout: int = 30) -> str | None:
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


def get_instance_id(token: str) -> str | None:
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
