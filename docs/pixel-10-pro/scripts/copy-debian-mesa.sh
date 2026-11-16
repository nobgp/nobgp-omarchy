#!/bin/bash
# Run as root in the Debian VM (not the container). Copies the VM's own Mesa 25.0.7 stack
# into the container under /opt/debian-mesa. Undo: rm -rf /var/lib/machines/omarchy/opt/debian-mesa
# The libraries come from the Terminal image's libegl-mesa0, libgbm1, libgl1-mesa-dri,
# mesa-libgallium, mesa-vulkan-drivers, libllvm19, libz3-4, libxml2 and libedit2.
set -euo pipefail
R=${R:-/var/lib/machines/omarchy}
L=/usr/lib/aarch64-linux-gnu
D=$R/opt/debian-mesa
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p $D/lib/dri $D/lib/gbm $D/icd.d
cp -aL $L/libEGL_mesa.so.0 $L/libgbm.so.1 $L/libgallium-25.0.7-2+deb13u1.so $L/libLLVM.so.19.1 \
       $L/libz3.so.4 $L/libxml2.so.2 $L/libedit.so.2 $L/libvulkan_gfxstream.so $D/lib/
# Any further library these need that the container doesn't already have
for f in $L/libxml2.so.2 $L/libz3.so.4 $L/libedit.so.2 $L/libLLVM.so.19.1; do
  for dep in $(ldd $f | awk '/=>/{print $3}'); do
    b=$(basename $dep)
    [ -e $R/usr/lib/$b ] || [ -e $D/lib/$b ] || { cp -aL $dep $D/lib/; echo "extra dep: $b"; }
  done
done
cp -a $L/dri/libdril_dri.so $D/lib/dri/ && ln -sf libdril_dri.so $D/lib/dri/zink_dri.so
cp -aL $L/gbm/dri_gbm.so $D/lib/gbm/
echo '{"file_format_version":"1.0.1","ICD":{"api_version":"1.1.305","library_path":"/opt/debian-mesa/lib/libvulkan_gfxstream.so"}}' > $D/icd.d/gfxstream_vk_icd.json
install -m 644 "$HERE/debian-mesa/env.sh" $D/env.sh
du -sh $D
