<script lang="ts">
  import { page } from '$app/state';
  import '../app.css'; 
  
  let { children } = $props();
</script>

<div class="app-container">
  <!-- Сайдбар -->
  <aside class="sidebar">
    <!-- Логотип -->
    <div class="logo-wrapper">
      <img src="/logo.png" alt="Himo Logo" class="logo-img" />
    </div>
    
    <nav class="nav-menu">
      <a href="/" class="nav-item" class:active={page.url.pathname === '/'}>
        Моя страница
      </a>
      <a href="/teams" class="nav-item" class:active={page.url.pathname === '/teams'}>
        Команды
      </a>
    </nav>

    <button class="logout-btn">Выход</button>
  </aside>

  <!-- Основной контент -->
  <main class="main-content">
    {@render children()}
  </main>
</div>

<style>
  .app-container {
    display: flex;
    width: 100vw;
    height: 100vh;
    background-color: #0f0f0f;
    margin: 0;
    padding: 0;
    overflow: hidden;
  }

  /* --- Оранжевый Сайдбар --- */
  .sidebar {
    width: 280px;
    background-color: #ff7a00;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 40px 20px;
    box-sizing: border-box;
    flex-shrink: 0;
  }

  /* Стили для логотипа */
  .logo-wrapper {
    margin-bottom: 40px;
    display: flex;
    justify-content: center;
    width: 100%;
  }

  .logo-img {
    width: 160px; /* Можете подогнать размер под свой вкус */
    height: 160px;
    object-fit: contain;
    /* Если у вашей картинки белый фон, а нужен прозрачный, 
       используйте PNG с прозрачностью */
  }

  .nav-menu {
    display: flex;
    flex-direction: column;
    gap: 15px;
    width: 100%;
  }

  .nav-item {
    display: block;
    width: 100%;
    padding: 12px 20px;
    background-color: transparent;
    color: #fff;
    text-decoration: none;
    border-radius: 25px;
    text-align: center;
    font-weight: 600;
    box-sizing: border-box;
    border: 2px solid #ffb366;
    transition: all 0.2s ease;
  }

  .nav-item:hover {
    background-color: rgba(255, 255, 255, 0.1);
    border-color: #fff;
  }

  .nav-item.active {
    background-color: #ffb366;
    color: #0f0f0f;
    border-color: #ffb366;
    box-shadow: 0 4px 10px rgba(0,0,0,0.15);
  }

  .logout-btn {
    margin-top: auto;
    width: 100%;
    padding: 12px 20px;
    background-color: transparent;
    color: #fff;
    border: 2px solid #ffb366;
    border-radius: 25px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .logout-btn:hover {
    background-color: rgba(255, 255, 255, 0.1);
    border-color: #fff;
  }

  /* --- Контент --- */
  .main-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 60px 40px;
    box-sizing: border-box;
    background-color: #0f0f0f;
    overflow-y: auto;
  }
</style>