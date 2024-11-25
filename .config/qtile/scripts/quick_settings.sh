#!/bin/bash

# Define icons and labels
VOLUME_ICON="󰕾"
BRIGHTNESS_ICON="󰃞"
WIFI_ICON="󰖩"
NIGHT_LIGHT_ICON="󰛨"
AIRPLANE_ICON="󰀝"
POWER_ICON="⏻"

# Function to get volume status
get_volume() {
    vol=$(pamixer --get-volume)
    muted=$(pamixer --get-mute)
    if [ "$muted" = "true" ]; then
        echo "$VOLUME_ICON Muted"
    else
        echo "$VOLUME_ICON Volume ($vol%)"
    fi
}

# Function to get brightness
get_brightness() {
    if command -v brightnessctl &> /dev/null; then
        bright=$(brightnessctl get)
        max=$(brightnessctl max)
        percent=$((bright * 100 / max))
        echo "$BRIGHTNESS_ICON Brightness ($percent%)"
    fi
}

# Function to get WiFi status
get_wifi() {
    if nmcli radio wifi | grep -q "enabled"; then
        WIFI_STATUS="On"
    else
        WIFI_STATUS="Off"
    fi
    echo "$WIFI_ICON WiFi ($WIFI_STATUS)"
}

# Function to get Night Light status
get_night_light() {
    if [ -f "/tmp/night_light_status" ] && [ "$(cat /tmp/night_light_status)" = "on" ]; then
        NL_STATUS="On"
    else
        NL_STATUS="Off"
    fi
    echo "$NIGHT_LIGHT_ICON Night Light ($NL_STATUS)"
}

# Function to get Airplane Mode status
get_airplane() {
    if nmcli radio all | grep -q "enabled"; then
        AP_STATUS="Off"
    else
        AP_STATUS="On"
    fi
    echo "$AIRPLANE_ICON Airplane Mode ($AP_STATUS)"
}

# Function to toggle volume mute
toggle_mute() {
    pamixer -t
}

# Function to toggle WiFi
toggle_wifi() {
    if nmcli radio wifi | grep -q "enabled"; then
        nmcli radio wifi off
    else
        nmcli radio wifi on
    fi
}

# Function to toggle Night Light
toggle_night_light() {
    if [ -f "/tmp/night_light_status" ] && [ "$(cat /tmp/night_light_status)" = "on" ]; then
        redshift -x
        echo "off" > /tmp/night_light_status
    else
        redshift -P -O 4500
        echo "on" > /tmp/night_light_status
    fi
}

# Function to toggle Airplane Mode
toggle_airplane() {
    if nmcli radio all | grep -q "enabled"; then
        nmcli radio all off
    else
        nmcli radio all on
    fi
}

# Create menu
menu="$(get_volume)\n$(get_brightness)\n$(get_wifi)\n$(get_night_light)\n$(get_airplane)\n$POWER_ICON Power Menu"

# Show rofi menu
chosen="$(echo -e "$menu" | rofi -dmenu -i -p "Quick Settings" -theme ~/.config/rofi/quick_settings.rasi)"

# Handle selection
case $chosen in
    *"Volume"*)
        toggle_mute
        ;;
    *"Brightness"*)
        brightnessctl set 10%+ # Increase brightness by 10%
        ;;
    *"WiFi"*)
        toggle_wifi
        ;;
    *"Night Light"*)
        toggle_night_light
        ;;
    *"Airplane Mode"*)
        toggle_airplane
        ;;
    *"Power Menu"*)
        ~/.config/rofi/powermenu.sh
        ;;
esac
