<template>
  <Toast />
  <div class="min-h-screen w-full flex justify-center items-start pt-[100px]">
    <div class="w-[485px] py-[48px] px-[64px] bg-[#16161E] rounded-lg">
      <div class="flex flex-col items-center text-center">
        <img src="/icons/logo.svg" alt="logo" width="64">
        <h1 class="text-lg text-center mt-8">Create Your Creditopia Account</h1>
        <p class="text-base mt-4 text-[#AAA] text-center">Sign up to start leveraging your business</p>
      </div>
      <div class="mt-[40px]">
        <form @submit.prevent="createAccount">
          <div class="flex flex-col gap-2 mt-5">
            <label for="name" class="text-sm text-[#AAA]">Name</label>
            <InputText v-model="name" id="name" placeholder="Enter your name" :invalid="$v.name.$error"/>
            <Message v-if="$v.name.$error" severity="error" icon="pi pi-times-circle">{{ $v.name.$errors[0].$message }}</Message>
          </div>
          <div class="flex flex-col gap-2 mt-5">
            <label for="email" class="text-sm text-[#AAA]">Email</label>
            <InputText v-model="email" id="email" placeholder="Enter your email" :invalid="$v.email.$error"/>
            <Message v-if="$v.email.$error" severity="error" icon="pi pi-times-circle">{{ $v.email.$errors[0].$message }}</Message>
          </div>
          <div class="flex flex-col gap-2 mt-5">
            <label for="phone-number" class="text-sm text-[#AAA]">Phone Number</label>
            <InputText v-model="phoneNumber" id="phone-number" :useGrouping="false" placeholder="Enter your phone number" :invalid="$v.phoneNumber.$error"/>
            <Message v-if="$v.phoneNumber.$error" severity="error" icon="pi pi-times-circle">{{ $v.phoneNumber.$errors[0].$message }}</Message>
          </div>
          <div class="flex flex-col gap-2 mt-5">
            <label for="adress" class="text-sm text-[#AAA]">Address</label>
            <InputText v-model="address" id="adress" placeholder="Enter your address" :invalid="$v.address.$error" />
            <Message v-if="$v.address.$error" severity="error" icon="pi pi-times-circle">{{ $v.address.$errors[0].$message }}</Message>
          </div>
          <Button type="submit" @click="createAccount" label="Sign Up" fluid class="mt-[40px]" severity="contrast" :loading="isLoading" />
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useToast } from 'primevue/usetoast';
import { useRouter } from 'vue-router';
import { useVuelidate } from '@vuelidate/core'
import { required, minLength, helpers, email as emailValidator, numeric } from '@vuelidate/validators'
import Message from 'primevue/message';
import InputText from 'primevue/inputtext';
import Button from 'primevue/button';
import { computed, ref } from 'vue';
import Toast from 'primevue/toast';
import { useAuthStore } from '../stores/auth';


const name = ref('');
const email = ref('');
const phoneNumber = ref('');
const address = ref('');

const isLoading = ref(false)

const toast = useToast()
const router = useRouter()

const authStore = useAuthStore()

const rules = computed(() => (
  {
    name: {
      required: helpers.withMessage('Name is required', required),
      minLength: minLength(3),
    },
    email: {
      required: helpers.withMessage('Email is required', required),
      email: helpers.withMessage('Email is invalid', emailValidator)
    },
    phoneNumber: {
      required: helpers.withMessage('Phone Number is required', required),
      numeric: helpers.withMessage('Phone Number is invalid', numeric)
    },
    address: {
      required: helpers.withMessage('Address is required', required)
    }
  }
));

const $v = useVuelidate(rules, { name, email, phoneNumber, address });

const createAccount = async () => {
  isLoading.value = true
  const result = $v.value.$validate();
  result.then(async (res) => {
    if (res) {
      const accountData = {
        name: name.value,
        email: email.value,
        phone: phoneNumber.value,
        address: address.value,
      };
      await authStore.createUser(accountData)
      toast.add({ ...authStore.status })
      router.push('/')
    }
  }).catch((err) => {
    console.log(err);
  }).finally(() => {
    isLoading.value = false
  })
}

</script>