import { browser } from '$app/environment';

// Загружаем профиль
const savedProfile = browser ? localStorage.getItem('himo_profile') : null;
export const userProfile = $state(
  savedProfile ? JSON.parse(savedProfile) : {
    firstName: 'Иван',
    lastName: 'Якушенко',
    username: 'yakshnkoooo',
    isTelegramLinked: false
  }
);

// Загружаем команды
const savedTeams = browser ? localStorage.getItem('my_teams') : null;
export const teamsData = $state(
  savedTeams ? JSON.parse(savedTeams) : [
    { 
      id: 1, 
      name: 'Ваша базовая команда', 
      members: 'Вы', 
      isBase: true, 
      invited: [] as string[] 
    }
  ]
);

// Сохраняем при изменениях
if (browser) {
  $effect.root(() => {
    $effect(() => {
      localStorage.setItem('himo_profile', JSON.stringify(userProfile));
    });
    $effect(() => {
      localStorage.setItem('my_teams', JSON.stringify(teamsData));
    });
  });
}