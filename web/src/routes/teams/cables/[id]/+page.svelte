<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/state';
  import { goto } from '$app/navigation';

  // Получаем ID из URL (это UUID, строка)
  const cableId = $derived(page.params.id); 
  const teamId = $derived(page.url.searchParams.get('teamId'));

  // Состояния
  let cable = $state<any>(null);
  let tests = $state<any[]>([]);
  let teamName = $state('Загрузка...');
  let isLoading = $state(true);
  let errorMessage = $state('');

  // Загрузка данных
  async function loadData() {
    if (!cableId) return;

    try {
      // 1. Загружаем команду (чтобы показать название в заголовке)
      if (teamId) {
        const teamRes = await fetch(`/api/v1/teams/${teamId}`, { credentials: 'include' });
        if (teamRes.ok) {
          const teamData = await teamRes.json();
          teamName = teamData.name;
        }
      }

      // 2. Загружаем сам кабель
      const cableRes = await fetch(`/api/v1/cables/${cableId}`, { credentials: 'include' });
      if (cableRes.ok) {
        cable = await cableRes.json();
      } else if (cableRes.status === 404) {
        errorMessage = 'Кабель не найден';
        return;
      } else if (cableRes.status === 401) {
        goto('/login');
        return;
      } else {
        errorMessage = 'Ошибка загрузки кабеля';
        return;
      }

      // 3. Загружаем историю тестов
      const testsRes = await fetch(`/api/v1/cables/${cableId}/tests`, { credentials: 'include' });
      if (testsRes.ok) {
        const testsData = await testsRes.json();
        tests = testsData.items || [];
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
</script>

<div class="detail-page">
  <h2 class="page-title">Кабели команды “{teamName}”</h2>

  {#if isLoading}
    <p style="color: #fff;">Загрузка данных кабеля...</p>
  {:else if errorMessage}
    <p style="color: #ff4444;">{errorMessage}</p>
  {:else if cable}
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
        <div class="detail-row">
          <span class="detail-label">Последнее сканирование:</span>
          <span class="detail-value">
            {cable.last_test_at ? new Date(cable.last_test_at).toLocaleDateString('ru-RU') : 'Нет'}
          </span>
        </div>
      </div>
    </div>

    <!-- Таблица измерений -->
    <div class="measurements-section">
      <h3 class="section-title">Измерения</h3>
      <div class="table-container">
        {#if tests.length > 0}
          <table class="measurements-table">
            <thead>
              <tr>
                <th>Дата</th>
                <th>Автор</th>
                <th>Health Score</th>
              </tr>
            </thead>
            <tbody>
              {#each tests as test (test.id)}
                <!-- Добавили onclick и класс для курсора -->
                <tr 
                  onclick={() => window.location.href = `/teams/cables/${cableId}/measurements/${test.id}?teamId=${teamId}`} 
                  class="clickable-row"
                >
                  <td>{new Date(test.measured_at).toLocaleString('ru-RU')}</td>
                  <td>{test.author.nickname}</td>
                  <td class="score-cell">{test.health_score !== null ? `${test.health_score}/100` : '—'}</td>
                </tr>
              {/each}
            </tbody>
          </table>
        {:else}
          <p class="no-data">Для этого кабеля пока нет измерений.</p>
        {/if}
      </div>
    </div>
  {:else}
    <p class="error-msg">Кабель не найден</p>
  {/if}

  <!-- Кнопка назад -->
  <a href="/teams/cables?id={teamId}" class="back-btn">
    Назад к кабелям
  </a>
</div>

<style>
  /* Стили (оставил как были, они хорошие) */
  .detail-page { display: flex; flex-direction: column; align-items: center; width: 100%; height: 100%; padding: 40px; box-sizing: border-box; overflow-y: auto; }
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

  .measurements-section { width: 100%; max-width: 900px; display: flex; flex-direction: column; align-items: center; margin-bottom: 20px; }
  .section-title { color: #fff; font-size: 24px; font-weight: 600; margin: 0 0 20px 0; }
  .table-container { width: 100%; background-color: #1a1a1a; border: 1px solid #333; border-radius: 16px; padding: 0; box-sizing: border-box; overflow: hidden; }
  .measurements-table { width: 100%; border-collapse: collapse; font-size: 15px; color: #fff; }
  .measurements-table th { font-weight: 600; padding: 20px 16px; text-align: center; border-bottom: 1px solid #333; color: #888; font-size: 14px; }
  .measurements-table td { padding: 18px 16px; text-align: center; border-bottom: 1px solid #333; }
  .measurements-table tbody tr:last-child td { border-bottom: none; }
  .measurements-table tbody tr:hover { background-color: #222; }
  .score-cell { font-weight: 700; color: #fff; }
  .no-data { text-align: center; color: #555; font-size: 15px; padding: 20px 0; margin: 0; }
  .error-msg { color: #ff4444; font-size: 18px; }

  .back-btn { display: flex; justify-content: center; align-items: center; width: 100%; max-width: 320px; margin: 40px auto 20px auto; padding: 16px 20px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #333; border-radius: 16px; font-size: 16px; font-weight: 600; text-decoration: none; cursor: pointer; transition: all 0.2s ease; box-sizing: border-box; }
  .back-btn:hover { border-color: #ff7a00; color: #ff7a00; box-shadow: 0 0 15px rgba(255, 122, 0, 0.15); }
</style>