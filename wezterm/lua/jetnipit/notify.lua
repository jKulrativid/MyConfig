local wezterm = require("wezterm")

local M = {}

function M.Sent(window, message, ms)
	window:set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = "#c0c0c0" } },
		{ Text = message .. " " },
	}))
	wezterm.time.call_after(ms / 100, function()
		window:set_right_status(wezterm.format({
			{ Text = "" },
		}))
	end)
end

return M
