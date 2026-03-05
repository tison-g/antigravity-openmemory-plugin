# Antigravity OpenMemory 记忆插件

本插件通过集成 [OpenMemory](https://github.com/openmemory/openmemory)，为您的 Antigravity (Gemini Code Assistant) 提供强大的跨会话、持久化记忆能力。它包含自动化安装脚本，能够自动下载、构建 OpenMemory，并将 **Memory Management Skill** 链接到您的 Antigravity 工作目录。

## 功能特性
- **跨会话存储**：Gemini 将跨不同的聊天会话记住您的架构设计、编程偏好、遗留 Bug 和项目规则。
- **自动总结**：内置的 Skill 指令会引导 AI 在对话结束或关键节点自动压缩并保存核心信息，无需用户手动干预。
- **原生 MCP 支持**：配置为 Antigravity 官方支持的 MCP `stdio` 服务器模式——无需常驻后台 API 服务，随 Antigravity 启动自动运行。

## 前置要求
- Windows, macOS, 或 Linux 操作系统
- [Node.js](https://nodejs.org/) (v18+) 及 NPM
- Git
- 已安装并配置好 Antigravity 插件

## 安装步骤

1. **克隆本仓库** 到您系统的任意位置：
   ```bash
   git clone https://github.com/tison-g/antigravity-openmemory-plugin
   cd antigravity-openmemory-plugin
   ```

2. **运行安装脚本：**
   在您的 **Antigravity 目标项目根目录** 下运行对应的安装脚本。

   **Windows (PowerShell):**
   ```powershell
   & "C:\path\to\antigravity-openmemory-plugin\install.ps1"
   ```

   **Unix/macOS (Bash):**
   ```bash
   bash "/path/to/antigravity-openmemory-plugin/install.sh"
   ```
   *该脚本会自动完成：*
   - 下载 OpenMemory 子源码。
   - 安装 NPM 依赖并编译 TypeScript 代码。
   - 创建 `skills/memory-management` 软链接（Junction）到您当前项目的 `.agents/skills` 目录，让 AI 知道如何管理记忆。

3. **在 Antigravity 中配置 MCP 设置**
   打开您的全局 Antigravity MCP 配置文件（通常位于 `~/.gemini/antigravity/mcp_config.json`），并添加安装脚本输出的配置信息。示例如下：

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
   *(注意：JSON 中的路径请务必使用正斜杠 `/`)*

4. **重启 Antigravity**
   重新加载您的工作区。Antigravity 现在会自动启动 `opm mcp` 并加载 `openmemory_store` 和 `openmemory_query` 等工具。

## 如何验证是否生效？
尝试问 Antigravity：
*“请记住我最喜欢的颜色是蓝色。”*
然后在开启一个新对话问它：
*“我最喜欢的颜色是什么？”*

如果配置成功，AI 会根据 `SKILL.md` 的指示，不仅记住了这个事实，还会通过 `openmemory_query` 在需要时自动找回它。
