# Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
case ":${PATH}:" in
    *:"${HOME}/.cargo/bin":*)
	;;
    *)
	export PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}"
	;;
esac
