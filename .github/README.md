# ⚈ `dot`

> [!NOTE]
> This file is computer generated!

Dotfiles tracked in place: a git dir at `~/.local/share/dot` with `$HOME` as
its work tree. No symlinks, no `~/.git`.

## Bootstrap

```sh
URL=https://github.com/jdc-pub/dotfiles.git
GD=$HOME/.local/share/dot

mkdir -p "${GD%/*}"
git clone --no-checkout --separate-git-dir="$GD" "$URL" /tmp/dot-stub
rm -rf /tmp/dot-stub

git --git-dir="$GD" config core.bare false
git --git-dir="$GD" config core.worktree "$HOME"
git --git-dir="$GD" config status.showUntrackedFiles no

git --git-dir="$GD" checkout -f # overwrites stock .bashrc and .bash_profile
```

Then open a new login shell so `~/.local/bin/dot` is on `PATH`.

## Usage

`dot` is `git` pointed at the repo above.

```sh
dot status
dot add -f ~/.config/foo/bar.toml
dot commit
dot push
```

Untracked files are hidden, so nothing is tracked until it is added.
