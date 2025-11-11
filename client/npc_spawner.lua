-- ============================================
-- NPC Spawner - NPC生成管理
-- ============================================

NPCSpawner = {}

-- 生成NPC
function NPCSpawner.SpawnNPC(data)
    if SpawnedNPCs[data.id] then
        Utils.Debug(("NPC already spawned: %d"):format(data.id), "warn")
        return
    end
    
    local model = GetHashKey(data.model)
    
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end
    
    local coords = data.position
    local heading = data.heading or 0.0
    
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading, false, true)
    
    -- 设置NPC属性
    SetEntityAsMissionEntity(ped, true, true)
    SetPedCanRagdoll(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanPlayAmbientBaseAnims(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    
    -- 保存到列表
    SpawnedNPCs[data.id] = {
        id = data.id,
        ped = ped,
        data = data,
        lastInteraction = 0
    }
    
    -- 如果有默认动画，播放
    if data.dialogue_config and data.dialogue_config.idle_animation then
        NPCAnimation.PlayIdle(data.id, data.dialogue_config.idle_animation)
    else
        NPCAnimation.PlayIdle(data.id, "WORLD_HUMAN_STAND_IMPATIENT")
    end
    
    Utils.Debug(("NPC spawned: %s (ID: %d)"):format(data.name, data.id), "debug")
    
    SetModelAsNoLongerNeeded(model)
end

-- 删除NPC
function NPCSpawner.DeleteNPC(id)
    if not SpawnedNPCs[id] then return end
    
    local npc = SpawnedNPCs[id]
    
    if DoesEntityExist(npc.ped) then
        DeleteEntity(npc.ped)
    end
    
    SpawnedNPCs[id] = nil
    
    Utils.Debug(("NPC deleted: ID %d"):format(id), "debug")
end

-- 获取附近的NPC
function NPCSpawner.GetNearbyNPCs(radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearby = {}
    
    for id, npc in pairs(SpawnedNPCs) do
        if DoesEntityExist(npc.ped) then
            local npcCoords = GetEntityCoords(npc.ped)
            local distance = #(playerCoords - npcCoords)
            
            if distance <= radius then
                table.insert(nearby, {
                    id = id,
                    distance = distance,
                    data = npc.data,
                    ped = npc.ped
                })
            end
        end
    end
    
    -- 按距离排序
    table.sort(nearby, function(a, b) return a.distance < b.distance end)
    
    return nearby
end

-- 获取最近的NPC
function NPCSpawner.GetClosestNPC()
    local nearby = NPCSpawner.GetNearbyNPCs(Config.NPC.InteractionDistance)
    return nearby[1] or nil
end

-- NPC渲染线程
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for id, npc in pairs(SpawnedNPCs) do
            if DoesEntityExist(npc.ped) then
                local npcCoords = GetEntityCoords(npc.ped)
                local distance = #(playerCoords - npcCoords)
                
                -- 在交互距离内显示提示
                if distance <= Config.NPC.InteractionDistance then
                    sleep = 0
                    DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, 
                        string.format("~g~[E]~w~ %s", npc.data.name))
                    
                    -- 调试模式显示ID
                    if Config.Debug.ShowNPCIds then
                        DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.2, 
                            string.format("~y~ID: %d~w~", id))
                    end
                end
            end
        end
        
        Wait(sleep)
    end
end)

-- 3D文本绘制
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

_G.NPCSpawner = NPCSpawner
