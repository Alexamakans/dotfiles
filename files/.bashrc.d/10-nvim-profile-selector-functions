# --- Neovim profile launcher (fzf required for picker) ------------------------
# Put this in your ~/.bashrc.d/ or equivalent.

# List profiles from ~/.config/nvim* with base ("nvim") last. Always include base.
_nv_list_profiles() {
  local -a items=() others=() base=()
  local d name
  for d in "$HOME/.config"/nvim*; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    if [[ "$name" == "nvim" ]]; then base=("nvim"); else others+=("$name"); fi
  done
  if ((${#others[@]})); then
    mapfile -t others < <(printf '%s\n' "${others[@]}" | sort -u)
  fi
  items=("${others[@]}")
  # ensure base option even if ~/.config/nvim doesn't exist
  items+=("nvim")
  printf '%s\n' "${items[@]}"
}

# Read first non-empty line from .nvim-profile by walking up parents.
# Returns:
#   0 with "--clean" or profile name on stdout
#   1 if no file found up to /
#   non-zero if a .nvim-profile exists but is unreadable (error)
_nv_read_local_profile() {
  local dir line f
  # Use physical path (no symlinks) to avoid weird parent traversals
  dir="$(pwd -P)"

  while :; do
    f="$dir/.nvim-profile"

    if [[ -e "$f" ]]; then
      # Found a candidate; require it to be a regular, readable file
      [[ -f "$f" && -r "$f" ]] || return 2

      while IFS= read -r line || [[ -n "$line" ]]; do
        # Trim CR (for CRLF), then trim leading/trailing whitespace
        line="${line%$'\r'}"
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"
        [[ -n "$line" ]] || continue

        if [[ "$line" == "clean" || "$line" == "--clean" ]]; then
          printf '%s\n' "--clean"
        else
          printf '%s\n' "$line"
        fi
        return 0
      done < "$f"

      # File existed but had no non-empty lines
      return 2
    fi

    # Stop at filesystem root
    [[ "$dir" == "/" ]] && return 1
    dir="$(dirname -- "$dir")" || return 2
  done
}

# Marker-based guess: add/adjust to match your profile names
_nv_guess_profile_from_markers() {
  local dir=${1:-$PWD}
  # map: suffix -> space-separated markers (files/dirs)
  declare -A markers=(
    [python]="pyproject.toml requirements.txt Pipfile poetry.lock uv.lock .venv venv"
    [golang]="go.mod go.sum"
    [rust]="Cargo.toml"
    [node]="package.json pnpm-lock.yaml yarn.lock"
    [ruby]="Gemfile"
    [php]="composer.json"
  )
  local suf f
  for suf in "${!markers[@]}"; do
    for f in ${markers[$suf]}; do
      if [[ -e "$dir/$f" && -d "$HOME/.config/nvim-$suf" ]]; then
        printf 'nvim-%s\n' "$suf"
        return 0
      fi
    done
  done
  return 1
}

# fzf picker (fzf required). base appears at bottom thanks to _nv_list_profiles.
_nv_pick_profile_fzf() {
  command -v fzf >/dev/null 2>&1 || {
    echo "[nvim-profile] fzf is required for the interactive picker." >&2
    echo "Install fzf (e.g., 'sudo apt install fzf' or 'sudo dnf install fzf' or 'brew install fzf')," >&2
    echo "or create a .nvim-profile file with the desired NVIM_APPNAME." >&2
    return 1
  }
  local sel
  sel="$(_nv_list_profiles | fzf --prompt="Pick NVIM profile > " --height=40% --reverse --border)"
  case $? in
    0)   printf '%s\n' "$sel"; return 0 ;;   # picked a profile
    1)   return 1 ;;                         # ESC / no selection
    130) return 130 ;;                       # Ctrl+C (SIGINT)
    *)   return 1 ;;
  esac
}

# Decide profile: .nvim-profile -> markers -> picker -> fail
_nv_determine_profile() {
  local p
  if p=$(_nv_read_local_profile); then
    echo "$p"; return 0
  fi
  if p=$(_nv_guess_profile_from_markers "$PWD"); then
    echo "$p"; return 0
  fi
  if p=$(_nv_pick_profile_fzf); then
    echo "$p"; return 0
  fi
  return 1
}

# Run nvim with the chosen profile
_nv_run() {
  local -a args=("$@")
  local profile
  local rc
  profile=$(_nv_determine_profile); rc=$?
  (( rc == 0)) || return "$rc"

  if [[ "$profile" == "--clean" ]]; then
    command nvim --clean "${args[@]}"
  elif [[ "$profile" == "nvim" ]]; then
    command nvim "${args[@]}"
  else
    NVIM_APPNAME="$profile" command nvim "${args[@]}"
  fi
}

# Public entry points:
# nt -> open current dir when no args
nt() {
  if [[ $# -eq 0 ]]; then
    _nv_run .
  else
    _nv_run "$@"
  fi
}

alias n=nt
