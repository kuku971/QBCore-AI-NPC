// ============================================
// AI-NPC UI Script
// ============================================

let language = {};
let currentNpcId = null;
let wizardStep = 1;
let wizardData = {};

// 初始化
window.addEventListener('load', () => {
    fetch(`https://${GetParentResourceName()}/ready`, {
        method: 'POST',
        body: JSON.stringify({})
    });
});

// 接收消息
window.addEventListener('message', (event) => {
    const data = event.data;
    
    switch(data.action) {
        case 'setLanguage':
            language = data.language;
            break;
            
        case 'openAdminPanel':
            openAdminPanel(data.npcs);
            break;
            
        case 'openCreateWizard':
            openWizardWithData(data);
            break;
            
        case 'openDialogue':
            openDialogue(data.npcId, data.npcName, data.npcOccupation);
            break;
            
        case 'closeDialogue':
            closeDialogue();
            break;
            
        case 'npcMessage':
            addNPCMessage(data.message, data.emotion);
            break;
            
        case 'updateRelationship':
            updateRelationshipDisplay(data.relationship);
            break;
    }
});

// ESC键关闭
document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        closeAll();
    }
});

// 关闭所有窗口
function closeAll() {
    closeDialogue();
    closePanel();
    closeWizard();
}

// ======== 对话系统 ========

function openDialogue(npcId, npcName, occupation) {
    currentNpcId = npcId;
    document.getElementById('npc-name').textContent = npcName;
    document.getElementById('npc-occupation').textContent = occupation;
    document.getElementById('dialogue-container').classList.remove('hidden');
    document.getElementById('messages').innerHTML = '';
    document.getElementById('message-input').value = '';
    document.getElementById('message-input').focus();
}

function closeDialogue() {
    document.getElementById('dialogue-container').classList.add('hidden');
    currentNpcId = null;
    
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function sendMessage() {
    const input = document.getElementById('message-input');
    const message = input.value.trim();
    
    if (!message || !currentNpcId) return;
    
    // 显示玩家消息
    addPlayerMessage(message);
    input.value = '';
    
    // 发送到服务器
    fetch(`https://${GetParentResourceName()}/sendMessage`, {
        method: 'POST',
        body: JSON.stringify({
            npcId: currentNpcId,
            message: message
        })
    });
}

function addPlayerMessage(message) {
    const messagesDiv = document.getElementById('messages');
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message player';
    messageDiv.innerHTML = `<div class="message-content">${escapeHtml(message)}</div>`;
    messagesDiv.appendChild(messageDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

function addNPCMessage(message, emotion) {
    const messagesDiv = document.getElementById('messages');
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message npc';
    
    const emotionText = getEmotionText(emotion);
    messageDiv.innerHTML = `
        <div class="message-content">${escapeHtml(message)}</div>
        <div class="emotion-indicator">${emotionText}</div>
    `;
    
    messagesDiv.appendChild(messageDiv);
    messagesDiv.scrollTop = messagesDiv.scrollHeight;
}

function updateRelationshipDisplay(data) {
    document.getElementById('relationship-level').textContent = 
        `关系: ${data.description} (${data.level})`;
}

function getEmotionText(emotion) {
    const emotions = {
        happy: '😊 开心',
        sad: '😢 悲伤',
        angry: '😠 生气',
        surprised: '😲 惊讶',
        confused: '😕 困惑',
        neutral: '😐 中性'
    };
    return emotions[emotion] || emotions.neutral;
}

// Enter键发送消息
document.getElementById('message-input')?.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        sendMessage();
    }
});

// ======== 管理面板 ========

function openAdminPanel(npcs) {
    document.getElementById('admin-panel').classList.remove('hidden');
    updateDashboard(npcs);
}

