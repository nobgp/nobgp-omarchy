#!/bin/bash
# Container entry (as droid): headless labwc (wlroots 0.20: wl_compositor v6 + xdg_wm_base v6)
# -> Omarchy's Hyprland nested as its only window -> wayvnc on 127.0.0.1:5900.
export XDG_RUNTIME_DIR=/tmp/xdg-droid; rm -rf $XDG_RUNTIME_DIR; mkdir -p -m 700 $XDG_RUNTIME_DIR
mkdir -p /home/droid/shots
unset WAYLAND_DISPLAY DISPLAY
# Container Mesa 26 cannot open a virgl context on this host ("No virgl contexts available on host"),
# so rendering is llvmpipe on the CPU; the render node is still used for GBM buffers.
export WLR_RENDERER_ALLOW_SOFTWARE=1 WLR_BACKENDS=headless WLR_HEADLESS_OUTPUTS=1 WLR_LIBINPUT_NO_DEVICES=1 WLR_RENDER_DRM_DEVICE=/dev/dri/renderD128
exec dbus-run-session -- labwc -C /home/droid/.config/labwc-remote > /home/droid/shots/labwc.log 2>&1
