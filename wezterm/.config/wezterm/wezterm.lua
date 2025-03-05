local wezterm = require("wezterm")
local config = require("config")
require("events")

-- Apply color scheme based on the WEZTERM_THEME environment variable
local themes = {
	nord = "Nord (Gogh)",
	onedark = "One Dark (Gogh)",
}
local success, stdout, stderr = wezterm.run_child_process({ os.getenv("SHELL"), "-c", "printenv WEZTERM_THEME" })
local selected_theme = stdout:gsub("%s+", "") -- Remove all whitespace characters including newline
config.color_scheme = themes[selected_theme]

local opacity = 0.8

wezterm.on("window-focus-changed", function(window, pane)
	local overrides = window:get_config_overrides() or {}

	if window:is_focused() then
		overrides.window_background_opacity = 1
	else
		overrides.window_background_opacity = opacity
	end

	window:set_config_overrides(overrides)
end)

config.window_background_opacity = opacity
config.macos_window_background_blur = 30

return config
