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
      <a v-ripple class="flex items-center" :class="{ 'active-item': route.path.includes(item.route) }"
        v-bind="props.action" :href="item.route">
        <span class="text-[#aaa]">{{ item.label }}</span>
      </a>
    </template>
    <template #end>
      <div v-if="authStore.isAuth">
        <div class="flex gap-4 items-center border border-gray-600 rounded-lg  py-2 px-3 cursor-pointer"
          aria-haspopup="true" aria-controls="overlay_menu" @click="toggleMenu">
          <Avatar :label="authStore.user?.name?.split(' ').map((value) => value.charAt(0)).join('').toUpperCase()"
            style="background-color: #dee9fc; color: #1a2551" />
          <h1>{{ authStore.user.name }}</h1>
        </div>
        <Menu ref="menu" id="overlay_menu" :model="menuItems" :popup="true" />
      </div>
      <Button label="Connect" severity="contrast" size="small" v-else-if="!authStore.isWalletConnected"
        @click="authStore.connectToWallet" />
      <Button label="Sign Up" severity="contrast" size="small" v-else @click="router.push('/signup')" />
    </template>
  </Menubar>
</template>

<script setup>
import { ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import Menubar from 'primevue/menubar';
import Avatar from 'primevue/avatar';
import Button from 'primevue/button';
import Menu from 'primevue/menu';
import { useAuthStore } from '../stores/auth';

const route = useRoute()
const router = useRouter()

const authStore = useAuthStore()

const menu = ref(null)
const menuItems = ref(
  [
    {
      label: 'Logout',
      icon: 'pi pi-power-off',
      command: async () => {
        await authStore.logout()
      }
    }
  ]
)

const toggleMenu = (event) => {
  menu.value.toggle(event);
};

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