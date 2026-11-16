#!/bin/bash
# The status pane shown in the session: what is actually rendering it.
. /usr/share/omarchy/default/bash/rc 2>/dev/null
printf '\e[1;36mOmarchy on Pixel 10 Pro, viewed over noBGP\e[0m\n'
printf 'Omarchy %s + %s, Arch Linux ARM container\n' "$(grep -oP 'VERSION_ID="\K[^"]+' /etc/os-release)" "$(Hyprland --version 2>/dev/null | head -1 | awk '{print $1, $2}')"
if [[ -n $HYPRLAND_INSTANCE_SIGNATURE ]]; then
  printf 'Compositor: \e[1;32mHyprland\e[0m nested full-screen in headless labwc -> wayvnc -> noVNC\n'
else
  printf 'Compositor: labwc (headless) -> wayvnc -> noVNC\n'
fi
r=$(. /opt/debian-mesa/env.sh 2>/dev/null; eglinfo -B -p surfaceless 2>/dev/null | grep -m1 'OpenGL ES profile renderer' | sed 's/.*renderer: //')
printf 'GPU: \e[1m%s\e[0m\n' "${r:-unknown}"
printf '     (Mesa 25.0.7 zink -> gfxstream Vulkan -> Android host GPU)\n'
printf 'nobgp-omarchy: %s\n' "$(nobgp-omarchy version 2>/dev/null | head -1)"
