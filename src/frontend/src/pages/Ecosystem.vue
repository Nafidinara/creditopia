<template>
  <div class="container mx-auto">
    <h1 class="mt-[40px] text-[40px] text-[#82A9FF] text-center">Creditopia Ecosystem</h1>
    <p class="text-[#AAA] text-center">Empowering growth through secure, transparent lending and rewarding staking.</p>
    <div class="grid grid-cols-12 gap-5 mt-[40px]">
      <div class="col-span-3 bg-[#1B1B23] border border-gray-600 rounded-3xl" v-for="content in contents"
        :key="content.id">
        <img :src="content.img" alt="img">
        <div class="py-3 px-5">
          <p class="font-bold text-base">{{ content.title }}</p>
          <div class="h-[120px] flex items-center w-full">
            <p class="text-xs text-[#aaa]">{{ content.description }}</p>
          </div>
          <div class="flex items-center gap-2">
            <img src="/icons/wallet.svg" alt="wallet">
            <img src="/icons/github.svg" alt="github">
            <img src="/icons/link.svg" alt="link">
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const contents = ref([
  {
    id: 1,
    title: 'Spinner Cash',
    description: 'Safeguard your financial privacy with zero-knowledge proofs',
    img: '/image/spinner-cash.png'
  },
  {
    id: 2,
    title: 'ICTC',
    description: 'IC Transaction Coordinator (ICTC) is a distributed transaction framework for Defi applications on IC network. It supports Motoko language. The core',
    img: '/image/spinner-cash.png-1.png'
  }
]);
</script>