local wezterm = require("wezterm")

local M = {}

function M.init(config)
	config.window_decorations = "RESIZE"
	config.status_update_interval = 1000
	config.font_size = 16.0
	config.line_height = 1.2
	config.tab_max_width = 32
	config.switch_to_last_active_tab_when_closing_tab = true
	-- enable ligatures like in Fira Code font
	config.font = wezterm.font("Fira Code", {})
	config.color_scheme = "Catppuccin Macchiato"
	config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
	config.window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	}
	config.window_background_opacity = 0.8
	config.macos_window_background_blur = 20

	return config
end

return M
