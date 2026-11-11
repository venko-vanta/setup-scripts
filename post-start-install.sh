#!/usr/bin/env bash
# Run by obsidian's .devcontainer/lifecycle/post-start.sh on every environment
# start, after the repository's own setup.
"$(dirname "$0")/mcp-servers.sh" post-start
