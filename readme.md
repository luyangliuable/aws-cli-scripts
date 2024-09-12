# AWS Secrets Manager Scripts

This repository contains scripts for managing secrets using Amazon Web Services (AWS) Secrets Manager. These scripts provide functions for extracting key-value pairs from JSON files, creating or updating secrets, and getting secret values.

## Setup

```sh
cat ./scripts >> ~/.zshrc
```

## Useful Functions

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

### `get_secret`
This function retrieves the value of a given secret using either JSON or text format and saves it to a local file. You can specify the secret name and output format.

```sh
get_secret <SECRET> [format=json]
```

### `get_all_secrets`
This function retrieves all secrets in JSON format and saves each value to a local file.

```sh
get_all_secrets [format=json|text]
```


Install AWS CLI if not already installed (https://aws.amazon.com/cli/) and configure it with your credentials.
