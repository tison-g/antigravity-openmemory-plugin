# Antigravity OpenMemory Plugin

[English](README.md) | [中文](README_CN.md)

This plugin supercharges your Antigravity (Gemini Code Assistant) with cross-session, persistent memory. It automatically installs [OpenMemory](https://github.com/openmemory/openmemory), builds it, and links the required **Memory Management Skill** into your active Antigravity working directory.

## Features
- **Cross-Session Storage**: Gemini will remember architectures, coding preferences, open bugs, and rules across different chat sessions.
- **Autonomous Summarization**: The integrated skill instructs the agent to proactively compress and save key insights without prompting.
- **Native MCP Support**: Configures OpenMemory strictly as an MCP `stdio` server directly supported by Antigravity—no background API services needed!

## Prerequisites
- Windows, macOS, or Linux
- [Node.js](https://nodejs.org/) (v18+) & NPM
- Git
- Antigravity extension configured

## Installation

1. **Clone this repository** anywhere on your system:
   ```bash
   git clone https://github.com/tison-g/antigravity-openmemory-plugin
   cd antigravity-openmemory-plugin
   ```

2. **Run the Installer:**
   Run the installation script from within the folder where your target Antigravity project resides, or pass the project path as an argument.

   **For Windows (PowerShell):**
   ```powershell
   & "path\to\antigravity-openmemory-plugin\install.ps1"
   ```

   **For Unix/macOS (Bash):**
   ```bash
   bash "path/to/antigravity-openmemory-plugin/install.sh"
   ```
   *What this does:*
   - Clones OpenMemory submodule.
   - Installs NPM packages and builds the TS output.
   - Junction links the `skills/memory-management` folder into your current project's `.agents/skills` directory so Antigravity knows when and how to store memories.

3. **Configure MCP settings in Antigravity**
   Open your global Antigravity MCP config file (`~/.gemini/antigravity/mcp_config.json`) and append the configuration exactly as printed by the installer output. It should look like this:

   ```json
   {
     "mcpServers": {
       "openmemory": {
         "type": "stdio",
         "command": "node",
         "args": ["C:/absolute/path/to/antigravity-openmemory-plugin/OpenMemory/packages/openmemory-js/bin/opm.js", "mcp"]
       }
     }
   }
   ```
   *(Note: Ensure paths use forward slashes `/` in the JSON).*

4. **Restart Antigravity Workspace**
   Reload your project. Antigravity will now automatically boot `opm mcp` via standard IO and hook up tools like `openmemory_store` and `openmemory_query`.

## Checking if it works
Simply ask Antigravity:
*"Remember my favorite color is Blue."*
Then in a new chat:
*"What was my favorite color?"*

If configured successfully, the core memory instructions from `SKILL.md` take over, prompting it to retrieve the fact!
