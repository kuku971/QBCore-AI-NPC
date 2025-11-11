-- ============================================
-- Dialogue Handler - 对话处理系统
-- ============================================

DialogueHandler = {}

-- 构建AI提示词（中文）
local function BuildSystemPromptZH(npc, playerName, relationship)
    local prompt = string.format([[你是一个名叫 %s 的NPC角色。

基本信息：
- 职业：%s
- 性格：%s
- 年龄：%d岁
- 背景故事：%s

性格特征：
- 友善度：%.1f/1.0
- 健谈度：%.1f/1.0
- 正式度：%.1f/1.0
- 情绪化：%.1f/1.0
- 幽默感：%.1f/1.0

与 %s 的关系等级：%d

请根据你的性格和背景，以第一人称回复玩家。保持角色一致性，回复长度控制在2-3句话。使用中文回复。]],
        npc.name,
        npc.occupation or '平民',
        npc.personality.type or 'friendly',
        npc.age or 30,
        npc.backstory or '一个普通的居民',
        npc.personality.traits.friendliness or 0.7,
        npc.personality.traits.talkativeness or 0.7,
        npc.personality.traits.formality or 0.5,
        npc.personality.traits.emotionality or 0.5,
        npc.personality.traits.humor or 0.5,
        playerName,
        relationship or 0
    )
    
    return prompt
end

-- 构建AI提示词（英文）
local function BuildSystemPromptEN(npc, playerName, relationship)
    local prompt = string.format([[You are an NPC character named %s.

Basic Information:
- Occupation: %s
- Personality: %s
- Age: %d years old
- Backstory: %s

Personality Traits:
- Friendliness: %.1f/1.0
- Talkativeness: %.1f/1.0
- Formality: %.1f/1.0
- Emotionality: %.1f/1.0
- Humor: %.1f/1.0

Relationship level with %s: %d

Please respond to the player in first person based on your personality and background. Keep character consistency and limit responses to 2-3 sentences. Respond in English.]],
        npc.name,
        npc.occupation or 'citizen',
        npc.personality.type or 'friendly',
        npc.age or 30,
        npc.backstory or 'An ordinary resident',
        npc.personality.traits.friendliness or 0.7,
        npc.personality.traits.talkativeness or 0.7,
        npc.personality.traits.formality or 0.5,
        npc.personality.traits.emotionality or 0.5,
        npc.personality.traits.humor or 0.5,
        playerName,
        relationship or 0
    )
    
    return prompt
end

-- 根据语言配置选择提示词
local function BuildSystemPrompt(npc, playerName, relationship)
    if Config.Language == 'zh' then
        return BuildSystemPromptZH(npc, playerName, relationship)
    else
        return BuildSystemPromptEN(npc, playerName, relationship)
    end
end

-- 处理对话
function DialogueHandler.ProcessDialogue(npcId, playerId, message, callback)
    local npc = ActiveNPCs[npcId]
    if not npc then
        callback(false, "NPC not found")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then
        callback(false, "Player not found")
        return
    end
    
    local playerIdentifier = Player.PlayerData.license
    local playerName = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    
    -- 获取对话历史
    Database.GetDialogueHistory(npcId, playerIdentifier, 5, function(history)
        -- 获取关系等级
        Database.GetRelationship(npcId, playerIdentifier, function(relationship)
            local relLevel = relationship and relationship.relationship_level or 0
            
            -- 构建消息历史
            local messages = {
                {
                    role = "system",
                    content = BuildSystemPrompt(npc, playerName, relLevel)
                }
            }
            
            -- 添加历史对话（最近5条）
            if history and #history > 0 then
                for i = #history, 1, -1 do
                    local h = history[i]
                    table.insert(messages, {role = "user", content = h.player_message})
                    table.insert(messages, {role = "assistant", content = h.npc_response})
                end
            end
            
            -- 添加当前消息
            table.insert(messages, {role = "user", content = message})
            
            -- 调用AI
            local aiConfig = npc.ai_config or {}
            OllamaAPI.Chat(messages, {
                model = aiConfig.model or Config.Ollama.Model,
                temperature = aiConfig.temperature or Config.Ollama.Temperature,
                maxTokens = aiConfig.max_tokens or 256
            }, function(success, response)
                if success then
                    -- 分析情绪
                    EmotionEngine.AnalyzeEmotion(response, function(emotion)
                        -- 保存对话
                        Database.SaveDialogue(npcId, playerIdentifier, message, response, emotion, {
                            playerName = playerName,
                            timestamp = os.time()
                        })
                        
                        -- 更新关系（每次对话+1）
                        local newLevel = relLevel + 1
                        Database.UpdateRelationship(npcId, playerIdentifier, newLevel)
                        
                        callback(true, {
                            response = response,
                            emotion = emotion,
                            relationshipLevel = newLevel
                        })
                    end)
                else
                    Utils.Debug(("Dialogue AI error: %s"):format(response), "error")
                    callback(false, "AI service error")
                end
            end)
        end)
    end)
