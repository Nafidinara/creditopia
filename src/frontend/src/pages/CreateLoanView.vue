<template>
  <div class="container mx-auto">
    <div class="cursor-pointer flex gap-4 items-center mt-[30px]" @click="router.push('/my-account')">
      <i class="pi pi-chevron-left"></i>
      <p>Back</p>
    </div>
    <h1 class="text-2xl text-center mt-[40px]">Start a New Loan for your<br> Business Growth</h1>
    <div class="flex justify-center">
      <div class="w-[700px] bg-[#16161E] rounded-lg p-4 mt-8">
        <div class="border-b border-[#333333] flex pb-2">
          <div class="flex-1 flex items-center justify-center gap-3 text-center text-base text-[#AAAAAA] cursor-pointer"
            :class="{ 'active-tabs': activeTabs === 0 }" @click="activeTabs = 0">
            <div class="h-[24px] w-[24px] rounded-full" :class="[activeTabs === 0 && 'bg-[#366E96]']">1</div>
            Business Identity
          </div>
          <div class="flex-1 flex items-center justify-center gap-3 text-center text-base text-[#AAAAAA] cursor-pointer"
            :class="{ 'active-tabs': activeTabs === 1 }" @click="activeTabs = 1">
            <div class="h-[24px] w-[24px] rounded-full" :class="[activeTabs === 1 && 'bg-[#366E96]']">2</div>
            Verification
          </div>
        </div>
        <div v-if="activeTabs === 0">
          <div class="grid grid-cols-12 gap-5 mt-[40px]">
            <div class="col-span-6">
              <div class="flex flex-col gap-2 mt-5">
                <label for="name" class="text-sm text-[#AAA]">Name</label>
                <InputText id="name" placeholder="Enter your business name" />
              </div>
            </div>
            <div class="col-span-6">
              <div class="flex flex-col gap-2 mt-5">
                <label for="category" class="text-sm text-[#AAA]">Select Category</label>
                <Select id="category" placeholder="--" :options="categories" optionLabel="name" />
              </div>
            </div>
          </div>
          <div class="flex flex-col gap-2 mt-5 pb-4 border-b border-gray-600">
            <label for="description" class="text-sm text-[#AAA]">Description</label>
            <Textarea id="description" placeholder="Write description of your business" />
          </div>
          <div class="mt-5">
            <div class="grid grid-cols-12 gap-5">
              <div class="col-span-6">
                <div class="flex flex-col gap-2 mt-5">
                  <label for="start_curation" class="text-sm text-[#AAA]">Start Duration</label>
                  <DatePicker showIcon fluid :showOnFocus="false" :manualInput="false" placeholder="MM/DD/YYYY" />
                </div>
              </div>
              <div class="col-span-6">
                <div class="flex flex-col gap-2 mt-5">
                  <label for="end_duration" class="text-sm text-[#AAA]">End Duration</label>
                  <DatePicker showIcon fluid :showOnFocus="false" :manualInput="false" placeholder="MM/DD/YYYY" />
                </div>
              </div>
            </div>
            <div class="grid grid-cols-12 gap-5 mt-5 pb-4 border-b border-gray-600">
              <div class="col-span-6">
                <div class="flex flex-col gap-2 mt-5">
                  <label for="commit" class="text-sm text-[#AAA]">When you commit to repay?</label>
                  <DatePicker showIcon fluid :showOnFocus="false" :manualInput="false" placeholder="MM/DD/YYYY" />
                </div>
              </div>
              <div class="col-span-6">
                <div class="flex flex-col gap-2 mt-5">
                  <label for="interest" class="text-sm text-[#AAA]">Interest</label>
                  <Select id="interest" placeholder="--" :options="categories" optionLabel="name" />
                </div>
              </div>
            </div>
            <div class="mt-5">
              <label for="logo" class="text-sm text-[#AAA]">Upload your Business Logo</label>
              <div class="w-full mt-2">
                <label
                  class="flex justify-center w-full h-40 px-4 transition bg-[#0B0B13] border-2 border-gray-600 rounded-md appearance-none cursor-pointer hover:border-gray-400 focus:outline-none">
                  <div class="flex items-center flex-col justify-center gap-2">
                    <img src="/icons/file.svg" alt="file">
                    <p class="text-[#838386]">Drop .png / .svg / .jpg image format or <span
                        class="text-[#82A9FF]">Browse
                        Here</span></p>
                    <p class="text-[#838386]">Photo size ratio is 1:1</p>
                  </div>
                  <input type="file" name="file_upload" class="hidden" ref="file">
                </label>
              </div>
            </div>
            <Button label="Next" fluid class="mt-[40px]" severity="contrast" />
          </div>
        </div>
        <div v-else>
          <div class="mt-[40px] grid grid-cols-12">
            <div class="col-span-6">
              <label for="face" class="text-sm text-[#AAA]">Upload your Face Photo</label>
              <div class="w-full mt-2">
                <label
                  class="flex justify-center w-full h-40 px-4 transition bg-[#0B0B13] border-2 border-gray-600 rounded-md appearance-none cursor-pointer hover:border-gray-400 focus:outline-none">
                  <div class="flex items-center flex-col justify-center gap-2">
                    <img src="/icons/file.svg" alt="file">
                    <p class="text-[#838386] text-xs text-center">Drop .png / .svg / .jpg image format or <span
                        class="text-[#82A9FF]">Browse
                        Here</span></p>
                    <p class="text-[#838386] text-xs text-center">Photo size ratio is 1:1</p>
                  </div>
                  <input type="file" name="file_upload" class="hidden" ref="file">
                </label>
              </div>
            </div>
            <div class="col-span-6">
            </div>
          </div>
          <Button label="Create Loan" fluid class="mt-[40px]" severity="contrast" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import InputText from 'primevue/inputtext';
import Select from 'primevue/select';
import Textarea from 'primevue/textarea';
import DatePicker from 'primevue/datepicker';
import Button from 'primevue/button';
import { useRouter } from 'vue-router';

const router = useRouter();

const categories = ref([
  { name: 'New York', code: 'NY' },
  { name: 'Rome', code: 'RM' },
  { name: 'London', code: 'LDN' },
  { name: 'Istanbul', code: 'IST' },
  { name: 'Paris', code: 'PRS' }
]);

const activeTabs = ref(0)

</script>

<style>
.active-tabs {
  position: relative;
  color: white;
}

.active-tabs::after {
  content: '';
  position: absolute;
  width: 100%;
  height: 2px;
  background-color: #366E96;
  bottom: -8px;
  left: 0;
}
</style>
