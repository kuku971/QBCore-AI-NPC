-- ============================================
-- UI Handler - UI事件处理
-- ============================================

UIHandler = {}
local nuiReady = false

-- NUI回调
RegisterNUICallback('ready', function(data, cb)
    nuiReady = true
    -- 发送语言数据
    SendNUIMessage({
        action = 'setLanguage',
        language = Locale:ExportForNUI()
    })
    cb('ok')
end)

-- 关闭NUI
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- 打开管理面板
function UIHandler.OpenAdminPanel()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openAdminPanel',
        npcs = SpawnedNPCs
    })
end

-- 打开创建向导
function UIHandler.OpenCreateWizard()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openCreateWizard',
        currentPosition = {
            x = playerCoords.x,
            y = playerCoords.y,
            z = playerCoords.z
        },
        currentHeading = heading,
        models = Config.NPCModels,
        occupations = Config.Occupations,
        personalities = Config.Personalities
    })
end

-- 打开编辑面板
function UIHandler.OpenEditPanel(npcId)
    local npc = SpawnedNPCs[npcId]
    if not npc then return end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openEditPanel',
        npc = npc.data
    })
end

-- 打开对话界面
function UIHandler.OpenDialogue(npcId, npcData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openDialogue',
        npcId = npcId,
        npcName = npcData.name,
        npcOccupation = npcData.occupation
    })
end

-- 关闭对话界面
function UIHandler.CloseDialogue()
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'closeDialogue'
    })
end

-- 显示NPC消息
function UIHandler.ShowNPCMessage(npcId, data)
    SendNUIMessage({
        action = 'npcMessage',
        npcId = npcId,
        message = data.response,
        emotion = data.emotion
    })
end

-- 更新关系信息
function UIHandler.UpdateRelationship(npcId, data)
    SendNUIMessage({
        action = 'updateRelationship',
        npcId = npcId,
        relationship = data
    })
end

-- NUI回调：创建NPC
RegisterNUICallback('createNPC', function(data, cb)
    QBCore.Functions.TriggerCallback('ainpc:server:createNPC', function(success, result)
        if success then
            QBCore.Functions.Notify(_('notify.npc_created'), 'success')
            cb({success = true, npc = result})
        else
            QBCore.Functions.Notify(_('notify.error') .. ': ' .. result, 'error')
            cb({success = false, error = result})
        end
    end, data)
end)

-- NUI回调：更新NPC
RegisterNUICallback('updateNPC', function(data, cb)
    QBCore.Functions.TriggerCallback('ainpc:server:updateNPC', function(success, result)
        if success then
            QBCore.Functions.Notify(_('notify.npc_updated'), 'success')
            cb({success = true})
        else
            QBCore.Functions.Notify(_('notify.error'), 'error')
            cb({success = false})
        end
    end, data.id, data.data)
end)

-- NUI回调：删除NPC
RegisterNUICallback('deleteNPC', function(data, cb)
    QBCore.Functions.TriggerCallback('ainpc:server:deleteNPC', function(success)
        if success then
            QBCore.Functions.Notify(_('notify.npc_deleted'), 'success')
            cb({success = true})
        else
            cb({success = false})
        end
    end, data.id)
end)

-- NUI回调：发送消息
RegisterNUICallback('sendMessage', function(data, cb)
    NPCInteraction.SendMessage(data.message)
    cb('ok')
end)

-- NUI回调：结束对话
RegisterNUICallback('endDialogue', function(data, cb)
    NPCInteraction.EndInteraction()
    cb('ok')
end)

-- 服务器回调注册
QBCore.Functions.CreateClientCallback('ainpc:client:getNearbyNPCs', function(cb)
    cb(NPCSpawner.GetNearbyNPCs(50.0))
end)

_G.UIHandler = UIHandler
