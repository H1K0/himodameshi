<script lang="ts">
  import { onMount } from 'svelte';
  import { page } from '$app/state';
  import { goto } from '$app/navigation';

  const teamId = $derived(page.url.searchParams.get('id'));

  let cables = $state<any[]>([]);
  let teamName = $state('Загрузка...');
  let isLoading = $state(true);
  let errorMessage = $state('');

  async function loadData() {
    if (!teamId) {
      errorMessage = 'Не указан ID команды';
      isLoading = false;
      return;
    }

    try {
      const teamRes = await fetch(`/api/v1/teams/${teamId}`, { credentials: 'include' });
      if (teamRes.ok) {
        const teamData = await teamRes.json();
        teamName = teamData.name;
      }

      const cablesRes = await fetch(`/api/v1/teams/${teamId}/cables`, { credentials: 'include' });
      if (cablesRes.ok) {
        const data = await cablesRes.json();
        cables = data.items || []; 
      } else if (cablesRes.status === 401) {
        goto('/login');
      } else {
        errorMessage = 'Не удалось загрузить кабели';
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

  function getCardColor(healthScore: number | null) {
    if (healthScore === null) return 'card-none';
    if (healthScore >= 80) return 'card-green';
    if (healthScore >= 40) return 'card-yellow';
    return 'card-red';
  }
</script>

<div class="cables-page">
  <h2 class="page-title">Кабели команды “{teamName}”</h2>

  {#if isLoading}
    <p style="color: #fff;">Загрузка кабелей...</p>
  {:else if errorMessage}
    <p style="color: #ff4444;">{errorMessage}</p>
  {:else if cables.length === 0}
    <div class="empty-state">
      <p>В этой команде пока нет кабелей.</p>
    </div>
  {:else}
    <div class="cables-grid">
      {#each cables as cable (cable.id)}
        <a href="/teams/cables/{cable.id}?teamId={teamId}" class="cable-card {getCardColor(cable.health_score)}">
          
          <div class="card-header">
            <h3 class="cable-name">{cable.name}</h3>
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
              <span class="detail-label">Тестов:</span>
              <span class="detail-value">{cable.test_count}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Последний тест:</span>
              <span class="detail-value">
                {cable.last_test_at ? new Date(cable.last_test_at).toLocaleDateString('ru-RU') : 'Нет'}
              </span>
            </div>
          </div>
          
        </a>
      {/each}
    </div>
  {/if}

  <a href="/teams" class="back-btn">
    Назад к командам
  </a>
</div>

<style>
  .cables-page { display: flex; flex-direction: column; width: 100%; height: 100%; padding: 40px; box-sizing: border-box; overflow-y: auto; }
  .page-title { color: #ffffff; font-size: 24px; font-weight: 700; margin: 0 0 30px 0; text-align: center; }
  .empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 50vh; color: #888; font-size: 18px; }
  
  .cables-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 24px; width: 100%; max-width: 1200px; margin: 0 auto; }
  
  .cable-card { border-radius: 16px; padding: 20px; display: flex; flex-direction: column; color: #111; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1); transition: transform 0.2s ease, box-shadow 0.2s ease; cursor: pointer; position: relative; overflow: hidden; text-decoration: none; }
  .cable-card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3); }
  
  .card-header { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; margin-bottom: 12px; }
  .cable-name { font-size: 18px; font-weight: 700; margin: 0; line-height: 1.3; flex: 1; }
  .cable-score-badge { background-color: rgba(0, 0, 0, 0.15); padding: 8px 16px; border-radius: 16px; font-weight: 800; font-size: 18px; white-space: nowrap; display: flex; align-items: center; justify-content: center; box-shadow: inset 0 1px 3px rgba(0,0,0,0.1); }
  .cable-type-tag { display: inline-block; background-color: rgba(0, 0, 0, 0.08); padding: 4px 12px; border-radius: 8px; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; align-self: flex-start; margin-bottom: 16px; }
  
  .cable-details { display: flex; flex-direction: column; gap: 8px; margin-top: auto; border-top: 1px solid rgba(0, 0, 0, 0.1); padding-top: 12px; }
  .detail-row { display: flex; justify-content: space-between; font-size: 13px; }
  .detail-label { color: rgba(0, 0, 0, 0.6); }
  .detail-value { font-weight: 600; color: #111; }

  .card-green { background-color: #c8f2c8; }
  .card-yellow { background-color: #faed9e; }
  .card-red { background-color: #fa9e9e; }
  .card-none { background-color: #e5e5e5; }

  .back-btn { display: flex; justify-content: center; align-items: center; width: 100%; max-width: 320px; margin: 40px auto 20px auto; padding: 16px 20px; background-color: #1a1a1a; color: #ffffff; border: 1px solid #333; border-radius: 45px; font-size: 16px; font-weight: 600; text-decoration: none; cursor: pointer; transition: all 0.2s ease; box-sizing: border-box; }
  .back-btn:hover { border-color: #ff7a00; color: #ff7a00; box-shadow: 0 0 15px rgba(255, 122, 0, 0.15); }
</style>