# Installed as /opt/debian-mesa/env.sh in the container. Source it to render with the Pixel GPU
# (zink -> gfxstream -> PowerVR) using the Debian Mesa copy instead of Arch's.
export LD_LIBRARY_PATH=/opt/debian-mesa/lib
export LIBGL_DRIVERS_PATH=/opt/debian-mesa/lib/dri GBM_BACKENDS_PATH=/opt/debian-mesa/lib/gbm
export VK_DRIVER_FILES=/opt/debian-mesa/icd.d/gfxstream_vk_icd.json VK_ICD_FILENAMES=/opt/debian-mesa/icd.d/gfxstream_vk_icd.json
export MESA_LOADER_DRIVER_OVERRIDE=zink MESA_VK_WSI_DEBUG=sw
# Mesa's VK_LAYER_MESA_device_select opens a Wayland connection to $WAYLAND_DISPLAY during vkEnumeratePhysicalDevices;
# inside Hyprland that is Hyprland's own (not yet serving) socket -> deadlock in gbm_create_device. Disable it.
export NODEVICE_SELECT=1 VK_LOADER_LAYERS_DISABLE='*device_select*'
