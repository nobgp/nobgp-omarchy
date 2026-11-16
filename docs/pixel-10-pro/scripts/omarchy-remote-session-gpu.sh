#!/bin/bash
# Container entry for the GPU desktop (runs as droid inside systemd-nspawn).
# Headless labwc renders with GLES2 on zink -> gfxstream -> the Pixel's PowerVR GPU
# (Debian Mesa 25.0.7 copied to /opt/debian-mesa). Its autostart starts wayvnc on
# 127.0.0.1:5900 and Hyprland nested full-screen (omarchy-hypr-nested.sh).
export XDG_RUNTIME_DIR=/tmp/xdg-droid; rm -rf $XDG_RUNTIME_DIR; mkdir -p -m 700 $XDG_RUNTIME_DIR
mkdir -p /home/droid/shots
unset WAYLAND_DISPLAY DISPLAY
export TZ=America/Los_Angeles
. /opt/debian-mesa/env.sh
export WLR_BACKENDS=headless WLR_HEADLESS_OUTPUTS=1 WLR_LIBINPUT_NO_DEVICES=1 WLR_RENDER_DRM_DEVICE=/dev/dri/renderD128 WLR_RENDERER=gles2
exec dbus-run-session -- labwc -C /home/droid/.config/labwc-remote-gpu > /home/droid/shots/labwc.log 2>&1
