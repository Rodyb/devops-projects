#!/bin/bash

# Check if sufficient arguments are provided
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <secret_agent_1> <secret_agent_2>"
  echo "Example: $0 jenkins-agent-1-secret jenkins-agent-2-secret"
  exit 1
fi

# Assign secrets to variables from positional arguments
SECRET_AGENT_1="$1"
SECRET_AGENT_2="$2"

# Read Terraform output
AGENT_IPS=$(jq -r '.[]' agents.json)

# Create an Ansible inventory
INVENTORY_FILE="inventory.ini"

# Start the inventory file
echo "[jenkins_agents]" > "$INVENTORY_FILE"

# Initialize counters and arrays for secrets and agent names
SECRETS_ARRAY=("$SECRET_AGENT_1" "$SECRET_AGENT_2")
AGENT_NAMES=("jenkins-agent-1" "jenkins-agent-2")

# Add each IP address, secret, and agent name to the inventory file
INDEX=0
for IP in $AGENT_IPS; do
  SECRET=${SECRETS_ARRAY[$INDEX]}
  AGENT_NAME=${AGENT_NAMES[$INDEX]}

  if [[ -z "$SECRET" || -z "$AGENT_NAME" ]]; then
    echo "Error: Missing secret or agent name for IP $IP."
    exit 1
  fi

  echo "$IP ansible_user=root ansible_ssh_private_key_file=~/.ssh/digital_ocean_macbook secret=$SECRET agent_name=$AGENT_NAME" >> "$INVENTORY_FILE"
  INDEX=$((INDEX + 1))
done

# Print the generated inventory
echo "Generated Ansible Inventory:"
cat "$INVENTORY_FILE"

# Move the inventory file to the Ansible directory
mv "$INVENTORY_FILE" ./ansible
