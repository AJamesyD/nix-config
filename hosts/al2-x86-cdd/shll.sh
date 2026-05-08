# shellcheck shell=bash
# shellcheck disable=SC2016
# shpool session selector
# keybindings:
#     k/x to kill
#     a/n/enter to attach
# Shortcut: ctrl+a then w
shpool_choose() {
	cmd_output=$(
		shpool list | tail -n +2 | cut -f1 | fzf \
			--bind 'k:execute(shpool kill {})' \
			--bind 'x:execute(shpool kill {})' \
			--bind 'a:execute(shpool attach --force {})' \
			--bind 'n:execute(shpool attach --force {})' \
			--preview 'shpool list | tail -n +2 | sed -n "$(({n}+1))"p' \
			--bind "change:reload(shpool list | tail -n +2)" \
			--reverse \
			--height=~100% \
			--preview-window down:wrap \
			--header "Shpool sessions" \
			--no-select-1 \
			--no-exit-0
	)

	# notify-send "$cmd_output"
	[ -n "$cmd_output" ] && shpool attach --force "$cmd_output"
}

shpool_choose
