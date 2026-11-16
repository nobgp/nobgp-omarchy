#!/bin/bash
# Real Hyprland with the normal Omarchy config, nested full-screen inside the headless labwc, on the Pixel GPU.
# Started by ~/.config/labwc-remote-gpu/autostart.
export OMARCHY_PATH=/usr/share/omarchy
# remote-bin first: the systemd-cat and omarchy-provision-first-run shims (see remote-bin/)
export PATH=/home/droid/.local/share/omarchy-remote/bin:/usr/share/omarchy/bin:/usr/local/bin:/usr/bin
export HYPRLAND_NO_RT=1 XDG_SESSION_TYPE=wayland XDG_CURRENT_DESKTOP=Hyprland TZ=America/Los_Angeles
. /opt/debian-mesa/env.sh
# No idle lock in an off-screen session: Omarchy's stay-awake indicator.
mkdir -p /home/droid/.local/state/omarchy/indicators && touch /home/droid/.local/state/omarchy/indicators/stay-awake
sleep 1
# aqflush.so flushes the parent Wayland connection before each event-loop wait (see aqflush/aqflush.c).
LD_PRELOAD=/opt/aqflush/aqflush.so exec Hyprland --config /home/droid/.config/hypr/remote.lua > /home/droid/shots/hyprland-remote.log 2>&1
