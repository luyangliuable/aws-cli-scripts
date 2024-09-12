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
    local SECRET=""
    local format="json"
    local root_dir="tmp"

    while getopts "s:f:d:" opt; do
        case $opt in
            s) SECRET=$OPTARG ;;
            f) format=$OPTARG ;;
            d) root_dir=$OPTARG ;;
            *) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
        esac
    done

    if [ -n "$SECRET" ]; then
        SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id "$SECRET" --query 'SecretString' --output "$format")

        if [ "$SECRET_VALUE" = "null" ]; then
            SECRET_BINARY=$(aws secretsmanager get-secret-value --secret-id "$SECRET" --query 'SecretBinary' --output "$format")
            SECRET_VALUE=$(echo "$SECRET_BINARY")
        fi

        if [ "$root_dir" = "tmp" ]; then
            echo $SECRET_VALUE
        else 
            DIR="~/tmp/$(dirname "$SECRET")"

            if [ -n "$root_dir" ]; then
                DIR="$root_dir/$(dirname "$SECRET")"
            fi

            echo "Creating directory: $DIR"
            mkdir -p "$DIR"

            FILE_PATH="~/tmp/$SECRET.txt"

            if [ -n "$root_dir" ]; then
                FILE_PATH="$root_dir/$SECRET.txt"
            fi

            echo "$SECRET_VALUE" > "$FILE_PATH"
            echo "Saved secret value for $SECRET to $FILE_PATH"
        fi
    else
        echo "Skipping empty secret name"
    fi
}

get_all_secret() {
    local format="json"
    local root_dir="tmp"
    while getopts "f:d:" opt; do
        case $opt in
            f) format=$OPTARG ;;
            d) root_dir=$OPTARG ;;
            *) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
        esac
    done
    secrets=$(aws secretsmanager list-secrets --query 'SecretList[*].Name' --output text | xargs echo)
    secrets_array=("${(@s: :)secrets}")
    for SECRET in "${secrets_array[@]}"; do
        get_secret -s "$SECRET" -f "$format" -d "$root_dir"
    done
}

compare_secret() {
    local SECRET1=$1
    local SECRET2=$2
    local format="json"

    echo "Comparing $SECRET1 with $SECRET2."
    secret_1_str=$(get_secret -s "$SECRET1")
    secret_2_str=$(get_secret -s "$SECRET2")

    if [ -n "$SECRET1" ] && [ -n "$SECRET2" ]; then
        secret_1_str=$(get_secret -s "$SECRET1" -f "$format")
        secret_2_str=$(get_secret -s "$SECRET2" -f "$format")

        if [ "$secret_1_str" = "$secret_2_str" ]; then
            echo "The secrets are identical."
        else
            echo "The secrets are different."
        fi
    else
        echo "Both secret names must be provided."
    fi
}
