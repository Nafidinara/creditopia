<template>
  <div class="container mx-auto">
    <h1 class="mb-4 font-bold text-lg ">All Listing Loans</h1>
    <DataTable tableStyle="min-width: 50rem" :value="loanStore.loans">
      <Column field="title" header="SME Name" class="text-sm text-[#AAA]">
        <template #body="{ data }">
          <div class="flex gap-2 items-center">
            <img src="/icons/market.png" alt="market">
            <h1 class="text-sm">
              {{ data.title }}
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
            <Button label="Supply" severity="contrast" size="small" @click="router.push(`/loans/${data.id}`)" />
          </div>
        </template>
      </Column>
    </DataTable>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Tag from 'primevue/tag';
import Button from 'primevue/button';
import { useRouter } from 'vue-router';
import { useLoanStore } from '../stores/loan';
import moment from 'moment';

const router = useRouter()
const loanStore = useLoanStore()

onMounted(async () => {
  await loanStore.getLoans()
})

</script>