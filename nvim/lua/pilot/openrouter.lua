local M = {}

function M.request(messages, callback)
    local config = require("pilot").get_config()

    if not config.api_key then
        callback(nil, "API key not configured")
        return
    end

    if type(messages) == "string" then
        messages = {{ role = "user", content = messages }}
    end

    local body = vim.fn.json_encode({
        model = config.model,
        messages = messages,
        max_tokens = 1024,
    })

    local cmd = {
        "curl",
        "-s",
        "--max-time", "30",
        "-X", "POST",
        config.base_url .. "/chat/completions",
        "-H", "Content-Type: application/json",
        "-H", "Authorization: Bearer " .. config.api_key,
        "-d", body,
    }

    local called = false
    local function safe_callback(result, err)
        if called then return end
        called = true
        callback(result, err)
    end

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if not data or #data == 0 then return end
            local response = table.concat(data, "")
            if response == "" then return end

            local ok, json = pcall(vim.fn.json_decode, response)
            if not ok then
                safe_callback(nil, "Failed to parse response")
                return
            end

            if json.error then
                safe_callback(nil, json.error.message)
                return
            end

            local content = json.choices
                and json.choices[1]
                and json.choices[1].message
                and json.choices[1].message.content

            if content then
                safe_callback(content, nil)
            else
                safe_callback(nil, "Empty response")
            end
        end,
        on_stderr = function(_, data)
            if data and #data > 0 and data[1] ~= "" then
                safe_callback(nil, table.concat(data, ""))
            end
        end,
        on_exit = function(_, code)
            if code ~= 0 and not called then
                safe_callback(nil, "Request failed with code " .. code)
            end
        end,
    })
end

return M
