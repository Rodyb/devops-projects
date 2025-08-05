#!/bin/bash

# Define the Python file to modify
file="app.py"

# Extract the current version (match only the CURRENT_MAJOR_RELEASE_VERSION line)
current_version=$(grep '^CURRENT_MAJOR_RELEASE_VERSION' "$file" | awk -F'=' '{print $2}' | tr -d '[:space:]' | tr -d '"')

# Verify the extracted current version
echo "Extracted current version: $current_version"

# Increment the version
new_version=$((current_version + 1))

# Update the CURRENT_MAJOR_RELEASE_VERSION in the file
sed -i '' "s/^CURRENT_MAJOR_RELEASE_VERSION = \"$current_version\"/CURRENT_MAJOR_RELEASE_VERSION = \"$new_version\"/" "$file"

# Also update APP_VERSION if it's set to f"{CURRENT_MAJOR_RELEASE_VERSION}.0.0"
sed -i '' "s/f\"{CURRENT_MAJOR_RELEASE_VERSION}.0.0\"/f\"$new_version.0.0\"/" "$file"

# Output the updated lines for verification
grep 'CURRENT_MAJOR_RELEASE_VERSION' "$file"
grep 'APP_VERSION' "$file"
