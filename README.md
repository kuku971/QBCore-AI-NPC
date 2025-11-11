# Pe0ny9-AI-NPC 智能NPC系统

> 基于 QBCore 和 Ollama 的 AI 驱动 NPC 系统

[English](README_EN.md) | 中文

## 特性

- ✅ **动态NPC管理** - 无需重启，实时创建/编辑NPC
- ✅ **AI对话系统** - 集成Ollama本地AI模型
- ✅ **智能动作** - 根据情绪自动播放动画
- ✅ **记忆系统** - NPC记住与玩家的对话
- ✅ **关系网络** - 玩家与NPC的关系等级
- ✅ **多语言** - 支持中文/英文

## 快速开始

### 1. 安装 Ollama

```bash
# Windows
winget install Ollama.Ollama

# 下载AI模型
ollama pull qwen2:7b
```

### 2. 安装数据库

```bash
mysql -u root -p your_database < sql/install.sql
```

### 3. 配置

编辑 `shared/config.lua`:

```lua
Config.Language = 'zh'  -- 语言: 'zh' 或 'en'
Config.Ollama.Host = "http://localhost:11434"
Config.Ollama.Model = "qwen2:7b"
Config.Target.System = "qb-target"  -- 目标系统: "qb-target", "ox_target" 或 "none"
```

### 4. 启动

在 `server.cfg` 添加:
```
ensure Pe0ny9-AI-NPC
```

## 使用

### 创建NPC
```
/npcadmin  -- 打开管理面板
```
或按 `F7` 键

### 对话
1. 走近NPC
2. 按 `E` 键（或使用目标系统）
3. 输入消息并发送

### 管理命令

```
/npcadmin          打开管理面板
/createnpc         创建NPC
/editnpc [ID]      编辑NPC
/deletenpc [ID]    删除NPC
/listnpcs          列出所有NPC
```

## 配置说明

### 语言设置

```lua
Config.Language = 'zh'  -- 'zh'中文 或 'en'英文
```

**影响范围:**
- UI界面语言
- AI对话提示词
- 问候语和告别语
- NPC回复语言

### 目标系统

```lua
Config.Target = {
    System = "qb-target",  -- "qb-target", "ox_target", "none"
    Icon = "fas fa-comments",
    Distance = 2.5,
}
```

### AI模型推荐

- **中文服务器**: `qwen2:7b`
- **英文服务器**: `llama3:8b` 或 `mistral:7b`
- **低配服务器**: `phi3:mini`

## 系统要求

- FiveM 服务器
- QBCore Framework
- oxmysql
- MySQL 数据库
- Ollama (本地或远程)

## 文件结构

```
Pe0ny9-AI-NPC/
├── fxmanifest.lua
├── shared/
│   ├── config.lua      # 配置文件
│   ├── locale.lua      # 多语言系统
│   └── utils.lua
├── server/
│   ├── main.lua
│   ├── npc_manager.lua # NPC管理核心
│   ├── ollama_api.lua  # AI集成
│   ├── dialogue_handler.lua
│   └── ...
├── client/
│   ├── main.lua
│   ├── npc_spawner.lua
│   ├── npc_interaction.lua
│   └── ...
├── html/              # UI界面
├── local/             # 语言包
└── sql/               # 数据库
```

## 常见问题

**Q: Ollama连接失败?**  
A: 确认Ollama服务运行中: `curl http://localhost:11434/api/tags`

**Q: NPC不显示?**  
A: 检查数据库是否安装，NPC状态是否启用

**Q: 如何切换语言?**  
A: 修改 `Config.Language` 为 `'zh'` 或 `'en'`，重启资源

**Q: 支持哪些目标系统?**  
A: qb-target, ox_target, 或默认按E键交互

## 性能优化

```lua
-- 低配置服务器
Config.Ollama.Model = "phi3:mini"
Config.NPC.DrawDistance = 20.0
Config.NPC.MaxMemoryLength = 3
```

## 许可证

MIT License

## 作者

Pe0ny9

---

**版本**: v1.0.0  
**更新**: 2025-11-11
