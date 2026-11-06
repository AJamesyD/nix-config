#!/usr/bin/env bash
# Evaluate every host configuration's top-level derivation without building it.
#
# NOTE: evaluation is platform-independent but building is not. This validates
#   the Linux home configs from a Mac (and the darwin config from Linux) and
#   catches the eval-error class (infinite recursion, undefined options, bad
#   references) before a push. Actual per-platform builds stay in CI.
#
# NOTE: positional args are forwarded to `nix eval`. Pass
#   `--override-input amzn-community path:./ci/stub-amzn-community` when the real
#   input is unreachable (build.yml passes it to nix-fast-build for the same reason).
#
# NOTE: evaluates the working tree (`.#`), not the exact commits being pushed, so
#   commit or stash before trusting the result.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

extra=("$@")

status=0

check() {
	local label=$1 output=$2 drv=$3
	echo "==> $label"
	# NOTE: --apply forces each config's drvPath in a single eval, so one
	#   invocation covers every host of this type across platforms. IFD is
	#   disabled so a config that imports a derivation fails as a clear eval error
	#   instead of silently triggering a cross-platform build.
	if nix eval --raw --no-warn-dirty --option allow-import-from-derivation false \
		".#${output}" ${extra[@]+"${extra[@]}"} \
		--apply "cs: builtins.concatStringsSep \"\n\" (map (c: c.${drv}) (builtins.attrValues cs))"; then
		echo
	else
		echo "FAILED to evaluate ${output}" >&2
		status=1
	fi
}

check "home-manager hosts" homeConfigurations "activationPackage.drvPath"
check "nix-darwin hosts" darwinConfigurations "config.system.build.toplevel.drvPath"

exit "$status"
