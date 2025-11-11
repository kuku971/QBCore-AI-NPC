# Pe0ny9-AI-NPC System

> AI-Powered NPC System for QBCore with Ollama Integration

English | [中文](README.md)

## Features

- ✅ **Dynamic NPC Management** - Create/Edit NPCs in real-time without restart
- ✅ **AI Dialogue System** - Powered by Ollama local AI models
- ✅ **Smart Animations** - Automatic emotion-based animations
- ✅ **Memory System** - NPCs remember conversations with players
- ✅ **Relationship Network** - Player-NPC relationship levels
- ✅ **Multi-language** - Chinese/English support

## Quick Start

### 1. Install Ollama

```bash
# Windows
winget install Ollama.Ollama

# Download AI model
ollama pull llama3:8b
```

### 2. Setup Database

```bash
mysql -u root -p your_database < sql/install.sql
```

### 3. Configuration

Edit `shared/config.lua`:

```lua
Config.Language = 'en'  -- Language: 'zh' or 'en'
Config.Ollama.Host = "http://localhost:11434"
Config.Ollama.Model = "llama3:8b"
Config.Target.System = "qb-target"  -- Target system: "qb-target", "ox_target" or "none"
```

### 4. Start

Add to `server.cfg`:
```
ensure Pe0ny9-AI-NPC
```

## Usage

### Create NPC
```
/npcadmin  -- Open admin panel
```
Or press `F7`

### Dialogue
1. Approach NPC
2. Press `E` (or use target system)
3. Type message and send

### Admin Commands

```
/npcadmin          Open admin panel
/createnpc         Create NPC
/editnpc [ID]      Edit NPC
/deletenpc [ID]    Delete NPC
/listnpcs          List all NPCs
```

## Configuration

### Language Setting

```lua
Config.Language = 'en'  -- 'zh' Chinese or 'en' English
```

**Affects:**
- UI interface language
- AI dialogue prompts
- Greetings and farewells
- NPC response language

### Target System

```lua
Config.Target = {
    System = "qb-target",  -- "qb-target", "ox_target", "none"
    Icon = "fas fa-comments",
    Distance = 2.5,
}
```

### AI Model Recommendations

- **Chinese Server**: `qwen2:7b`
- **English Server**: `llama3:8b` or `mistral:7b`
- **Low-end Server**: `phi3:mini`

## Requirements

- FiveM Server
- QBCore Framework
- oxmysql
- MySQL Database
- Ollama (local or remote)

## File Structure

```
Pe0ny9-AI-NPC/
├── fxmanifest.lua
├── shared/
│   ├── config.lua      # Configuration
│   ├── locale.lua      # Multi-language
│   └── utils.lua
├── server/
│   ├── main.lua
│   ├── npc_manager.lua # NPC manager core
│   ├── ollama_api.lua  # AI integration
│   ├── dialogue_handler.lua
│   └── ...
├── client/
│   ├── main.lua
│   ├── npc_spawner.lua
│   ├── npc_interaction.lua
│   └── ...
├── html/              # UI interface
├── local/             # Language packs
└── sql/               # Database
```

## FAQ

**Q: Ollama connection failed?**  
A: Check if Ollama is running: `curl http://localhost:11434/api/tags`

**Q: NPCs not showing?**  
A: Verify database installation, check NPC status is enabled

**Q: How to change language?**  
A: Set `Config.Language` to `'zh'` or `'en'`, restart resource

**Q: Supported target systems?**  
A: qb-target, ox_target, or default E key interaction

## Performance Optimization

```lua
-- For low-end servers
Config.Ollama.Model = "phi3:mini"
Config.NPC.DrawDistance = 20.0
Config.NPC.MaxMemoryLength = 3
```

## License

MIT License

## Author

Pe0ny9

---

**Version**: v1.0.0  
**Updated**: 2025-11-11
