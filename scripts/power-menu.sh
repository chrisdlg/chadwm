#!/bin/dash

options="⏻ Shutdown\n⭮ Restart\n⏾ Suspend\n⇠ Logout\n⟳ Update & Shutdown\n⟳ Update & Restart"

selected=$(echo "$options" | rofi -dmenu -i -p "Power Menu")

case $selected in
    "⏻ Shutdown")
        systemctl poweroff
        ;;
    "⭮ Restart")
        systemctl reboot
        ;;
    "⏾ Suspend")
        systemctl suspend
        ;;
    "⇠ Logout")
        killall bar.sh chadwm
        ;;
    "⟳ Update & Shutdown")
        # Check which package manager is available
        kitty bash -c "paru -Syu --noconfirm && systemctl poweroff"
        ;;
    "⟳ Update & Restart")
        # Check which package manager is available
        kitty bash -c "paru -Syu --noconfirm && systemctl reboot"
        ;;
esac
