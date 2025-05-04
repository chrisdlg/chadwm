#!/bin/sh

xrdb merge ~/.Xresources 
xbacklight -set 10 &
feh --bg-fill ~/Pictures/wallpapersden.com_new-cool-swirl-4k-art_2880x1800.jpg &
xset r rate 200 50 &
picom &

# execute lock screen script
dash ~/.config/chadwm/scripts/lock-screen.sh &
# start bar update script
dash ~/.config/chadwm/scripts/bar.sh &

while type chadwm >/dev/null; do chadwm && continue || break; done
