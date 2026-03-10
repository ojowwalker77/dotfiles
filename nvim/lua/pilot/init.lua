local M = {}

local config = {
    api_key = nil,
    model = "google/gemini-3-flash-preview",
    base_url = "https://openrouter.ai/api/v1",
    context_lines = 15,
}

local function read_env_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    for line in file:lines() do
        local key, value = line:match("^([%w_]+)%s*=%s*[\"']?([^\"']+)[\"']?$")
        if key == "OPENROUTER_API_KEY" then
            file:close()
            return value
        end
    end
    file:close()
    return nil
end

local function find_api_key()
    local paths = {
        vim.fn.getcwd() .. "/.env",
        vim.fn.expand("~/.env"),
        vim.fn.expand("~/.config/pilot/.env"),
    }
    for _, path in ipairs(paths) do
        local key = read_env_file(path)
        if key then return key end
    end
    return os.getenv("OPENROUTER_API_KEY")
end

function M.setup(opts)
    opts = opts or {}
    config.api_key = opts.api_key or find_api_key()
    config.model = opts.model or config.model
    config.base_url = opts.base_url or config.base_url
    config.context_lines = opts.context_lines or config.context_lines

    if not config.api_key then
        vim.notify("pilot.nvim: OPENROUTER_API_KEY not found", vim.log.levels.WARN)
    end
end

function M.set_context_lines(n)
    config.context_lines = tonumber(n) or config.context_lines
    vim.notify("pilot: context_lines = " .. config.context_lines)
end

function M.get_config()
    return config
end

function M.lookup(opts)
    require("pilot.actions.lookup").lookup(opts)
end

function M.ask()
    require("pilot.actions.lookup").lookup({ file = true })
end

function M.help()
    local help = {
        "╭─────────────────────────────────────────────────────────╮",
        "│                      PILOT.NVIM                        │",
        "├─────────────────────────────────────────────────────────┤",
        "│                                                         │",
        "│  <space>?  LOOKUP - Pergunta pra IA (tooltip)          │",
        "│            Modo 1: codigo // ? sua pergunta            │",
        "│            Modo 2: seleciona codigo + <space>?         │",
        "│                                                         │",
        "│  <space>a  ASK - Pergunta sobre o arquivo inteiro      │",
        "│                                                         │",
        "├─────────────────────────────────────────────────────────┤",
        "│  :PilotContext N  - Define linhas de contexto (def 15) │",
        "│  <leader>f ou [f] - follow-up (continuar conversa)      │",
        "│  [q] fecha o tooltip                                   │",
        "╰─────────────────────────────────────────────────────────╯",
    }
    for _, line in ipairs(help) do
        print(line)
    end
end

return M
