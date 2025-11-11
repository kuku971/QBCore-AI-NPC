-- ============================================
-- NPC Manager - 动态NPC管理核心
-- ============================================

NPCManager = {}

-- 加载所有NPC
function NPCManager.LoadAllNPCs()
    Utils.Debug("Loading all NPCs from database...", "info")
    
    Database.GetAllNPCs(function(npcs)
        if npcs then
            ActiveNPCs = npcs
            local count = Utils.TableLength(npcs)
            Utils.Debug(("Loaded %d NPCs"):format(count), "info")
            
            -- 通知所有客户端
            TriggerClientEvent('ainpc:client:syncAllNPCs', -1, npcs)
        else
            Utils.Debug("No NPCs found in database", "warn")
        end
    end)
end

-- 创建NPC
function NPCManager.CreateNPC(data, callback)
    -- 验证数据
    local valid, error = Utils.ValidateNPCData(data)
    if not valid then
        Utils.Debug(("NPC validation failed: %s"):format(error), "error")
        if callback then callback(false, error) end
        return
    end
    
    -- 保存到数据库
    Database.CreateNPC(data, function(insertId)
        if insertId then
            -- 获取完整NPC数据
            Database.GetNPC(insertId, function(npc)
                if npc then
                    ActiveNPCs[insertId] = npc
                    
                    -- 通知所有客户端生成NPC
                    TriggerClientEvent('ainpc:client:spawnNPC', -1, npc)
                    
                    Utils.Debug(("NPC created: %s (ID: %d)"):format(npc.name, insertId), "info")
                    
                    if callback then callback(true, npc) end
                end
            end)
        else
            Utils.Debug("Failed to create NPC in database", "error")
            if callback then callback(false, "Database error") end
        end
    end)
end

-- 更新NPC
function NPCManager.UpdateNPC(id, data, callback)
    if not ActiveNPCs[id] then
        if callback then callback(false, "NPC not found") end
        return
    end
    
    Database.UpdateNPC(id, data, function(success)
        if success then
            -- 更新内存中的NPC数据
            for key, value in pairs(data) do
                ActiveNPCs[id][key] = value
            end
            
            -- 通知所有客户端更新NPC
            TriggerClientEvent('ainpc:client:updateNPC', -1, id, data)
            
            Utils.Debug(("NPC updated: ID %d"):format(id), "info")
            
            if callback then callback(true, ActiveNPCs[id]) end
        else
            Utils.Debug(("Failed to update NPC: ID %d"):format(id), "error")
            if callback then callback(false, "Database error") end
        end
    end)
end

-- 删除NPC
function NPCManager.DeleteNPC(id, callback)
    if not ActiveNPCs[id] then
        if callback then callback(false, "NPC not found") end
        return
    end
    
    local npcName = ActiveNPCs[id].name
    
    Database.DeleteNPC(id, function(success)
        if success then
            ActiveNPCs[id] = nil
            
            -- 通知所有客户端删除NPC
            TriggerClientEvent('ainpc:client:deleteNPC', -1, id)
            
            Utils.Debug(("NPC deleted: %s (ID: %d)"):format(npcName, id), "info")
            
            if callback then callback(true) end
        else
            Utils.Debug(("Failed to delete NPC: ID %d"):format(id), "error")
            if callback then callback(false, "Database error") end
        end
    end)
end

-- 切换NPC状态
function NPCManager.ToggleNPC(id, callback)
    if not ActiveNPCs[id] then
        if callback then callback(false, "NPC not found") end
        return
    end
    
    local newStatus = ActiveNPCs[id].status == 1 and 0 or 1
    
    NPCManager.UpdateNPC(id, {status = newStatus}, function(success)
        if success then
            Utils.Debug(("NPC %s: ID %d"):format(newStatus == 1 and "enabled" or "disabled", id), "info")
            if callback then callback(true, newStatus) end
        else
            if callback then callback(false, "Failed to toggle") end
        end
    end)
end

-- 获取NPC
function NPCManager.GetNPC(id)
    return ActiveNPCs[id]
end

-- 获取所有NPC
function NPCManager.GetAllNPCs()
    return ActiveNPCs
end

-- 保存NPC
function NPCManager.SaveNPC(id)
    if not ActiveNPCs[id] then return false end
    
    local npc = ActiveNPCs[id]
    Database.UpdateNPC(id, npc, function(success)
        if success then
            Utils.Debug(("NPC saved: ID %d"):format(id), "debug")
        end
    end)
    
    return true
end

-- 导出NPC配置
function NPCManager.ExportNPC(id)
    local npc = ActiveNPCs[id]
    if not npc then return nil end
    
    local export = Utils.DeepCopy(npc)
    export.id = nil -- 移除ID，导入时会重新生成
    
    return json.encode(export, {indent = true})
end

-- 导入NPC配置
function NPCManager.ImportNPC(jsonData, callback)
    local success, data = pcall(json.decode, jsonData)
    if not success then
        if callback then callback(false, "Invalid JSON") end
        return
    end
    
    NPCManager.CreateNPC(data, callback)
end

-- 自动保存
if Config.NPC.SaveInterval > 0 then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.NPC.SaveInterval)
            
            local count = 0
            for id, _ in pairs(ActiveNPCs) do
                NPCManager.SaveNPC(id)
                count = count + 1
            end
            
            if count > 0 then
                Utils.Debug(("Auto-saved %d NPCs"):format(count), "debug")
            end
        end
    end)
end

_G.NPCManager = NPCManager