end

-- 默认问候语（中文）
local DefaultGreetingsZH = {
    "你好！有什么可以帮你的吗？",
    "欢迎！",
    "嗨，很高兴见到你！",
    "你好啊！",
    "早上好！",
    "今天过得怎么样？"
}

-- 默认问候语（英文）
local DefaultGreetingsEN = {
    "Hello! How can I help you?",
    "Welcome!",
    "Hi, nice to meet you!",
    "Hey there!",
    "Good day!",
    "How are you doing?"
}

-- 默认告别语（中文）
local DefaultFarewellsZH = {
    "再见！",
    "下次见！",
    "保重！",
    "回头见！",
    "慢走！",
    "祝你愉快！"
}

-- 默认告别语（英文）
local DefaultFarewellsEN = {
    "Goodbye!",
    "See you later!",
    "Take care!",
    "See you around!",
    "Have a great day!",
    "Until next time!"
}

-- 生成问候语
function DialogueHandler.GenerateGreeting(npcId, playerId, callback)
    local npc = ActiveNPCs[npcId]
    if not npc then
        callback(false, "NPC not found")
        return
    end
    
    -- 使用预设问候语或生成
    if npc.dialogue_config and npc.dialogue_config.greetings and #npc.dialogue_config.greetings > 0 then
        local greeting = Utils.GetRandomElement(npc.dialogue_config.greetings)
        callback(true, {response = greeting, emotion = "happy"})
    else
        -- 根据语言配置选择默认问候语
        local greetings = Config.Language == 'zh' and DefaultGreetingsZH or DefaultGreetingsEN
        callback(true, {response = Utils.GetRandomElement(greetings), emotion = "happy"})
    end
end

-- 生成告别语
function DialogueHandler.GenerateFarewell(npcId, callback)
    local npc = ActiveNPCs[npcId]
    if not npc then
        callback(false, "NPC not found")
        return
    end
    
    if npc.dialogue_config and npc.dialogue_config.farewells and #npc.dialogue_config.farewells > 0 then
        local farewell = Utils.GetRandomElement(npc.dialogue_config.farewells)
        callback(true, {response = farewell, emotion = "neutral"})
    else
        -- 根据语言配置选择默认告别语
        local farewells = Config.Language == 'zh' and DefaultFarewellsZH or DefaultFarewellsEN
        callback(true, {response = Utils.GetRandomElement(farewells), emotion = "neutral"})
    end
end

_G.DialogueHandler = DialogueHandler

-- 事件：开始对话
RegisterNetEvent('ainpc:server:startDialogue', function(npcId)
    local src = source
    DialogueHandler.GenerateGreeting(npcId, src, function(success, data)
        if success then
            TriggerClientEvent('ainpc:client:receiveMessage', src, npcId, data)
        end
    end)
end)

-- 事件：发送消息
RegisterNetEvent('ainpc:server:sendMessage', function(npcId, message)
    local src = source
    
    -- 清理输入
    message = Utils.SanitizeString(message, 500)
    
    if not message or message == "" then
        return
    end
    
    DialogueHandler.ProcessDialogue(npcId, src, message, function(success, data)
        if success then
            TriggerClientEvent('ainpc:client:receiveMessage', src, npcId, data)
        else
            TriggerClientEvent('QBCore:Notify', src, _('notify.ollama_error'), 'error')
        end
    end)
end)

-- 事件：结束对话
RegisterNetEvent('ainpc:server:endDialogue', function(npcId)
    local src = source
    DialogueHandler.GenerateFarewell(npcId, function(success, data)
        if success then
            TriggerClientEvent('ainpc:client:receiveMessage', src, npcId, data)
        end
    end)
end)
