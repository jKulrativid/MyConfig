local wezterm = require("wezterm")
local tab = require("lua/jetnipit/tab")
local workspace = require("lua/jetnipit/workspace")
local act = wezterm.action

local M = {}

function M.init(config)
	wezterm.on("save_session", workspace.save_state)
	wezterm.on("restore_session", workspace.restore_state)

	config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 3000 }

	config.keys = {
		{ key = "v", mods = "LEADER", action = wezterm.action.ActivateCopyMode },

		{ key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
		{ key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
		{ key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
		{ key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
		{ key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
		{ key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
		{ key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
		{ key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
		{ key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },

		{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "r", mods = "LEADER", action = tab.rename_tab() },
		{ key = "x", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "(", mods = "LEADER", action = act.MoveTabRelative(-1) },
		{ key = ")", mods = "LEADER", action = act.MoveTabRelative(1) },

		{ key = "s", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		{ key = "s", mods = "LEADER|SHIFT", action = wezterm.action({ EmitEvent = "save_session" }) },
		{ key = "l", mods = "LEADER|SHIFT", action = wezterm.action({ EmitEvent = "restore_session" }) },

		{ key = "r", mods = "LEADER|SHIFT", action = workspace.rename_workspace() },
		{ key = "c", mods = "LEADER|SHIFT", action = act.SwitchToWorkspace },
		{ key = "x", mods = "LEADER|SHIFT", action = workspace.kill_wokspace() },
	}
	return config
end

return M
