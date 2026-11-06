# Use z over cd
if command -v "zoxide" >/dev/null; then
	eval "$(zoxide init bash)"
	alias cd=z
fi
