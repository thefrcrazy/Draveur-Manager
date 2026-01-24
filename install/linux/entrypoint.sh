#!/bin/bash
set -e

# ID of the internal user
USER=kweebec
USER_ID=$(id -u $USER)

echo "🚀 Kweebec Manager Entrypoint"

# Function to fix permissions
fix_permissions() {
    local dir="$1"
    if [ -d "$dir" ]; then
        echo "🔧 Checking permissions for $dir..."
        # Check if the directory is owned by the user
        if [ "$(stat -c '%u' "$dir")" != "$USER_ID" ]; then
            echo "   👉 Fixing ownership of $dir to $USER_ID..."
            chown -R $USER:$USER "$dir"
        fi
    fi
}

# Fix permissions for data directories
fix_permissions "/data"
fix_permissions "/servers"
fix_permissions "/backups"

# If the command starts with '-', assume it's an argument to the app
if [ "${1:0:1}" = '-' ]; then
    set -- ./kweebec "$@"
fi

# Drop privileges and execute the command
if [ "$1" = './kweebec' ] || [ "$1" = '/app/kweebec' ]; then
    echo "✅ Starting Kweebec Manager as $USER..."
    exec gosu $USER "$@"
else
    # Execute other commands as is (useful for debugging)
    exec "$@"
fi
