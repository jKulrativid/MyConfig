local wezterm = require("wezterm")
local notify = require("lua/jetnipit/notify")
local utils = require("lua/jetnipit/util")
local act = wezterm.action
local mux = wezterm.mux

--- Retrieves the workspace data from the active window.
local function retrieve_workspace_data(window)
    local workspace_data = {
        name = window:get_workspace(),
        tabs = {},
    }

    -- Iterate over tabs in the current window
    for _, tab in ipairs(window:tabs()) do
        local tab_data = {
            tab_id = tostring(tab:tab_id()),
            tab_title = tostring(tab:get_title()),
            panes = {},
        }


        -- Iterate over panes in the current tab
        for _, pane_info in ipairs(tab:panes_with_info()) do
            -- Collect pane details, including layout and process information
            wezterm.log_info("retreive workspace CWD: ", tostring(pane_info.pane:get_current_working_dir()))

            table.insert(tab_data.panes, {
                pane_id = tostring(pane_info.pane:pane_id()),
                index = pane_info.index,
                is_active = pane_info.is_active,
                is_zoomed = pane_info.is_zoomed,
                left = pane_info.left,
                top = pane_info.top,
                width = pane_info.width,
                height = pane_info.height,
                pixel_width = pane_info.pixel_width,
                pixel_height = pane_info.pixel_height,
                cwd = tostring(pane_info.pane:get_current_working_dir()),
                tty = tostring(pane_info.pane:get_foreground_process_name()),
            })
        end

        table.insert(workspace_data.tabs, tab_data)
    end

    wezterm.log_info("workspace data: " .. wezterm.json_encode(workspace_data))

    return workspace_data
end

local function save_to_json_file(data, file_path)
    if not data then
        wezterm.log_info("No workspace data to log.")
        return false
    end

    local file = io.open(file_path, "w")
    if file then
        file:write(wezterm.json_encode(data))
        file:close()
        return true
    else
        return false
    end
end

local function load_from_json_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        wezterm.log_info("Failed to open file: " .. file_path)
        return nil
    end

    local file_content = file:read("*a")
    file:close()

    local data = wezterm.json_parse(file_content)
    if not data then
        wezterm.log_info("Failed to parse JSON data from file: " .. file_path)
    end
    return data
end

local function extract_path_from_dir(working_directory)
    local os_name, _ = utils.getOS()
    if os_name == "Windows" then
        return working_directory:gsub("file:///", "")
    elseif os_name == "Linux" then
        local val = working_directory:gsub("^.*(/home/)", "/home/")
        wezterm.log_info("XX: ", working_directory, val)
        return val
    elseif os_name == "Mac" then
        return working_directory:gsub("^.*(/Users/)", "/Users/")
    else
        wezterm.log_info("os not supported: ", os_name)
    end
end

local function recreate_workspace(workspace_data)
    wezterm.log_info("recreate workspace" .. workspace_data.name)

    local tab, _, window
    for i, tab_data in ipairs(workspace_data.tabs) do
        wezterm.log_info("tab data: ", tab_data)
        local cwd_uri = tab_data.panes[1].cwd
        local cwd_path = extract_path_from_dir(cwd_uri)
        wezterm.log_info("cwd_path: " .. cwd_path)

        if i == 1 then
            tab, _, window = mux.spawn_window({
                workspace = workspace_data.name,
                cwd = cwd_path,
            })
            if not tab then
                wezterm.log_info("Failed to create a new tab.")
                return false
            end
            tab:set_title(tab_data.tab_title)
        else
            local new_tab = window:spawn_tab({ cwd = cwd_path })
            if not new_tab then
                wezterm.log_info("Failed to create a new tab.")
                return false
            end
            new_tab:set_title(tab_data.tab_title)
        end
    end

    return true
end

local function get_all_saved_workspaces()
    local workspace_dir = wezterm.home_dir .. "/.config/wezterm/workspace/"
    local files = {}

    -- Use ls command to list files (works on Unix-like systems)
    local handle = io.popen('ls "' .. workspace_dir .. '"')

    if handle then
        for file in handle:lines() do
            table.insert(files, wezterm.home_dir .. "/.config/wezterm/workspace/" .. file)
        end
        handle:close()
    end

    wezterm.log_info("files: " .. wezterm.json_encode(files))

    return files
end

local M = {}

function M.save_state(window)
    local windows = mux.all_windows()

    local done = true
    local fail_window = ""

    for _, w in ipairs(windows) do
        if w:get_workspace() == "default" then
            wezterm.log_info("skip default workspace")
        else
            wezterm.log_info("saving workspace: " .. w:get_workspace())
            local data = retrieve_workspace_data(w)
            local file_path = wezterm.home_dir
                .. "/.config/wezterm/workspace/wezterm_state_"
                .. w:get_workspace()
                .. ".json"

            if not save_to_json_file(data, file_path) then
                fail_window = w
                done = false
                break
            end
        end
    end

    if done then
        local noti = " workspaces state saved successfully"
        notify.Sent(window, noti, 2000)
    else
        local noti = "Failed to save  " .. fail_window .. "  workspace state"
        notify.Sent(window, noti, 2000)
    end
end

function M.restore_state(window)
    local workspaces_files = get_all_saved_workspaces()
    for _, file_path in ipairs(workspaces_files) do
        local workspace_data = load_from_json_file(file_path)
        if not workspace_data then
            local message = "Workspace state file not found file: " .. workspaces_files
            notify.Sent(window, message, 4000)
            return
        end

        if recreate_workspace(workspace_data) then
            local message = "Workspace state loaded successfully for workspace: " .. workspace_data.name
            notify.Sent(window, message, 1000)
        else
            local message = "Workspace state loading failed for workspace: " .. workspace_data.name
            notify.Sent(window, message, 4000)
        end
    end
end

function M.rename_workspace()
    return act.PromptInputLine({
        description = wezterm.format({
            { Attribute = { Intensity = "Bold" } },
            { Text = "Rename workspace to " },
        }),
        action = wezterm.action_callback(function(window, _, line)
            if line then
                local old_title = window:mux_window():get_workspace()
                mux.rename_workspace(window:mux_window():get_workspace(), line)
                local status_message = "Renamed workspace: " .. old_title .. " -> " .. line
                notify.Sent(window, status_message, 5000)
            end
        end),
    })
end

function M.kill_wokspace()
    return wezterm.action_callback(function(window, _, _)
        local workspace = window:active_workspace()
        local success, stdout =
            wezterm.run_child_process({ "/opt/homebrew/bin/wezterm", "cli", "list", "--format=json" })

        if success then
            local json = wezterm.json_parse(stdout)
            if not json then
                return
            end

            local workspace_panes = {}

            for _, v in ipairs(json) do
                if v.workspace == workspace then
                    table.insert(workspace_panes, v)
                end
            end

            for _, p in ipairs(workspace_panes) do
                wezterm.run_child_process({
                    "/opt/homebrew/bin/wezterm",
                    "cli",
                    "kill-pane",
                    "--pane-id=" .. p.pane_id,
                })
            end
        end

        local workspace_path = wezterm.home_dir .. "/.config/wezterm/workspace/wezterm_state_" .. workspace .. ".json"
        os.remove(workspace_path)
    end)
end

return M
