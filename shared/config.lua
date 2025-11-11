Config = {}

-- 语言设置
Config.Language = 'zh' -- 'zh' 或 'en' 
-- 影响范围：
-- 1. UI界面文本
-- 2. AI对话提示词
-- 3. 默认问候语和告别语
-- 4. NPC回复语言

-- Ollama 配置
Config.Ollama = {
    Enabled = true,
    Host = "http://localhost:11434", -- Ollama 服务器地址
    Model = "qwen2:7b", -- 默认AI模型
    Timeout = 30000, -- 请求超时(毫秒)
    Temperature = 0.7, -- 创造性 (0-1)
    MaxTokens = 2048, -- 最大token数
    StreamResponse = false, -- 是否使用流式响应
}

-- NPC 配置
Config.NPC = {
    InteractionDistance = 3.0, -- 交互距离(米)
    DrawDistance = 50.0, -- NPC渲染距离
    MaxMemoryLength = 10, -- NPC记忆的最大对话条数
    SaveInterval = 300000, -- 自动保存间隔(5分钟)
    DefaultModel = "a_m_m_business_01", -- 默认NPC模型
    RespawnOnDelete = false, -- 删除后是否重生
}

-- 动画配置
Config.Animation = {
    UseAI = true, -- 使用AI决定动作
    DefaultEmotion = "neutral", -- 默认情绪
    TransitionTime = 1000, -- 动画过渡时间(毫秒)
    EmotionAnimations = {
        happy = "WORLD_HUMAN_CHEERING",
        sad = "WORLD_HUMAN_BUM_STANDING",
        angry = "WORLD_HUMAN_GUARD_STAND",
        neutral = "WORLD_HUMAN_STAND_IMPATIENT",
        confused = "WORLD_HUMAN_TOURIST_MAP",
        surprised = "WORLD_HUMAN_STUPOR"
    }
}

-- 对话配置
Config.Dialogue = {
    TypewriterEffect = true, -- 打字机效果
    TypewriterSpeed = 50, -- 打字速度(毫秒/字符)
    MaxDialogueLength = 500, -- 最大对话长度
    SaveHistory = true, -- 保存对话历史
    ShowEmotion = true, -- 显示NPC情绪
}

-- UI 配置
Config.UI = {
    Theme = "dark", -- 主题 'dark' 或 'light'
    FontSize = 16, -- 字体大小
    EnableSound = true, -- 启用音效
    AdminKey = 'F7', -- 管理面板快捷键
}

-- 目标系统配置
Config.Target = {
    System = "qb-target", -- 可选: "qb-target", "ox_target", "none"
    -- none = 使用默认的按E键交互
    -- qb-target = 使用 qb-target
    -- ox_target = 使用 ox_target
    
    Icon = "fas fa-comments", -- 目标图标
    Distance = 2.5, -- 目标交互距离
}

-- 权限配置
Config.Permissions = {
    AdminGroup = "admin", -- 管理员组
    ModeratorGroup = "mod", -- 审核员组
    AllowedJobs = {}, -- 允许的工作(为空则不限制)
}

-- 调试配置
Config.Debug = {
    Enabled = false, -- 调试模式
    LogLevel = "info", -- 日志级别: debug, info, warn, error
    ShowPrompts = false, -- 显示AI提示词
    ShowNPCIds = false, -- 在NPC上方显示ID
}

-- 性能配置
Config.Performance = {
    EnableCache = true, -- 启用缓存
    CacheExpire = 3600, -- 缓存过期时间(秒)
    MaxConcurrentRequests = 5, -- 最大并发AI请求
    NPCSleepDistance = 100.0, -- NPC休眠距离
}

-- 预设性格模板
Config.Personalities = {
    friendly = {
        name = "友好",
        traits = {
            friendliness = 0.9,
            talkativeness = 0.8,
            formality = 0.3,
            emotionality = 0.6,
            humor = 0.7
        }
    },
    serious = {
        name = "严肃",
        traits = {
            friendliness = 0.5,
            talkativeness = 0.4,
            formality = 0.9,
            emotionality = 0.3,
            humor = 0.2
        }
    },
    humorous = {
        name = "幽默",
        traits = {
            friendliness = 0.8,
            talkativeness = 0.9,
            formality = 0.2,
            emotionality = 0.7,
            humor = 0.95
        }
    },
    shy = {
        name = "害羞",
        traits = {
            friendliness = 0.6,
            talkativeness = 0.3,
            formality = 0.6,
            emotionality = 0.8,
            humor = 0.3
        }
    },
    aggressive = {
        name = "好斗",
        traits = {
            friendliness = 0.2,
            talkativeness = 0.6,
            formality = 0.4,
            emotionality = 0.9,
            humor = 0.3
        }
    }
}

-- 预设职业
Config.Occupations = {
    { value = "shopkeeper", label = "商店老板" },
    { value = "police", label = "警察" },
    { value = "doctor", label = "医生" },
    { value = "mechanic", label = "机械师" },
    { value = "citizen", label = "平民" },
    { value = "bartender", label = "酒保" },
    { value = "taxi_driver", label = "出租车司机" },
    { value = "banker", label = "银行职员" },
}

-- NPC模型列表
Config.NPCModels = {
    -- 男性
    "a_m_m_business_01",
    "a_m_m_bevhills_01",
    "a_m_m_beach_01",
    "a_m_m_farmer_01",
    "a_m_m_fatlatin_01",
    "a_m_m_genfat_01",
    "a_m_m_golfer_01",
    "a_m_m_hasjew_01",
    -- 女性
    "a_f_m_beach_01",
    "a_f_m_bevhills_01",
    "a_f_m_bodybuild_01",
    "a_f_m_business_02",
    "a_f_m_downtown_01",
    "a_f_m_eastsa_01",
    "a_f_m_fatwhite_01",
}
