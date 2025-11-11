-- ============================================
-- AI-NPC 多语言系统
-- ============================================

local Locale = {
    current = Config and Config.Language or 'zh',
    data = {},
    fallback = 'en'
}

-- 加载JSON语言文件
local function LoadLanguageFile(lang)
    local file = ('local/%s.json'):format(lang)
    local data = LoadResourceFile(GetCurrentResourceName(), file)
    
    if not data then
        return nil, ('Language file not found: %s'):format(file)
    end
    
    local success, decoded = pcall(json.decode, data)
    if not success then
        return nil, ('Failed to parse JSON: %s'):format(file)
    end
    
    return decoded
end

-- 初始化语言系统
local function Init()
    -- 加载主语言
    local main, err = LoadLanguageFile(Locale.current)
    if main then
        Locale.data[Locale.current] = main
        print(('[AI-NPC] Loaded language: %s'):format(Locale.current))
    else
        print(('[AI-NPC] ERROR: %s'):format(err))
    end
    
    -- 加载备用语言
    if Locale.current ~= Locale.fallback then
        local backup = LoadLanguageFile(Locale.fallback)
        if backup then
            Locale.data[Locale.fallback] = backup
        end
    end
end

-- 获取嵌套值
local function GetNestedValue(tbl, keys)
    local value = tbl
    for _, key in ipairs(keys) do
        if type(value) ~= 'table' or not value[key] then
            return nil
        end
        value = value[key]
    end
    return value
end

-- 获取翻译（支持回退）
local function GetTranslation(key)
    local keys = {}
    for k in string.gmatch(key, '[^.]+') do
        keys[#keys + 1] = k
    end
    
    -- 尝试主语言
    local lang = Locale.data[Locale.current]
    if lang then
        local value = GetNestedValue(lang, keys)
        if value then return value end
    end
    
    -- 回退到备用语言
    local fallback = Locale.data[Locale.fallback]
    if fallback and Locale.current ~= Locale.fallback then
        local value = GetNestedValue(fallback, keys)
        if value then return value end
    end
    
    return key -- 都没找到，返回键名
end

-- 替换变量
local function ReplaceVars(text, vars)
    if not vars or type(text) ~= 'string' then
        return text
    end
    
    for k, v in pairs(vars) do
        text = text:gsub('{' .. k .. '}', tostring(v))
    end
    return text
end

-- 主翻译函数
function _(key, vars)
    local text = GetTranslation(key)
    return ReplaceVars(text, vars)
end

-- 切换语言
function Locale:SetLanguage(lang)
    if not self.data[lang] then
        local data, err = LoadLanguageFile(lang)
        if not data then
            print(('[AI-NPC] Failed to load language %s: %s'):format(lang, err))
            return false
        end
        self.data[lang] = data
    end
    self.current = lang
    print(('[AI-NPC] Language changed to: %s'):format(lang))
    return true
end

-- 获取可用语言
function Locale:GetAvailable()
    local langs = {}
    for lang in pairs(self.data) do
        langs[#langs + 1] = lang
    end
    return langs
end

-- 获取当前语言
function Locale:GetCurrent()
    return self.current
end

-- 导出用于NUI
function Locale:ExportForNUI()
    return self.data[self.current] or {}
end

-- 初始化
Init()

-- 全局导出
_G.Locale = Locale
_G._ = _
