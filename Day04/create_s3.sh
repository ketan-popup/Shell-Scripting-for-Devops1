#!/bin/bash
set -euo pipefail

# Function to check if AWS CLI is installed
check_awscli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Please install it first." >&2
        exit 1
    fi
}

# Function to create an S3 bucket
create_s3_bucket() {
    local bucket_name="$1"
    local region="$2"

    echo "Creating S3 bucket: $bucket_name in region: $region"

    if [[ "$region" == "us-east-1" ]]; then
        aws s3api create-bucket --bucket "$bucket_name" --region "$region"
    else
        aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region "$region" \
            --create-bucket-configuration LocationConstraint="$region"
    fi

    echo "S3 bucket $bucket_name created successfully."
}

# Main function
main() {
    check_awscli

    # Define region and unique bucket name
    REGION="us-east-1"  # Change this to your preferred region
    BUCKET_NAME="my-unique-s3-bucket-$(date +%s)"

    create_s3_bucket "$BUCKET_NAME" "$REGION"
}

# Run main
main "$@"
~
~
"create_s3.sh" 43L, 1040B                                              
