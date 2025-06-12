local M = {}

M.options = {
    enable = false,
    format = "  %d reference(s)",
    include_declaration = true, -- ??
    kinds = { 12, 6, 5, 23, 8 },
    hl_group = "Comment",       --color with hl_group
    color = nil,                -- custom color
    virt_text_pos = "eol",      -- vitrual text position
    pattern = nil,              -- files for enable with LspAttach autocommand
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
