"""
Docstring for app
"""

import json
import os
import subprocess
import urllib

import boto3
from boto3.dynamodb.conditions import Key
from flask import Flask, Response, request

import utils

dynamo_table_name = os.environ.get("TC_DYNAMO_TABLE", "Candidates")
dyndb_client = boto3.resource("dynamodb", region_name="us-east-2")
dyndb_table = dyndb_client.Table(dynamo_table_name)

health_check_timeout = os.environ.get(
    "APP_HEALTH_CHECK_TIMEOUT", os.environ.get("TF_VAR_app_health_check_timeout", 30)
)

candidates_app = Flask(__name__)


@candidates_app.route("/", methods=["GET"])
def default():
    """
    Default GET endpoint
    """
    return {"status": "invalid request"}, 400


@candidates_app.route("/gtg", methods=["GET"])
def gtg():
    """
    /gtg GET endpoint
    """
    try:
        details = request.args.get("details", None)
        instance_id = _get_instance_id(health_check_timeout)
    except urllib.error.HTTPError as e:
        return {"status": str(e.reason)}, e.code
    # pylint: disable=broad-except
    except Exception as e:
        return {"status": str(e)}, 500

    if details is not None:
        return {"connected": "true", "instance-id": instance_id}, 200

    return "OK", 200


@candidates_app.route("/candidate/<name>", methods=["GET"])
def get_candidate(name):
    """
    /candidate/name GET endpoint
    """

    try:
        response = dyndb_table.query(
            KeyConditionExpression=Key("CandidateName").eq(name)
        )

        if len(response["Items"]) == 0:
            raise ValueError

        print(response["Items"])
        item = response["Items"][0]
        result = {"CandidateName": item["CandidateName"]}
        if "Party" in item:
            result["Party"] = item["Party"]

        return json.dumps(result), 200

    # pylint: disable=broad-except
    except Exception:
        return "Not Found", 404


@candidates_app.route("/candidate/<name>", methods=["POST"])
def post_candidate(name):
    """
    /candidate/name POST endpoint
    """

    try:
        party = get_party_from_request()
        item = {"CandidateName": name}
        if party:
            item["Party"] = party
        dyndb_table.put_item(Item=item)
    except ValueError as ex:
        return {"error": str(ex)}, 400
    # pylint: disable=broad-except
    except Exception:
        return "Unable to update", 500

    return item, 200


@candidates_app.route("/candidates", methods=["GET"])
def get_candidates():
    """
    /candidates GET endpoint
    """

    try:
        items = dyndb_table.scan()["Items"]

        if len(items) == 0:
            raise ValueError

        results = []
        for item in items:
            candidate = {"CandidateName": item["CandidateName"]}
            if "Party" in item:
                candidate["Party"] = item["Party"]
            results.append(candidate)

        return json.dumps(results), 200

    # pylint: disable=broad-except
    except Exception:
        return "Not Found", 404


@candidates_app.route("/demo", methods=["GET"])
@candidates_app.route("/demo/<int:qty>", methods=["GET"])
@candidates_app.route("/demo/<int:qty>/<int:length>", methods=["GET"])
def demo(qty: int = 1, length: int = 20) -> Response | tuple[dict, int]:
    """
    /demo[/qty][/length] GET endpoint - runs `passgen.sh` with optional parameters
    """
    try:
        result = subprocess.run(
            ["/usr/local/bin/passgen.sh", f"-{qty}", f"{length}"],
            shell=False,
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )

        if result.returncode != 0:
            return {"error": "Command failed", "stderr": result.stderr}, 500

        # return Response(result.stdout, status=200, mimetype="text/plain")
        return result.stdout, 200, {"Content-Type": "text/plain; charset=utf-8"}

    except subprocess.TimeoutExpired:
        return {"error": "Command timed out"}, 500

    # pylint: disable=broad-except
    except Exception as e:
        return {"error": str(e)}, 500


def _get_instance_id(timeout: int) -> str:
    """Helper to get the instance id

    Args:
        timeout: (int) The request timeout in seconds
    """
    token = utils.get_token(timeout)
    instance_id = utils.get_instance_id(token)
    return instance_id


def get_party_from_request() -> str:
    """Helper to extract and validate the party query parameter.

    Returns:
        str: The party string
    """

    party_param = request.args.get("party", None)
    if party_param is None or party_param == "":
        return None  # No party assigned if not supplied

    party = utils.PartyEnum.from_key(party_param)
    if party is None:
        raise ValueError("Invalid party value")

    return party
