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
      <div class="flex gap-4 items-center">
        <img src="/icons/logo.svg" alt="logo" width="32" />
        <h1 class="text-lg">Creditopia</h1>
      </div>
    </template>
    <template #item="{ item, props, hasSubmenu, root }">
      <a v-ripple class="flex items-center" v-bind="props.action">
        <span class="text-[#aaa]">{{ item.label }}</span>
        <Badge v-if="item.badge" :class="{ 'ml-auto': !root, 'ml-2': root }" :value="item.badge" />
        <span v-if="item.shortcut"
          class="ml-auto border border-surface rounded bg-emphasis text-muted-color text-xs p-1">{{ item.shortcut
          }}</span>
        <i v-if="hasSubmenu"
          :class="['pi pi-angle-down', { 'pi-angle-down ml-2': root, 'pi-angle-right ml-auto': !root }]"></i>
      </a>
    </template>
  </Menubar>
</template>

<script setup>
import Menubar from 'primevue/menubar';
import { ref } from 'vue';

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
    route: '/my-accounts'
  }
]);
</script>