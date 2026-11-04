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
case ":${PATH}:" in
    *:"${HOME}/.cargo/bin":*)
	;;
    *)
	export PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}"
	;;
esac

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

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:"${HOME}/.juliaup/bin":*)
        ;;

    *)
        export PATH="${HOME}/.juliaup/bin"${PATH:+:${PATH}}
        ;;
esac
# Tab completion for juliaup and julia channel selection
[ -f "${HOME}/.julia/juliaup/completions/bash.sh" ] && source "${HOME}/.julia/juliaup/completions/bash.sh"

# Added by flyctl installer
export FLYCTL_INSTALL="/var/home/joey/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
