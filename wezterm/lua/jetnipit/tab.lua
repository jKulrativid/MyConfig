local wezterm = require("wezterm")
local notify = require("lua/jetnipit/notify")
local act = wezterm.action

local M = {}

function M.init(config)
	config.tab_max_width = 32
	config.switch_to_last_active_tab_when_closing_tab = true
	config.use_fancy_tab_bar = false
	config.switch_to_last_active_tab_when_closing_tab = true
	config.tab_bar_style = {
		new_tab = wezterm.format({
			{ Text = "" },
		}),
		new_tab_hover = wezterm.format({
			{ Text = "" },
		}),
	}

	local function tab_title(tab_info)
		local title = tab_info.tab_title
		if title and #title > 0 then
			return title
		end
		return tab_info.active_pane.title
	end

	local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
	scheme.tab_bar.inactive_tab.bg_color = "#89b4fa"
	scheme.tab_bar.active_tab.bg_color = "#f4b387"
	scheme.tab_bar.background = "#191826"

	wezterm.on("format-tab-title", function(tab)
		local index = " " .. tostring(tab.tab_index + 1) .. " "
		local title = " " .. tab_title(tab) .. " "

		local active_tab_bg = scheme.tab_bar.active_tab.bg_color
		local inactive_tab_bg = scheme.tab_bar.inactive_tab.bg_color

		local active_tab_fg = scheme.tab_bar.active_tab.fg_color

		return {
			{ Background = { Color = tab.is_active and active_tab_bg or inactive_tab_bg } },
			{ Foreground = { Color = active_tab_fg } },
			{ Text = index },
			{ Background = { Color = tab.is_active and scheme.tab_bar.new_tab.bg_color or scheme.background } },
			{ Foreground = { Color = scheme.foreground } },
			{ Text = title },
		}
	end)

	wezterm.on("update-status", function(window, pane)
		local workspace = window:active_workspace()

		window:set_left_status(wezterm.format({
			{ Foreground = { Color = "#a2e2d5" } },
			{ Background = { Color = "#323245" } },
			{ Text = " " .. wezterm.nerdfonts.md_collage .. " " .. workspace .. " " },
		}))
	end)

	return config
end

function M.rename_tab()
	return act.PromptInputLine({
		description = wezterm.format({
			{ Attribute = { Intensity = "Bold" } },
			{ Text = "Rename tab to " },
		}),
		action = wezterm.action_callback(function(window, pane, line)
			if line then
				local old_title = window:active_tab():get_title()
				window:active_tab():set_title(line)
				local status_message = "Renamed tab: " .. old_title .. " -> " .. line
				notify.Sent(window, status_message, 4000)
			end
		end),
	})
end

return M
