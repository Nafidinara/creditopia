import { createPinia } from 'pinia';
import { createApp } from 'vue';
import App from './App.vue';
import { createRouter, createWebHistory } from 'vue-router'
import PrimeVue from 'primevue/config';
import Aura from '@primevue/themes/aura';
import 'primeicons/primeicons.css'
import './index.css';

import HomeView from './pages/HomeView.vue'
import LoanView from './pages/LoanView.vue'
import DetailLoanView from './pages/DetailLoanView.vue'

const routes = [
  { path: '', component: HomeView, meta: { auth: false } },
  { path: '/loans', component: LoanView, meta: { auth: true } },
  { path: '/loans/:id', component: DetailLoanView, meta: { auth: true } },
]

const router = createRouter({
  history: createWebHistory(),
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
