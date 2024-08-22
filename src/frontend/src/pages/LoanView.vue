<template>
  <div class="container mx-auto">
    <h1 class="mb-4 font-bold text-lg">All Listing Loans</h1>
    <DataTable tableStyle="min-width: 50rem" :value="data">
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
      <Column field="returnTime" header="Return Time" class="text-sm text-[#AAA]">
        <template #body="{ data }">
          <div class="flex gap-8 items-center">
            <p class="text-sm">{{ data.returnTime }}</p>
            <Button label="Supply" severity="contrast" size="small" @click="router.push(`/loans/${data.id}`)" />
          </div>
        </template>
      </Column>
    </DataTable>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import DataTable from 'primevue/datatable';
import Column from 'primevue/column';
import Tag from 'primevue/tag';
import Button from 'primevue/button';
import { useRouter } from 'vue-router';

const router = useRouter()

const data = ref([
  {
    id: 1,
    name: 'Market Cuan',
    creator: 'Bebe Bonica',
    category: 'Event',
    totalSupplied: '400 ICP',
    interest: '12% - 15%',
    returnTime: '08/14/2024'
  }
]);

</script>