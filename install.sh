#!/usr/bin/env bash
set -e

# Aliases block (edit these lines to your liking)
read -r -d '' ALIAS_BLOCK <<'EOF'
# -- custom aliases from dotfiles --
alias ll='ls -lah'
alias gst='git status'
alias gc='git commit -v'
alias gp='git push'
alias gd='git diff'
# -- end custom aliases --
EOF

BASHRC="$HOME/.bashrc"

# Backup existing ~/.bashrc if not already backed up
if [ ! -f "${HOME}/.bashrc.before-dotfiles" ]; then
  cp "${BASHRC}" "${HOME}/.bashrc.before-dotfiles" || true
#!/usr/bin/env bash
set -e

# Aliases block (edit these lines to your liking)
read -r -d '' ALIAS_BLOCK <<'EOF'
# -- custom aliases from dotfiles --
alias ll='ls -lah'
alias gst='git status'
alias gc='git commit -v'
alias gp='git push'
alias gd='git diff'
# -- end custom aliases --
EOF

BASHRC="$HOME/.bashrc"

# Backup existing ~/.bashrc if not already backed up
if [ ! -f "${HOME}/.bashrc.before-dotfiles" ]; then
  cp "${BASHRC}" "${HOME}/.bashrc.before-dotfiles" || true
fi

# Check if the alias block is already in ~/.bashrc
if grep -F "# -- custom aliases from dotfiles --" "${BASHRC}" >/dev/null 2>&1; then
  echo "Alias block already present in ${BASHRC}. Skipping append."
else
  echo "" >> "${BASHRC}"
  echo "${ALIAS_BLOCK}" >> "${BASHRC}"
  echo "Appended custom aliases into ${BASHRC}."
fi

