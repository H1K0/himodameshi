<script lang="ts">
  import { userProfile } from '#lib/store.svelte';

  // Состояния для редактирования (они локальные, это нормально)
  let isEditingFirstName = $state(false);
  let isEditingLastName = $state(false);
  let isEditingUsername = $state(false);

  function toggleTelegram() {
    userProfile.isTelegramLinked = !userProfile.isTelegramLinked;
  }
</script>

<div class="profile-page">
  <!-- Аватарка -->
  <div class="avatar-wrapper">
    <div class="avatar">
      <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path>
        <circle cx="12" cy="13" r="4"></circle>
      </svg>
    </div>
  </div>

  <!-- Форма -->
  <form class="profile-form" onsubmit={(e: SubmitEvent) => e.preventDefault()}>
    
    <!-- Поле Имя -->
    <div class="input-group">
      <input 
        type="text" 
        bind:value={userProfile.firstName} 
        placeholder="Имя" 
        disabled={!isEditingFirstName} 
        class:editing={isEditingFirstName}
      />
      <button type="button" class="icon-btn" onclick={() => isEditingFirstName = !isEditingFirstName}>
        {#if isEditingFirstName}
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
        {:else}
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
        {/if}
      </button>
    </div>

    <!-- Поле Фамилия -->
    <div class="input-group">
      <input 
        type="text" 
        bind:value={userProfile.lastName} 
        placeholder="Фамилия" 
        disabled={!isEditingLastName} 
        class:editing={isEditingLastName}
      />
      <button type="button" class="icon-btn" onclick={() => isEditingLastName = !isEditingLastName}>
        {#if isEditingLastName}
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
        {:else}
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
        {/if}
      </button>
    </div>

    <!-- Поле Логин -->
    <div class="input-group">
      <input 
        type="text" 
        bind:value={userProfile.username} 
        placeholder="Логин" 
        disabled={!isEditingUsername} 
        class:editing={isEditingUsername}
      />
      <button type="button" class="icon-btn" onclick={() => isEditingUsername = !isEditingUsername}>
        {#if isEditingUsername}
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
        {:else}
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>
        {/if}
      </button>
    </div>

  </form>

  <!-- Кнопка Telegram -->
  <button class="telegram-btn" onclick={toggleTelegram}>
    {#if userProfile.isTelegramLinked}
      - отвязать ТГ
    {:else}
      + привязать ТГ
    {/if}
  </button>
</div>

<style>
  /* Ваши стили для профиля оставляем без изменений */
  .profile-page { display: flex; flex-direction: column; align-items: center; width: 100%; max-width: 400px; margin-top: 20px; }
  .avatar-wrapper { margin-bottom: 40px; }
  .avatar { width: 120px; height: 120px; background-color: #1a1a1a; border: 2px solid #ff7a00; border-radius: 50%; display: flex; justify-content: center; align-items: center; color: #ff7a00; transition: transform 0.3s ease; cursor: pointer; }
  .avatar:hover { transform: scale(1.05); box-shadow: 0 0 20px rgba(255, 122, 0, 0.3); }
  .profile-form { display: flex; flex-direction: column; gap: 16px; width: 100%; margin-bottom: 30px; }
  .input-group { position: relative; display: flex; align-items: center; width: 100%; }
  .input-group input { width: 100%; padding: 14px 45px 14px 20px; background-color: #1a1a1a; border: 1px solid #333; border-radius: 25px; font-size: 16px; color: #fff; outline: none; transition: all 0.2s ease; }
  .input-group input:disabled { background-color: #121212; color: #aaa; border-color: #222; cursor: not-allowed; opacity: 0.8; }
  .input-group input.editing { background-color: #1a1a1a; color: #fff; border-color: #ff7a00; box-shadow: 0 0 0 2px rgba(255, 122, 0, 0.2); cursor: text; }
  .input-group input::placeholder { color: #777; }
  .icon-btn { position: absolute; right: 15px; background: none; border: none; cursor: pointer; color: #777; display: flex; align-items: center; justify-content: center; padding: 5px; transition: color 0.2s; }
  .icon-btn:hover { color: #ff7a00; }
  .telegram-btn { background: none; border: none; color: #ff7a00; font-size: 16px; font-weight: bold; cursor: pointer; padding: 10px; transition: all 0.2s; }
  .telegram-btn:hover { text-shadow: 0 0 10px rgba(255, 122, 0, 0.5); transform: translateY(-1px); }
</style>