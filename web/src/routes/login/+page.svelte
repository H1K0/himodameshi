<script lang="ts">
  import { goto } from '$app/navigation';
  import { userProfile } from '#lib/store.svelte'; // Импортируем хранилище

  // Состояния для полей ввода
  let login = $state('');
  let password = $state('');

  // Состояния для UI
  let isLoading = $state(false);
  let errorMessage = $state('');

    async function handleLogin(e: Event) {
    e.preventDefault();
    errorMessage = '';

    if (!login.trim() || !password.trim()) {
      errorMessage = 'Пожалуйста, заполните все поля';
      return;
    }

    isLoading = true;

    try {
      const response = await fetch('/api/v1/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include', // Важно для получения Cookie
        body: JSON.stringify({
          nickname: login,
          password: password,
          client: 'web' // Указываем, что мы веб-клиент
        })
      });

      if (!response.ok) {
        if (response.status === 401) {
          errorMessage = 'Неверный логин или пароль';
        } else if (response.status === 429) {
          errorMessage = 'Слишком много попыток. Подождите.';
        } else {
          errorMessage = 'Ошибка авторизации';
        }
        return;
      }

      const data = await response.json();

      // Сохраняем данные пользователя из ответа сервера
      userProfile.username = data.user.nickname;
      userProfile.firstName = '';
      userProfile.lastName = '';
      userProfile.isAuthenticated = true;

      await goto('/');
    } catch (err) {
      errorMessage = 'Сервер недоступен. Проверьте соединение.';
    } finally {
      isLoading = false;
    }
  }
</script>

<div class="login-page">
  <!-- Шапка с логотипом -->
  <header class="login-header">
    <div class="logo-wrapper">
      <img src="/logo.png" alt="Himo" class="logo-img" />
    </div>
  </header>

  <!-- Форма авторизации -->
  <main class="login-main">
    <h1 class="page-title">Авторизация</h1>

    <form class="login-form" onsubmit={handleLogin}>

      <!-- Поле логина -->
      <div class="input-group">
        <input
          type="text"
          bind:value={login}
          placeholder="Логин"
          disabled={isLoading}
        />
      </div>

      <!-- Поле пароля -->
      <div class="input-group">
        <input
          type="password"
          bind:value={password}
          placeholder="Пароль"
          disabled={isLoading}
        />
      </div>

      <!-- Вывод ошибки -->
      {#if errorMessage}
        <div class="error-message">
          {errorMessage}
        </div>
      {/if}

      <!-- Кнопка входа -->
      <button type="submit" class="submit-btn" disabled={isLoading}>
        {#if isLoading}
          Вход...
        {:else}
          Войти
        {/if}
      </button>

    </form>
  </main>
</div>

<style>
  .login-page {
    display: flex;
    flex-direction: column;
    width: 100vw;
    height: 100vh;
    background-color: #0f0f0f;
  }

  /* --- Оранжевая шапка --- */
  .login-header {
    background-color: #ff7a00;
    width: 100%;
    height: 40vh; /* Занимает 40% экрана */
    display: flex;
    justify-content: center;
    align-items: center;
    flex-shrink: 0;
  }

  .logo-wrapper {
    width: 220px;
    height: 220px;
  }

  .logo-img {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }

  /* --- Основная часть --- */
  .login-main {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-top: 60px;
  }

  .page-title {
    color: #ffffff;
    font-size: 28px;
    font-weight: 700;
    margin: 0 0 40px 0;
  }

  .login-form {
    display: flex;
    flex-direction: column;
    width: 100%;
    max-width: 350px;
    gap: 20px;
  }

  .input-group input {
    width: 100%;
    padding: 16px 24px;
    background-color: #1a1a1a;
    border: 1px solid #333;
    border-radius: 30px;
    color: #fff;
    font-size: 16px;
    outline: none;
    box-sizing: border-box;
    transition: border-color 0.2s;
  }

  .input-group input:focus {
    border-color: #ff7a00;
  }

  .input-group input::placeholder {
    color: #777;
  }

  .input-group input:disabled {
    background-color: #111;
    color: #555;
    cursor: not-allowed;
  }

  /* Кнопка */
  .submit-btn {
    width: 100%;
    padding: 16px;
    margin-top: 10px;
    background-color: #2a2a2a;
    color: #fff;
    border: none;
    border-radius: 30px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }

  .submit-btn:hover:not(:disabled) {
    background-color: #3a3a3a;
  }

  .submit-btn:disabled {
    background-color: #1a1a1a;
    color: #777;
    cursor: not-allowed;
  }

  /* Ошибка */
  .error-message {
    background-color: rgba(255, 68, 68, 0.1);
    border: 1px solid #ff4444;
    color: #ff4444;
    padding: 12px;
    border-radius: 12px;
    font-size: 14px;
    text-align: center;
  }
</style>
