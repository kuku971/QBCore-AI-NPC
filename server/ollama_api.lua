-- ============================================
-- Ollama API Integration
-- ============================================

OllamaAPI = {
    requestQueue = {},
    processing = false
}

-- HTTP请求封装
local function MakeRequest(endpoint, data, callback)
    local url = Config.Ollama.Host .. endpoint
    
    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local success, decoded = pcall(json.decode, response)
            if success then
                callback(true, decoded)
            else
                Utils.Debug(("Failed to parse Ollama response: %s"):format(response), "error")
                callback(false, "Failed to parse response")
            end
        else
            Utils.Debug(("Ollama API error: %d - %s"):format(statusCode, response), "error")
            callback(false, "API request failed")
        end
    end, 'POST', json.encode(data), {
        ['Content-Type'] = 'application/json'
    })
end

-- 生成对话
function OllamaAPI.Chat(messages, options, callback)
    if not Config.Ollama.Enabled then
        callback(false, "Ollama is disabled")
        return
    end
    
    local requestData = {
        model = options.model or Config.Ollama.Model,
        messages = messages,
        stream = false,
        options = {
            temperature = options.temperature or Config.Ollama.Temperature,
            num_predict = options.maxTokens or Config.Ollama.MaxTokens
        }
    }
    
    MakeRequest('/api/chat', requestData, function(success, response)
        if success and response.message then
            callback(true, response.message.content)
        else
            callback(false, response or "Unknown error")
        end
    end)
end

-- 生成文本
function OllamaAPI.Generate(prompt, options, callback)
    if not Config.Ollama.Enabled then
        callback(false, "Ollama is disabled")
        return
    end
    
    local requestData = {
        model = options.model or Config.Ollama.Model,
        prompt = prompt,
        stream = false,
        options = {
            temperature = options.temperature or Config.Ollama.Temperature,
            num_predict = options.maxTokens or Config.Ollama.MaxTokens
        }
    }
    
    MakeRequest('/api/generate', requestData, function(success, response)
        if success and response.response then
            callback(true, response.response)
        else
            callback(false, response or "Unknown error")
        end
    end)
end

-- 检查连接
function OllamaAPI.CheckConnection(callback)
    PerformHttpRequest(Config.Ollama.Host .. '/api/tags', function(statusCode, response, headers)
        if statusCode == 200 then
            callback(true, "Connected")
        else
            callback(false, "Not connected")
        end
    end, 'GET')
end

-- 列出可用模型
function OllamaAPI.ListModels(callback)
    PerformHttpRequest(Config.Ollama.Host .. '/api/tags', function(statusCode, response, headers)
        if statusCode == 200 then
            local success, decoded = pcall(json.decode, response)
            if success and decoded.models then
                local modelNames = {}
                for _, model in ipairs(decoded.models) do
                    table.insert(modelNames, model.name)
                end
                callback(true, modelNames)
            else
                callback(false, "Failed to parse models")
            end
        else
            callback(false, "Failed to fetch models")
        end
    end, 'GET')
end

_G.OllamaAPI = OllamaAPI
