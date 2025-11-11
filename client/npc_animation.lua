-- ============================================
-- NPC Animation - 动画控制
-- ============================================

NPCAnimation = {}

-- 播放情绪动画
function NPCAnimation.PlayEmotion(npcId, emotion)
    local npc = SpawnedNPCs[npcId]
    if not npc or not DoesEntityExist(npc.ped) then 
        return 
    end
    
    local scenario = Config.Animation.EmotionAnimations[emotion] or Config.Animation.EmotionAnimations.neutral
    
    -- 清除当前场景
    ClearPedTasks(npc.ped)
    
    Wait(100)
    
    -- 播放新场景
    TaskStartScenarioInPlace(npc.ped, scenario, 0, true)
    
    if Config.Debug and Config.Debug.Enabled then
        print(string.format("[AI-NPC] Playing emotion: %s for NPC: %d", emotion, npcId))
    end
end

-- 播放空闲动画
function NPCAnimation.PlayIdle(npcId, scenario)
    local npc = SpawnedNPCs[npcId]
    if not npc or not DoesEntityExist(npc.ped) then 
        return 
    end
    
    scenario = scenario or "WORLD_HUMAN_STAND_IMPATIENT"
    
    TaskStartScenarioInPlace(npc.ped, scenario, 0, true)
end

-- 播放手势
function NPCAnimation.PlayGesture(npcId, gesture)
    local npc = SpawnedNPCs[npcId]
    if not npc or not DoesEntityExist(npc.ped) then 
        return 
    end
    
    local animations = {
        GESTURE_HELLO = {"gestures@m@standing@casual", "gesture_hello"},
        GESTURE_BYE_HARD = {"gestures@m@standing@casual", "gesture_bye_hard"},
        GESTURE_POINT = {"gestures@m@standing@casual", "gesture_point"},
        GESTURE_NOD = {"gestures@m@standing@casual", "gesture_nod_yes"},
        GESTURE_SHRUG = {"gestures@m@standing@casual", "gesture_shrug_hard"}
    }
    
    local anim = animations[gesture]
    if not anim then 
        return 
    end
    
    RequestAnimDict(anim[1])
    while not HasAnimDictLoaded(anim[1]) do
        Wait(50)
    end
    
    TaskPlayAnim(npc.ped, anim[1], anim[2], 8.0, -8.0, -1, 49, 0, false, false, false)
    
    Wait(2000)
    RemoveAnimDict(anim[1])
end

-- 播放自定义动画
function NPCAnimation.PlayAnimation(npcId, dict, name, duration)
    local npc = SpawnedNPCs[npcId]
    if not npc or not DoesEntityExist(npc.ped) then 
        return 
    end
    
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(50)
    end
    
    TaskPlayAnim(npc.ped, dict, name, 8.0, -8.0, duration or -1, 1, 0, false, false, false)
end

-- 停止动画
function NPCAnimation.StopAnimation(npcId)
    local npc = SpawnedNPCs[npcId]
    if not npc or not DoesEntityExist(npc.ped) then 
        return 
    end
    
    ClearPedTasks(npc.ped)
end

-- 让NPC看向玩家
function NPCAnimation.LookAtPlayer(npcId, duration)
    local npc = SpawnedNPCs[npcId]
    if not npc or not DoesEntityExist(npc.ped) then 
        return 
    end
    
    local playerPed = PlayerPedId()
    
    TaskLookAtEntity(npc.ped, playerPed, duration or 3000, 2048, 3)
end

_G.NPCAnimation = NPCAnimation
