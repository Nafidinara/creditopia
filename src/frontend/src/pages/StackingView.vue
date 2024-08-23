<template>
  <div class="container mx-auto">
    <div class="grid grid-cols-12 gap-4 items-start mt-[40px]">
      <div class="col-span-2"></div>
      <div class="col-span-6 bg-[#16161E] rounded-lg">
        <div class="p-4">
          <div class="grid grid-cols-12 gap-4">
            <div class="rounded-2xl pt-5 pb-[1px] bg-[#0B0B13] bg-opacity-20 border border-gray-600 col-span-6">
              <h1 class="text-base ml-4">Total Stake</h1>
              <div class="bg-[#0B0B13] flex justify-center items-center rounded-2xl py-8 mt-5 gap-2">
                <img src="/icons/cdtp.svg" alt="Icp">
                <p class="text-base">5,876,990 ICP</p>
              </div>
            </div>
            <div class="rounded-2xl pt-5 pb-[1px] bg-[#0B0B13] bg-opacity-20 border border-gray-600 col-span-6">
              <h1 class="text-base ml-4">Total Reward</h1>
              <div class="bg-[#0B0B13] flex justify-center items-center rounded-2xl py-8 mt-5 gap-2">
                <img src="/icons/point.svg" alt="Icp">
                <p class="text-base">6,785 Points</p>
              </div>
            </div>
          </div>
        </div>
        <div class="flex justify-between items-center border border-gray-600 rounded-lg py-2 px-6">
          <p>Remaining Time</p>
          <p class="text-[#82A9FF] font-bold">2 <span class="text-[#AAA] font-normal">Days</span> 16 <span
              class="text-[#AAA] font-normal">Hours</span> 17 <span class="text-[#AAA] font-normal">Minute</span></p>
        </div>
      </div>
      <div class="col-span-4 bg-[#16161E] rounded-lg p-6">
        <div class="flex justify-center mb-8">
          <SelectButton :value="valueSelect" :items="optionsSelect" @onChange="(value) => valueSelect = value" />
        </div>
        <div v-if="valueSelect === 'Stake'">
          <p class="text-sm">Your Balance</p>
          <div class="flex gap-3 bg-[#333333] p-4 items-center justify-center rounded-lg mt-4">
            <img src="/icons/cdtp.svg" alt="cdtp">
            <p class="text-lg font-bold">{{ parseInt(balance) / 100000000 }} CDTP</p>
          </div>
          <p class="text-sm mt-4">You Stake</p>
          <div class="bg-[#0B0B13] border border-gray-600 rounded-lg p-4 flex items-center mt-4">
            <img src="/icons/icp.svg" alt="icp" />
            <input v-model="stackingValue" type="text" class="outline-none border-none bg-[#0B0B13] ml-4 flex-1" placeholder="0">
            <p>≈ $0</p>
            <div class="py-1 px-3 border border-gray-600 rounded-lg ml-4">Max</div>
          </div>
          <p class="text-sm mt-4">Lock Period</p>
          <div v-for="category in categories" :key="category.key"
            class="flex items-center justify-between p-3 rounded-full border border-gray-600 bg-[#55555b04] mt-4">
            <div class="flex items-center">
              <RadioButton v-model="selectedCategory" :inputId="category.key" name="dynamic" :value="category.name" />
              <label :for="category.key" class="ml-2">{{ category.name }}</label>
            </div>
            <div class="flex items-center gap-3">
              <p>{{ category.interest }}</p>
              <img src="/icons/flash.svg" alt="flash">
            </div>
          </div>
          <Button label="Stake" @click="stakeNow" fluid class="mt-[40px]" severity="contrast" />
        </div>
        <div v-else>
          <p class="text-sm">Available to Unstake</p>
          <div class="flex gap-3 bg-[#333333] p-4 items-center justify-center rounded-lg mt-4">
            <div class="flex items-center relative">
              <img src="/icons/cdtp.svg" alt="cdtp" width="32" height="32">
              <img src="/icons/point.svg" alt="point" width="32" height="32" class="absolute right-[-15px]">
            </div>
            <p class="text-lg font-bold ml-4">5,883,775</p>
          </div>
          <p class="text-sm mt-4">You Unstake</p>
          <div class="bg-[#0B0B13] border border-gray-600 rounded-lg p-4 flex items-center mt-4">
            <img src="/icons/icp.svg" alt="icp" />
            <input type="text" class="outline-none border-none bg-[#0B0B13] ml-4 flex-1" placeholder="0">
            <p>≈ $0</p>
            <div class="py-1 px-3 border border-gray-600 rounded-lg ml-4">Max</div>
          </div>
          <Button label="Unstake" fluid class="mt-[40px]" severity="contrast" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import SelectButton from '../components/SelectButton.vue';
import RadioButton from 'primevue/radiobutton';
import Button from 'primevue/button';
import { staking } from 'declarations/staking/index';
import { CDTP } from 'declarations/CDTP'
import { useAuthStore } from '../stores/auth';

import { Principal } from '@dfinity/principal';

import {Actor,HttpAgent} from '@dfinity/agent'
import {idlFactory } from 'declarations/CDTP/CDTP.did.js';
const valueSelect = ref('Stake');
const optionsSelect = ref(['Stake', 'Unstake']);

const stackingValue = ref('')
const balance = ref('')

const authStore = useAuthStore();
const selectedCategory = ref('Production');
const categories = ref([
  { name: '1 Day', key: '1_day', interest: '2,5%' },
  { name: '3 Day', key: '3_day', interest: '5%' },
  { name: '10 Day', key: '10_day', interest: '10%' },
]);

onMounted(async () => {
 await CDTP.icrc1_balance_of({owner:Principal.fromText(authStore.principalId), subaccount:[]}).then((res) => {
  console.log(res)
  balance.value = res
 });
});

const stakeNow = async () =>{
// Initialize the agent
// const agent = HttpAgent.createSync({ identity: authStore.principalId });
// // agent.addIdentity('staker'); // Replace 'staker' with the actual identity
// await agent.fetchRootKey();
// // Initialize the actor
// const cdtp = Actor.createActor(idlFactory, { agent: JSON.parse(authStore.userAgent).agent , canisterId: 'bkyz2-fmaaa-aaaaa-qaaaq-cai' }); // Replace 'cdtp-canister-id' with the actual canister ID
// console.log("cdtp", cdtp)
// console.log("agent", agent)
// Make the call

const cdtp = await window.ic.plug.createActor({
    canisterId: 'bkyz2-fmaaa-aaaaa-qaaaq-cai',
    interfaceFactory: idlFactory,
});

console.log("Agent", cdtp);

await cdtp.icrc1_balance_of({owner:Principal.fromText(authStore.principalId), subaccount:[]}).then((res) => {
  console.log(res)
  balance.value = res
 }).catch((e) => {
  console.log("error in icrc1_balance_of", e)
 });
const approve = await cdtp.icrc2_approve({
  spender: {
    owner: Principal.fromText('be2us-64aaa-aaaaa-qaabq-cai'), // Replace 'staking-canister-id' with the actual canister ID
    subaccount: [],
  },
  amount: 9999999999999999,
  fee:[],
  memo:[],
  from_subaccount:[],
  created_at_time: [],
  expected_allowance: [],
  expires_at: [],
});

console.log("approve", approve);

console.log("should success");

// const localstacking = await staking.deposit(parseInt(stackingValue.value) * 100000000, 0)

}

</script>