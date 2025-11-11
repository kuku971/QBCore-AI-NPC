-- ============================================
-- AI-NPC Client Main
-- ============================================

QBCore = exports['qb-core']:GetCoreObject()

-- 全局变量
local SpawnedNPCs = {}
local CurrentInteraction = nil
local PlayerData = {}

-- 资源启动
CreateThread(function()
    Wait(1000)
    PlayerData = QBCore.Functions.GetPlayerData()
    Utils.Debug("Client initialized", "info")
end)

-- 玩家数据更新
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    CurrentInteraction = nil
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(data)
    PlayerData = data
end)

-- 同步所有NPC
RegisterNetEvent('ainpc:client:syncAllNPCs', function(npcs)
    Utils.Debug(("Syncing %d NPCs"):format(Utils.TableLength(npcs)), "info")
    
    -- 删除旧的NPC
    for id, npc in pairs(SpawnedNPCs) do
        if not npcs[id] then
            NPCSpawner.DeleteNPC(id)
        end
    end
    
    -- 生成新的NPC
    for id, data in pairs(npcs) do
        if data.status == 1 then
            NPCSpawner.SpawnNPC(data)
        end
    end
end)

-- 生成单个NPC
RegisterNetEvent('ainpc:client:spawnNPC', function(npc)
    if npc.status == 1 then
        NPCSpawner.SpawnNPC(npc)
        QBCore.Functions.Notify(_('notify.npc_created'), 'success')
    end
end)

-- 更新NPC
RegisterNetEvent('ainpc:client:updateNPC', function(id, data)
    if SpawnedNPCs[id] then
        -- 如果位置改变，重新生成
        if data.position then
            NPCSpawner.DeleteNPC(id)
            Wait(100)
            NPCSpawner.SpawnNPC(Utils.MergeTables(SpawnedNPCs[id], data))
        else
            -- 否则只更新数据
            SpawnedNPCs[id] = Utils.MergeTables(SpawnedNPCs[id], data)
        end
    end
end)

-- 删除NPC
RegisterNetEvent('ainpc:client:deleteNPC', function(id)
    NPCSpawner.DeleteNPC(id)
end)

-- 传送到NPC
RegisterNetEvent('ainpc:client:teleportToNPC', function(coords)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    QBCore.Functions.Notify('Teleported to NPC', 'success')
end)

-- 打开管理面板
RegisterNetEvent('ainpc:client:openAdminPanel', function()
    UIHandler.OpenAdminPanel()
end)

-- 打开创建向导
RegisterNetEvent('ainpc:client:openCreateWizard', function()
    UIHandler.OpenCreateWizard()
end)

-- 编辑NPC
RegisterNetEvent('ainpc:client:editNPC', function(id)
    UIHandler.OpenEditPanel(id)
end)

-- 接收NPC消息
RegisterNetEvent('ainpc:client:receiveMessage', function(npcId, data)
    UIHandler.ShowNPCMessage(npcId, data)
    
    -- 播放情绪动画
    if data.emotion and SpawnedNPCs[npcId] then
        NPCAnimation.PlayEmotion(npcId, data.emotion)
    end
end)

-- 关系数据
RegisterNetEvent('ainpc:client:relationshipData', function(npcId, data)
    UIHandler.UpdateRelationship(npcId, data)
end)

-- 导出函数
exports('GetNearbyNPCs', function(radius)
    return NPCSpawner.GetNearbyNPCs(radius or 10.0)
end)

exports('GetSpawnedNPCs', function()
    return SpawnedNPCs
end)

exports('IsInteracting', function()
    return CurrentInteraction ~= nil
end)

-- 全局导出
_G.SpawnedNPCs = SpawnedNPCs
_G.CurrentInteraction = CurrentInteraction
