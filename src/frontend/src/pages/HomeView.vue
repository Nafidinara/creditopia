<template>
  <div class="min-h-screen w-full flex justify-center items-start pt-[100px]">
    <div class="w-[485px] py-[48px] px-[64px] bg-[#16161E] rounded-lg">
      <div class="flex flex-col items-center text-center">
        <img src="/icons/logo.svg" alt="logo" width="64">
        <h1 class="text-lg text-center mt-8">Create Your Creditopia Account</h1>
        <p class="text-base mt-4 text-[#AAA] text-center">Sign up to start leveraging your business</p>
      </div>
      <div class="mt-[40px]">
        <div class="flex flex-col gap-2 mt-5">
          <label for="name" class="text-sm text-[#AAA]">Name</label>
          <InputText id="name" placeholder="Enter your name" />
        </div>
        <div class="flex flex-col gap-2 mt-5">
          <label for="email" class="text-sm text-[#AAA]">Email</label>
          <InputText id="email" placeholder="Enter your email" />
        </div>
        <div class="flex flex-col gap-2 mt-5">
          <label for="phone-number" class="text-sm text-[#AAA]">Phone Number</label>
          <InputText id="phone-number" placeholder="Enter your phone number" />
        </div>
        <div class="flex flex-col gap-2 mt-5">
          <label for="adress" class="text-sm text-[#AAA]">Adress</label>
          <InputText id="adress" placeholder="Enter your address" />
        </div>
        <Button label="Sign Up" fluid class="mt-[40px]" severity="contrast" />
      </div>
    </div>
  </div>
</template>

<script setup>
import InputText from 'primevue/inputtext';
import Button from 'primevue/button';
</script>