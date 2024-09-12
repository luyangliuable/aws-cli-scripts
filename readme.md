# AWS Secrets Manager Scripts

This repository contains scripts for managing secrets using Amazon Web Services (AWS) Secrets Manager. These scripts provide functions for extracting key-value pairs from JSON files, creating or updating secrets, and getting secret values.

## Setup

```
cat ./scripts.sh >> ~/.zshrc
```

## Useful Functions
`create_secret`

This function creates or updates a secret using either text or binary data from a file. You can specify the secret name, file path, and type (text or binary).

```
create_secret.sh <secret_name> <file_path> [type=text|binary]
```

`update_secret`
This function updates a secret using either text or binary data from a file. You can specify the secret name, file path, and type (text or binary).

```
update_secret.sh <secret_name> <file_path> [type=text|binary]
```

`aws_switch`
This function switches to an assumed AWS role using the provided IAM role ID, name, and session name. It returns the access key ID, secret access key, and session token.

```
aws_switch.sh <role_id> [<role_name>] [<session_name>]
```

`get_secret`
This function retrieves the value of a given secret using either JSON or text format and saves it to a local file. You can specify the secret name and output format.

```
get_secret.sh <SECRET> [format=json]
```

`get_all_secrets`
This function retrieves all secrets in JSON format and saves each value to a local file.

```
get_all_secrets.sh [format=json|text]
Usage
Install AWS CLI if not already installed (
https://aws.amazon.com/cli/
) and configure it with your credentials.
```

Make the scripts executable:

```sh
chmod +x extract_key_value_pairs.sh create_secret.sh update_secret.sh aws_switch.sh get_secret.sh get_all_secrets.sh
```
