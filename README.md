# setup-scripts

Dotfiles that Ona applies to every environment.

- `install.sh`: run by Ona when it clones this repo. Adds shell aliases to `~/.bashrc`, and a fallback line that registers the MCP servers from the first interactive shell.
- `post-start-install.sh`: run by obsidian's `.devcontainer/lifecycle/post-start.sh` on every environment start, after the repository's own setup. Registers the MCP servers.
- `mcp-servers.sh`: registers Claude Code MCP servers (Slack, Granola) at user scope. Safe to rerun; logs to `~/.cache/dotfiles-mcp.log` and writes `~/.cache/dotfiles-mcp.done` once every server is registered.

After a new environment starts, run `/mcp` in Claude Code once per server to sign in. Sign-ins aren't carried between environments.

This repository is public: never commit tokens, keys or other secrets. Use Ona user secrets and refer to their environment variables instead.
