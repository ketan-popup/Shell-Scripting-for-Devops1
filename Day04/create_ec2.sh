#!/bin/bash
set -euo pipefail

# Function to check if AWS CLI is installed
check_awscli() {
    if ! command -v aws &> /dev/null; then
        return 1
    fi
    return 0
}

# Function to install AWS CLI
install_awscli() {
    echo "Installing AWS CLI v2 on Linux..."

    # Download and install AWS CLI v2
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo apt-get update -y &> /dev/null
    sudo apt-get install -y unzip &> /dev/null
    unzip -q awscliv2.zip
    sudo ./aws/install

    # Verify installation
    aws --version

    # Clean up
    rm -rf awscliv2.zip ./aws
}

# Wait for the EC2 instance to be in running state
wait_for_instance() {
    local instance_id="$1"
    echo "Waiting for instance $instance_id to be in running state..."

    while true; do
        state=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[0].Instances[0].State.Name' --output text)
        if [[ "$state" == "running" ]]; then
            echo "Instance $instance_id is now running."
            break
        fi
        sleep 10
    done
}

# Create EC2 instance
create_ec2_instance() {
    local ami_id="$1"
    local instance_type="$2"
    local key_name="$3"
    local subnet_id="$4"
    local security_group_ids="$5"
    local instance_name="$6"

    echo "Creating EC2 instance..."

    instance_id=$(aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --key-name "$key_name" \
        --subnet-id "$subnet_id" \
        --security-group-ids $security_group_ids \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

    if [[ -z "$instance_id" ]]; then
        echo "Failed to create EC2 instance." >&2
        exit 1
    fi

    echo "Instance $instance_id created successfully."

    wait_for_instance "$instance_id"
}

# Main function
main() {
    # Check and install AWS CLI if needed
    if ! check_awscli; then
        install_awscli || { echo "Failed to install AWS CLI"; exit 1; }
    fi

    # EC2 instance parameters
    AMI_ID="ami-0d1b5a8c13042c939"
    INSTANCE_TYPE="t2.micro"
    KEY_NAME="shell-scripting"
    SUBNET_ID="subnet-05e1584fecc4c053d"
    SECURITY_GROUP_IDS="sg-02222f67ca19c3510"  # Replace with actual Security Group ID(s)
    INSTANCE_NAME="Shell-Script-EC2-Demo"

    # Create the EC2 instance
    create_ec2_instance "$AMI_ID" "$INSTANCE_TYPE" "$KEY_NAME" "$SUBNET_ID" "$SECURITY_GROUP_IDS" "$INSTANCE_NAME"

    echo "EC2 instance creation completed."
}

# Run main
main "$@"
                                       


