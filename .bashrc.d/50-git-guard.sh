# Guard against a stray git repo at $HOME
# A repo at ~/.git makes $HOME its work tree, so `git status` shows the whole
# home directory as untracked and `git clean -xdf` would wipe it.
# Dotfiles live in the `dot` repo (~/.local/share/dot); never `git init` here.
if [ -d "$HOME/.git" ]; then
    printf '\n\033[31mWARNING:\033[0m ~/.git exists — $HOME is a git work tree again.\n'
    printf 'Never run: git clean -xdf\n'
    printf 'Inspect with `dot status`; remove the stray repo with: rm -rf ~/.git\n\n'
fi
