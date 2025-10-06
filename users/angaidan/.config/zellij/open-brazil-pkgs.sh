#!/usr/bin/env bash

set -eu
set -o pipefail

brazil_ws_info="$(brazil workspace show --format json)"
readarray -t brazil_packages < <(echo "$brazil_ws_info" | jq -c '.packages[]')

for package in "''${brazil_packages[@]}"; do
	name=$(echo "$package" | jq -r '.name')
	mv=$(echo "$package" | jq -r '.mv')
	source_location=$(echo "$package" | jq -r '.source_location')

	zellij action new-tab --name="$name-$mv" --cwd="$source_location" --layout="brazil_pkg"
done

zellij action go-to-tab 1 # Tab this script is run from
zellij action close-tab

exit 0
