<template>
  <div>
    <Toast />
    <Navbar v-if="route.meta.auth && route.path !== '/loans/create'" />
    <router-view></router-view>
  </div>
</template>

<script setup>
import { useRoute } from 'vue-router';
import Navbar from './components/Navbar.vue'
import { onMounted } from 'vue';
import Toast from 'primevue/toast';

const route = useRoute()

onMounted(() => {
  const element = document.querySelector('html');
  element.classList.add('app');
});
</script>
