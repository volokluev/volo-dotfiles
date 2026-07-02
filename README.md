# dotfiles

Codespaces dotfiles for installing:

- fzf, with shell integration for Bash and Zsh
- Neovim, using the latest stable prebuilt Linux archive when needed
- LazyVim, using the tracked config in `.config/nvim`

GitHub Codespaces runs `install.sh` automatically when this repository is selected as your dotfiles repository.

## Use with GitHub Codespaces

1. Push this repository to GitHub.
2. Open GitHub Settings -> Codespaces.
3. Under Dotfiles, enable automatic installation and select this repository.
4. Create a new codespace.

Changes here apply to new codespaces only.

## Run manually

```sh
./install.sh
```

The installer is safe to rerun. If an existing Neovim config or state directory is present and is not already linked to this repository, it is moved to a timestamped `.bak.YYYYMMDDHHMMSS` path before `.config/nvim` is linked into place.
