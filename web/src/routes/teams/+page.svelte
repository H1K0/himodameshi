<script lang="ts">
  // 1. Импортируем данные из общего хранилища (обратите внимание на #lib)
  import { teamsData } from '#lib/store.svelte';

  // Состояния экранов
  let isCreating = $state(false);
  let editingTeamId = $state<number | null>(null);

  // Данные для формы создания
  let newTeamName = $state('');
  
  // Данные для редактирования
  let editName = $state('');
  let isEditingName = $state(false);
  let inviteInput = $state('');
  let invitedUsers = $state<string[]>([]);

  // --- ФУНКЦИИ ---

  function createTeam() {
    if (newTeamName.trim() === '') return;
    teamsData.push({
      id: Date.now(),
      name: newTeamName,
      members: 'Вы',
      isBase: false,
      invited: []
    });
    newTeamName = '';
    isCreating = false;
  }

  function deleteTeam(id: number) {
    // Находим индекс и удаляем из глобального массива
    const index = teamsData.findIndex(t => t.id === id);
    if (index !== -1) {
      teamsData.splice(index, 1);
    }
  }

  function openSettings(id: number) {
    const team = teamsData.find(t => t.id === id);
    if (!team) return;
    
    editingTeamId = id;
    editName = team.name;
    inviteInput = '';
    invitedUsers = [...team.invited]; // Копируем массив приглашенных
    isEditingName = false;
  }

  function toggleNameEdit() {
    isEditingName = !isEditingName;
  }

  function getCurrentTeamName() {
    const team = teamsData.find(t => t.id === editingTeamId);
    return team ? team.name : editName;
  }

  function saveSettings() {
    const team = teamsData.find(t => t.id === editingTeamId);
    if (team) {
      if (editName.trim() !== '') {
        team.name = editName;
      }
      team.invited = [...invitedUsers]; // Сохраняем приглашенных
    }
    editingTeamId = null;
  }

  function inviteUser() {
    if (inviteInput.trim() !== '' && !invitedUsers.includes(inviteInput)) {
      invitedUsers.push(inviteInput);
      inviteInput = '';
    }
  }

  function removeInvited(user: string) {
    invitedUsers = invitedUsers.filter(u => u !== user);
  }
</script>

