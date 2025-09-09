#!/usr/bin/env bash

update() {
	SSID=$(system_profiler SPAirPortDataType | awk '/Current Network Information:/ { getline; print substr($0, 13, (length($0) - 13)); exit }')
	IS_VPN=$(scutil --nwi | /etc/profiles/per-user/angaidan/bin/rg -m1 'utun' | awk '{ print $1 }')

	if [[ $IS_VPN != "" ]]; then
		ICON=􀤆
		LABEL="VPN"
	elif [[ $SSID != "" ]]; then
		ICON=􀙇
		LABEL="$SSID"
	else
		ICON=􀙈
		LABEL="Not Connected"
	fi

	sketchybar --set "$NAME" \
		icon=$ICON \
		label="$LABEL"
}

click() {
	CURRENT_WIDTH="$(sketchybar --query "$NAME" | jq -r .label.width)"

	WIDTH=0
	if [ "$CURRENT_WIDTH" -eq "0" ]; then
		WIDTH=dynamic
	fi

	sketchybar --animate sin 20 --set "$NAME" label.width="$WIDTH"
}

case "$SENDER" in
"wifi_change")
	update
	;;
"mouse.clicked")
	click
	;;
esac
