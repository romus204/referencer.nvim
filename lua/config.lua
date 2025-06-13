local M = {}

M.options = {
    enable = false,
    format = "  %d reference(s)",
    show_no_reference = true,
    kinds = { 5, 6, 8, 12, 13, 14, 23, },
    hl_group = "Comment",
    color = nil,
    virt_text_pos = "eol",
    pattern = nil,
}

local hl_group_from_color = nil

function M.setup(user_opts)
    M.options = vim.tbl_deep_extend("force", M.options, user_opts or {})

    if M.options.color then
        hl_group_from_color = "ReferencerCustomColor"
        vim.api.nvim_set_hl(0, hl_group_from_color, { fg = M.options.color })
    end

    if M.options.enable then
        vim.api.nvim_create_autocmd("LspAttach", {
            pattern = M.options.pattern,
            callback = function()
                require("referencer").show_all()
            end,
        })
    end
end

function M.get_hl_group()
    return hl_group_from_color or M.options.hl_group
end

return M
