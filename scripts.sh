extract_key_value_pairs() {
    local file_path=$1

    cat "$file_path" | tr -d '\n' | sed 's/[{}]//g' | tr ',' '\n' | while IFS=: read -r key value; do
        key=$(echo $key | sed 's/\"//g' | xargs)
        value=$(echo $value | sed 's/\"//g' | xargs)
        echo "Key: $key, Value: $value"
    done
}

create_secret() {
    local secret_name=$1
    local file_path=$2
    local type=$3

    json_object=$(cat "$file_path")
    aws secretsmanager create-secret --name "$secret_name" --secret-string "$json_object"
    echo "Created or updated secret $secret_name with value from $file_path"
}

create_secret() {
    local secret_name=$1
    local file_path=$2
    local type=$3

    if [[ $type == "binary" ]]; then
        binary_content=$(base64 -i "$file_path")
        aws secretsmanager create-secret --name "$secret_name" --secret-binary "$binary_content" ||
            aws secretsmanager update-secret --secret-id "$secret_name" --secret-binary "$binary_content"
        echo "Created or updated binary secret $secret_name with value from $file_path"
    else
        json_object=$(cat "$file_path")
        aws secretsmanager create-secret --name "$secret_name" --secret-string "$json_object" ||
            aws secretsmanager update-secret --secret-id "$secret_name" --secret-string "$json_object"
        echo "Created or updated secret $secret_name with value from $file_path"
    fi
}


update_secret() {
    local secret_name=$1
    local file_path=$2
    local type=$3

    if [[ $type == "binary" ]]; then
        # binary_content=$(base64 -i "$file_path")
        # Assume file already in binary!
        binary_content=$(cat "$file_path")
        aws secretsmanager update-secret --secret-id "$secret_name" --secret-binary "$binary_content"
        echo "Created or updated binary secret $secret_name with value from $file_path"
    else
        json_object=$(cat "$file_path")
        aws secretsmanager update-secret --secret-id "$secret_name" --secret-string "$json_object"
        echo "Created or updated secret $secret_name with value from $file_path"
    fi
}

aws_switch() {
    local role_id=${1:-830055605338}
    local role_name=${2:-AdminUserRole}
    local session_name=${3:-SESSION_NAME}

    local response=$(aws sts assume-role --role-arn arn:aws:iam::"$role_id":role/$role_name --role-session-name $session_name)

    export AWS_ACCESS_KEY_ID=$(echo $response | grep -o '"AccessKeyId":[^,]*' | awk -F'"' '{print $4}')
    export AWS_SECRET_ACCESS_KEY=$(echo $response | grep -o '"SecretAccessKey":[^,]*' | awk -F'"' '{print $4}')
    export AWS_SESSION_TOKEN=$(echo $response | grep -o '"SessionToken":[^,]*' | awk -F'"' '{print $4}')
}

get_secret() {
    local SECRET=$1
    local format=$2

    if [ -n "$SECRET" ]; then
        SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET" --query 'SecretString' --output "$format")

        if [ "$SECRET_VALUE" = "null" ]; then
            # If SecretString is null, retrieve SecretBinary and decode it
            SECRET_BINARY=$(aws secretsmanager get-secret-value --secret-id "$SECRET" --query 'SecretBinary' --output "$format")
            SECRET_VALUE=$(echo "$SECRET_BINARY")
        fi

        DIR="~/tmp/$(dirname "$SECRET")"
        echo "Creating directory: $DIR"
        mkdir -p "$DIR"

        FILE_PATH="~/tmp/$SECRET.txt"
        echo "$SECRET_VALUE" > "$FILE_PATH"

        echo "Saved secret value for $SECRET to $FILE_PATH"
    else
        echo "Skipping empty secret name"
    fi
}

get_all_secret() {
    format=${1:"json"}
    secrets=$(aws secretsmanager list-secrets --query 'SecretList[*].Name' --output text | xargs echo)

    # IFS=' ' read -r -a secrets_array <<< "$secrets"
    secrets_array=("${(@s: :)secrets}")

    for SECRET in "${secrets_array[@]}"; do
        get_secret "$SECRET" json
    done
}
