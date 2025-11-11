-- ============================================
-- Database Operations
-- ============================================

Database = {}

-- 初始化数据库
function Database.Init()
    Utils.Debug("Initializing database...", "info")
    
    -- 检查表是否存在
    MySQL.query('SHOW TABLES LIKE "ainpc_data"', {}, function(result)
        if not result or #result == 0 then
            print("^3[AI-NPC] Database tables not found. Please run sql/install.sql^0")
        else
            Utils.Debug("Database tables found", "info")
        end
    end)
end

-- 创建NPC
function Database.CreateNPC(data, callback)
    MySQL.insert([[
        INSERT INTO ainpc_data (name, model, gender, age, occupation, personality, backstory, position, heading, ai_config, dialogue_config, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        data.name,
        data.model,
        data.gender or 'male',
        data.age or 30,
        data.occupation or 'citizen',
        json.encode(data.personality or {}),
        data.backstory or '',
        Utils.SerializeCoords(data.position),
        data.heading or 0.0,
        json.encode(data.ai_config or {}),
        json.encode(data.dialogue_config or {}),
        data.status or 1
    }, function(insertId)
        if callback then callback(insertId) end
    end)
end

-- 获取NPC
function Database.GetNPC(id, callback)
    MySQL.query('SELECT * FROM ainpc_data WHERE id = ?', {id}, function(result)
        if result and #result > 0 then
            local npc = result[1]
            npc.position = Utils.DeserializeCoords(npc.position)
            npc.personality = json.decode(npc.personality or '{}')
            npc.ai_config = json.decode(npc.ai_config or '{}')
            npc.dialogue_config = json.decode(npc.dialogue_config or '{}')
            if callback then callback(npc) end
        else
            if callback then callback(nil) end
        end
    end)
end

-- 获取所有NPC
function Database.GetAllNPCs(callback)
    MySQL.query('SELECT * FROM ainpc_data', {}, function(result)
        local npcs = {}
        if result then
            for _, npc in ipairs(result) do
                npc.position = Utils.DeserializeCoords(npc.position)
                npc.personality = json.decode(npc.personality or '{}')
                npc.ai_config = json.decode(npc.ai_config or '{}')
                npc.dialogue_config = json.decode(npc.dialogue_config or '{}')
                npcs[npc.id] = npc
            end
        end
        if callback then callback(npcs) end
    end)
end

-- 更新NPC
function Database.UpdateNPC(id, data, callback)
    local fields = {}
    local values = {}
    
    for key, value in pairs(data) do
        if key ~= 'id' then
            table.insert(fields, key .. ' = ?')
            if key == 'position' then
                table.insert(values, Utils.SerializeCoords(value))
            elseif type(value) == 'table' then
                table.insert(values, json.encode(value))
            else
                table.insert(values, value)
            end
        end
    end
    
    table.insert(values, id)
    
    local query = string.format('UPDATE ainpc_data SET %s WHERE id = ?', table.concat(fields, ', '))
    
    MySQL.update(query, values, function(affectedRows)
        if callback then callback(affectedRows > 0) end
    end)
end

-- 删除NPC
function Database.DeleteNPC(id, callback)
    MySQL.update('DELETE FROM ainpc_data WHERE id = ?', {id}, function(affectedRows)
        if callback then callback(affectedRows > 0) end
    end)
end

-- 保存对话记录
function Database.SaveDialogue(npcId, playerIdentifier, playerMessage, npcResponse, emotion, context, callback)
    MySQL.insert([[
        INSERT INTO ainpc_dialogues (npc_id, player_identifier, player_message, npc_response, emotion, context)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], {
        npcId,
        playerIdentifier,
        playerMessage,
        npcResponse,
        emotion or 'neutral',
        json.encode(context or {})
    }, function(insertId)
        if callback then callback(insertId) end
    end)
end

-- 获取对话历史
function Database.GetDialogueHistory(npcId, playerIdentifier, limit, callback)
    limit = limit or 10
    MySQL.query([[
        SELECT * FROM ainpc_dialogues 
        WHERE npc_id = ? AND player_identifier = ?
        ORDER BY timestamp DESC
        LIMIT ?
    ]], {npcId, playerIdentifier, limit}, function(result)
        if callback then callback(result or {}) end
    end)
end

-- 更新玩家关系
function Database.UpdateRelationship(npcId, playerIdentifier, level, callback)
    MySQL.query([[
        INSERT INTO ainpc_relationships (npc_id, player_identifier, relationship_level, interactions_count, last_interaction)
        VALUES (?, ?, ?, 1, NOW())
        ON DUPLICATE KEY UPDATE 
            relationship_level = ?,
            interactions_count = interactions_count + 1,
            last_interaction = NOW()
    ]], {npcId, playerIdentifier, level, level}, function(result)
        if callback then callback(result) end
    end)
end

-- 获取玩家关系
function Database.GetRelationship(npcId, playerIdentifier, callback)
    MySQL.query([[
        SELECT * FROM ainpc_relationships 
        WHERE npc_id = ? AND player_identifier = ?
    ]], {npcId, playerIdentifier}, function(result)
        if result and #result > 0 then
            if callback then callback(result[1]) end
        else
            if callback then callback(nil) end
        end
    end)
end

-- 记录日志
function Database.LogAction(logType, npcId, playerIdentifier, action, details, callback)
    MySQL.insert([[
        INSERT INTO ainpc_logs (log_type, npc_id, player_identifier, action, details)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        logType,
        npcId,
        playerIdentifier,
        action,
        json.encode(details or {})
    }, function(insertId)
        if callback then callback(insertId) end
    end)
end

_G.Database = Database
