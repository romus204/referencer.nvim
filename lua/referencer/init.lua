local M = {}
local ns = vim.api.nvim_create_namespace("Referencer")
local config = require("referencer.config")

local function append_virtual_text(bufnr, line, text_to_add)
    local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, -1, { line, 0 }, { line, -1 }, { details = true })

    local virt_texts = {}

    for _, ext in ipairs(extmarks) do
        local details = ext[4]
        if details and details.virt_text and details.virt_text_pos == "eol" then
            for _, chunk in ipairs(details.virt_text) do
                table.insert(virt_texts, chunk)
            end
        end
    end

    table.insert(virt_texts, { text_to_add, config.get_hl_group() })

    local ours = vim.api.nvim_buf_get_extmarks(bufnr, ns, { line, 0 }, { line, -1 }, {})
    for _, mark in ipairs(ours) do
        vim.api.nvim_buf_del_extmark(bufnr, ns, mark[1])
    end

    vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
        virt_text = virt_texts,
        virt_text_pos = config.options.virt_text_pos,
        hl_mode = "combine",
    })
end

function M.show_all()
    local bufnr = vim.api.nvim_get_current_buf()
    local client = vim.lsp.get_active_clients({ bufnr = bufnr })[1]
    if not client then return end

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", {
        textDocument = vim.lsp.util.make_text_document_params(),
    }, function(_, result, _, _)
        if not result then return end

        local function process(symbols)
            for _, sym in ipairs(symbols) do
                if vim.tbl_contains(config.options.kinds, sym.kind) then
                    local pos = sym.selectionRange.start
                    local line = pos.line

                    local params = {
                        textDocument = vim.lsp.util.make_text_document_params(),
                        position = pos,
                        context = { includeDeclaration = config.options.include_declaration },
                    }

                    client.request("textDocument/references", params, function(_, refs)
                        if not refs or #refs == 0 then return end
                        vim.schedule(function()
                            local msg = string.format(config.options.format, #refs - 1)
                            append_virtual_text(bufnr, line, msg)
                        end)
                    end, bufnr)
                end
                if sym.children then
                    process(sym.children)
                end
            end
        end

        process(result)
    end)
end

function M.setup(user_opts)
    config.setup(user_opts)
    vim.api.nvim_create_user_command("ReferencerShow", M.show_all, {})
end

return M
