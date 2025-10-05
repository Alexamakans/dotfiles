#!/usr/bin/env bash
set -euo pipefail

bold()  { printf "\e[1m%s\e[0m\n" "$*"; }
note()  { printf "🛈  %s\n" "$*"; }
warn()  { printf "\e[33m⚠ %s\e[0m\n" "$*"; }
err()   { printf "\e[31m✖ %s\e[0m\n" "$*" >&2; }
ok()    { printf "\e[32m✔ %s\e[0m\n" "$*"; }

ask_yes_no() {
  local prompt="${1:-Proceed?} [Y/n] "
  read -r -p "$prompt" ans || true
  case "${ans:-Y}" in [Yy]* ) return 0 ;; * ) return 1 ;; esac
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

USER_NAME="$(whoami)"
HOST_NAME="$(hostname)"

bold "NixOS first-time setup"
note "Repo: $REPO_ROOT"
note "User: $USER_NAME"
note "Host: $HOST_NAME"

# Paths
FILES_DIR_REL="files"                            # dotfiles live here (relative to repo root)
FILES_DIR_ABS="$REPO_ROOT/$FILES_DIR_REL"
HOST_DIR="$REPO_ROOT/hosts/$HOST_NAME"
USER_DIR="$REPO_ROOT/home/$USER_NAME"
TEMPLATE_HOME="$REPO_ROOT/home/template/home.nix"
TEMPLATE_CONF="$REPO_ROOT/hosts/template/configuration.nix"
REPO_FLAKE="$REPO_ROOT/flake.nix"

# Sanity checks
[[ -f "$REPO_FLAKE" ]] || { err "flake.nix not found in repo root. Aborting."; exit 1; }
[[ -d "$FILES_DIR_ABS" ]] || { err "Expected dotfiles directory: $FILES_DIR_ABS"; exit 1; }
[[ -f "$TEMPLATE_HOME" ]] || { err "Missing template: $TEMPLATE_HOME"; exit 1; }
[[ -f "$TEMPLATE_CONF" ]] || { err "Missing template: $TEMPLATE_CONF"; exit 1; }

# Create / confirm directories
for d in "$HOST_DIR" "$USER_DIR"; do
  if [[ -e "$d" ]]; then
    warn "Path exists: $d"
    ask_yes_no "Continue and keep existing contents?" || { err "Aborted."; exit 1; }
  else
    mkdir -p "$d"
    ok "Created $d"
  fi
done

# Copy templates with placeholder substitution
copy_with_subst () {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then
    warn "Exists: $dst"
    ask_yes_no "Overwrite $dst?" || { note "Keeping existing $dst"; return 0; }
  fi
  cp "$src" "$dst"
  # Substitute placeholders; __DOT__ is where you reference your dotfiles from home.nix
  sed -i "s|__USER__|$USER_NAME|g" "$dst"
  sed -i "s|__HOST__|$HOST_NAME|g" "$dst"
  sed -i "s|__DOT__|../../$FILES_DIR_REL|g" "$dst"
  ok "Wrote $dst"
}

copy_with_subst "$TEMPLATE_HOME" "$USER_DIR/home.nix"
copy_with_subst "$TEMPLATE_CONF" "$HOST_DIR/configuration.nix"

# Hardware configuration handling
ETC_HW="/etc/nixos/hardware-configuration.nix"
REPO_HW="$HOST_DIR/hardware-configuration.nix"

if [[ -e "$REPO_HW" ]]; then
  note "hardware-configuration.nix already present in repo: $REPO_HW"
else
  if [[ -f "$ETC_HW" ]]; then
    note "Found $ETC_HW"
    if ask_yes_no "Copy hardware-configuration.nix into the repo"; then
      sudo cp "$ETC_HW" "$REPO_HW"
      sudo chown "$USER_NAME":"$USER_NAME" "$REPO_HW" || true
      ok "Copied to $REPO_HW"
    else
      note "Will import hardware config from /etc instead of repo."
      sed -i 's#\./hardware-configuration\.nix#/etc/nixos/hardware-configuration.nix#g' "$HOST_DIR/configuration.nix"
      if ! grep -q "hosts/$HOST_NAME/hardware-configuration.nix" "$REPO_ROOT/.gitignore" 2>/dev/null; then
        echo "hosts/$HOST_NAME/hardware-configuration.nix" >> "$REPO_ROOT/.gitignore"
      fi
      ok "Configured to import /etc/nixos/hardware-configuration.nix"
    fi
  else
    warn "No $ETC_HW found. If this is a fresh system, generate it with:"
    warn "  sudo nixos-generate-config"
  fi
fi

arch=$(uname -m)
os=$(uname -s)
mysystem='unknown'
case "$arch,$os" in
	x86_64,Linux) mysystem='x86_64-linux' ;;
	aarch64,Linux) mysystem='aarch64-linux' ;;
	x86_64,Darwin) mysystem='x86_64-darwin' ;;
	arm64,Darwin) mysystem='aarch64-darwin' ;;
esac

# Print instructions for flake.nix
bold "Next steps for flake.nix"
cat <<INSTR

Edit $REPO_FLAKE and ensure you have:

1) A nixosConfigurations entry for this host:

     nixosConfigurations = {
       # [...]

       # Add this
       # $(hostname) = mkHost {
       #   host = "$(hostname)";
       #   users = "$(whoami)";
       #   system = "$(echo "$mysystem")";
       # };
     };

2) Then build & switch:

   sudo nixos-rebuild switch --flake "$REPO_ROOT#$HOST_NAME" \\
     --option experimental-features "nix-command flakes"

INSTR

ok "Setup complete."
