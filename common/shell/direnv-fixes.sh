# shellcheck shell=bash
# HACK: nix-direnv's use_flake exports all stdenv variables, including `name`,
#   into the interactive shell. When `name` contains hyphens (e.g. the mkShell
#   default "nix-shell-env"), gitstatus crashes because zsh parameter names
#   can't contain hyphens (_GITSTATUS_LOCK_FD_$name).
#   Only wraps use_flake; use_nix has the same leak but we don't use it.
#   Remove when nix-direnv filters `name` in _nix_import_env (nix-community/nix-direnv#278)
#   or NixOS/nix#7501 decouples nix develop from stdenv.
if declare -f use_flake >/dev/null 2>&1; then
	eval "$(declare -f use_flake | sed '1s/use_flake/__wrapped_use_flake/')"
	use_flake() {
		__wrapped_use_flake "$@"
		local rc=$?
		unset name
		return $rc
	}
fi
