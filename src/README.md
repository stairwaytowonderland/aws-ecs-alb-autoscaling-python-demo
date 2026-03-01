# tech-challenge-flask-app - Hello, Candidate

## About

Simple flask based api that adds data to a database and returns it

Includes a health check

## Preparing

A DynamoDB table is required for this application to function

Instructions can be found here: [Setting Up DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SettingUp.DynamoWebService.html)

> **Note:** Make sure you create an instance role using IAM to allow access for your ec2 instances to the DynamoDB table
> or the application will not run!

Information on IAM for DynamoDB can be found here:
[DynamoDB - using identity based policies](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/using-identity-based-policies.html)

> **Note:** This requires Python 3

## Running

Reads environment variable to connect to dynamodb in AWS with a connection string; this must be set first appropriately
for your host OS

using bash on Linux this would look like the following:

```bash
export TC_DYNAMO_TABLE=<dynamodb table>
```

windows using powershell

```powershell
$env:TC_DYNAMO_TABLE=<dynamodb table>
```

To install requirements (requires pip):

```bash
pip install -r requirements.txt
```

To run on port 8000 (default port):

```bash
gunicorn -b 0.0.0.0 app:candidates_app
```

## Testing

A python test script is provided and can be run locally when the app is running as follows:

```bash
python ./test_candidates.py <ip/dns address>:8000
```

## Containerizing

A dockerfile may be provided to build an image for the application

## Routes

- [GET] /gtg
  - Simple healthcheck - returns HTTP 200 OK if everything is working
  - Empty return

- [GET] /gtg?details
  - Advanced healthcheck - returns HTTP 200 OK if everything is working and some service details
  - JSON return

- [POST] /candidate/<str:name>
  - Adds a new string (candidate name) to a list, returns HTTP 200 OK if working
  - JSON return

  - optional parameter ?party=
  - will assign to a political party
    - empty/unsupplied or ind: none/independent (default)
    - dem: democratic
    - rep: republican
  - will error if supplied with something other than the three parameters above

- [GET] /candidate/<str:name>
  - Gets candidate name from the list, returns HTTP 200 OK and data
  - JSON return

- [GET] /candidates
  - Gets list of all candidates from a list, returns HTTP 200 OK and data
  - JSON return

---

## DynamoDB

If you are standing up this app for the first time, you probably need to create a DynamoDB table.

You can do this by using the following terraform snippet:

```tf
variable "ttl_enabled" {
  description = "Enable Time to Live (TTL) for the DynamoDB table."
  type        = bool
  default     = false
}

resource "aws_dynamodb_table" "candidate-table" {
  name           = "Candidates"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "CandidateName"

  attribute {
    name = "CandidateName"
    type = "S"
  }

  # NOTE
  # Setting 'attribute_name' with 'enabled' false requires aws provider version >= 5.75.1
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#attribute_name-1
  # https://github.com/hashicorp/terraform-provider-aws/blob/v5.75.1/CHANGELOG.md

  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#attribute_name
      attribute_name = "TimeToExist"
      enabled        = true
    }
  }

  lifecycle {
    ignore_changes = [
      ttl
    ]
  }
}
```
