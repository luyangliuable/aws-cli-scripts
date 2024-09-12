# AWS Secrets Manager Scripts

This repository contains scripts for managing secrets using Amazon Web Services (AWS) Secrets Manager. These scripts provide functions for extracting key-value pairs from JSON files, creating or updating secrets, and getting secret values.

## Setup

```sh
cat ./scripts.sh >> ~/.zshrc
```

## Useful Functions

### `compare_secret`
This function compares the values of two secrets and prints whether they are identical or different. You can specify the secret names and output format using flags.

```sh
compare_secret <SECRET1> <SECRET2>
```

#### Flags:
* `-f <format>`: The format of the secret values. Options are json or text. Default is json.

Example:
```sh
compare_secret "my-secret-1" "my-secret-2"
```

By following these steps and using the updated documentation, you should be able to retrieve, save, and compare secret values from AWS Secrets Manager using flag-based parameter specification. If you have any further questions or need additional assistance, feel free to ask!

### `get_all_secret`
This function retrieves all secrets and saves each value to a local file. You can specify the output format and root directory using flags.

```sh
get_all_secret [-f format=json|text] [-d root_dir=tmp]
```

#### Flags:
* `-f <format>`: The format of the secret values. Options are json or text. Default is json.
* `-d <root_dir>`: The root directory where the secret values will be saved. Default is tmp.

Example:
```sh
get_all_secret -f "json" -d "/Users/liul31/secrets"
```

### `get_secret`
This function retrieves the value of a given secret using either JSON or text format and saves it to a local file. You can specify the secret name, output format, and root directory using flags.

If no `-d` specified it will simply output to stdout. Otherwise save to a file in root_dir.

```sh
get_secret -s <SECRET> [-f format=json|text] [-d root_dir=tmp]
```

Flags:
* `-s <SECRET>`: The name of the secret to retrieve. This flag is required.
* `-f <format>`: The format of the secret value. Options are json or text. Default is json.
* `-d <root_dir>`: The root directory where the secret value will be saved. Default is tmp.

Example:
```sh
get_secret -s "my-secret" -f "json" -d "/Users/liul31/secrets"
```

### `create_secret`

This function creates or updates a secret using either text or binary data from a file. You can specify the secret name, file path, and type (text or binary).

```sh
create_secret <secret_name> <file_path> [type=text|binary]
```

### `update_secret`
This function updates a secret using either text or binary data from a file. You can specify the secret name, file path, and type (text or binary).

```sh
update_secret <secret_name> <file_path> [type=text|binary]
```

### `aws_switch`
This function switches to an assumed AWS role using the provided IAM role ID, name, and session name. It returns the access key ID, secret access key, and session token.

```sh
aws_switch <role_id> [<role_name>] [<session_name>]
```

Install AWS CLI if not already installed (https://aws.amazon.com/cli/) and configure it with your credentials.
