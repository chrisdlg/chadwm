#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/tundra

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)
  cpu_temp=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input)
  cpu_temp=$((cpu_temp / 1000))

  printf "^c$black^ ^b$green^  "
  printf "^c$white^ ^b$grey^ $cpu_val|$cpu_temp°C"
}

pkg_updates() {
  #updates=$({ timeout 20 doas xbps-install -un 2>/dev/null || true; } | wc -l) # void
  updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l) # arch
  # updates=$({ timeout 20 aptitude search '~U' 2>/dev/null || true; } | wc -l)  # apt (ubuntu, debian etc)

  if [ -z "$updates" ]; then
    printf "  ^c$green^ 󰚰 0"
  else
    printf "  ^c$green^ 󰚰 %s" "$updates"
  fi
}

mem() {
  printf "^c$blue^^b$black^  "
  printf "^c$blue^$(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
    case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
    up) 
        wifi_name=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d':' -f2)
        printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^$wifi_name" ;;
    down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Off" ;;
    esac
}

battery() {
  acpi_out=$(acpi -b 2>/dev/null | head -n1)
  bat_status=$(printf '%s' "$acpi_out" | cut -d',' -f1 | cut -d':' -f2 | tr -d ' ')
  bat_percent=$(printf '%s' "$acpi_out" | grep -oE '[0-9]+%' | head -n1)
  bat_time=$(printf '%s' "$acpi_out" | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}')

  case "$bat_status" in
    Charging)    bat_icon="󰂄" ;;
    Discharging) bat_icon="󰁹" ;;
    Full)        bat_icon="󰁹" ;;
    *)           bat_icon="󰁹" ;;
  esac

  bat_short_time=$(printf '%s' "$bat_time" | cut -d':' -f1,2)
  case "$bat_status" in
    Charging)    bat_sym="↑" ;;
    Discharging) bat_sym="↓" ;;
    *)           bat_sym="" ;;
  esac

  if [ -n "$bat_short_time" ] && [ "$bat_status" != "Full" ]; then
    printf "^c%s^ %s %s%s%s" "$blue" "$bat_icon" "$bat_percent" "$bat_sym" "$bat_short_time"
  else
    printf "^c%s^ %s %s" "$blue" "$bat_icon" "$bat_percent"
  fi
}

brightness() {
  printf "^c$red^ 󰃟 "
  printf "^c$red^%.0f\n" $(echo "$(xrandr --verbose | grep -i brightness | sed 's/.*Brightness: //')*100/1" | bc)
}

clock() {
	printf "^c$black^ ^b$darkblue^ 󱑆 "
  printf "^c$black^^b$blue^ %s" "$(date +'%a %d %B %H:%M')"
  printf "^b$black^"
}

volume_level() {
  vol_lvl=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -n 1)
	printf "^c$blue^^b$black^ 🔊"
  printf "^c%s^ %s%%" "$blue" "$vol_lvl"
}

power_menu() {
    printf "^c$red^ ⏻ ^d^"  # Added spaces before and after the icon
}

while true; do

  [ $interval = 30 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates)
  interval=$((interval + 1))

  sleep 1 && xsetroot -name "$updates $(battery) $(cpu) $(mem) $(wlan) $(brightness) $(volume_level) $(clock)"
done
