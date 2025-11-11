-- ============================================
-- AI-NPC System Database
-- ============================================

-- NPC基础数据表
CREATE TABLE IF NOT EXISTS `ainpc_data` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `model` VARCHAR(100) NOT NULL,
    `gender` VARCHAR(10) DEFAULT 'male',
    `age` INT DEFAULT 30,
    `occupation` VARCHAR(50),
    `personality` LONGTEXT,
    `backstory` TEXT,
    `position` VARCHAR(255) NOT NULL,
    `heading` FLOAT DEFAULT 0.0,
    `ai_config` LONGTEXT,
    `dialogue_config` LONGTEXT,
    `status` TINYINT(1) DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_status` (`status`),
    INDEX `idx_occupation` (`occupation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- NPC对话历史表
CREATE TABLE IF NOT EXISTS `ainpc_dialogues` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `npc_id` INT NOT NULL,
    `player_identifier` VARCHAR(50) NOT NULL,
    `player_message` TEXT,
    `npc_response` TEXT,
    `emotion` VARCHAR(50),
    `context` LONGTEXT,
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`npc_id`) REFERENCES `ainpc_data`(`id`) ON DELETE CASCADE,
    INDEX `idx_npc_player` (`npc_id`, `player_identifier`),
    INDEX `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- NPC与玩家关系表
CREATE TABLE IF NOT EXISTS `ainpc_relationships` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `npc_id` INT NOT NULL,
    `player_identifier` VARCHAR(50) NOT NULL,
    `relationship_level` INT DEFAULT 0,
    `interactions_count` INT DEFAULT 0,
    `last_interaction` TIMESTAMP NULL,
    `notes` TEXT,
    FOREIGN KEY (`npc_id`) REFERENCES `ainpc_data`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_relationship` (`npc_id`, `player_identifier`),
    INDEX `idx_npc` (`npc_id`),
    INDEX `idx_player` (`player_identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- NPC之间关系表
CREATE TABLE IF NOT EXISTS `ainpc_npc_relationships` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `npc_id_1` INT NOT NULL,
    `npc_id_2` INT NOT NULL,
    `relationship_type` VARCHAR(50),
    `relationship_level` INT DEFAULT 0,
    `description` TEXT,
    FOREIGN KEY (`npc_id_1`) REFERENCES `ainpc_data`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`npc_id_2`) REFERENCES `ainpc_data`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_npc_relation` (`npc_id_1`, `npc_id_2`),
    INDEX `idx_npc1` (`npc_id_1`),
    INDEX `idx_npc2` (`npc_id_2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 系统日志表
CREATE TABLE IF NOT EXISTS `ainpc_logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `log_type` VARCHAR(50),
    `npc_id` INT,
    `player_identifier` VARCHAR(50),
    `action` VARCHAR(100),
    `details` TEXT,
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_type` (`log_type`),
    INDEX `idx_npc` (`npc_id`),
    INDEX `idx_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
