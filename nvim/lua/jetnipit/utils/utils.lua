local M = {}

M.get_vscode_settings = function()
    local settings_file = vim.fn.getcwd() .. '/.vscode/settings.json'
    if vim.fn.filereadable(settings_file) == 1 then
        local contents = vim.fn.readfile(settings_file)
        local settings = vim.fn.json_decode(table.concat(contents, '\n'))
        return settings
    end
    return {}
end

M.compare_version = function(lhs, rhs)
    -- Handle nil inputs
    if not lhs or not rhs then
        return -1
    end

    -- Split versions into parts
    local function split_version(ver)
        local parts = {}
        for part in ver:gmatch("%d+") do
            table.insert(parts, tonumber(part))
        end
        return parts
    end

    local lhs_parts = split_version(lhs)
    local rhs_parts = split_version(rhs)

    local max_len = math.max(#lhs_parts, #rhs_parts)

    for i = 1, max_len do
        local l = lhs_parts[i] or 0
        local r = rhs_parts[i] or 0

        if l > r then
            return 1
        elseif l < r then
            return -1
        end
    end

    return 0
end

M.get_go_version = function()
    local handle = io.popen('go version')
    if handle then
        local output = handle:read("*a")
        handle:close()
        -- Extract version from output (format: "go version go1.21.0 darwin/arm64")
        local version = output:match("go(%d+%.%d+%.%d+)")
        return version
    end
    return nil
end

return M
