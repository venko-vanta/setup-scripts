#!/usr/bin/env bash
# Registers MCP servers for Claude Code at user scope. Safe to run repeatedly,
# and always exits 0 so it can never break environment startup. Results are
# logged to ~/.cache/dotfiles-mcp.log. Each server still needs a one-time
# `/mcp` sign-in per environment; no credentials belong in this repo.
set -u

caller="${1:-manual}"
log_file="$HOME/.cache/dotfiles-mcp.log"
done_marker="$HOME/.cache/dotfiles-mcp.done"
mkdir -p "$HOME/.cache"

log() {
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [$caller] $1" >>"$log_file"
}

# Startup shells may not have ~/.local/bin on PATH, so prefer the full path.
claude_bin="$HOME/.local/bin/claude"
if [[ ! -x "$claude_bin" ]]; then
  claude_bin="$(command -v claude || true)"
fi
if [[ -z "$claude_bin" ]]; then
  log "claude not found; skipping"
  exit 0
fi

failed=0
add_server() {
  local name="$1" url="$2" output
  if output="$(timeout 60 "$claude_bin" mcp add --scope user --transport http "$name" "$url" 2>&1)"; then
    log "added $name"
  elif [[ "$output" == *"already exists"* ]]; then
    log "$name already registered"
  else
    log "failed to add $name: $output"
    failed=1
  fi
}

# https://docs.slack.dev/ai/slack-mcp-server/connect-to-harnesses/
add_server slack https://mcp.slack.com/mcp
# https://docs.granola.ai/help-center/sharing/integrations/mcp
add_server granola https://mcp.granola.ai/mcp

if [[ "$failed" -eq 0 ]]; then
  touch "$done_marker"
fi
exit 0
