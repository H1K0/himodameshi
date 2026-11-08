<script lang="ts">
  import { page } from '$app/state';
  import { teamsData } from '#lib/store.svelte';

  const cableId = $derived(Number(page.params.id));
  const teamId = $derived(Number(page.url.searchParams.get('teamId')));
  const currentTeam = $derived(teamsData.find((t: any) => t.id === teamId));
  const teamName = $derived(currentTeam ? currentTeam.name : 'Неизвестная команда');

  // Единый массив кабелей (с добавленным lastScan)
  const allCables = [
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

  // Находим текущий кабель по ID из URL
  const cable = $derived(allCables.find((c: any) => c.id === cableId));

  // Заглушка для таблицы измерений
  const measurements = $derived([
    { id: 4, date: '23/06/2026', author: 'vlad2121', tests: 'Целостность', score: 80 },
    { id: 3, date: '21/06/2026', author: 'yakshnkoooo', tests: 'CMRR, АЧХ', score: 80 },
    { id: 2, date: '19/06/2026', author: 'yakshnkoooo', tests: 'CMRR, целостность', score: 75 },
    { id: 1, date: '18/06/2026', author: 'valery332', tests: 'CMRR, АЧХ, целостность', score: 63 }
  ]);

  // Функция для цвета
  function getCardColor(score: number) {
    if (score >= 70) return 'card-green';
    if (score >= 40) return 'card-yellow';
    return 'card-red';
  }
</script>

<div class="detail-page">
  
  <h2 class="page-title">Кабели команды “{teamName}”</h2>

  {#if cable}
    <!-- Верхняя карточка (широкая) -->
    <div class="cable-card {getCardColor(cable.score)}">
      
      <div class="card-header">
        <h1 class="cable-name">{cable.name}</h1>
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
        <!-- ДОБАВИЛИ ЭТУ СТРОКУ -->
        <div class="detail-row">
          <span class="detail-label">Последнее сканирование:</span>
          <span class="detail-value">{cable.lastScan}</span>
        </div>
      </div>
      
    </div>

    <!-- Таблица измерений -->
    <div class="measurements-section">
      <h3 class="section-title">Измерения</h3>
      <div class="table-container">
        <table class="measurements-table">
          <thead>
            <!-- ... заголовки таблицы ... -->
          </thead>
          <tbody>
            {#each measurements as m (m.id)}
              <!-- ВОТ СЮДА ВСТАВЛЯЕТСЯ ЭТА СТРОКА -->
              <tr onclick={() => window.location.href = `/teams/cables/${cableId}/measurements/${m.id}?teamId=${teamId}`} class="clickable-row">
                <td>{m.id}</td>
                <td>{m.date}</td>
                <td>{m.author}</td>
                <td>{m.tests}</td>
                <td class="score-cell">{m.score}/100</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {:else}
    <p class="error-msg">Кабель с ID {cableId} не найден 😢</p>
  {/if}

  <!-- Кнопка назад -->
  <a href="/teams/cables?id={teamId}" class="back-btn">
    Назад
  </a>

</div>

<style>
  .detail-page { display: flex; flex-direction: column; align-items: center; width: 100%; height: 100%; padding: 40px; box-sizing: border-box; overflow-y: auto; }
  .page-title { color: #ffffff; font-size: 24px; font-weight: 700; margin: 0 0 40px 0; text-align: center; }

  /* Карточка */
  .cable-card { width: 100%; max-width: 900px; border-radius: 20px; padding: 30px 40px; display: flex; flex-direction: column; color: #111; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2); margin-bottom: 40px; box-sizing: border-box; }
  .card-green { background-color: #c8f2c8; }
  .card-yellow { background-color: #faed9e; }
  .card-red { background-color: #fa9e9e; }

  .card-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 20px; margin-bottom: 16px; }
  .cable-name { font-size: 32px; font-weight: 700; margin: 0; line-height: 1.2; flex: 1; }
  .cable-score-badge { background-color: rgba(0, 0, 0, 0.15); padding: 10px 20px; border-radius: 16px; font-weight: 800; font-size: 22px; white-space: nowrap; display: flex; align-items: center; justify-content: center; box-shadow: inset 0 1px 3px rgba(0,0,0,0.1); }
  .cable-type-tag { display: inline-block; background-color: rgba(0, 0, 0, 0.08); padding: 6px 16px; border-radius: 8px; font-size: 14px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; align-self: flex-start; margin-bottom: 24px; }
  .cable-details { display: flex; flex-direction: column; gap: 12px; margin-top: auto; border-top: 1px solid rgba(0, 0, 0, 0.1); padding-top: 20px; }
  .detail-row { display: flex; justify-content: space-between; font-size: 16px; }
  .detail-label { color: rgba(0, 0, 0, 0.6); }
  .detail-value { font-weight: 600; color: #111; }

  /* Таблица */
   .measurements-section { width: 100%; max-width: 900px; display: flex; flex-direction: column; align-items: center; margin-bottom: 20px; }
  .section-title { color: #fff; font-size: 24px; font-weight: 600; margin: 0 0 20px 0; }
  
  .table-container { 
    width: 100%; 
    background-color: #1a1a1a; /* Темный фон, как у блока участников */
    border: 1px solid #333;    /* Тонкая рамка */
    border-radius: 16px; 
    padding: 0;                /* Убираем внутренние отступы, чтобы линии были от края до края */
    box-sizing: border-box; 
    overflow: hidden;          /* Чтобы скругленные углы обрезали таблицу */
  }

  .measurements-table { 
    width: 100%; 
    border-collapse: collapse; 
    font-size: 15px; /* Чуть уменьшили, чтобы влезало в темную тему */
    color: #fff;     /* Белый текст */
  }

  /* Заголовки колонок */
  .measurements-table th { 
    font-weight: 600; 
    padding: 20px 16px; 
    text-align: center; 
    border-bottom: 1px solid #333; 
    color: #888; /* Серый цвет для заголовков, чтобы не перегружать */
    font-size: 14px;
  }

  /* Ячейки с данными */
  .measurements-table td { 
    padding: 18px 16px; 
    text-align: center; 
    border-bottom: 1px solid #333; /* Темная линия-разделитель */
  }

  /* Убираем нижнюю линию у последней строки */
  .measurements-table tbody tr:last-child td { 
    border-bottom: none; 
  }

  /* Подсветка строки при наведении (как в блоке участников) */
  .measurements-table tbody tr:hover { 
    background-color: #222; 
  }

  /* Жирный шрифт для Health Score */
  .score-cell { 
    font-weight: 700; 
    color: #fff;
  }

  .error-msg { color: #ff4444; font-size: 18px; }

  /* Кнопка */
  .back-btn { display: flex; justify-content: center; align-items: center; width: 100%; max-width: 320px; margin: 40px auto 20px auto; padding: 16px 20px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #333; border-radius: 45px; font-size: 16px; font-weight: 600; text-decoration: none; cursor: pointer; transition: all 0.2s ease; box-sizing: border-box; }
  .back-btn:hover { border-color: #ff7a00; color: #ff7a00; box-shadow: 0 0 15px rgba(255, 122, 0, 0.15); }

   .clickable-row {
    cursor: pointer;
    transition: background-color 0.2s;
  }
</style>