import { createPinia } from 'pinia';
import { createApp } from 'vue';
import App from './App.vue';
import { createRouter, createMemoryHistory } from 'vue-router'
import HomeView from './pages/HomeView.vue'
import PrimeVue from 'primevue/config';
import Aura from '@primevue/themes/aura';
import 'primeicons/primeicons.css'
import './index.css';

const routes = [
  { path: '/', component: HomeView },
]

const router = createRouter({
  history: createMemoryHistory(),
  routes,
})

createApp(App)
  .use(PrimeVue, {
    theme: {
      preset: Aura
    }
  })
  .use(router)
  .use(createPinia())
  .mount('#app');
