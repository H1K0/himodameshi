import adapter from '@sveltejs/adapter-static';
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [
		sveltekit({
			compilerOptions: {
				// Force runes mode for the project, except for libraries. Can be removed in svelte 6.
				runes: ({ filename }) =>
					filename.split(/[/\\]/).includes('node_modules') ? undefined : true
			},

			// SPA: статика в build/ раздаётся Go-сервером Hub, на неизвестные пути он отвечает
			// index.html, дальше маршрут разбирает роутер в браузере (ADR-015).
			adapter: adapter({ fallback: 'index.html' })
		})
	]
});
