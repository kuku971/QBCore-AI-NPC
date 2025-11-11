-- ============================================
-- Relationship System - 关系网络系统
-- ============================================

RelationshipSystem = {}

-- 获取玩家与NPC的关系
function RelationshipSystem.GetPlayerRelationship(npcId, playerIdentifier, callback)
    Database.GetRelationship(npcId, playerIdentifier, callback)
end

-- 获取NPC之间的关系
function RelationshipSystem.GetNPCRelationship(npcId1, npcId2, callback)
    MySQL.query([[
        SELECT * FROM ainpc_npc_relationships 
        WHERE (npc_id_1 = ? AND npc_id_2 = ?) OR (npc_id_1 = ? AND npc_id_2 = ?)
    ]], {npcId1, npcId2, npcId2, npcId1}, function(result)
        if result and #result > 0 then
            callback(result[1])
        else
            callback(nil)
        end
    end)
end

-- 设置NPC之间的关系
function RelationshipSystem.SetNPCRelationship(npcId1, npcId2, relationshipType, level, description, callback)
    MySQL.query([[
        INSERT INTO ainpc_npc_relationships (npc_id_1, npc_id_2, relationship_type, relationship_level, description)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE 
            relationship_type = ?,
            relationship_level = ?,
            description = ?
    ]], {
        npcId1, npcId2, relationshipType, level, description,
        relationshipType, level, description
    }, function(result)
        if callback then callback(result) end
    end)
end

-- 获取关系等级描述
function RelationshipSystem.GetLevelDescription(level)
    if level >= 100 then return "挚友"
    elseif level >= 50 then return "朋友"
    elseif level >= 20 then return "熟人"
    elseif level >= 0 then return "陌生人"
    elseif level >= -20 then return "不喜欢"
    elseif level >= -50 then return "讨厌"
    else return "敌人"
    end
end

_G.RelationshipSystem = RelationshipSystem

-- 事件：获取关系信息
RegisterNetEvent('ainpc:server:getRelationship', function(npcId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    local identifier = Player.PlayerData.license
    
    RelationshipSystem.GetPlayerRelationship(npcId, identifier, function(relationship)
        local level = relationship and relationship.relationship_level or 0
        local description = RelationshipSystem.GetLevelDescription(level)
        
        TriggerClientEvent('ainpc:client:relationshipData', src, npcId, {
            level = level,
            description = description,
            interactions = relationship and relationship.interactions_count or 0
        })
    end)
end)
