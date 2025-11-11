-- ============================================
-- Admin Commands
-- ============================================

-- 打开管理面板
QBCore.Commands.Add('npcadmin', _('command.npcadmin'), {}, false, function(source)
    if not HasPermission(source, "admin") then
        TriggerClientEvent('QBCore:Notify', source, _('notify.permission_denied'), 'error')
        return
    end
    
    TriggerClientEvent('ainpc:client:openAdminPanel', source)
end, 'admin')

-- 创建NPC
QBCore.Commands.Add('createnpc', _('command.createnpc'), {}, false, function(source)
    if not HasPermission(source, "admin") then
        TriggerClientEvent('QBCore:Notify', source, _('notify.permission_denied'), 'error')
        return
    end
    
    TriggerClientEvent('ainpc:client:openCreateWizard', source)
end, 'admin')

-- 编辑NPC
QBCore.Commands.Add('editnpc', _('command.editnpc'), {{name = 'id', help = 'NPC ID'}}, true, function(source, args)
    if not HasPermission(source, "admin") then
        TriggerClientEvent('QBCore:Notify', source, _('notify.permission_denied'), 'error')
        return
    end
    
    local id = tonumber(args[1])
    if not id or not ActiveNPCs[id] then
        TriggerClientEvent('QBCore:Notify', source, _('notify.npc_not_found'), 'error')
        return
    end
    
    TriggerClientEvent('ainpc:client:editNPC', source, id)
end, 'admin')

-- 删除NPC
QBCore.Commands.Add('deletenpc', _('command.deletenpc'), {{name = 'id', help = 'NPC ID'}}, true, function(source, args)
    if not HasPermission(source, "admin") then
        TriggerClientEvent('QBCore:Notify', source, _('notify.permission_denied'), 'error')
        return
    end
    
    local id = tonumber(args[1])
    if not id or not ActiveNPCs[id] then
        TriggerClientEvent('QBCore:Notify', source, _('notify.npc_not_found'), 'error')
        return
    end
    
    NPCManager.DeleteNPC(id, function(success)
        if success then
            TriggerClientEvent('QBCore:Notify', source, _('notify.npc_deleted'), 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, _('notify.error'), 'error')
        end
    end)
end, 'admin')

-- 传送到NPC
QBCore.Commands.Add('tpnpc', 'Teleport to NPC', {{name = 'id', help = 'NPC ID'}}, true, function(source, args)
    if not HasPermission(source, "admin") then
        TriggerClientEvent('QBCore:Notify', source, _('notify.permission_denied'), 'error')
        return
    end
    
    local id = tonumber(args[1])
    if not id or not ActiveNPCs[id] then
        TriggerClientEvent('QBCore:Notify', source, _('notify.npc_not_found'), 'error')
        return
    end
    
    local npc = ActiveNPCs[id]
    TriggerClientEvent('ainpc:client:teleportToNPC', source, npc.position)
end, 'admin')

-- 列出所有NPC
QBCore.Commands.Add('listnpcs', 'List all NPCs', {}, false, function(source)
    if not HasPermission(source, "admin") then
        TriggerClientEvent('QBCore:Notify', source, _('notify.permission_denied'), 'error')
        return
    end
    
    local count = Utils.TableLength(ActiveNPCs)
    print(("^2=== NPC List (%d NPCs) ===^0"):format(count))
    
    for id, npc in pairs(ActiveNPCs) do
        print(("^3ID: %d | Name: %s | Model: %s | Status: %s^0"):format(
            id, 
            npc.name, 
            npc.model,
            npc.status == 1 and "Enabled" or "Disabled"
        ))
    end
end, 'admin')

-- 切换NPC状态
QBCore.Commands.Add('togglenpc', 'Toggle NPC', {{name = 'id', help = 'NPC ID'}}, true, function(source, args)
    if not HasPermission(source, "admin") then
        TriggerClientEvent('QBCore:Notify', source, _('notify.permission_denied'), 'error')
        return
    end
    
    local id = tonumber(args[1])
    if not id or not ActiveNPCs[id] then
        TriggerClientEvent('QBCore:Notify', source, _('notify.npc_not_found'), 'error')
        return
    end
    
    NPCManager.ToggleNPC(id, function(success, newStatus)
        if success then
            local status = newStatus == 1 and _('common.enabled') or _('common.disabled')
            TriggerClientEvent('QBCore:Notify', source, 'NPC ' .. status, 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, _('notify.error'), 'error')
        end
    end)
end, 'admin')

-- 导出NPC
QBCore.Commands.Add('exportnpc', 'Export NPC', {{name = 'id', help = 'NPC ID'}}, true, function(source, args)
    if not HasPermission(source, "admin") then
        TriggerClientEvent('QBCore:Notify', source, _('notify.permission_denied'), 'error')
        return
    end
    
    local id = tonumber(args[1])
    if not id or not ActiveNPCs[id] then
        TriggerClientEvent('QBCore:Notify', source, _('notify.npc_not_found'), 'error')
        return
    end
    
    local exportData = NPCManager.ExportNPC(id)
    if exportData then
        print("^2=== NPC Export ===^0")
        print(exportData)
        TriggerClientEvent('QBCore:Notify', source, 'Check server console for export data', 'success')
    end
end, 'admin')
