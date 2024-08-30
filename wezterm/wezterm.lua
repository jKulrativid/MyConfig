local wezterm = require("wezterm")

local config = wezterm.config_builder()
require("lua/jetnipit/option").init(config)
require("lua/jetnipit/tab").init(config)
require("lua/jetnipit/keymap").init(config)

return config
