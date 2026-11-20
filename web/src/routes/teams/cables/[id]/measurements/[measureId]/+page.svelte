<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/state';
  import { goto } from '$app/navigation';

  // Получаем ID из URL
  const cableId = $derived(page.params.id);
  const measureId = $derived(page.params.measureId);
  const teamId = $derived(page.url.searchParams.get('teamId'));

  // Состояния
  let test = $state<any>(null);
  let cable = $state<any>(null);
  let teamName = $state('Загрузка...');
  let isLoading = $state(true);
  let errorMessage = $state('');

  async function loadData() {
    if (!measureId || !cableId) return;

    try {
      // 1. Загружаем название команды
      if (teamId) {
        const teamRes = await fetch(`/api/v1/teams/${teamId}`, { credentials: 'include' });
        if (teamRes.ok) {
          const teamData = await teamRes.json();
          teamName = teamData.name;
        }
      }

      // 2. Загружаем данные кабеля (для верхней карточки)
      const cableRes = await fetch(`/api/v1/cables/${cableId}`, { credentials: 'include' });
      if (cableRes.ok) {
        cable = await cableRes.json();
      }

      // 3. Загружаем данные самого теста
      const testRes = await fetch(`/api/v1/tests/${measureId}`, { credentials: 'include' });
      if (testRes.ok) {
        test = await testRes.json();
      } else if (testRes.status === 404) {
        errorMessage = 'Измерение не найдено';
      } else {
        errorMessage = 'Ошибка загрузки измерения';
      }
    } catch (e) {
      console.error(e);
      errorMessage = 'Сервер недоступен';
    } finally {
      isLoading = false;
    }
  }

  onMount(() => {
    loadData();
  });

  function getCardColor(score: number | null) {
    if (score === null) return 'card-none';
    if (score >= 80) return 'card-green';
    if (score >= 40) return 'card-yellow';
    return 'card-red';
  }

  // Функция для перевода статусов проводников на русский
  function translateStatus(status: string) {
    if (status === 'ok') return 'Норма';
    if (status === 'warning') return 'Внимание';
    if (status === 'open') return 'Обрыв';
    if (status === 'short') return 'КЗ';
    return status;
  }
</script>

<div class="measure-page">
  <h2 class="page-title">Кабели команды “{teamName}”</h2>

  {#if isLoading}
    <p style="color: #fff;">Загрузка данных...</p>
  {:else if errorMessage}
    <p style="color: #ff4444;">{errorMessage}</p>
  {:else if test && cable}
    <!-- Верхняя карточка кабеля -->
    <div class="cable-card {getCardColor(cable.health_score)}">
      <div class="card-header">
        <h1 class="cable-name">{cable.name}</h1>
        <div class="cable-score-badge">
          {cable.health_score !== null ? `${cable.health_score}/100` : '—'}
        </div>
      </div>
      <div class="cable-type-tag">{cable.cable_type.toUpperCase()}</div>
      <div class="cable-details">
        <div class="detail-row">
          <span class="detail-label">Владелец:</span>
          <span class="detail-value">{cable.assignee ? cable.assignee.nickname : 'Не назначен'}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Добавлен:</span>
          <span class="detail-value">{new Date(cable.created_at).toLocaleDateString('ru-RU')}</span>
        </div>
      </div>
    </div>

    <!-- Заголовок теста -->
    <h3 class="section-title">Тесты измерения</h3>

    <!-- Блок с результатами -->
    <div class="results-layout">
      
      <!-- Левая колонка: Целостность -->
      <div class="tests-column">
        {#if test.results?.continuity}
          <div class="test-block">
            <h4 class="test-title">Целостность</h4>
            <div class="test-list">
              {#each Object.entries(test.results.continuity.conductors) as [pin, data]}
                <div class="test-row">
                  <span>{pin}</span>
                  <span>{data.r} Ом <span class="status">({translateStatus(data.s)})</span></span>
                </div>
              {/each}
            </div>
          </div>
        {/if}

        <!-- Блок CMRR (если есть) -->
        {#if test.results?.cmrr}
          <div class="test-block cmrr-block">
            <h4 class="test-title">CMRR</h4>
            <span class="cmrr-value">{test.results.cmrr.cmrr_db} дБ ({translateStatus(test.results.cmrr.status)})</span>
          </div>
        {/if}
      </div>

      <!-- Правая колонка: Комментарий -->
      <div class="comment-column">
        <div class="comment-box">
          <h4 class="comment-title">Комментарий ИИ-агента</h4>
          <p class="comment-text">
            {test.insight ? test.insight.body : 'Комментарий ещё не сгенерирован.'}
          </p>
        </div>
      </div>

    </div>
  {:else}
    <p class="error-msg">Данные не найдены</p>
  {/if}

  <!-- Кнопка назад -->
  <a href="/teams/cables/{cableId}?teamId={teamId}" class="back-btn">
    Назад к кабелю
  </a>
</div>

<style>
  /* Стили остались прежними, я добавил лишь .status для красоты */
  .measure-page { display: flex; flex-direction: column; align-items: center; width: 100%; height: 100%; padding: 40px; box-sizing: border-box; overflow-y: auto; }
  .page-title { color: #ffffff; font-size: 24px; font-weight: 700; margin: 0 0 40px 0; text-align: center; }

  .cable-card { width: 100%; max-width: 900px; border-radius: 20px; padding: 30px 40px; display: flex; flex-direction: column; color: #111; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2); margin-bottom: 40px; box-sizing: border-box; }
  .card-green { background-color: #c8f2c8; }
  .card-yellow { background-color: #faed9e; }
  .card-red { background-color: #fa9e9e; }
  .card-none { background-color: #e5e5e5; }

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
  .status { color: #fff; font-weight: 600; }
  
  .cmrr-block { display: flex; justify-content: space-between; align-items: center; }
  .cmrr-block .test-title { margin: 0; }
  .cmrr-value { color: #fff; font-weight: 600; font-size: 15px; }
  
  .comment-column { flex: 1; height: 100%; }
  .comment-box { background-color: #1a1a1a; border: 1px solid #333; border-radius: 16px; padding: 24px; height: 100%; box-sizing: border-box; display: flex; flex-direction: column; color: #fff; }
  .comment-title { font-size: 16px; font-weight: 700; margin: 0 0 16px 0; }
  .comment-text { font-size: 15px; line-height: 1.5; margin: 0; color: #aaa; }

  .back-btn { display: flex; justify-content: center; align-items: center; width: 100%; max-width: 320px; margin: 40px auto 20px auto; padding: 16px 20px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #333; border-radius: 45px; font-size: 16px; font-weight: 600; text-decoration: none; cursor: pointer; transition: all 0.2s ease; box-sizing: border-box; }
  .back-btn:hover { border-color: #ff7a00; color: #ff7a00; box-shadow: 0 0 15px rgba(255, 122, 0, 0.15); }

  .error-msg { color: #ff4444; font-size: 18px; }
</style>