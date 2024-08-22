<template>
  <div class="container mx-auto">
    <div class="cursor-pointer flex gap-4 items-center" @click="router.push('/loans')">
      <i class="pi pi-chevron-left"></i>
      <p>Back</p>
    </div>
    <div class="grid grid-cols-12 mt-4 gap-4">
      <div class="col-span-8 bg-[#16161E] rounded-lg pb-6">
        <div class="flex justify-between items-center p-6 border-b border-gray-600">
          <div class="flex gap-2">
            <img src="/icons/course.png" alt="market">
            <div>
              <p class="text-base">Event Course</p>
              <p class="text-xs text-[#AAA] mt-1">Event Professional Organizer</p>
            </div>
          </div>
          <Tag severity="secondary" value="Event" />
        </div>
        <div class="mt-4 px-4 pb-4 border-b border-gray-600">
          <p class="text-sm font-bold">Description</p>
          <p class="mt-3 text-[#AAA]">Event Course is an innovative SME that specializes in creating immersive and
            educational
            event-based learning experiences. We bridge the gap between traditional education and experiential learning
            by offering customized courses designed around dynamic events, workshops, and seminars. Our mission is to
            enhance learning outcomes by providing participants with hands-on, real-world experiences that complement
            theoretical knowledge.</p>
        </div>
        <div class="mt-4 px-4 pb-4 border-b border-gray-600">
          <div class="grid grid-cols-12">
            <div class="col-span-4">
              <p class="text-xs text-[#BDD4FF]">Dana yang Dibutuhkan</p>
              <p class="text-2xl mt-2">564,356 ICP</p>
            </div>
            <div class="col-span-4">
              <p class="text-xs text-[#BDD4FF]">Interest</p>
              <p class="text-2xl mt-2">15%</p>
            </div>
            <div class="col-span-4 text-right">
              <p class="text-sm">282,173 CP <span class="text-[#aaa]">| 564,356 ICP</span></p>
              <p class="text-[#aaa] text-xs mt-2">50% remaining</p>
            </div>
          </div>
          <div
            class="flex justify-between mt-4 py-2 px-3 border border-gray-600 rounded bg-gradient-to-r from-gray-900">
            <p class="text-sm">Payment period</p>
            <p class="text-bold text-sm">6 Month</p>
          </div>
        </div>
        <div class="mt-4 px-4 pb-4 border-b border-gray-600">
          <div class="flex justify-between">
            <p class="text-sm font-bold">Borrow Used</p>
            <p class="text-sm">70% | 400 ICP</p>
          </div>
          <MeterGroup :value="meter" class="mt-4" :pt="{
            labelList: {
              class: ['!hidden']
            }
          }" />
        </div>
        <div class="mt-4 px-4 pb-4 border-b border-gray-600">
          <p class="text-sm font-bold">The Lender (6)</p>
          <div class="grid grid-cols-12 gap-4 mt-4">
            <div class="col-span-3">
              <div
                class="border border-gray-600 rounded-2xl bg-gradient-to-r from-gray-900 py-2 px-3 text-sm font-bold">
                cfic7-3********</div>
            </div>
            <div class="col-span-3">
              <div
                class="border border-gray-600 rounded-2xl bg-gradient-to-r from-gray-900 py-2 px-3 text-sm font-bold">
                cfic7-3********</div>
            </div>
            <div class="col-span-3">
              <div
                class="border border-gray-600 rounded-2xl bg-gradient-to-r from-gray-900 py-2 px-3 text-sm font-bold">
                cfic7-3********</div>
            </div>
            <div class="col-span-3">
              <div
                class="border border-gray-600 rounded-2xl bg-gradient-to-r from-gray-900 py-2 px-3 text-sm font-bold">
                cfic7-3********</div>
            </div>
            <div class="col-span-3">
              <div
                class="border border-gray-600 rounded-2xl bg-gradient-to-r from-gray-900 py-2 px-3 text-sm font-bold">
                cfic7-3********</div>
            </div>
          </div>
        </div>
        <div class="mt-4 px-4 pb-4">
          <p class="text-sm font-bold">Report of Use</p>
          <DataTable tableStyle="min-width: 50rem" :value="data" class="mt-4">
            <Column field="date" header="Date" class="text-sm text-[#AAA]" />
            <Column field="totalUse" header="Total Use" class="text-sm text-[#AAA]" />
            <Column field="detail" header="Detail" class="text-sm text-[#AAA]" />
          </DataTable>
        </div>
      </div>
      <div class="col-span-4 bg-[#16161E] rounded-lg p-6">
        <div class="flex justify-center">
          <SelectButton :value="valueSelect" :items="optionsSelect" @onChange="(value) => valueSelect = value" />
        </div>
        <div v-if="valueSelect === 'Supply'">
          <div class="bg-[#0B0B13] border border-gray-600 rounded-lg p-4 flex items-center mt-8">
            <img src="/icons/icp.svg" alt="icp" />
            <input type="text" class="outline-none border-none bg-[#0B0B13] ml-4 flex-1" placeholder="0">
            <p>≈ $0</p>
            <div class="py-1 px-3 border border-gray-600 rounded-lg ml-4">Max</div>
          </div>
          <div class="mt-4">
            <div class="flex justify-between">
              <p class="text-sm text-[#AAA]">Wallet Balance</p>
              <p class="text-sm text-[#AAA]">$982,736 USDT</p>
            </div>
            <div class="flex justify-between mt-2">
              <p class="text-sm text-[#AAA]">Oracle Price</p>
              <p class="text-sm text-[#AAA]">$1</p>
            </div>
          </div>
          <div class="mt-[40px] rounded-2xl pt-5 pb-[1px] bg-[#0B0B13] bg-opacity-20 border border-gray-600">
            <h1 class="text-center text-sm">Reward Calculation</h1>
            <div class="bg-[#0B0B13] flex justify-center items-center rounded-2xl py-3 mt-5 gap-2">
              <img src="/icons/cdtp.svg" alt="Icp">
              <p class="text-sm">0 CDTP</p>
            </div>
          </div>
        </div>
        <div v-else>
          <div class="bg-[#0B0B13] border border-gray-600 rounded-lg p-4 flex items-center mt-8">
            <img src="/icons/icp.svg" alt="icp" />
            <input type="text" class="outline-none border-none bg-[#0B0B13] ml-4 flex-1" placeholder="0">
            <p>≈ $0</p>
            <div class="py-1 px-3 border border-gray-600 rounded-lg ml-4">Max</div>
          </div>
          <div class="mt-4">
            <div class="flex justify-between">
              <p class="text-sm text-[#AAA]">Wallet Balance</p>
              <p class="text-sm text-[#AAA]">$982,736 USDT</p>
            </div>
            <div class="flex justify-between mt-2">
              <p class="text-sm text-[#AAA]">Claimable Amount</p>
              <p class="text-sm text-[#AAA]">$98,273 USDT</p>
            </div>
            <div class="flex justify-between mt-2">
              <p class="text-sm text-[#AAA]">Oracle Price</p>
              <p class="text-sm text-[#AAA]">$1</p>
            </div>
          </div>
        </div>
        <Button label="Supply" fluid class="mt-[40px]" severity="contrast" />
      </div>
    </div>
  </div>
</template>

<script setup>
import Column from 'primevue/column';
import DataTable from 'primevue/datatable';
import MeterGroup from 'primevue/metergroup';
import SelectButton from '../components/SelectButton.vue';
import Button from 'primevue/button';
import Tag from 'primevue/tag';
import { ref } from 'vue';
import { useRouter } from 'vue-router';

const valueSelect = ref('Supply');
const optionsSelect = ref(['Supply', 'Claim']);

const router = useRouter()

const data = ref([
  {
    id: 1,
    date: '08/14/2024',
    totalUse: '-90 ICP',
    detail: 'Lorem ipsum dolor sit amet, consectet'
  },
  {
    id: 2,
    date: '08/14/2024',
    totalUse: '-90 ICP',
    detail: 'Lorem ipsum dolor sit amet, consectet'
  },
  {
    id: 3,
    date: '08/14/2024',
    totalUse: '-90 ICP',
    detail: 'Lorem ipsum dolor sit amet, consectet'
  },
])
const meter = ref([
  {
    value: '70',
    color: '#2B88F3'
  }
])
</script>