-- omarchy-remote: the normal Omarchy config + what a nested, VNC-viewed session needs.
dofile(os.getenv("HOME") .. "/.config/hypr/hyprland.lua")
-- aquamarine's wayland output has no preferred mode -> give it one explicitly (matches labwc's 1280x720 headless output)
hl.monitor({ output = "WAYLAND-1", mode = "1280x720@60", position = "0x0", scale = 1 })
-- VNC adds latency between key press/release; 250ms default repeat caused doubled letters
hl.config({ input = { repeat_delay = 600, repeat_rate = 25 } })
hl.on("hyprland.start", function()
  hl.exec_cmd("foot --app-id=omarchy-status -o 'font=JetBrainsMono Nerd Font:size=10' bash -lc 'fastfetch; /home/droid/omarchy-remote-status.sh; exec bash -l'")
end)
