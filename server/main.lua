-- ============================================
-- AI-NPC Server Main
-- ============================================

QBCore = exports['qb-core']:GetCoreObject()

-- 全局变量
NPCManager = {}
ActiveNPCs = {}
PlayerInteractions = {}

-- 资源启动
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print("^2========================================^0")
    print("^2  AI-NPC System Starting...^0")
    print("^2========================================^0")
    
    -- 初始化数据库
    Database.Init()
    
    -- 加载所有NPC
    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        NPCManager.LoadAllNPCs()
    end)
    
    print("^2[AI-NPC] System started successfully!^0")
end)

-- 资源停止
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print("^3[AI-NPC] Saving all data...^0")
    
    -- 保存所有数据
    for _, npc in pairs(ActiveNPCs) do
        NPCManager.SaveNPC(npc.id)
    end
    
    print("^3[AI-NPC] System stopped^0")
end)

-- 玩家离开服务器
AddEventHandler('playerDropped', function(reason)
    local src = source
    local identifier = QBCore.Functions.GetIdentifier(src, 'license')
    
    if PlayerInteractions[identifier] then
        PlayerInteractions[identifier] = nil
    end
end)

-- 权限检查
function HasPermission(src, level)
    level = level or "admin"
    
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    
    if level == "admin" then
        return QBCore.Functions.HasPermission(src, Config.Permissions.AdminGroup) or
               QBCore.Functions.HasPermission(src, "god")
    elseif level == "mod" then
        return QBCore.Functions.HasPermission(src, Config.Permissions.ModeratorGroup) or
               HasPermission(src, "admin")
    end
    
    return false
end

-- QBCore回调
QBCore.Functions.CreateCallback('ainpc:server:createNPC', function(source, cb, data)
    if not HasPermission(source, "admin") then
        cb(false, "Permission denied")
        return
    end
    
    NPCManager.CreateNPC(data, cb)
end)

QBCore.Functions.CreateCallback('ainpc:server:updateNPC', function(source, cb, id, data)
    if not HasPermission(source, "admin") then
        cb(false, "Permission denied")
        return
    end
    
    NPCManager.UpdateNPC(id, data, cb)
end)

QBCore.Functions.CreateCallback('ainpc:server:deleteNPC', function(source, cb, id)
    if not HasPermission(source, "admin") then
        cb(false)
        return
    end
    
    NPCManager.DeleteNPC(id, cb)
end)

QBCore.Functions.CreateCallback('ainpc:server:getAllNPCs', function(source, cb)
    cb(ActiveNPCs)
end)

QBCore.Functions.CreateCallback('ainpc:server:getNPC', function(source, cb, id)
    cb(ActiveNPCs[id])
end)

-- 导出函数
exports('GetNPCById', function(id)
    return ActiveNPCs[id]
end)

exports('GetAllNPCs', function()
    return ActiveNPCs
end)

exports('HasPermission', HasPermission)