<div class="teams-page">
  
  <!-- 1. ЭКРАН СОЗДАНИЯ КОМАНДЫ -->
  {#if isCreating}
    <div class="form-container">
      <h2 class="page-title">Создание новой команды</h2>
      <input 
        type="text" 
        bind:value={newTeamName} 
        placeholder="Название команды" 
        class="text-input"
        onkeydown={(e) => e.key === 'Enter' && createTeam()}
      />
      <div class="form-actions">
        <button class="btn primary" onclick={createTeam}>Создать команду</button>
        <button class="btn secondary" onclick={() => isCreating = false}>Назад</button>
      </div>
    </div>

  <!-- 2. ЭКРАН НАСТРОЕК КОМАНДЫ -->
  {:else if editingTeamId !== null}
    <div class="form-container">
      <!-- Выводим сохраненное имя, а не то, что печатаем -->
      <h2 class="page-title">Команда “{getCurrentTeamName()}”</h2>
      
      <!-- Поле изменения названия -->
      <div class="input-wrapper">
        <input 
          type="text" 
          bind:value={editName} 
          class="text-input"
          class:editing={isEditingName}
          disabled={!isEditingName}
          placeholder="Название команды"
        />
        <button class="input-icon-btn" onclick={toggleNameEdit} aria-label="Редактировать">
          {#if isEditingName}
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
          {:else}
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
          {/if}
        </button>
      </div>

      <!-- Поле добавления участников -->
      <div class="input-wrapper">
        <input 
          type="text" 
          bind:value={inviteInput} 
          placeholder="Добавьте пользователя в команду по его логину" 
          class="text-input"
          onkeydown={(e) => e.key === 'Enter' && inviteInput.trim() !== '' && inviteUser()}
        />
        <button 
          class="input-icon-btn" 
          onclick={inviteUser} 
          disabled={inviteInput.trim() === ''}
          aria-label="Найти"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
        </button>
      </div>

      <!-- Общий блок участников -->
      {#if invitedUsers.length > 0}
        <div class="participants-container">
          {#each invitedUsers as user, index}
            <div class="participant-row">
              <span class="participant-name">{user}</span>
              <span class="participant-status">Приглашение отправлено</span>
              <button class="remove-btn" onclick={() => removeInvited(user)} aria-label="Удалить из команды">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <polyline points="3 6 5 6 21 6"></polyline>
                  <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                </svg>
              </button>
            </div>
            {#if index < invitedUsers.length - 1}
              <div class="divider"></div>
            {/if}
          {/each}
        </div>
      {/if}

      <div class="form-actions">
        <button class="btn primary" onclick={saveSettings}>Сохранить</button>
        <button class="btn secondary" onclick={() => editingTeamId = null}>Назад</button>
      </div>
    </div>

  <!-- 3. ЭКРАН СПИСКА КОМАНД -->
  {:else}
    <div class="teams-list">
      {#each teamsData as team (team.id)}
        <div class="team-card">
          <div class="team-info">
            <div class="team-header">
              <h3 class="team-title">{team.name}</h3>
              
              {#if !team.isBase}
                <div class="team-controls">
                  <button class="icon-btn" onclick={() => openSettings(team.id)} aria-label="Настройки">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                  </button>
                  <button class="icon-btn delete" onclick={() => deleteTeam(team.id)} aria-label="Удалить команду">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                  </button>
                </div>
              {/if}
            </div>
            
            {#if team.isBase}
              <p class="team-participants">Участники: {team.members}</p>
            {:else}
              <p class="team-participants">Админ: {team.members}</p>
              <!-- Считаем: 1 (Вы) + длина массива приглашенных -->
              <p class="team-participants">
                Участники: {1 + (team.invited ? team.invited.length : 0)}
              </p>
            {/if}
          </div>
          <a href="/teams/cables?id={team.id}" class="cables-link">Перейти в раздел кабелей</a>
        </div>
      {/each}
    </div>

    <button class="create-team-btn" onclick={() => isCreating = true}>
      Создать команду
    </button>
  {/if}

</div>

<style>
  .teams-page { display: flex; flex-direction: column; align-items: center; justify-content: center; width: 100%; height: 100%; }
  .form-container { display: flex; flex-direction: column; align-items: center; width: 100%; max-width: 600px; gap: 20px; }
  .page-title { color: #ffffff; font-size: 24px; font-weight: 700; margin: 0 0 20px 0; text-align: center; }
  .input-wrapper { position: relative; width: 100%; }
  .text-input { width: 100%; padding: 18px 55px 18px 24px; background-color: #1a1a1a; border: 1px solid #333; border-radius: 30px; color: #fff; font-size: 16px; outline: none; box-sizing: border-box; transition: all 0.2s; }
  .text-input:disabled { background-color: #111; color: #888; border-color: #222; cursor: not-allowed; }
  .text-input.editing { background-color: #1a1a1a; color: #fff; border-color: #ff7a00; box-shadow: 0 0 0 2px rgba(255, 122, 0, 0.2); cursor: text; }
  .text-input::placeholder { color: #666; }
  .input-icon-btn { position: absolute; right: 20px; top: 50%; transform: translateY(-50%); background: none; border: none; color: #777; cursor: pointer; padding: 5px; display: flex; align-items: center; transition: all 0.2s; }
  .input-icon-btn:disabled { color: #333; cursor: default; }
  .input-icon-btn:not(:disabled):hover { color: #ff7a00; }
  .participants-container { width: 100%; background-color: #1a1a1a; border: 1px solid #333; border-radius: 20px; display: flex; flex-direction: column; overflow: hidden; margin-top: 10px; }
  .participant-row { display: flex; align-items: center; padding: 16px 24px; transition: background-color 0.2s; }
  .participant-row:hover { background-color: #222; }
  .participant-name { font-weight: 600; color: #fff; font-size: 15px; }
  .participant-status { font-size: 13px; color: #777; margin-left: auto; margin-right: 20px; }
  .remove-btn { background: none; border: none; color: #666; cursor: pointer; display: flex; align-items: center; padding: 4px; transition: color 0.2s; }
  .remove-btn:hover { color: #ff4444; }
  .divider { height: 1px; background-color: #333; margin: 0 24px; }
  .form-actions { display: flex; gap: 20px; width: 100%; justify-content: center; margin-top: 20px; }
  .btn { padding: 16px 40px; border-radius: 30px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.2s; border: 1px solid transparent; }
  .btn.primary { background-color: #ff7a00; color: #000; }
  .btn.primary:hover { background-color: #ff9933; }
  .btn.secondary { background-color: #1a1a1a; color: #fff; border-color: #333; }
  .btn.secondary:hover { border-color: #ff7a00; color: #ff7a00; }
  .teams-list { display: flex; flex-direction: column; gap: 16px; width: 100%; max-width: 700px; }
  .team-card { width: 100%; background-color: #1a1a1a; border: 1px solid #333; border-radius: 16px; padding: 24px 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.4); box-sizing: border-box; }
  .team-info { display: flex; flex-direction: column; gap: 6px; }
  .team-header { display: flex; align-items: center; gap: 12px; }
  .team-title { margin: 0; font-size: 18px; font-weight: 700; color: #ffffff; }
  .team-participants { margin: 0; font-size: 13px; color: #888888; }
  .cables-link { color: #ff7a00; font-size: 14px; text-decoration: none; font-weight: 500; transition: text-shadow 0.2s ease; white-space: nowrap; }
  .cables-link:hover { text-shadow: 0 0 8px rgba(255, 122, 0, 0.6); text-decoration: underline; text-underline-offset: 4px; }
  .create-team-btn { background-color: #1a1a1a; color: #ffffff; border: 1px solid #333; padding: 14px 40px; border-radius: 25px; font-size: 16px; font-weight: 500; cursor: pointer; transition: all 0.2s ease; margin-top: 20px; }
  .create-team-btn:hover { border-color: #ff7a00; color: #ff7a00; box-shadow: 0 0 15px rgba(255, 122, 0, 0.15); }
  .team-controls { display: flex; gap: 8px; margin-left: 10px; }
  .icon-btn { background: none; border: none; color: #666; cursor: pointer; padding: 4px; display: flex; align-items: center; justify-content: center; transition: color 0.2s; }
  .icon-btn:hover { color: #ff7a00; }
  .icon-btn.delete:hover { color: #ff4444; }
</style>