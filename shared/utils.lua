-- ============================================
-- 工具函数
-- ============================================

Utils = {}

-- 调试打印
function Utils.Debug(message, level)
    if not Config.Debug.Enabled then return end
    
    level = level or "info"
    local prefix = "[AI-NPC]"
    
    if level == "error" then
        print(("^1%s ERROR: %s^0"):format(prefix, message))
    elseif level == "warn" then
        print(("^3%s WARN: %s^0"):format(prefix, message))
    elseif level == "debug" then
        print(("^5%s DEBUG: %s^0"):format(prefix, message))
    else
        print(("^2%s INFO: %s^0"):format(prefix, message))
    end
end

-- 深拷贝表
function Utils.DeepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in next, orig, nil do
            copy[Utils.DeepCopy(k)] = Utils.DeepCopy(v)
        end
        setmetatable(copy, Utils.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- 合并表
function Utils.MergeTables(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
            Utils.MergeTables(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

-- 获取表大小
function Utils.TableLength(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- 检查表中是否存在值
function Utils.TableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- 生成UUID
function Utils.GenerateUUID()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- 格式化时间戳
function Utils.FormatTimestamp(timestamp)
    if not timestamp then return "未知" end
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

-- 计算两点距离
function Utils.GetDistance(coords1, coords2)
    if type(coords1) == "table" then
        coords1 = vector3(coords1.x, coords1.y, coords1.z)
    end
    if type(coords2) == "table" then
        coords2 = vector3(coords2.x, coords2.y, coords2.z)
    end
    return #(coords1 - coords2)
end

-- 验证坐标
function Utils.ValidateCoords(coords)
    if not coords then return false end
    if type(coords) ~= "table" and type(coords) ~= "vector3" then return false end
    
    local x, y, z
    if type(coords) == "table" then
        x, y, z = coords.x, coords.y, coords.z
    else
        x, y, z = coords.x, coords.y, coords.z
    end
    
    return x ~= nil and y ~= nil and z ~= nil
end

-- 转换坐标为vector3
function Utils.ToVector3(coords)
    if type(coords) == "vector3" then
        return coords
    end
    if type(coords) == "table" and coords.x and coords.y and coords.z then
        return vector3(coords.x, coords.y, coords.z)
    end
    return nil
end

-- 序列化坐标
function Utils.SerializeCoords(coords)
    if type(coords) == "vector3" then
        return json.encode({x = coords.x, y = coords.y, z = coords.z})
    end
    return json.encode(coords)
end

-- 反序列化坐标
function Utils.DeserializeCoords(str)
    local success, coords = pcall(json.decode, str)
    if success and coords then
        return vector3(coords.x, coords.y, coords.z)
    end
    return nil
end

-- 清理字符串
function Utils.SanitizeString(str, maxLength)
    if not str then return "" end
    str = tostring(str):gsub("[<>\"']", "")
    if maxLength and #str > maxLength then
        str = str:sub(1, maxLength)
    end
    return str
end

-- 验证NPC数据
function Utils.ValidateNPCData(data)
    if not data then return false, "数据为空" end
    if not data.name or data.name == "" then return false, "名字不能为空" end
    if not data.model or data.model == "" then return false, "模型不能为空" end
    if not Utils.ValidateCoords(data.position) then return false, "坐标无效" end
    return true
end

-- 格式化数字
function Utils.FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

-- 获取随机值
function Utils.GetRandom(min, max)
    return math.random(min, max)
end

-- 获取随机表元素
function Utils.GetRandomElement(tbl)
    if not tbl or #tbl == 0 then return nil end
    return tbl[math.random(#tbl)]
end

-- 延迟执行
function Utils.Delay(ms, callback)
    if IsDuplicityVersion() then
        -- Server side
        SetTimeout(ms, callback)
    else
        -- Client side
        Citizen.SetTimeout(ms, callback)
    end
end

-- Round number
function Utils.Round(num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

_G.Utils = Utils