function closePanel() {
    document.getElementById('admin-panel').classList.add('hidden');
    
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function showTab(tabName) {
    // 隐藏所有标签
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    
    // 显示选中的标签
    document.getElementById(`tab-${tabName}`).classList.add('active');
    
    // 更新侧边栏按钮状态
    document.querySelectorAll('.sidebar-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
}

function updateDashboard(npcs) {
    let total = 0;
    let active = 0;
    
    for (let id in npcs) {
        total++;
        if (npcs[id].data && npcs[id].data.status === 1) {
            active++;
        }
    }
    
    document.getElementById('total-npcs').textContent = total;
    document.getElementById('active-npcs').textContent = active;
}

// ======== 创建向导 ========

function openCreateWizard() {
    closePanel();
    // 触发服务器获取创建向导数据
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function openWizardWithData(data) {
    document.getElementById('create-wizard').classList.remove('hidden');
    wizardStep = 1;
    wizardData = {
        position: data.currentPosition,
        heading: data.currentHeading
    };
    
    // 填充模型列表
    const modelSelect = document.getElementById('npc-model');
    modelSelect.innerHTML = '';
    data.models.forEach(model => {
        const option = document.createElement('option');
        option.value = model;
        option.textContent = model;
        modelSelect.appendChild(option);
    });
    
    // 填充职业列表
    const occupationSelect = document.getElementById('npc-occupation');
    occupationSelect.innerHTML = '';
    data.occupations.forEach(occ => {
        const option = document.createElement('option');
        option.value = occ.value;
        option.textContent = occ.label;
        occupationSelect.appendChild(option);
    });
    
    // 填充性格列表
    const personalitySelect = document.getElementById('personality-preset');
    personalitySelect.innerHTML = '';
    for (let key in data.personalities) {
        const option = document.createElement('option');
        option.value = key;
        option.textContent = data.personalities[key].name;
        personalitySelect.appendChild(option);
    }
    
    updateWizardStep();
}

function closeWizard() {
    document.getElementById('create-wizard').classList.add('hidden');
    wizardData = {};
    
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
}

function nextStep() {
    if (wizardStep < 6) {
        wizardStep++;
        updateWizardStep();
    }
}

function prevStep() {
    if (wizardStep > 1) {
        wizardStep--;
        updateWizardStep();
    }
}

function updateWizardStep() {
    // 隐藏所有步骤
    document.querySelectorAll('.wizard-step').forEach(step => {
        step.classList.remove('active');
    });
    
    // 显示当前步骤
    document.getElementById(`step-${wizardStep}`).classList.add('active');
    document.getElementById('wizard-step').textContent = wizardStep;
    
    // 更新按钮状态
    document.getElementById('prev-btn').disabled = wizardStep === 1;
    
    if (wizardStep === 6) {
        document.getElementById('next-btn').classList.add('hidden');
        document.getElementById('create-btn').classList.remove('hidden');
    } else {
        document.getElementById('next-btn').classList.remove('hidden');
        document.getElementById('create-btn').classList.add('hidden');
    }
}

function useCurrentPosition() {
    if (wizardData.position) {
        document.getElementById('pos-x').value = wizardData.position.x.toFixed(2);
        document.getElementById('pos-y').value = wizardData.position.y.toFixed(2);
        document.getElementById('pos-z').value = wizardData.position.z.toFixed(2);
        document.getElementById('pos-heading').value = wizardData.heading.toFixed(2);
    }
}

// 年龄滑块更新
document.getElementById('npc-age')?.addEventListener('input', (e) => {
    document.getElementById('age-value').textContent = e.target.value;
});

function createNPC() {
    const npcData = {
        name: document.getElementById('npc-name').value,
        model: document.getElementById('npc-model').value,
        gender: document.getElementById('npc-gender').value,
        age: parseInt(document.getElementById('npc-age').value),
        position: {
            x: parseFloat(document.getElementById('pos-x').value),
            y: parseFloat(document.getElementById('pos-y').value),
            z: parseFloat(document.getElementById('pos-z').value)
        },
        heading: parseFloat(document.getElementById('pos-heading').value),
        occupation: document.getElementById('npc-occupation').value,
        backstory: document.getElementById('npc-backstory').value,
        personality: {
            type: document.getElementById('personality-preset').value,
            traits: {}
        },
        dialogue_config: {
            style: document.getElementById('dialogue-style').value
        },
        ai_config: {},
        status: 1
    };
    
    fetch(`https://${GetParentResourceName()}/createNPC`, {
        method: 'POST',
        body: JSON.stringify(npcData)
    }).then(resp => resp.json()).then(data => {
        if (data.success) {
            closeWizard();
        }
    });
}

// 工具函数
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function GetParentResourceName() {
    return window.location.hostname;
}
