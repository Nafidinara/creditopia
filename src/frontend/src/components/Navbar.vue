<template>
  <Menubar :model="items" :pt="{
    root: {
      class: ['!border-none !bg-[#121212] !px-[80px] !py-8']
    },
    rootList: {
      class: ['!ml-auto']
    }
  }">
    <template #start>
      <div class="flex gap-4 items-center cursor-pointer" @click="router.push('/')">
        <img src="/icons/logo.svg" alt="logo" width="32" />
        <h1 class="text-lg">Creditopia</h1>
      </div>
    </template>
    <template #item="{ item, props, hasSubmenu, root }">
      <a v-ripple class="flex items-center" :class="{ 'active-item': route.path.includes(item.route) }" v-bind="props.action"
        :href="item.route">
        <span class="text-[#aaa]">{{ item.label }}</span>
      </a>
    </template>
    <template #end>
      <div class="flex gap-4 items-center border border-gray-600 rounded-lg  py-2 px-3">
        <Avatar label="KH" style="background-color: #dee9fc; color: #1a2551" />
        <h1>Ken Hiller</h1>
      </div>
    </template>
  </Menubar>
</template>

<script setup>
import { ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import Menubar from 'primevue/menubar';
import Avatar from 'primevue/avatar';

const route = useRoute()
const router = useRouter()

const items = ref([
  {
    label: 'Loans',
    route: '/loans'
  },
  {
    label: 'Staking',
    route: '/stacking'
  },
  {
    label: 'Ecosystem',
    route: '/ecosystem'
  },
  {
    label: 'My accounts',
    route: '/my-account'
  }
]);
</script>

<style scoped>
.active-item {
  display: block;
  position: relative;
}

.active-item:after {
  display: block;
  margin: 0 auto;
  position: absolute;
  left: 40%;
  bottom: 0;
  content: '';
  height: 4px;
  width: 12px;
  border-radius: 12px;
  background-color: #3A6BD5;
}
</style>