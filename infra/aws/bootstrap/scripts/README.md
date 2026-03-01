# OIDC Provider Thumbprint Extraction Script

## Overview

This script (**provided as a single-line *command***) extracts SSL (TLS) certificate thumbprints from a secure host. It's particularly useful when configuring AWS IAM OIDC providers that need to trust a certificate chain.

### What is a thumbprint?

A server certificate thumbprint is the hex-encoded SHA-1 hash value of the X.509 certificate used by the domain where the OpenID Connect provider makes its keys available.

### Variables and values

- **HOST** - Refers to the `<OIDC Provider FQDN>`
- **PORT** - Refers to the secure port for the aforementioned `<HOST>`

### Code examples

- **Usage examples** - Most of the examples reference **`<command>`**, which **_needs be replaced_** with one of the 3 [usage](#usage) options (*below*).
- **Example values** - For working example purposes, `token.actions.githubusercontent.com` is used for the value of `<HOST>` throughout this document.
- **Output values** - The thumbprint output values are real.

> **Note:** The examples use GitHub, but the *command* can also be used with GitLab, as well as any other OIDC provider.

## Full *command*

```bash
OPENID_CONFIG_URL=$(printf 'https://%s/%s' \
  'vstoken.actions.githubusercontent.com' \
  '.well-known/openid-configuration'); \
HOST=$(wget -qO- "$OPENID_CONFIG_URL" \
    | jq -r '.jwks_uri | split("/")[2]'); \
PORT='443'; \
openssl s_client \
  -servername "$HOST" \
  -showcerts \
  -connect "$HOST:$PORT" \
  < /dev/null 2>/dev/null \
  | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; print}' \
  | {
    cert_text=""
    while IFS= read -r line; do
      case "$line" in
        *"END CERTIFICATE"*)
          cert_text="$cert_text$line
"
          printf '%s' "$cert_text" \
            | openssl x509 \
              -fingerprint \
              -sha1 \
              -noout
          cert_text=""
          ;;
        *)
          cert_text="$cert_text$line
"
          ;;
      esac
    done
  } \
  | awk -F'=' '{print $2}' \
  | sed 's/://g' \
  | tr '[:upper:]' '[:lower:]'
```

## Usage

**Option 1** *(Recommended)*

Copy and paste entire [*command*](#full-command) into your terminal.

**Option 2**

Download *Gist* and pipe to *`sh`* (e.g. `| sh - `).

> **Note:** You can pipe to *`bash`* if you prefer (e.g. `| bash - `)

```bash
GIST_ID='<Gist ID>'; \
wget -qO- https://api.github.com/users/andrewhaller/gists \
  | jq --arg gist "$GIST_ID" --arg file "${GIST_FILE:-thumbprints.sh}" \
    '.[]
    | select(.id == $gist)
    | .files[]
    | select(.filename == $file)
    | .raw_url' -r \
  | wget -qO- -i - \
  | sh -
```

> **Tip:** To output the README.md, set `GIST_FILE=README.md`, and pipe to *`cat`* **instead of** *`sh`* (e.g. `| cat`)

**Option 3**

Manually download and execute.

```bash
sh thumbprints.sh
```

**Output**

```
7560d6f40fa55195f740ee2b1b7c0b4836cbe103
dd55b4520291e276588f0dd02fafd83a7368e0fa
2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f
```

## Command Breakdown

### Step 1: Configuration and Host Discovery

```bash
OPENID_CONFIG_URL=$(printf 'https://%s/%s' \
  'vstoken.actions.githubusercontent.com' \
  '.well-known/openid-configuration'); \
HOST=$(wget -qO- "$OPENID_CONFIG_URL" \
    | jq -r '.jwks_uri | split("/")[2]'); \
PORT='443'
```

#### What it does

1. **`OPENID_CONFIG_URL=...`** - Sets the URL to the provider's OpenID Connect configuration endpoint
2. **`wget -qO- "$OPENID_CONFIG_URL"`** - Downloads the JSON configuration file
   - `-q`: Quiet mode (no *`wget`* output)
   - `-O-`: Output to stdout instead of a file
3. **`jq -r '.jwks_uri | split("/")[2]'`** - Parses the JSON response
   - `.jwks_uri`: Extracts the `jwks_uri` field
   - `split("/")[2]`: Splits the URL by `/` and takes the 3rd element (the hostname)
   - `-r`: Raw output (no quotes)
4. **`PORT='443'`** - Sets HTTPS port

#### Example JSON response

```json
{
  "issuer": "https://token.actions.githubusercontent.com",
  "jwks_uri": "https://token.actions.githubusercontent.com/.well-known/jwks",
  "subject_types_supported": ["public"]
}
```

**Result**

```bash
HOST='token.actions.githubusercontent.com'
```

### Step 2: SSL/TLS Certificate Retrieval

```bash
openssl s_client \
  -servername "$HOST" \
  -showcerts \
  -connect "$HOST:$PORT" \
  < /dev/null 2>/dev/null
```

#### What it does

1. **`openssl s_client`** - Establishes an SSL/TLS connection
2. **`-servername "$HOST"`** - Sets SNI (Server Name Indication) for virtual hosting
   - Required for servers hosting multiple domains on the same IP
3. **`-showcerts`** - Returns the **entire certificate chain**
   - Server certificate
   - Intermediate certificates
   - Root certificate
4. **`-connect "$HOST:$PORT"`** - Specifies the host and port to connect to
5. **`< /dev/null`** - Provides empty input to prevent the *`openssl`* from hanging
6. **`2>/dev/null`** - Suppresses error messages and connection information

#### Sample output

```
CONNECTED(00000003)
depth=2 C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root CA
verify return:1
depth=1 C = US, O = DigiCert Inc, CN = DigiCert TLS RSA SHA256 2020 CA1
verify return:1
depth=0 C = US, ST = California, L = San Francisco, O = "GitHub, Inc.", CN = *.actions.githubusercontent.com
verify return:1
---
Certificate chain
 0 s:C = US, ST = California, L = San Francisco, O = "GitHub, Inc.", CN = *.actions.githubusercontent.com
   i:C = US, O = DigiCert Inc, CN = DigiCert TLS RSA SHA256 2020 CA1
-----BEGIN CERTIFICATE-----
MIIHXjCCBkagAwIBAgIQC8+6l2mLLkSP3M1gMKnLCDANBgkqhkiG9w0BAQsFADBP...
-----END CERTIFICATE-----
 1 s:C = US, O = DigiCert Inc, CN = DigiCert TLS RSA SHA256 2020 CA1
   i:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root CA
-----BEGIN CERTIFICATE-----
MIIEvjCCA6agAwIBAgIQBtjZBNVYQ0b2ii+nVCJ+xDANBgkqhkiG9w0BAQsFADBh...
-----END CERTIFICATE-----
```

### Step 3: Certificate Extraction

```bash
awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; print}'
```

#### What it does

1. **`/BEGIN/,/END/`** - AWK range pattern
   - Matches all lines between `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE-----`
2. **`if(/BEGIN/){a++}`** - Increments counter when it sees `BEGIN`
   - Useful for debugging (counts number of certificates)
3. **`print`** - Outputs the matched lines

#### Input

```
Certificate chain
 0 s:C = US, ...
-----BEGIN CERTIFICATE-----
MIIHXjCCBkag...
-----END CERTIFICATE-----
 1 s:C = US, ...
-----BEGIN CERTIFICATE-----
MIIEvjCCA6ag...
-----END CERTIFICATE-----
```

#### Output

```
-----BEGIN CERTIFICATE-----
MIIHXjCCBkag...
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEvjCCA6ag...
-----END CERTIFICATE-----
```

### Step 4: Certificate Processing Loop

```bash
{
  cert_text=""
  while IFS= read -r line; do
    case "$line" in
      *"END CERTIFICATE"*)
        cert_text="$cert_text$line
"
        printf '%s' "$cert_text" \
          | openssl x509 \
            -fingerprint \
            -sha1 \
            -noout
        cert_text=""
        ;;
      *)
        cert_text="$cert_text$line
"
        ;;
    esac
  done
}
```

#### What it does

1. **`{ ... }`** - Groups commands together (maintains variable scope)
   - Variables modified inside persist outside the block
2. **`cert_text=""`** - Initializes an empty variable to accumulate certificate lines
3. **`while IFS= read -r line`** - Reads input line by line
   - `IFS=`: Preserves leading/trailing whitespace
   - `-r`: Prevents backslash interpretation (raw mode)
4. **`case "$line" in`** - Checks what type of line we're reading
5. **`*"END CERTIFICATE"*)`** - When we encounter the end of a certificate:
   - Append the final line to `cert_text`
   - Pipe the complete certificate to `openssl x509` for processing
   - Reset `cert_text` for the next certificate
6. **`*)`** - For all other lines:
   - Append the line to `cert_text` with a newline

#### Why this approach?

Each certificate needs to be processed as a **complete block** by `openssl x509`. We can't pipe line-by-line because OpenSSL expects a full PEM certificate.

### Step 5: Fingerprint Extraction

```bash
openssl x509 -fingerprint -sha1 -noout
```

> **Note:** See [command alterations](#command-alterations) for tips on retrieving other useful information

#### What it does

1. **`openssl x509`** - Certificate display and signing utility
2. **`-fingerprint`** - Generates the certificate fingerprint
   - A hash of the entire certificate
   - Used to uniquely identify certificates
3. **`-sha1`** - Uses [SHA-1](#why-sha-1) hashing algorithm
   - Required by AWS IAM OIDC providers
   - ***Note:** SHA-1 is cryptographically weak but still used for fingerprints*
4. **`-noout`** - Suppresses certificate output
   - Only prints the fingerprint, not the certificate details

#### Input

```
-----BEGIN CERTIFICATE-----
MIIHXjCCBkagAwIBAgIQC8+6l2mLLkSP3M1gMKnLCDANBgkqhkiG9w0BAQsFADBP...
-----END CERTIFICATE-----
```

#### Output

```
SHA1 Fingerprint=75:60:D6:F4:0F:A5:51:95:F7:40:EE:2B:1B:7C:0B:48:36:CB:E1:03
```

### Step 6: Format Cleanup

```bash
awk -F'=' '{print $2}' | sed 's/://g' | tr '[:upper:]' '[:lower:]'
```

> **Note:** See [command alterations](#command-alterations) for tips on retrieving other useful information

#### What it does

##### 6a. Extract Fingerprint Value

```bash
awk -F'=' '{print $2}'
```

- **`-F'='`** - Sets field separator to `=`
- **`{print $2}`** - Prints the second field (everything after `=`)

**Input:** `SHA1 Fingerprint=75:60:D6:F4:0F:A5:51:95:F7:40:EE:2B:1B:7C:0B:48:36:CB:E1:03`

**Output:** `75:60:D6:F4:0F:A5:51:95:F7:40:EE:2B:1B:7C:0B:48:36:CB:E1:03`

##### 6b. Remove Colons

```bash
sed 's/://g'
```

- **`s/://g`** - Substitute (replace) all `:` with nothing
- **`g`** - Global flag (all occurrences on each line)

**Input:** `75:60:D6:F4:0F:A5:51:95:F7:40:EE:2B:1B:7C:0B:48:36:CB:E1:03`

**Output:** `7560D6F40FA55195F740EE2B1B7C0B4836CBE103`

##### 6c. Convert to Lowercase

```bash
tr '[:upper:]' '[:lower:]'
```

- **`tr`** - Translate characters
- **`'[:upper:]'`** - POSIX character class for uppercase letters
- **`'[:lower:]'`** - POSIX character class for lowercase letters

**Input:** `7560D6F40FA55195F740EE2B1B7C0B4836CBE103`

**Output:** `7560d6f40fa55195f740ee2b1b7c0b4836cbe103`

---

## Prerequisites


| Tool      | Purpose               | POSIX?    |
|-----------|-----------------------|-----------|
| `jq`      | JSON parsing          | ❌ No     |
| `wget`    | HTTP client           | ❌ No     |
| `openssl` | SSL/TLS operations    | ✅ Common |
| `awk`     | Text processing       | ✅ Yes    |
| `sed`     | Stream editing        | ✅ Yes    |
| `tr`      | Character translation | ✅ Yes    |

## POSIX Compliance

For **full POSIX compliance**, hardcode the `HOST` (`wget` and `jq` steps omitted):

```bash
HOST='token.actions.githubusercontent.com'
PORT='443'

openssl s_client \
  # ... rest of command
```

## Common Use Cases

### 1. AWS IAM OIDC Provider Setup (CLI)

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  # Replace <command> with one of the 3 usage options:
  #   (e.g. `sh thumbprints.sh`)
  --thumbprint-list $(<command> | xargs echo)
```

### 2. AWS IAM OIDC Provider Setup (Terraform)

```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "7560d6f40fa55195f740ee2b1b7c0b4836cbe103",
    "dd55b4520291e276588f0dd02fafd83a7368e0fa",
    "2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f",
  ]
}
```

### 3. CloudFormation Template

```yaml
GitHubOIDCProvider:
  Type: AWS::IAM::OIDCProvider
  Properties:
    Url: https://token.actions.githubusercontent.com
    ClientIdList:
      - sts.amazonaws.com
    ThumbprintList:
      - 7560d6f40fa55195f740ee2b1b7c0b4836cbe103
      - dd55b4520291e276588f0dd02fafd83a7368e0fa
      - 2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f
```

### 4. Get Only the First Thumbprint (Server Certificate)

**Option 1**

Run full *command* and extract the **first value**.

```bash
# Replace <command> with one of the 3 usage options:
#   (e.g. `sh thumbprints.sh`)
<command> | head -n 1
```

**Option 2**

Running the *command* **without** the [cert extraction](#step-3-certificate-extraction) and [processing loop](#step-4-certificate-processing-loop) pieces will parse **only the first cert** in the chain.

```bash
openssl s_client \
  -servername <HOST> \
  -showcerts \
  -connect <HOST>:<PORT> \
  < /dev/null 2>/dev/null \
  | openssl x509 \
    -fingerprint \
    -sha1 \
    -noout \
  | awk -F'=' '{print $2}' \
  | sed 's/://g' \
  | tr '[:upper:]' '[:lower:]'
```

**Output** (*both options*)

```
7560d6f40fa55195f740ee2b1b7c0b4836cbe103
```

### 5. Get Thumbprints as Comma-Separated List

```bash
# Replace <command> with one of the 3 usage options:
#   (e.g. `sh thumbprints.sh`)
<command> | paste -sd ',' -
```

**Output**

```
7560d6f40fa55195f740ee2b1b7c0b4836cbe103,dd55b4520291e276588f0dd02fafd83a7368e0fa,2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f
```

## Troubleshooting

### Issue: Empty output

**Possible causes**

- Network connectivity issues
- Host unreachable on port 443
- Firewall blocking outbound HTTPS
- Invalid variable value in the [configuration and host discovery](#step-1-configuration-and-host-discovery)

**Solution**

```bash
# Test connectivity
curl -v https://token.actions.githubusercontent.com

# Check if port 443 is open
nc -zv token.actions.githubusercontent.com 443

# Hardcode the <HOST>
HOST='token.actions.githubusercontent.com'
```

### Issue: Certificate errors

**Possible causes**

- SSL/TLS handshake failure
- Certificate validation issues
- SNI not supported

**Solution**

```bash
# Test SSL/TLS connection manually
openssl s_client -servername token.actions.githubusercontent.com \
  -connect token.actions.githubusercontent.com:443
```

### Issue: `jq: command not found`

**Solution**

Install `jq` or use the POSIX-compliant version with hardcoded host.

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# RHEL/CentOS
sudo yum install jq

# Alpine
sudo apk add jq
```

### Issue: `wget: command not found`

**Solution**

Use `curl` instead:

```bash
HOST=$(curl -sL "$OPENID_CONFIG_URL" | jq -r '.jwks_uri | split("/")[2]' \
  || echo token.actions.githubusercontent.com)
```

## Why SHA-1?

AWS IAM OIDC providers **require SHA-1 thumbprints** for certificate validation, even though SHA-1 is cryptographically weak for signing purposes. This is because:

1. **Legacy compatibility** - SHA-1 is still widely used for fingerprints
2. **Collision resistance** - Not critical for fingerprints (only identification)
3. **AWS API requirement** - The API only accepts SHA-1

> **Note:** This does **not** compromise security—the thumbprint is only used to verify you're connecting to the correct certificate chain, not for cryptographic operations.

## What else?

The *command* is specifically written to retrieve the SHA-1 fingerprints of a certificate chain, cleaned up to be used as OIDC provider thumbprints.

### Command alterations

#### Retrieving the **Issuer** and **Subject**

With some *minor alterations*, the **Issuer** and **Subject** information can be retrieved.

1. On the [fingerprint extraction](#step-5-fingerprint-extraction) line, change `-fingerprint -sha1` to `-subject -issuer`
1. Remove the [format cleanup](#step-6-format-cleanup) pieces

## References

- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM OIDC Provider Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
- [OpenSSL s_client Manual](https://www.openssl.org/docs/man1.1.1/man1/openssl-s_client.html)
- [OpenSSL x509 Manual](https://www.openssl.org/docs/man1.1.1/man1/openssl-x509.html)
