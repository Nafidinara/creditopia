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
          <InputText v-model="name" id="name" placeholder="Enter your name" />
        </div>
        <div class="flex flex-col gap-2 mt-5">
          <label for="email" class="text-sm text-[#AAA]">Email</label>
          <InputText v-model="email" id="email" placeholder="Enter your email" />
        </div>
        <div class="flex flex-col gap-2 mt-5">
          <label for="phone-number" class="text-sm text-[#AAA]">Phone Number</label>
          <InputText v-model="phoneNumber" id="phone-number" placeholder="Enter your phone number" />
        </div>
        <div class="flex flex-col gap-2 mt-5">
          <label for="adress" class="text-sm text-[#AAA]">Adress</label>
          <InputText v-model="address" id="adress" placeholder="Enter your address" />
        </div>
        <Button @click="createAccount" label="Sign Up" fluid class="mt-[40px]" severity="contrast" />
        <Button @click="connectToWallet" label="Connect" fluid class="mt-[40px]" severity="contrast" />

      </div>
    </div>
  </div>
</template>

<script setup>
import InputText from 'primevue/inputtext';
import Button from 'primevue/button';
import { ref } from 'vue';
import { user } from 'declarations/user/index';

import { useRouter } from 'vue-router';

const router = useRouter()

let principal = ref('')
const name = ref('');
const email = ref('');
const phoneNumber = ref('');
const address = ref('');
const connectToWallet = async () => {
  try {
   if (window.ic && window.ic.plug) {
      // Request connection to the Bitfinity wallet
      await window.ic.plug.requestConnect();

      // Get the principal string
      const userPrincipal = await window.ic.plug.agent.getPrincipal();
      principal = userPrincipal.toString();
      console.log(userPrincipal.toString());

     await user.get_user(userPrincipal.toString()).then((response) =>{
        // create session here
        console.log(response,length > 0, "user ada")
      })
    } else {
      console.error('Bitfinity wallet is not installed or not available.');
    }
  } catch (error) {
    console.error('Error connecting to Plug wallet:', error);
  }
};

const createAccount = async () => {
  try {
    


    // Use the collected input values
    const accountData = {
      id: principal,
      name: name.value,
      email: email.value,
      phone: phoneNumber.value,
      address: address.value,
    };
    
    // Implement account creation logic here
    console.log('Account data:', accountData);
    
    // Example: Call to a backend API or smart contract
    await user.create_user(principal,name.value,email.value,phoneNumber.value,address.value);

    // create session here
    //  console.log(user)

  } catch (error) {
    console.log(error)
  }
}

</script>