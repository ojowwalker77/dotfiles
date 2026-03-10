local M = {}
local openrouter = require("pilot.openrouter")
local float = require("pilot.ui.float")

local function get_visual_selection()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_row, start_col = start_pos[2], start_pos[3]
    local end_row, end_col = end_pos[2], end_pos[3]

    local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
    if #lines == 0 then return nil end

    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col, end_col)
    else
        lines[1] = string.sub(lines[1], start_col)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end

    return table.concat(lines, "\n")
end

function M.lookup(opts)
    opts = opts or {}
    local is_visual = opts.visual or false
    local is_file = opts.file or false

    local filetype = vim.bo.filetype
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local config = require("pilot").get_config()

    local code, question

    if is_file then
        question = vim.fn.input("Pergunta sobre o arquivo: ")
        if question == "" then
            return
        end
        code = nil
    elseif is_visual then
        code = get_visual_selection()
        if not code or code == "" then
            vim.notify("pilot: nenhum código selecionado", vim.log.levels.WARN)
            return
        end
        question = vim.fn.input("Pergunta: ")
        if question == "" then
            return
        end
    else
        local line = vim.api.nvim_get_current_line()
        code, question = line:match("(.-)%s*//%s*%?%s*(.+)")
        if not question then
            code, question = line:match("(.-)%s*#%s*%?%s*(.+)")
        end
        if not question then
            code, question = line:match("(.-)%s*%-%-%s*%?%s*(.+)")
        end
        if not question then
            vim.notify("pilot: use // ? pergunta (ou selecione código + <space>?)", vim.log.levels.WARN)
            return
        end
    end

    local close_loading = float.show_loading()

    local all_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local file_content = table.concat(all_lines, "\n")
    local filename = vim.fn.expand("%:t")

    local context = string.format("Arquivo: %s\n```%s\n%s\n```\n\n", filename, filetype, file_content)

    if is_file then
        context = context .. "Contexto: arquivo inteiro\n\n"
    elseif is_visual then
        context = context .. string.format("Código selecionado (linhas %d-%d):\n%s\n\n",
            vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2], code)
    else
        context = context .. string.format("Linha atual (%d): %s\n\n", row, code or "")
    end

    local prompt = string.format(
        [[%sLinguagem: %s
Pergunta: %s

Responda de forma concisa (max 5 linhas):
1. Explique considerando o código mostrado
2. Se precisar de exemplo, mostre
Seja didático mas breve.]],
        context,
        filetype,
        question
    )

    local messages = {{ role = "user", content = prompt }}

    openrouter.request(messages, function(response, err)
        vim.schedule(function()
            close_loading()
            if err then
                vim.notify("pilot: " .. err, vim.log.levels.ERROR)
                return
            end
            if response then
                table.insert(messages, { role = "assistant", content = response })
                float.show_tooltip(response, {
                    filetype = filetype,
                    messages = messages,
                    context = context,
                })
            end
        end)
    end)
end

return M
