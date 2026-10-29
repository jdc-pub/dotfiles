# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# User variables
export EDITOR='vi'

# Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Starship prompt
if command -v "starship" >/dev/null; then
	eval "$(starship init bash)"
fi

# Use z over cd
if command -v "zoxide" >/dev/null; then
	eval "$(zoxide init bash)"
	alias cd=z
fi

# Use eza over ls
if command -v "eza" >/dev/null; then
	alias ls=eza
fi

# Use bat over cat
if command -v "bat" >/dev/null; then
	alias cat=bat
fi
