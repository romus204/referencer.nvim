local M = {}
local ns = vim.api.nvim_create_namespace("Referencer")
local config = require("config")

M.enable = false

local function append_virtual_text(bufnr, line, text_to_add)
    local virt_texts = {}

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

function M.show_all(client)
    M.enable = true
    local bufnr = vim.api.nvim_get_current_buf()
    if not client then return end

    local servers = config.options.lsp_servers

    if servers and not vim.tbl_isempty(servers) then
        if not vim.tbl_contains(servers, client.name) then
            return
        end
    end

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
                        context = { includeDeclaration = true },
                    }

                    client.request("textDocument/references", params, function(_, refs)
                        if not refs or #refs == 0 then return end
                        vim.schedule(function()
                            local refsCount = #refs - 1
                            local msg = string.format(config.options.format, refsCount)

                            if not config.options.show_no_reference and refsCount == 0 then
                                return
                            end

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

function M.delete_all()
    M.enable = false
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

function M.toggle()
    if M.enable then
        M.delete_all()
    else
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
        for _, v in ipairs(clients) do
            M.show_all(v)
        end
    end
end

function M.update()
    if M.enable then
        M.delete_all()

        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
        for _, v in ipairs(clients) do
            M.show_all(v)
        end
    end
end

function M.setup(user_opts)
    config.setup(user_opts)

    vim.api.nvim_create_user_command("ReferencerToggle", M.toggle, {})
    vim.api.nvim_create_user_command("ReferencerUpdate", M.update, {})
end

return M
