<script lang="ts">
  import { page } from '$app/state';
  import { browser } from '$app/environment';
  import { teamsData } from '#lib/store.svelte';

  const cableId = $derived(Number(page.params.id));
  const measureId = $derived(Number(page.params.measureId));
  const teamId = $derived(Number(page.url.searchParams.get('teamId')));
  const currentTeam = $derived(teamsData.find((t: any) => t.id === teamId));
  const teamName = $derived(currentTeam ? currentTeam.name : 'Неизвестная команда');

  // ВОТ ЭТА СТРОКА:
  console.log("Ищем ID:", teamId, "Доступные команды:", teamsData);

  // Массив для карточки кабеля
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

  const cableInfo = $derived(allCables.find((c: any) => c.id === cableId) || allCables[0]);

  // ОДНА И ТА ЖЕ ЗАГЛУШКА ДЛЯ ВСЕХ ИЗМЕРЕНИЙ
  const currentMeasure = $derived({
    title: `Тесты измерения №${measureId}`,
    integrity: [
      { name: 'pin1', value: '0.9 Ом' }, 
      { name: 'pin2', value: '1.2 Ом' }, 
      { name: 'pin3', value: '1.4 Ом' }
    ],
    cmrr: '40 дБ',
    comment: 'Провод в полном порядке!'
  });

  function getCardColor(score: number) {
    if (score >= 70) return 'card-green';
    if (score >= 40) return 'card-yellow';
    return 'card-red';
  }
</script>

<div class="measure-page">
  
  <h2 class="page-title">Кабели команды “{teamName}”</h2>

  <!-- ВЕРХНЯЯ КАРТОЧКА (динамическая, берет данные по cableId) -->
  <div class="cable-card {getCardColor(cableInfo.score)}">
    <div class="card-header">
      <h1 class="cable-name">{cableInfo.name}</h1>
      <div class="cable-score-badge">{cableInfo.score}/100</div>
    </div>
    
    <div class="cable-type-tag">{cableInfo.type}</div>

    <div class="cable-details">
      <div class="detail-row">
        <span class="detail-label">Владелец:</span>
        <span class="detail-value">{cableInfo.owner}</span>
      </div>
      <div class="detail-row">
        <span class="detail-label">Добавлен:</span>
        <span class="detail-value">{cableInfo.dateAdded}</span>
      </div>
      <div class="detail-row">
        <span class="detail-label">Последнее сканирование:</span>
        <span class="detail-value">{cableInfo.lastScan}</span>
      </div>
    </div>
  </div>

  <!-- Подзаголовок тестов -->
  <h3 class="section-title">{currentMeasure.title}</h3>

  <!-- Основной блок с результатами -->
  <div class="results-layout">
    
    <!-- Левая колонка: Тесты -->
    <div class="tests-column">
      <div class="test-block">
        <h4 class="test-title">Целостность</h4>
        <div class="test-list">
          {#each currentMeasure.integrity as item}
            <div class="test-row">
              <span>{item.name}</span>
              <span>{item.value}</span>
            </div>
          {/each}
        </div>
      </div>

      <div class="test-block cmrr-block">
        <h4 class="test-title">CMRR</h4>
        <span class="cmrr-value">{currentMeasure.cmrr}</span>
      </div>
    </div>

    <!-- Правая колонка: Комментарий -->
    <div class="comment-column">
      <div class="comment-box">
        <h4 class="comment-title">Комментарий ИИ-агента</h4>
        <p class="comment-text">{currentMeasure.comment}</p>
      </div>
    </div>

  </div>

  <!-- Кнопка назад -->
  <a href="/teams/cables/{cableId}?teamId={teamId}" class="back-btn">
    Назад
  </a>

</div>

<style>
  /* Стили остаются без изменений, они уже идеально совпадают */
  .measure-page { display: flex; flex-direction: column; align-items: center; width: 100%; height: 100%; padding: 40px; box-sizing: border-box; overflow-y: auto; }
  .page-title { color: #ffffff; font-size: 24px; font-weight: 700; margin: 0 0 40px 0; text-align: center; }
  
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

  .section-title { color: #fff; font-size: 22px; font-weight: 600; margin: 0 0 30px 0; text-align: center; }

  .results-layout { display: flex; gap: 30px; width: 100%; max-width: 900px; align-items: flex-start; }
  .tests-column { flex: 1; display: flex; flex-direction: column; gap: 20px; }
  .test-block { background-color: #1a1a1a; border: 1px solid #333; border-radius: 16px; padding: 20px 24px; }
  .test-title { color: #fff; font-size: 16px; font-weight: 700; margin: 0 0 16px 0; }
  .test-list { display: flex; flex-direction: column; gap: 8px; }
  .test-row { display: flex; justify-content: space-between; color: #aaa; font-size: 14px; }
  .cmrr-block { display: flex; justify-content: space-between; align-items: center; }
  .cmrr-block .test-title { margin: 0; }
  .cmrr-value { color: #fff; font-weight: 600; font-size: 15px; }

  .comment-column { flex: 1; height: 100%; }
  .comment-box { 
    background-color: #1a1a1a; /* Темный фон, как у тестов */
    border: 1px solid #333;    /* Тонкая рамка */
    border-radius: 16px; 
    padding: 24px; 
    height: 100%; 
    box-sizing: border-box; 
    display: flex; 
    flex-direction: column; 
    color: #ffffff;            /* Белый текст */
  }

  .comment-title { 
    font-size: 16px; 
    font-weight: 700; 
    margin: 0 0 16px 0; 
    color: #ffffff;            /* Заголовок тоже белый */
  }

  .comment-text { 
    font-size: 15px; 
    line-height: 1.5; 
    margin: 0; 
    color: #aaaaaa;            /* Текст сделаем чуть серым для иерархии, как в тестах */
  }

  .back-btn { display: flex; justify-content: center; align-items: center; width: 100%; max-width: 320px; margin: 40px auto 20px auto; padding: 16px 20px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #333; border-radius: 45px; font-size: 16px; font-weight: 600; text-decoration: none; cursor: pointer; transition: all 0.2s ease; box-sizing: border-box; }
  .back-btn:hover { border-color: #ff7a00; color: #ff7a00; box-shadow: 0 0 15px rgba(255, 122, 0, 0.15); }
</style>