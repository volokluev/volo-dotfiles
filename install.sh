#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
LOCAL_OPT="$HOME/.local/opt"
NVIM_MIN_VERSION="0.9.0"

log() {
  printf '\n==> %s\n' "$*"
}

warn() {
  printf '\n!! %s\n' "$*" >&2
}

run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

sudo_run() {
  if [ "$(id -u)" -eq 0 ]; then
    run "$@"
  elif command -v sudo >/dev/null 2>&1; then
    run sudo "$@"
  else
    warn "sudo is not available; skipping privileged command: $*"
    return 1
  fi
}

ensure_local_bin() {
  run mkdir -p "$LOCAL_BIN" "$LOCAL_OPT"
}

append_shell_block() {
  local rc_file="$1"
  local marker="dotfiles-codespaces"

  run touch "$rc_file"

  if grep -q "BEGIN $marker" "$rc_file"; then
    log "Shell setup already present in $rc_file"
    return
  fi

  log "Adding shell setup to $rc_file"
  {
    printf '\n# BEGIN %s\n' "$marker"
    printf 'export PATH="$HOME/.local/bin:$PATH"\n'
    printf '\n'
    printf 'if command -v fzf >/dev/null 2>&1; then\n'
    printf '  if [ -n "${BASH_VERSION:-}" ]; then\n'
    printf '    if fzf --bash >/dev/null 2>&1; then\n'
    printf '      eval "$(fzf --bash)"\n'
    printf '    else\n'
    printf '      [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash\n'
    printf '      [ -f /usr/share/doc/fzf/examples/completion.bash ] && source /usr/share/doc/fzf/examples/completion.bash\n'
    printf '    fi\n'
    printf '  elif [ -n "${ZSH_VERSION:-}" ]; then\n'
    printf '    if fzf --zsh >/dev/null 2>&1; then\n'
    printf '      source <(fzf --zsh)\n'
    printf '    else\n'
    printf '      [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh\n'
    printf '      [ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh\n'
    printf '    fi\n'
    printf '  fi\n'
    printf 'fi\n'
    printf '# END %s\n' "$marker"
  } >>"$rc_file"
}

setup_shell() {
  append_shell_block "$HOME/.bashrc"
  append_shell_block "$HOME/.zshrc"
}

install_packages() {
  log "Installing command-line dependencies"

  if command -v apt-get >/dev/null 2>&1; then
    sudo_run apt-get update
    sudo_run env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      fd-find \
      fzf \
      git \
      ripgrep \
      tar \
      unzip
  elif command -v dnf >/dev/null 2>&1; then
    sudo_run dnf install -y \
      ca-certificates \
      curl \
      fd-find \
      fzf \
      gcc \
      gcc-c++ \
      git \
      make \
      ripgrep \
      tar \
      unzip
  elif command -v brew >/dev/null 2>&1; then
    run brew install curl fd fzf git neovim ripgrep unzip
  else
    warn "No supported package manager found. Install git, curl, fzf, ripgrep, fd, and unzip manually."
  fi

  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    log "Linking fd-find as fd"
    run ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"
  fi
}

version_at_least() {
  local current="$1"
  local minimum="$2"
  local current_parts minimum_parts index current_part minimum_part

  current="${current%%[-+]*}"
  minimum="${minimum%%[-+]*}"

  IFS=. read -r -a current_parts <<<"$current"
  IFS=. read -r -a minimum_parts <<<"$minimum"

  for index in 0 1 2; do
    current_part="${current_parts[$index]:-0}"
    minimum_part="${minimum_parts[$index]:-0}"

    if ((10#$current_part > 10#$minimum_part)); then
      return 0
    fi

    if ((10#$current_part < 10#$minimum_part)); then
      return 1
    fi
  done

  return 0
}

current_nvim_version() {
  if ! command -v nvim >/dev/null 2>&1; then
    return 1
  fi

  nvim --version | sed -n 's/^NVIM v\([0-9][0-9.]*\).*/\1/p' | head -n1
}

install_neovim() {
  local current_version=""
  current_version="$(current_nvim_version || true)"

  if [ -n "$current_version" ] && version_at_least "$current_version" "$NVIM_MIN_VERSION"; then
    log "Neovim $current_version is already installed"
    return
  fi

  if [ "$(uname -s)" != "Linux" ]; then
    warn "Neovim $NVIM_MIN_VERSION or newer is required. Install it with your system package manager."
    return 1
  fi

  local arch package archive tmpdir
  arch="$(uname -m)"

  case "$arch" in
    x86_64 | amd64)
      package="nvim-linux-x86_64"
      ;;
    aarch64 | arm64)
      package="nvim-linux-arm64"
      ;;
    *)
      warn "Unsupported architecture for Neovim prebuilt archive: $arch"
      return 1
      ;;
  esac

  if [ -x "$LOCAL_OPT/$package/bin/nvim" ]; then
    log "Using Neovim from $LOCAL_OPT/$package"
    run ln -sf "$LOCAL_OPT/$package/bin/nvim" "$LOCAL_BIN/nvim"
    return
  fi

  log "Installing latest stable Neovim"
  tmpdir="$(mktemp -d)"
  archive="$tmpdir/$package.tar.gz"

  run curl -fsSL -o "$archive" "https://github.com/neovim/neovim/releases/latest/download/$package.tar.gz"
  run rm -rf "$LOCAL_OPT/$package"
  run tar -xzf "$archive" -C "$LOCAL_OPT"
  run ln -sf "$LOCAL_OPT/$package/bin/nvim" "$LOCAL_BIN/nvim"
  run rm -rf "$tmpdir"
}

backup_path() {
  local path="$1"
  local backup="$path.bak.$(date +%Y%m%d%H%M%S)"

  log "Backing up $path to $backup"
  run mv "$path" "$backup"
}

is_lazyvim_config() {
  local nvim_config="$1"

  [ -f "$nvim_config/lua/config/lazy.lua" ] && grep -q 'LazyVim/LazyVim' "$nvim_config/lua/config/lazy.lua"
}

install_lazyvim() {
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
  local cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
  local nvim_config="$config_home/nvim"

  if is_lazyvim_config "$nvim_config"; then
    log "LazyVim is already installed at $nvim_config"
    return
  fi

  log "Installing LazyVim starter"

  if [ -e "$nvim_config" ]; then
    backup_path "$nvim_config"
  fi

  for path in "$data_home/nvim" "$state_home/nvim" "$cache_home/nvim"; do
    if [ -e "$path" ]; then
      backup_path "$path"
    fi
  done

  run mkdir -p "$config_home"
  run git clone https://github.com/LazyVim/starter "$nvim_config"
  run rm -rf "$nvim_config/.git"
}

main() {
  log "Setting up dotfiles from $DOTFILES_DIR"
  ensure_local_bin
  install_packages
  install_neovim
  setup_shell
  install_lazyvim

  log "Done. Open a new shell, then run nvim. Inside Neovim, run :LazyHealth after plugins finish installing."
}

main "$@"
