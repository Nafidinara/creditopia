<template>
  <Toast />
  <div class="container mx-auto">
    <h1 class="text-[48px] mt-[88px] text-center">Empowering SMEs with Innovative Lending <br>
      for <span class="text-[#82A9FF]">Real-World Impact</span></h1>
    <div class="grid grid-cols-12 mt-[40px]">
      <div class="col-span-1"></div>
      <div class="col-span-10 flex items-center">
        <div class="flex-1 text-center flex flex-col items-center">
          <p class="text-[#82A9FF] text-sm">Total Borrow</p>
          <p class="text-[28px] font-bold mt-3 flex items-center gap-3"><count-up :end-val="567"></count-up> <span
              class="text-xl font-normal">ICP</span></p>
        </div>
        <div class="flex-1 text-center border-l border-gray-600 border-r flex flex-col items-center">
          <p class="text-[#82A9FF] text-sm">Total Loan</p>
          <p class="text-[28px] font-bold mt-3 flex items-center gap-3"><count-up :end-val="4356"></count-up> <span
              class="text-xl font-normal">ICP</span></p>
        </div>
        <div class="flex-1 text-center flex flex-col items-center">
          <p class="text-[#82A9FF] text-sm">Total Value Locket (TVL)</p>
          <p class="text-[28px] font-bold mt-3 flex items-center gap-3"><count-up :end-val="12879"></count-up> <span
              class="text-xl font-normal">ICP</span></p>
        </div>
      </div>
      <div class="col-span-1"></div>
    </div>
    <div class="flex justify-center">
      <Button label="Connect with Internet Identity" class="mt-[40px]" severity="contrast"
        @click="onClickConnectWallet" />
    </div>
    <div class="grid grid-cols-12 mt-[120px]">
      <div class="col-span-7">
        <h1 class="text-[40px]">
          <span class="h-[2px] w-[140px] inline-block relative bottom-3 mr-4 bg-gradient-to-l from-[#CFD6E6]"></span>
          By Accepting real-world collateral we offers lenders with highest level of security
        </h1>
        <div class="flex items-start gap-[40px] mt-[50px]">
          <p class="text-xl">Fact</p>
          <div>
            <div class="flex items-start gap-2">
              <div class="h-[2px] w-[30px] -rotate-45 bg-gradient-to-r from-[#3A6BD5] to-[#82A9FF] relative top-4">
              </div>
              <p class="text-lg text-[#E2ECFF]">Creditopia securely connects crypto<br> lenders and SME borrowers to
                improve</p>
            </div>
            <div class="flex items-start gap-2 mt-5">
              <div class="h-[2px] w-[30px] -rotate-45 bg-gradient-to-r from-[#3A6BD5] to-[#82A9FF] relative top-4">
              </div>
              <p class="text-lg text-[#E2ECFF]">Our Products are designer to maximise<br> returns while minimising the
                risks</p>
            </div>
          </div>
        </div>
      </div>
      <div class="col-span-5 flex items-center">
        <img src="/image/landing_1.png" alt="landing_1" class="-rotate-[20deg]">
        <img src="/image/landing_2.svg" alt="landing_2" class="-ml-[45px]">
      </div>
    </div>
    <div class="grid grid-cols-12 mt-[120px] pt-[80px] items-start">
      <div class="col-span-4 flex gap-[26px] items-center">
        <img src="/icons/no_1.svg" alt="no">
        <p class="text-lg">About us</p>
      </div>
      <div class="col-span-8">
        <h1 class="text-[42px]">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Welcome to Creditopia, the<br>
          groundbreaking lending platform
          that<br> provides crypto loans backed by real-world assets.</h1>
        <div class="h-[2px] w-full inline-block my-[48px] bg-gradient-to-l from-[#CFD6E6]"></div>
        <div class="grid grid-cols-12 gap-[40px]">
          <div class="col-span-6">
            <p class="text-[#B7BFD0]">Our mission is to close the debt financing gap and drive real-world impact by
              offering fair and
              accessible lending solutions to small and medium-sized enterprises (SMEs) in the region. With Creditopia,
              you can secure reliable loans backed by real-world assets like real estate, future receivables, and more
            </p>
          </div>
          <div class="col-span-6">
            <p class="text-[#B7BFD0]">Our lending platform provides lenders with stable and predictable returns, driven
              by the real economy. Join us in revolutionizing the alternative lending industry and creating a positive
              impact worldwide.</p>
          </div>
        </div>
      </div>
    </div>
    <div class="grid grid-cols-12 mt-[120px] pt-[80px items-start">
      <div class="col-span-4 flex gap-[26px] items-center">
        <img src="/icons/no_2.svg" alt="no">
        <p class="text-lg">Our Mission</p>
      </div>
      <div class="col-span-8 bg-gray-600 bg-opacity-10 rounded-lg pl-[40px] pr-2 pb-[40px]">
        <div class="grid grid-cols-12 relative">
          <div class="col-span-8">
            <div class="flex mt-[40px] gap-6 items-center">
              <div class="border border-white p-3 rounded-full"><img src="/icons/coins.svg" alt="coin"></div>
              <p class="text-lg">We offer accessible lending solutions for<br> SMEs</p>
            </div>
            <div class="flex mt-[40px] gap-6 items-center">
              <div class="border border-white p-3 rounded-full"><img src="/icons/cube.svg" alt="coin"></div>
              <p class="text-lg">We leverage blockchain technology to<br> achieve secure and stable returns</p>
            </div>
          </div>
          <div class="col-span-4 flex flex-col items-end mt-2">
            <div class="w-[100px] h-[100px] bg-black bg-opacity-40 rounded-3xl"></div>
            <img src="/image/landing_3.svg" alt="landing_1" class="absolute -bottom-[150px] -right-[50px]">
          </div>
        </div>
      </div>
    </div>
    <div class="grid grid-cols-12 mt-[120px] pt-[80px items-start">
      <div class="col-span-4 flex gap-[26px] items-center">
        <img src="/icons/no_3.svg" alt="no">
        <p class="text-lg">Lenders</p>
      </div>
      <div class="col-span-8">
        <h1 class="text-[42px]">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Lenders can benefit from stable<br>
          and predictable returns on loans<br>
          collateralized by real-world assets.</h1>
        <div class="h-[2px] w-full inline-block my-[48px] bg-gradient-to-l from-[#CFD6E6]"></div>
        <div class="grid grid-cols-12 gap-[32px] items-start">
          <div class="col-span-6 relative">
            <img src="/image/landing_4.svg" alt="landing" class="w-full z-10">
            <img src="/image/landing_5.svg" alt="landing" class="absolute -bottom-[200px] -left-[200px] -z-10">
          </div>
          <div class="col-span-6">
            <p class="text-[#B7BFD0] text-lg">Invest in Creditopia's alternative lending products, including loan
              portfolios, single loan exposures, and corporate bonds from the real economy. These options are designed
              to deliver attractive returns, mitigate risk, and support SMEs</p>
          </div>
        </div>
      </div>
    </div>
    <div class="grid grid-cols-12 mt-[300px] pt-[80px items-start">
      <div class="col-span-4 flex gap-[26px] items-center">
        <img src="/icons/no_4.svg" alt="no">
        <p class="text-lg">Borrowers</p>
      </div>
      <div class="col-span-8">
        <h1 class="text-[42px]">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;We are committed to helping small
          and<br>
          medium enterprises (SMEs) access<br> the financing they need togrow and succeed.</h1>
        <div class="h-[2px] w-full inline-block my-[48px] bg-gradient-to-l from-[#CFD6E6]"></div>
        <div class="grid grid-cols-12 gap-[32px] items-start">
          <div class="col-span-6 relative">
            <img src="/image/landing_6.svg" alt="landing" class="w-full z-10">
            <img src="/image/landing_5.svg" alt="landing" class="absolute -bottom-[200px] -left-[200px] -z-10">
            <div class="bg-[#161616] absolute z-10 top-[50%] -right-[200px] rounded-xl">
              <img src="/image/landing_7.svg" alt="landing">

            </div>
          </div>
          <div class="col-span-6">
            <p class="text-[#B7BFD0] text-lg">Creditopia provides flexible financing solutions customized to meet the
              unique needs of each borrower. Every borrower on our platform must provide collateral and undergo our
              proprietary risk scoring.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
  <div class="mt-[300px] bg-[#161616] pt-[60px] pb-[40px] px-[20px]">
    <h1 class="text-center text-[48px]">Growth your Business, <br>Take your Step with Us!</h1>
    <div class="flex justify-center">
      <Button label="Connect with Internet Identity" class="mt-[40px]" severity="contrast" />
    </div>
    <div class="container mx-auto bg-[#161616] mt-[60px] pt-[36px] border-t border-gray-600">
      <div class="flex justify-between">
        <p>©2024. All right reserved</p>
        <p>Ulti Nolan Team</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import Button from 'primevue/button';
import CountUp from 'vue-countup-v3'
import { useAuthStore } from '../stores/auth';
import Toast from 'primevue/toast';
import { useToast } from 'primevue/usetoast';

const authStore = useAuthStore()

const toast = useToast()

const onClickConnectWallet = async () => {
  await authStore.connectToWallet()
  toast.add({ ...authStore.status })
};
</script>