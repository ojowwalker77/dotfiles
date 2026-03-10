local M = {}

local state = {
    win = nil,
    buf = nil,
    augroup = nil,
    messages = {},
    context = nil,
    filetype = nil,
    origin_buf = nil,
}

local function cleanup()
    if state.augroup then
        pcall(vim.api.nvim_del_augroup_by_id, state.augroup)
        state.augroup = nil
    end
    if state.origin_buf and vim.api.nvim_buf_is_valid(state.origin_buf) then
        pcall(vim.api.nvim_buf_del_keymap, state.origin_buf, "n", "<leader>f")
    end
    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_close(state.win, true)
    end
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
        vim.api.nvim_buf_delete(state.buf, { force = true })
    end
    state.win = nil
    state.buf = nil
    state.messages = {}
    state.context = nil
    state.filetype = nil
    state.origin_buf = nil
end

local function update_content(lines)
    if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
        return
    end

    if type(lines) == "string" then
        lines = vim.split(lines, "\n")
    end

    table.insert(lines, "")
    table.insert(lines, "[<leader>f / f] follow-up  [q] fechar")

    vim.api.nvim_set_option_value("modifiable", true, { buf = state.buf })
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = state.buf })

    local max_width = 80
    local max_height = 30
    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(width, #line)
    end
    width = math.min(width + 2, max_width)
    local height = math.min(#lines, max_height)

    if state.win and vim.api.nvim_win_is_valid(state.win) then
        vim.api.nvim_win_set_config(state.win, {
            width = width,
            height = height,
        })
    end
end

local function ask_followup()
    local question = vim.fn.input("Follow-up: ")
    if question == "" then
        return
    end

    table.insert(state.messages, { role = "user", content = question })

    update_content({ "..." })

    local openrouter = require("pilot.openrouter")
    openrouter.request(state.messages, function(response, err)
        vim.schedule(function()
            if err then
                vim.notify("pilot: " .. err, vim.log.levels.ERROR)
                return
            end
            if response then
                table.insert(state.messages, { role = "assistant", content = response })
                update_content(response)
            end
        end)
    end)
end

function M.show_tooltip(lines, opts)
    opts = opts or {}

    local origin = vim.api.nvim_get_current_buf()

    cleanup()

    state.origin_buf = origin
    state.context = opts.context
    state.filetype = opts.filetype
    state.messages = opts.messages or {}

    if type(lines) == "string" then
        lines = vim.split(lines, "\n")
    end

    table.insert(lines, "")
    table.insert(lines, "[<leader>f / f] follow-up  [q] fechar")

    local max_width = opts.max_width or 80
    local max_height = opts.max_height or 30

    local width = 0
    for _, line in ipairs(lines) do
        width = math.max(width, #line)
    end
    width = math.min(width + 2, max_width)
    local height = math.min(#lines, max_height)

    state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = state.buf })
    vim.api.nvim_set_option_value("filetype", "text", { buf = state.buf })

    local win_opts = {
        relative = "cursor",
        row = 2,
        col = 0,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
    }

    state.win = vim.api.nvim_open_win(state.buf, false, win_opts)

    state.augroup = vim.api.nvim_create_augroup("PilotFloat", { clear = true })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = state.augroup,
        callback = function()
            local current_buf = vim.api.nvim_get_current_buf()
            if current_buf == state.buf then
                return
            end
            if state.win and vim.api.nvim_win_is_valid(state.win) then
                vim.api.nvim_win_set_config(state.win, {
                    relative = "cursor",
                    row = 2,
                    col = 0,
                })
            end
        end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
        group = state.augroup,
        pattern = tostring(state.win),
        callback = function()
            cleanup()
        end,
    })

    vim.api.nvim_buf_set_keymap(state.buf, "n", "q", "", {
        callback = cleanup,
        noremap = true,
        silent = true,
    })

    vim.api.nvim_buf_set_keymap(state.buf, "n", "f", "", {
        callback = ask_followup,
        noremap = true,
        silent = true,
    })

    vim.keymap.set("n", "q", cleanup, { buffer = 0 })

    vim.api.nvim_buf_set_keymap(state.origin_buf, "n", "<leader>f", "", {
        callback = ask_followup,
        noremap = true,
        silent = true,
    })

    return state.win, state.buf
end

function M.close()
    cleanup()
end

function M.show_loading()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " ... " })

    local win = vim.api.nvim_open_win(buf, false, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = 7,
        height = 1,
        style = "minimal",
        border = "rounded",
    })

    return function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end

return M
