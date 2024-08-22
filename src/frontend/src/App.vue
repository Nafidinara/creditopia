<template>
  <div>
    <Navbar v-if="route.meta.auth" />
    <router-view></router-view>
  </div>
</template>

<script setup>
import { useRoute } from 'vue-router';
import Navbar from './components/Navbar.vue'

const route = useRoute()
</script>