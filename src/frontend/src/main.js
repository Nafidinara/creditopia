import { createPinia } from 'pinia';
import { createApp } from 'vue';
import App from './App.vue';
import { createRouter, createWebHistory } from 'vue-router'
import PrimeVue from 'primevue/config';
import Aura from '@primevue/themes/aura';
import ToastService from 'primevue/toastservice';
import './index.css';
import 'primeicons/primeicons.css'

import HomeView from './pages/HomeView.vue'
import LoanView from './pages/LoanView.vue'
import DetailLoanView from './pages/DetailLoanView.vue'
import MyAccountView from './pages/MyAccountView.vue'
import CreateLoanView from './pages/CreateLoanView.vue'

const routes = [
  { path: '', component: HomeView, meta: { auth: false } },
  { path: '/loans', component: LoanView, meta: { auth: true } },
  { path: '/loans/create', component: CreateLoanView, meta: { auth: true } },
  { path: '/loans/:id', component: DetailLoanView, meta: { auth: true } },
  { path: '/my-account', component: MyAccountView, meta: { auth: true } },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

createApp(App)
  .use(PrimeVue, {
    theme: {
      preset: Aura,
      options: {
        prefix: 'p',
        darkModeSelector: '.app',
        cssLayer: false,
        cssVariables: {
          '--primary-color': '#3A6BD5'
        }
      }
    }
  })
  .use(ToastService)
  .use(router)
  .use(createPinia())
  .mount('#app');
