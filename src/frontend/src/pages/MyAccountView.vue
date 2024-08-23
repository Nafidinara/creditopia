<template>
  <div class="container mx-auto">
    <h1 class="mb-4 font-bold text-lg mt-[40px]">My Accounts</h1>
    <div class="mt-4">
      <div class="grid grid-cols-10 border border-gray-600 rounded-lg py-[55px] px-8">
        <div class="col-span-2">
          <p class="text-sm text-[#BDD4FF]">Supply Balance</p>
          <p class="text-[30px] mt-3"><span class="!text-[35px] !font-bold">{{ Number(totalSuppliedLoans) +
            Number(totalBorrowerLoans) }}</span> ICP</p>
        </div>
        <div class="col-span-2">
          <p class="text-sm text-[#BDD4FF]">Supplied Loans</p>
          <p class="text-[30px] mt-3"><span class="!text-[35px] !font-bold">{{
            Number(totalSuppliedLoans) === 0 ? 0 :
              Number(totalSuppliedLoans) / (10 ** 8) < 1 ? '<1' : Number(totalSuppliedLoans) / (10 ** 8) }}</span> ICP
          </p>
        </div>
        <div class="col-span-2">
          <p class="text-sm text-[#BDD4FF]">Borrowed Loans</p>
          <p class="text-[30px] mt-3"><span class="!text-[35px] !font-bold">{{ Number(totalBorrowerLoans) === 0 ? 0
            : Number(totalBorrowerLoans) / (10 ** 8) < 1 ? '<1' : Number(totalBorrowerLoans) / (10 ** 8) }}</span> ICP
          </p>
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
        <div class="w-[304px] shrink-0 border border-gray-600 rounded-lg" v-for="item in borrowerLoans" :key="item.id">
          <div class="flex justify-between items-center p-4">
            <div class="flex items-center gap-3">
              <img src="/icons/electric.svg" alt="electric">
              <p>{{ item.title }}</p>
            </div>
            <Tag severity="secondary" :value="item.category" />
          </div>
          <div class="bg-[#0B0B13] rounded-lg py-2 px-4">
            <p class="text-sm text-center">{{ Number(item.fundedAmount) / (10 ** 8) }} CP <span class="text-[#aaa]">| {{
            item.totalAmount }}
                ICP</span></p>

            <div class="flex gap-4 items-center mt-4">
              <MeterGroup :value="[
            {
              value: isNaN(Math.abs((Number(item.fundedAmount) / (Number(item.fundedAmount) + Number(item.totalAmount))) * 100)) ? 50 : Math.abs((Number(item.fundedAmount) / (Number(item.fundedAmount) + Number(item.totalAmount)))),
              color: '#2B88F3',
            },
            {
              value: isNaN(Math.abs((Number(item.totalAmount) / (Number(item.totalAmount) + Number(item.fundedAmount))) * 100)) ? 50 : Math.abs((Number(item.totalAmount) / (Number(item.totalAmount) + Number(item.fundedAmount)))),
              color: '#FC2496',
            }
          ]" class="w-full" :pt="{
            labellist: {
              class: ['!hidden']
            }
          }" />
              <p class="text-[#aaa] text-xs mt-2 text-center">{{ 100 - ((Number(item.fundedAmount) / (10 ** 8)) /
            Number(item.totalAmount) *
            100) }}% remaining</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="mt-[70px]">
      <DataTable tableStyle="min-width: 50rem" :value="suppliedLoans">
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
              {{ data?.userData?.name || '-' }}
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
                <p class="text-sm">{{ Number(data.fundedAmount) / (10 ** 8) }} CP <span class="text-[#aaa]">| {{
            data.totalAmount }}
                    ICP</span></p>
                <p class="text-[#aaa] text-xs mt-2">{{ 100 - ((Number(data.fundedAmount) / (10 ** 8)) /
            Number(data.totalAmount) *
            100).toFixed(2) }}% remaining</p>
              </div>
            </div>
          </template>
        </Column>
        <Column field="interestRate" header="Interest" class="text-sm text-[#AAA]">
          <template #body="{ data }">
            {{ data.interestRate }} %
          </template>
        </Column>
        <Column field="claimDeadline" header="Repayment Duration" class="text-sm text-[#AAA]">
          <template #body="{ data }">
            <div class="flex gap-8 items-center">
              <p class="text-sm">{{
            moment(Number(data.claimDeadline / 1000000n))
              .diff(moment(Number(data.createdAt / 1000000n)), 'days') }} Days</p>
            </div>
          </template>
        </Column>
      </DataTable>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue';
import Tag from 'primevue/tag';
import MeterGroup from 'primevue/metergroup';
import Button from 'primevue/button';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import { useRouter } from 'vue-router';
import { loan } from 'declarations/loan'
import { user } from 'declarations/user'
import { useAuthStore } from '../stores/auth';
import { Principal } from '@dfinity/principal';
import moment from 'moment';

const isLoading = ref(false)

const authStore = useAuthStore()

const borrowerLoans = ref([])
const suppliedLoans = ref([])

const totalBorrowerLoans = computed(() => {
  if (borrowerLoans.value.length) {
    return borrowerLoans.value.reduce((total, transaction) => {
      return total + Number(transaction.fundedAmount);
    }, 0);
  } return 0
})

const totalSuppliedLoans = computed(() => {
  if (suppliedLoans.value.length) {
    suppliedLoans.value
      .flatMap(loan => loan.lenders).reduce((total, lender) => {
        if (lender.lender.toString() === authStore.user.id.toString()) {
          return total + Number(lender.amount);
        }
        return total;
      }, 0);

  } return 0
})

onMounted(async () => {
  await getData()
})

const getData = async () => {
  const response = await loan.getLoansByBorrower(Principal.fromText(authStore.user.id))
  borrowerLoans.value = response
  const suppliedLoansResponse = await loan.getLoansByLender(Principal.fromText(authStore.user.id))
  let filteredResponse = suppliedLoansResponse;
  filteredResponse = await Promise.all(filteredResponse.map(async item => {
    const userData = await user.get_user(item.borrower.toString())
    return {
      ...item,
      userData: userData
    }
  }))
  console.log(filteredResponse)
  suppliedLoans.value = filteredResponse
}

const router = useRouter()

const meter = ref([
  {
    value: isNaN(Math.abs((Number(totalSuppliedLoans.value) / (Number(totalBorrowerLoans.value) + Number(totalSuppliedLoans.value))) * 100)) ? 50 : Math.abs((Number(totalSuppliedLoans.value) / (Number(totalBorrowerLoans.value) + Number(totalSuppliedLoans.value)))),
    color: '#2B88F3',
    label: 'Supplied Loans'
  },
  {
    value: isNaN(Math.abs((Number(totalBorrowerLoans.value) / (Number(totalBorrowerLoans.value) + Number(totalSuppliedLoans.value))) * 100)) ? 50 : Math.abs((Number(totalSuppliedLoans.value) / (Number(totalBorrowerLoans.value) + Number(totalSuppliedLoans.value)))),
    color: '#FC2496',
    label: 'Borrowed Loans'
  }
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