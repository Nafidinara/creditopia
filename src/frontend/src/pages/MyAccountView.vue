<template>
  <div class="container mx-auto">
    <h1 class="mb-4 font-bold text-lg mt-[40px]">My Accounts</h1>
    <div class="mt-4">
      <div class="grid grid-cols-10 border border-gray-600 rounded-lg py-[55px] px-8">
        <div class="col-span-2">
          <p class="text-sm text-[#BDD4FF]">Supply Balance</p>
          <p class="text-[30px] mt-3"><span class="!text-[35px] !font-bold">567.834</span> ICP</p>
        </div>
        <div class="col-span-2">
          <p class="text-sm text-[#BDD4FF]">Supplied Loans</p>
          <p class="text-[30px] mt-3"><span class="!text-[35px] !font-bold">564,356</span> ICP</p>
        </div>
        <div class="col-span-2">
          <p class="text-sm text-[#BDD4FF]">Borrowed Loans</p>
          <p class="text-[30px] mt-3"><span class="!text-[35px] !font-bold">3,356</span> ICP</p>
        </div>
        <div class="col-span-2">
          <p class="text-sm text-[#BDD4FF]">Profit</p>
          <p class="text-[30px] mt-3"><span class="!text-[35px] !font-bold">356</span> ICP</p>
        </div>
        <div class="col-span-2 flex flex-col border border-gray-800 rounded-lg p-3">
          <div class="flex items-center justify-between">
            <p class="text-xs text-[#BDD4FF]">Next Payment</p>
            <div class="flex items-center gap-3">
              <img src="/icons/icp.svg" alt="icp">
              <p class="text-xs">Market Cuan</p>
            </div>
          </div>
          <p class="text-right mt-4 text-xl">08/24/2024</p>
        </div>
        <div class="col-span-10">
          <MeterGroup :value="meter" class="mt-4" />
        </div>
      </div>
    </div>
    <div class="mt-[70px]">
      <div class="flex justify-between items-center">
        <h1 class="mb-4 font-bold text-lg">My Loans</h1>
        <Button label="Create Loan" severity="contrast" @click="router.push('/loans/create')" />
      </div>
      <div class="flex flex-row gap-4 mt-4 overflow-x-scroll">
        <div class="w-[304px] shrink-0 border border-gray-600 rounded-lg" v-for="item in myLoans" :key="item.id">
          <div class="flex justify-between items-center p-4">
            <div class="flex items-center gap-3">
              <img src="/icons/electric.svg" alt="electric">
              <p>{{ item.title }}</p>
            </div>
            <Tag severity="secondary" :value="item.category" />
          </div>
          <div class="bg-[#0B0B13] rounded-lg py-2 px-4">
            <p class="text-center">400 ICP <span>| 800 ICP</span></p>
            <div class="flex gap-4 items-center mt-4">
              <MeterGroup :value="meter" class="w-full" :pt="{
            labellist: {
              class: ['!hidden']
            }
          }" />
              <p class="text-sm text-[#AAA]">60%</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="mt-[70px]">
      <DataTable tableStyle="min-width: 50rem" :value="mySuppliedLoans">
        <Column field="name" header="SME Name" class="text-sm text-[#AAA]">
          <template #body="{ data }">
            <div class="flex gap-2 items-center">
              <img src="/icons/market.png" alt="market">
              <h1 class="text-sm">
                {{ data.name }}
              </h1>
            </div>
          </template>
        </Column>
        <Column field="creator" header="Creator" class="text-sm text-[#AAA]">
          <template #body="{ data }">
            <h1 class="text-sm">
              {{ data.creator }}
            </h1>
          </template>
        </Column>
        <Column field="category" header="Category" class="text-sm text-[#AAA]">
          <template #body="{ data }">
            <Tag severity="secondary" :value="data.category" />
          </template>
        </Column>
        <Column field="totalSupplied" header="Total Supplied" class="text-sm text-[#AAA]">
          <template #body="{ data }">
            <div class="flex gap-2 items-center">
              <div>
                <p class="text-sm">400 ICP | 800 ICP</p>
                <p class="text-xs">50% remaining</p>
              </div>
            </div>
          </template>
        </Column>
        <Column field="interest" header="Interest" class="text-sm text-[#AAA]"></Column>
        <Column field="repaymentDuration" header="Repayment Duration" class="text-sm text-[#AAA]">
          <template #body="{ data }">
            <div class="flex gap-8 items-center">
              <p class="text-sm">{{ data.repaymentDuration }}</p>
            </div>
          </template>
        </Column>
      </DataTable>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import Tag from 'primevue/tag';
import MeterGroup from 'primevue/metergroup';
import Button from 'primevue/button';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import { useRouter } from 'vue-router';

const router = useRouter()

const meter = ref([
  {
    value: '70',
    color: '#2B88F3',
    label: 'Supplied Loans'
  },
  {
    value: '30',
    color: '#FC2496',
    label: 'Borrowed Loans'
  }
]);

const myLoans = ref([
  {
    id: 1,
    title: 'ElectricPay',
    category: 'UMKM'
  },
  {
    id: 2,
    title: 'ElectricPay',
    category: 'UMKM'
  },
  {
    id: 3,
    title: 'ElectricPay',
    category: 'UMKM'
  },
  {
    id: 4,
    title: 'ElectricPay',
    category: 'UMKM'
  },
  {
    id: 5,
    title: 'ElectricPay',
    category: 'UMKM'
  },
  {
    id: 6,
    title: 'ElectricPay',
    category: 'UMKM'
  },
]);

const mySuppliedLoans = ref([
  {
    id: 1,
    name: 'Market Cuan',
    creator: 'Bebe Bonica',
    category: 'Event',
    totalSupplied: '400 ICP',
    interest: '15%',
    repaymentDuration: '08/14/2024'
  },
  {
    id: 2,
    name: 'Tax',
    creator: 'Iwan Fals',
    category: 'Event',
    totalSupplied: '400 ICP',
    interest: '15%',
    repaymentDuration: '08/14/2024'
  },
  {
    id: 3,
    name: 'Cash Advance',
    creator: 'John F Kennedy',
    category: 'Event',
    totalSupplied: '400 ICP',
    interest: '15%',
    repaymentDuration: '08/14/2024'
  },
]);
</script>