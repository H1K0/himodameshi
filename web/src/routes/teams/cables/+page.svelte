<script lang="ts">

 import { page } from '$app/state'; // <--- Добавили
 import { teamsData } from '#lib/store.svelte'; // <--- Добавили

  // Получаем ID команды из URL (например, ?id=12345)
  const teamId = $derived(Number(page.url.searchParams.get('id')));
  
  // Ищем эту команду в хранилище и берем её имя
  const currentTeam = $derived(teamsData.find((t: any) => t.id === teamId));
  const teamName = $derived(currentTeam ? currentTeam.name : 'Неизвестная команда');
  // 1. Данные
  const cables = [
    { id: 1, name: 'Dynacord MXX1 1.0m', type: 'XLR', score: 80, dateAdded: '18/06/2026', owner: 'valery332', lastScan: '19/06/2026' },
    { id: 2, name: 'Real Cable XLR 128 1.0 m', type: 'XLR', score: 44, dateAdded: '20/06/2026', owner: 'yakshnkoooo', lastScan: '20/06/2026' },
    { id: 3, name: 'Optimum XLR 3m', type: 'XLR', score: 55, dateAdded: '21/06/2026', owner: 'vlad2121', lastScan: '24/06/2026' },
    { id: 4, name: 'DREMAKE 6.35 MM TRS', type: 'TRS', score: 29, dateAdded: '18/06/2026', owner: 'valery332', lastScan: '20/06/2026' },
    { id: 5, name: 'Hosa Stereo 1/8" TRS', type: 'TRS', score: 78, dateAdded: '19/06/2026', owner: 'savin67', lastScan: '22/06/2026' },
    { id: 6, name: 'CAVEL TS 703J', type: 'TS', score: 85, dateAdded: '20/06/2026', owner: 'yakshnkoooo', lastScan: '21/06/2026' },
    { id: 7, name: 'Тест1', type: 'XLR', score: 90, dateAdded: '20/06/2026', owner: 'savin67', lastScan: '22/06/2026' },
    { id: 8, name: 'Тест2', type: 'TS', score: 62, dateAdded: '19/06/2026', owner: 'yakshnkoooo', lastScan: '21/06/2026' },
    { id: 9, name: 'Тест3', type: 'TRS', score: 69, dateAdded: '17/06/2026', owner: 'vlad2121', lastScan: '19/06/2026' }
  ];

  // 2. Состояния фильтров и сортировки
  let filterValue = $state('Все');
  let sortValue = $state('dateAdded');
  
  // 3. Автоматические списки для фильтров
  let allOwners = $derived([...new Set(cables.map(c => c.owner))]);
  let allTypes = $derived([...new Set(cables.map(c => c.type))]);

  // 4. Функция цвета карточки
  function getCardColor(score: number) {
    if (score >= 70) return 'card-green';
    if (score >= 40) return 'card-yellow';
    return 'card-red';
  }

  // 5. Функция для сортировки дат (превращает "ДД/ММ/ГГГГ" в миллисекунды)
  function parseDate(dateStr: string) {
    const [day, month, year] = dateStr.split('/');
    return new Date(Number(year), Number(month) - 1, Number(day)).getTime();
  }
</script>

