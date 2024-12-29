return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            panel = {
                enabled = false,
            },
            suggestion = {
                enabled = false,
            },
            filetypes = {
                sh = function()
                    local filename = vim.fs.basename(vim.api.nvim_buf_get_name(0))
                    if string.match(filename, "^%.env.*") then
                        -- disable for .env files
                        return false
                    elseif string.match(filename, "backend.conf") then
                        -- disable for Terraform's backend.conf
                        return false
                    elseif string.match(filename, "^%.pem") then
                        -- disable for .pem file
                        return false
                    elseif string.match(filename, "^%.key") then
                        -- disable for .key file
                        return false
                    end
                    return true
                end,
            },
        })
    end,
}
