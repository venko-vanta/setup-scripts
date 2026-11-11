#!/usr/bin/env bash
set -e

BASHRC="$HOME/.bashrc"

# `read -d ''` returns 1 at the end of a heredoc, which `set -e` would treat
# as a failure, so this file builds its blocks with `cat` instead.
ALIAS_BLOCK="$(cat <<'EOF'
# -- custom aliases from dotfiles --
alias ll='ls -lah'
alias gb='git branch'
alias gc='git checkout'
alias gp='git pull'
alias gl='git log'
alias gprom='git pull --rebase origin main'
# -- end custom aliases --
EOF
)"

# Fallback for the post-start hook: registers the MCP servers in the background
# from the first interactive shell, until a run succeeds.
MCP_BLOCK="$(cat <<'EOF'
# -- dotfiles MCP setup --
[ -f "$HOME/.cache/dotfiles-mcp.done" ] || ("$HOME/dotfiles/mcp-servers.sh" bashrc &)
# -- end dotfiles MCP setup --
EOF
)"

# Backup existing ~/.bashrc if not already backed up
if [ ! -f "${HOME}/.bashrc.before-dotfiles" ]; then
  cp "${BASHRC}" "${HOME}/.bashrc.before-dotfiles" || true
fi

append_block() {
  local marker="$1" block="$2"
  if grep -F "$marker" "${BASHRC}" >/dev/null 2>&1; then
    echo "${marker} already present in ${BASHRC}. Skipping append."
  else
    printf '\n%s\n' "$block" >>"${BASHRC}"
    echo "Appended ${marker} into ${BASHRC}."
  fi
}

append_block "# -- custom aliases from dotfiles --" "$ALIAS_BLOCK"
append_block "# -- dotfiles MCP setup --" "$MCP_BLOCK"