<div class="cables-page">
  <!-- Заголовок -->
    <h2 class="page-title">Кабели команды “{teamName}”</h2>

  <!-- Панель фильтров -->
  <div class="filters-panel">
    
    <!-- Поиск -->
    <div class="search-wrapper">
      <input type="text" placeholder="Поиск" class="search-input" />
      <svg class="search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="11" cy="11" r="8"></circle>
        <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
      </svg>
    </div>

    <!-- Комбинированный фильтр -->
    <div class="select-wrapper">
      <select class="filter-select" bind:value={filterValue}>
        <option value="Все">Фильтр: Все кабели</option>
        
        <optgroup label="По типу кабеля">
          {#each allTypes as type}
            <option value="type:{type}">Тип: {type}</option>
          {/each}
        </optgroup>

        <optgroup label="По владельцу">
          {#each allOwners as owner}
            <option value="owner:{owner}">Владелец: {owner}</option>
          {/each}
        </optgroup>
      </select>
    </div>

    <!-- Сортировка -->
    <div class="select-wrapper">
      <select class="filter-select" bind:value={sortValue}>
        <option value="dateAdded">Сортировка: по дате добавления</option>
        <option value="lastScan">Сортировка: по дате сканирования</option>
      </select>
    </div>

  </div>

  <!-- Сетка кабелей -->
  <div class="cables-grid">
    {#each cables
      // Фильтрация
      .filter(c => {
        if (filterValue === 'Все') return true;
        const [filterType, filterData] = filterValue.split(':');
        if (filterType === 'type') return c.type === filterData;
        if (filterType === 'owner') return c.owner === filterData;
        return true;
      })
      // Сортировка
      .sort((a, b) => {
        const dateA = parseDate(a[sortValue as 'dateAdded' | 'lastScan']);
        const dateB = parseDate(b[sortValue as 'dateAdded' | 'lastScan']);
        return dateB - dateA; // От новых к старым
      }) as cable (cable.id)}
      
      <!-- Новая улучшенная карточка -->
      <a href="/teams/cables/{cable.id}?teamId={teamId}" class="cable-card {getCardColor(cable.score)}">
        
        <div class="card-header">
          <h3 class="cable-name">{cable.name}</h3>
          <div class="cable-score-badge">{cable.score}/100</div>
        </div>
        
        <div class="cable-type-tag">{cable.type}</div>

        <div class="cable-details">
          <div class="detail-row">
            <span class="detail-label">Владелец:</span>
            <span class="detail-value">{cable.owner}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Добавлен:</span>
            <span class="detail-value">{cable.dateAdded}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Последнее сканирование:</span>
            <span class="detail-value">{cable.lastScan}</span>
          </div>
        </div>
        
      </a>
      
    {/each}
  </div>

  <!-- НОВАЯ КНОПКА "НАЗАД" -->
  <a href="/teams" class="back-btn">
    Назад
  </a>
</div>

<style>
  .cables-page {
    display: flex;
    flex-direction: column;
    width: 100%;
    height: 100%;
    padding: 40px;
    box-sizing: border-box;
    overflow-y: auto;
  }

  .page-title {
    color: #ffffff;
    font-size: 24px;
    font-weight: 700;
    margin: 0 0 30px 0;
    text-align: center;
  }

  /* --- Панель фильтров --- */
  .filters-panel {
    display: flex;
    gap: 20px;
    margin-bottom: 30px;
    width: 100%;
    max-width: 1200px;
    margin-left: auto;
    margin-right: auto;
  }

  .search-wrapper {
    position: relative;
    flex: 1;
  }

  .search-input {
    width: 100%;
    padding: 14px 20px 14px 45px;
    background-color: #1a1a1a;
    border: 1px solid #333;
    border-radius: 25px;
    color: #fff;
    font-size: 15px;
    outline: none;
    box-sizing: border-box;
    transition: border-color 0.2s;
  }

  .search-input:focus {
    border-color: #ff7a00;
  }

  .search-input::placeholder {
    color: #777;
  }

  .search-icon {
    position: absolute;
    left: 18px;
    top: 50%;
    transform: translateY(-50%);
    color: #777;
  }

  .select-wrapper {
    flex: 1;
    position: relative;
  }

  .filter-select {
    width: 100%;
    padding: 14px 20px;
    background-color: #1a1a1a;
    border: 1px solid #333;
    border-radius: 25px;
    color: #fff;
    font-size: 15px;
    outline: none;
    appearance: none;
    cursor: pointer;
    transition: border-color 0.2s;
  }

  .filter-select:focus {
    border-color: #ff7a00;
  }

  .filter-select option, .filter-select optgroup {
    background-color: #1a1a1a;
    color: #fff;
  }

  .select-wrapper::after {
    content: '▼';
    font-size: 10px;
    position: absolute;
    right: 20px;
    top: 50%;
    transform: translateY(-50%);
    color: #777;
    pointer-events: none;
  }

  /* --- Сетка кабелей --- */
  .cables-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 24px;
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
  }

  /* --- НОВАЯ КАРТОЧКА --- */
  .cable-card {
    border-radius: 16px;
    padding: 20px;
    display: flex;
    flex-direction: column;
    color: #111;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    text-decoration: none; /* Убирает подчеркивание ссылки */
    color: #111;           /* Оставляет цвет текста черным, как было */
  }

  .cable-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
  }

  /* Шапка: Название + Оценка */
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 12px;
    margin-bottom: 12px;
  }

  .cable-name {
    font-size: 18px;
    font-weight: 700;
    margin: 0;
    line-height: 1.3;
    flex: 1;
  }

  /* Плашка для оценки */
  .cable-score-badge {
    background-color: rgba(0, 0, 0, 0.15); /* Чуть темнее фон */
    padding: 8px 16px;                     /* Увеличили внутренние отступы */
    border-radius: 16px;                   /* Сделали скругление более плавным */
    font-weight: 800;
    font-size: 18px;                       /* Увеличили шрифт */
    white-space: nowrap;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: inset 0 1px 3px rgba(0,0,0,0.1); /* Легкая внутренняя тень для объема */
  }

  /* Плашка для типа */
  .cable-type-tag {
    display: inline-block;
    background-color: rgba(0, 0, 0, 0.08);
    padding: 4px 12px;
    border-radius: 8px;
    font-size: 12px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    align-self: flex-start;
    margin-bottom: 16px;
  }

  /* Блок с деталями */
  .cable-details {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-top: auto; /* Прижимает к низу */
    border-top: 1px solid rgba(0, 0, 0, 0.1);
    padding-top: 12px;
  }

  .detail-row {
    display: flex;
    justify-content: space-between;
    font-size: 13px;
  }

  .detail-label {
    color: rgba(0, 0, 0, 0.6);
  }

  .detail-value {
    font-weight: 600;
    color: #111;
  }

  /* Цвета карточек */
  .card-green { background-color: #c8f2c8; }
  .card-yellow { background-color: #faed9e; }
  .card-red { background-color: #fa9e9e; }

  /* --- Красивый скроллбар --- */
  .cables-page::-webkit-scrollbar {
    width: 8px; /* Делаем полоску тонкой (по умолчанию около 15px) */
  }

  .cables-page::-webkit-scrollbar-track {
    background: transparent; /* Делаем фон дорожки прозрачным (невидимым) */
  }

  .cables-page::-webkit-scrollbar-thumb {
    background-color: #333; /* Темно-серый цвет ползунка */
    border-radius: 10px;    /* Закругляем края */
  }

  .cables-page::-webkit-scrollbar-thumb:hover {
    background-color: #ff7a00; /* При наведении становится оранжевым */
  }

   .back-btn {
    display: flex;
    justify-content: center; /* Центрируем текст внутри кнопки */
    align-items: center;
    width: 100%;
    max-width: 320px; /* Ширина примерно как у одной карточки */
    margin: 40px auto 20px auto; /* Авто-отступы по бокам выровняют её по центру */
    padding: 16px 20px;
    background-color: #1a1a1a;
    color: #ffffff;
    border: 1px solid #333;
    border-radius: 45px; /* Скругления как у карточек */
    font-size: 16px;
    font-weight: 600;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.2s ease;
    box-sizing: border-box;
  }

  .back-btn:hover {
    border-color: #ff7a00;
    color: #ff7a00;
    box-shadow: 0 0 15px rgba(255, 122, 0, 0.15);
  }
</style>