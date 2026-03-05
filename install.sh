#!/bin/bash

# Antigravity OpenMemory Installer for Unix (Bash)

ANTIGRAVITY_PROJECT_DIR=${1:-$(pwd)}
OPENMEMORY_REPO_URL="https://github.com/openmemory/openmemory.git"
OPENMEMORY_BRANCH="main"

echo "=================================="
echo " Antigravity OpenMemory Installer "
echo "=================================="

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OPENMEMORY_DIR="$SCRIPT_DIR/OpenMemory"

# 1. Clone OpenMemory
if [ ! -d "$OPENMEMORY_DIR" ]; then
    echo "Cloning OpenMemory repository..."
    git clone -b "$OPENMEMORY_BRANCH" "$OPENMEMORY_REPO_URL" "$OPENMEMORY_DIR"
else
    echo "OpenMemory directory already exists. Pulling latest changes..."
    cd "$OPENMEMORY_DIR" && git pull && cd ..
fi

# 2. Build OpenMemory
echo "Installing dependencies and building OpenMemory..."
cd "$OPENMEMORY_DIR"
npm install
npm run build
cd "$SCRIPT_DIR"

# 3. Setup .env
ENV_EXAMPLE="$OPENMEMORY_DIR/.env.example"
ENV_FILE="$OPENMEMORY_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    if [ -f "$ENV_EXAMPLE" ]; then
        echo "Creating default .env file..."
        cp "$ENV_EXAMPLE" "$ENV_FILE"
    else
        echo "Warning: No .env.example found. You may need to configure .env manually."
    fi
fi

# 4. Link Skill to desired Antigravity Project
TARGET_AGENTS_DIR="$ANTIGRAVITY_PROJECT_DIR/.agents"
TARGET_SKILLS_DIR="$TARGET_AGENTS_DIR/skills"
TARGET_SKILL_LINK="$TARGET_SKILLS_DIR/memory-management"
SOURCE_SKILL_DIR="$SCRIPT_DIR/skills/memory-management"

if [ ! -d "$TARGET_SKILLS_DIR" ]; then
    echo "Creating skills directory in target project: $TARGET_SKILLS_DIR"
    mkdir -p "$TARGET_SKILLS_DIR"
fi

if [ -L "$TARGET_SKILL_LINK" ] || [ -e "$TARGET_SKILL_LINK" ]; then
    echo "Skill mapping already exists at: $TARGET_SKILL_LINK. Overwriting..."
    rm -rf "$TARGET_SKILL_LINK"
fi

echo "Linking memory-management skill to target project..."
ln -s "$SOURCE_SKILL_DIR" "$TARGET_SKILL_LINK"

echo ""
echo "=== Installation Complete! ==="
echo "Next Steps:"
echo "1. Open your Antigravity global MCP config (usually ~/.gemini/antigravity/mcp_config.json)"
echo "2. Add the following stdio server configuration:"
echo ""
echo '    "openmemory": {'
echo '      "type": "stdio",'
echo '      "command": "node",'
echo "      \"args\": [\"$OPENMEMORY_DIR/packages/openmemory-js/bin/opm.js\", \"mcp\"]"
echo '    }'
echo ""
echo "3. Restart Antigravity."
