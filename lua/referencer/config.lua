local M = {}

M.options = {
    format = "  %d reference(s)",
    include_declaration = true,
    kinds = { 12, 6, 5 },
    hl_group = "Comment",
    color = '#ff9900', -- можно указать "#ff9900"
    virt_text_pos = "eol",
}

local hl_group_from_color = nil

function M.setup(user_opts)
    M.options = vim.tbl_deep_extend("force", M.options, user_opts or {})

    if M.options.color then
        hl_group_from_color = "ReferencerCustomColor"
        vim.api.nvim_set_hl(0, hl_group_from_color, { fg = M.options.color })
    end
end

function M.get_hl_group()
    return hl_group_from_color or M.options.hl_group
end

return M
