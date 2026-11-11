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

install_plugin() {
  local plugin="$1" marketplace="$2" marketplace_source="$3" output
  if ! output="$(timeout 120 "$claude_bin" plugin marketplace add "$marketplace_source" 2>&1)"; then
    log "failed to add marketplace $marketplace: $output"
    failed=1
    return
  fi
  if output="$(timeout 180 "$claude_bin" plugin install "$plugin@$marketplace" --scope user 2>&1)"; then
    log "installed or kept plugin $plugin@$marketplace"
  else
    log "failed to install plugin $plugin@$marketplace: $output"
    failed=1
  fi
}

# Slack's MCP server rejects clients that register themselves, so it is set up
# through Slack's plugin, which carries their OAuth client ID.
# https://docs.slack.dev/ai/slack-mcp-server/connect-to-harnesses/
install_plugin slack claude-plugins-official anthropics/claude-plugins-official
# A plain `slack` server from earlier versions of this script can't sign in.
if timeout 60 "$claude_bin" mcp remove --scope user slack >/dev/null 2>&1; then
  log "removed the plain slack server"
fi
# https://docs.granola.ai/help-center/sharing/integrations/mcp
add_server granola https://mcp.granola.ai/mcp

if [[ "$failed" -eq 0 ]]; then
  touch "$done_marker"
fi
exit 0
