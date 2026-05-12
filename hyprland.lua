-- Hyprland 0.55+ Lua config.
-- See https://wiki.hypr.land/Configuring/Start/

local terminal = "kitty"
local fileManager = "thunar"
local mainMod = "SUPER"

hl.monitor({
  output = "DP-1",
  mode = "1920x1080@165",
  position = "0x0",
  scale = 1,
})

hl.config({
  input = {
    kb_layout = "fr",
  },
})

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

hl.on("hyprland.start", function()
  hl.exec_cmd("quickshell")
end)

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
