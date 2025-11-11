-- ============================================
-- Memory System - NPC记忆系统
-- ============================================

MemorySystem = {}

-- 获取NPC对玩家的记忆
function MemorySystem.GetMemory(npcId, playerIdentifier, callback)
    Database.GetDialogueHistory(npcId, playerIdentifier, Config.NPC.MaxMemoryLength, function(history)
        Database.GetRelationship(npcId, playerIdentifier, function(relationship)
            callback({
                dialogues = history or {},
                relationship = relationship,
                summary = MemorySystem.GenerateSummary(history)
            })
        end)
    end)
end

-- 生成记忆摘要
function MemorySystem.GenerateSummary(dialogues)
    if not dialogues or #dialogues == 0 then
        return "这是你们第一次对话"
    end
    
    local count = #dialogues
    local lastTime = dialogues[1].timestamp
    
    return string.format("你们已经对话了 %d 次，最后一次是在 %s", 
        count, 
        Utils.FormatTimestamp(lastTime)
    )
end

-- 清理旧记忆（保留最近N条）
function MemorySystem.CleanOldMemories(npcId, playerIdentifier, keepCount)
    keepCount = keepCount or Config.NPC.MaxMemoryLength
    
    MySQL.query([[
        DELETE FROM ainpc_dialogues 
        WHERE npc_id = ? AND player_identifier = ? 
        AND id NOT IN (
            SELECT id FROM (
                SELECT id FROM ainpc_dialogues 
                WHERE npc_id = ? AND player_identifier = ?
                ORDER BY timestamp DESC 
                LIMIT ?
            ) tmp
        )
    ]], {npcId, playerIdentifier, npcId, playerIdentifier, keepCount})
end

_G.MemorySystem = MemorySystem
