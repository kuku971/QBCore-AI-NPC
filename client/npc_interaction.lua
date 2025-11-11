-- ============================================
-- NPC Interaction - 交互系统
-- ============================================

NPCInteraction = {}
local isInteracting = false

-- 开始交互
function NPCInteraction.StartInteraction(npcId)
    if isInteracting then return end
    
    local npc = SpawnedNPCs[npcId]
    if not npc then return end
    
    isInteracting = true
    CurrentInteraction = npcId
    
    -- 面向玩家
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local npcCoords = GetEntityCoords(npc.ped)
    local heading = GetHeadingFromVector_2d(playerCoords.x - npcCoords.x, playerCoords.y - npcCoords.y)
    SetEntityHeading(npc.ped, heading)
    
    -- 播放问候动画
    NPCAnimation.PlayGesture(npcId, "GESTURE_HELLO")
    
    -- 请求问候语
    TriggerServerEvent('ainpc:server:startDialogue', npcId)
    
    -- 打开对话UI
    UIHandler.OpenDialogue(npcId, npc.data)
    
    -- 获取关系信息
    TriggerServerEvent('ainpc:server:getRelationship', npcId)
    
    Utils.Debug(("Started interaction with NPC: %d"):format(npcId), "debug")
end

-- 结束交互
function NPCInteraction.EndInteraction()
    if not isInteracting then return end
    
    local npcId = CurrentInteraction
    
    -- 发送告别
    TriggerServerEvent('ainpc:server:endDialogue', npcId)
    
    Wait(1000)
    
    -- 播放告别动画
    if SpawnedNPCs[npcId] then
        NPCAnimation.PlayGesture(npcId, "GESTURE_BYE_HARD")
    end
    
    -- 关闭UI
    UIHandler.CloseDialogue()
    
    isInteracting = false
    CurrentInteraction = nil
    
    Utils.Debug(("Ended interaction with NPC: %d"):format(npcId), "debug")
end

-- 发送消息
function NPCInteraction.SendMessage(message)
    if not isInteracting or not CurrentInteraction then return end
    
    TriggerServerEvent('ainpc:server:sendMessage', CurrentInteraction, message)
end

-- 交互检测线程（仅在使用默认交互时启用）
CreateThread(function()
    while true do
        local sleep = 500
        
        -- 如果使用第三方目标系统，不运行默认交互检测
        if Config.Target.System == "none" then
            if not isInteracting then
                local closest = NPCSpawner.GetClosestNPC()
                
                if closest and closest.distance <= Config.NPC.InteractionDistance then
                    sleep = 0
                    
                    -- 按E键交互
                    if IsControlJustReleased(0, 38) then -- E key
                        NPCInteraction.StartInteraction(closest.id)
                    end
                end
            else
                sleep = 100
                
                -- 按ESC或距离太远时结束交互
                local npc = SpawnedNPCs[CurrentInteraction]
                if npc and DoesEntityExist(npc.ped) then
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local npcCoords = GetEntityCoords(npc.ped)
                    local distance = #(playerCoords - npcCoords)
                    
                    if distance > Config.NPC.InteractionDistance * 2 then
                        NPCInteraction.EndInteraction()
                        QBCore.Functions.Notify(_('notify.too_far'), 'error')
                    end
                end
            end
        else
            sleep = 5000
        end
        
        Wait(sleep)
    end
end)

_G.NPCInteraction = NPCInteraction
