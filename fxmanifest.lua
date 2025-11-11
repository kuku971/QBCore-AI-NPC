fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Pe0ny9'
description 'AI-Powered NPC System with Ollama Integration'
version '1.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/locale.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua',
    'client/npc_spawner.lua',
    'client/npc_interaction.lua',
    'client/npc_animation.lua',
    'client/ui_handler.lua',
    'client/targeting.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/npc_manager.lua',
    'server/ollama_api.lua',
    'server/dialogue_handler.lua',
    'server/emotion_engine.lua',
    'server/memory_system.lua',
    'server/relationship.lua',
    'server/database.lua',
    'server/commands.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'local/*.json'
}

dependencies {
    'qb-core',
    'oxmysql'
}

escrow_ignore {
    'shared/config.lua',    -- 配置文件
    'local/*.json',         -- 语言文件
    'sql/*.sql',            -- 数据库文件
    'html/**/*',            -- NUI 文件（目前 Escrow 不支持 NUI）
}