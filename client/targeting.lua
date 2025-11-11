-- ============================================
-- Targeting System - 目标系统集成
-- ============================================

-- 根据配置自动选择目标系统
local function InitializeTargeting()
    local targetSystem = Config.Target.System
    
    -- 如果配置为none，使用默认按E键交互
    if targetSystem == "none" then
        Utils.Debug("Using default interaction (E key)", "info")
        return
    end
    
    -- qb-target 集成
    if targetSystem == "qb-target" then
        if GetResourceState('qb-target') == 'started' then
            Utils.Debug("Initializing qb-target integration", "info")
            
            exports['qb-target']:AddTargetModel(Config.NPCModels, {
                options = {
                    {
                        icon = Config.Target.Icon,
                        label = _('dialogue.chat_with'),
                        action = function(entity)
                            for id, npc in pairs(SpawnedNPCs) do
                                if npc.ped == entity then
                                    NPCInteraction.StartInteraction(id)
                                    break
                                end
                            end
                        end,
                        canInteract = function(entity)
                            for id, npc in pairs(SpawnedNPCs) do
                                if npc.ped == entity then
                                    return npc.data.status == 1
                                end
                            end
                            return false
                        end
                    }
                },
                distance = Config.Target.Distance
            })
        else
            Utils.Debug("qb-target not found, falling back to default", "warn")
        end
        return
    end
    
    -- ox_target 集成
    if targetSystem == "ox_target" then
        if GetResourceState('ox_target') == 'started' then
            Utils.Debug("Initializing ox_target integration", "info")
            
            exports.ox_target:addModel(Config.NPCModels, {
                {
                    name = 'ainpc_interact',
                    icon = Config.Target.Icon,
                    label = _('dialogue.chat_with'),
                    onSelect = function(data)
                        for id, npc in pairs(SpawnedNPCs) do
                            if npc.ped == data.entity then
                                NPCInteraction.StartInteraction(id)
                                break
                            end
                        end
                    end,
                    canInteract = function(entity, distance, coords, name)
                        for id, npc in pairs(SpawnedNPCs) do
                            if npc.ped == entity then
                                return npc.data.status == 1
                            end
                        end
                        return false
                    end,
                    distance = Config.Target.Distance
                }
            })
        else
            Utils.Debug("ox_target not found, falling back to default", "warn")
        end
        return
    end
    
    Utils.Debug("Invalid target system configured, using default", "warn")
end

-- 等待资源启动后初始化
CreateThread(function()
    Wait(1000) -- 等待其他资源加载
    InitializeTargeting()
end)

-- 清理函数（资源停止时调用）
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    local targetSystem = Config.Target.System
    
    if targetSystem == "qb-target" and GetResourceState('qb-target') == 'started' then
        exports['qb-target']:RemoveTargetModel(Config.NPCModels)
    end
    
    if targetSystem == "ox_target" and GetResourceState('ox_target') == 'started' then
        exports.ox_target:removeModel(Config.NPCModels)
    end
end)
