-- ============================================
-- Emotion Engine - 情绪分析系统
-- ============================================

EmotionEngine = {}

-- 情绪关键词映射
local EmotionKeywords = {
    happy = {"开心", "高兴", "快乐", "欢迎", "哈哈", "不错", "太好了", "happy", "glad", "great", "wonderful"},
    sad = {"难过", "伤心", "遗憾", "可惜", "抱歉", "失望", "sad", "sorry", "disappointed"},
    angry = {"生气", "愤怒", "烦", "讨厌", "滚", "混蛋", "angry", "mad", "annoyed"},
    surprised = {"惊讶", "什么", "真的", "不会吧", "天啊", "surprised", "wow", "really"},
    confused = {"不明白", "什么意思", "困惑", "奇怪", "confused", "strange"},
    neutral = {"好的", "知道了", "嗯", "哦", "okay", "alright"}
}

-- 简单的关键词情绪分析
function EmotionEngine.AnalyzeEmotion(text, callback)
    if not text or text == "" then
        callback("neutral")
        return
    end
    
    text = text:lower()
    
    local emotionScores = {
        happy = 0,
        sad = 0,
        angry = 0,
        surprised = 0,
        confused = 0,
        neutral = 0
    }
    
    -- 计算每种情绪的得分
    for emotion, keywords in pairs(EmotionKeywords) do
        for _, keyword in ipairs(keywords) do
            keyword = keyword:lower()
            local _, count = text:gsub(keyword, "")
            emotionScores[emotion] = emotionScores[emotion] + count
        end
    end
    
    -- 找出得分最高的情绪
    local maxScore = 0
    local dominantEmotion = "neutral"
    
    for emotion, score in pairs(emotionScores) do
        if score > maxScore then
            maxScore = score
            dominantEmotion = emotion
        end
    end
    
    callback(dominantEmotion)
end

-- 根据情绪获取动画
function EmotionEngine.GetAnimationForEmotion(emotion)
    return Config.Animation.EmotionAnimations[emotion] or Config.Animation.EmotionAnimations.neutral
end

-- 根据对话内容分析推荐动作
function EmotionEngine.SuggestAction(text, emotion, callback)
    local animation = EmotionEngine.GetAnimationForEmotion(emotion)
    
    -- 简单的动作建议
    local actions = {
        greeting = {"你好", "hi", "hello", "嗨"},
        farewell = {"再见", "bye", "goodbye", "回见"},
        thinking = {"想想", "让我想想", "考虑", "think"},
        pointing = {"那边", "那里", "指", "point"},
        drinking = {"喝", "drink", "咖啡", "茶"}
    }
    
    text = text:lower()
    local suggestedAction = nil
    
    for action, keywords in pairs(actions) do
        for _, keyword in ipairs(keywords) do
            if text:find(keyword:lower()) then
                suggestedAction = action
                break
            end
        end
        if suggestedAction then break end
    end
    
    callback({
        animation = animation,
        action = suggestedAction,
        emotion = emotion
    })
end

_G.EmotionEngine = EmotionEngine
