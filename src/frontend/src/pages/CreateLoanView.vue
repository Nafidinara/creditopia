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
        <div v-show="activeTabs === 0">
          <div class="grid grid-cols-12 gap-5 mt-[40px]">
            <div class="col-span-6">
              <div class="flex flex-col gap-2 mt-5">
                <label for="name" class="text-sm text-[#AAA]">Name</label>
                <InputText v-model="name" id="name" placeholder="Enter your business name" />
              </div>
            </div>
            <div class="col-span-6">
              <div class="flex flex-col gap-2 mt-5">
                <label for="category" class="text-sm text-[#AAA]">Select Category</label>
                <Select v-model="category" id="category" placeholder="--" :options="categories" optionLabel="name" />
              </div>
            </div>
          </div>
          <div class="flex flex-col gap-2 mt-5 pb-4 border-b border-gray-600">
            <label for="description" class="text-sm text-[#AAA]">Description</label>
            <Textarea v-model="description" id="description" placeholder="Write description of your business" />
          </div>
          <div class="mt-5">
            <div class="grid grid-cols-12 gap-5">
              <div class="col-span-6">
                <div class="flex flex-col gap-2">
                  <label for="start_curation" class="text-sm text-[#AAA]">Start Duration</label>
                  <DatePicker v-model="startDuration" showIcon fluid :showOnFocus="false" :manualInput="false"
                    placeholder="MM/DD/YYYY" />
                </div>
              </div>
              <div class="col-span-6">
                <div class="flex flex-col gap-2">
                  <label for="end_duration" class="text-sm text-[#AAA]">End Duration</label>
                  <DatePicker v-model="endDuration" showIcon fluid :showOnFocus="false" :manualInput="false"
                    placeholder="MM/DD/YYYY" />
                </div>
              </div>
            </div>
            <div class="grid grid-cols-12 gap-5 mt-5 pb-4 border-b border-gray-600">
              <div class="col-span-6">
                <div class="flex flex-col gap-2 mt-5">
                  <label for="commit" class="text-sm text-[#AAA]">When you commit to repay?</label>
                  <DatePicker v-model="commit" showIcon fluid :showOnFocus="false" :manualInput="false"
                    placeholder="MM/DD/YYYY" />
                </div>
              </div>
              <div class="col-span-6">
                <div class="flex flex-col gap-2 mt-5">
                  <label for="interest" class="text-sm text-[#AAA]">Interest</label>
                  <Select v-model="interest" id="interest" placeholder="--" :options="listInterest"
                    optionLabel="name" />
                </div>
                <div class="col-span-12">
                  <div class="flex flex-col gap-2 mt-5">
                    <label for="name" class="text-sm text-[#AAA]">Total ICP</label>
                    <InputText v-model="amount" id="name" placeholder="Enter your business name" />
                  </div>
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
        <div v-show="activeTabs === 1">
          <div class="mt-[40px] grid grid-cols-12 gap-4">
            <div class="col-span-6">
              <label for="face" class="text-sm text-[#AAA]">Upload your Face Photo</label>
              <div class="w-full mt-2">
                <label
                  class="flex justify-center w-full h-[244px] px-4 transition bg-[#0B0B13] border-2 border-gray-600 rounded-md appearance-none cursor-pointer hover:border-gray-400 focus:outline-none">
                  <div class="flex items-center flex-col justify-center gap-2" v-if="!photo">
                    <img src="/icons/file.svg" alt="file">
                    <p class="text-[#838386] text-xs text-center">Drop .png / .svg / .jpg image format or <span
                        class="text-[#82A9FF]">Browse
                        Here</span></p>
                    <p class="text-[#838386] text-xs text-center">Photo size ratio is 1:1</p>
                  </div>
                  <div class="flex flex-col items-center" v-else>
                    <img :src="photo" alt="photo" class="h-[150px] mt-4 rounded-lg">
                    <p class="mt-3 text-sm text-[#82A9FF]">Change Photo</p>
                  </div>
                  <input type="file" name="file_upload" class="hidden" ref="file" @change="onChangeUploadPhoto">
                </label>
              </div>
            </div>
            <div class="col-span-6">
              <label for="face" class="text-sm text-[#AAA]">Take photo of your face</label>
              <div class="mt-2">
                <img id="image" ref="imageRef" :class="{ hidden: !state.isImageVisible }"
                  alt="Placeholder" class="rounded-lg" />
                <video id="video" ref="videoRef" :class="{ hidden: !state.isVideoVisible }" class="rounded-lg"
                  playsinline></video>
                <canvas id="canvas" ref="canvasRef" :class="{ hidden: !state.isCanvasVisible }"
                  class="w-full rounded-lg"></canvas>
                <Button @click="recognize" label="Take Photo" fluid class="mt-[40px]" severity="contrast" />
                <Button @click="restart" label="Retake Photo" fluid class="mt-[40px]" severity="contrast" />
              </div>
              {{ state.message }}
            </div>
          </div>
          <Button @click="create" :disabled="disableButton" label="Create Loan" fluid class="mt-[40px]" severity="contrast" />
          {{ authStore.user }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue';
import InputText from 'primevue/inputtext';
import Select from 'primevue/select';
import Textarea from 'primevue/textarea';
import DatePicker from 'primevue/datepicker';
import Button from 'primevue/button';
import { useRouter } from 'vue-router';
import { user } from 'declarations/user/index';
import { loan } from 'declarations/loan/index';
import { useAuthStore } from '../stores/auth';
import { Principal } from '@dfinity/principal';
const router = useRouter();
const authStore = useAuthStore();

const name = ref('');
const description = ref('');
const interest = ref(null);
const startDuration = ref(null);
const endDuration = ref(null);
const category = ref(null);
const amount = ref(0);
const commit = ref(null);

const photo = ref(null)
const disableButton = ref(false)

const categories = ref([
  { name: 'F&B', code: 'F&B' },
  { name: 'Fashion', code: 'Fashion' },
  { name: 'Culinary', code: 'Culinary' },
  { name: 'Healthcare', code: 'Healthcare' },
  { name: 'Event', code: 'Event' },
  { name: 'UMKM', code: 'UMKM' },
  { name: 'Others', code: 'Others' }
]);

const listInterest = ref([
  { name: '5%', code: '5' },
  { name: '10%', code: '10' },
  { name: '15%', code: '15' },
])
const activeTabs = ref(0)
const state = reactive({
  message: '',
  isVideoVisible: false,
  isImageVisible: true,
  isCanvasVisible: false,
  isButtonsVisible: false,
  isLoaderVisible: false,
  isRestartVisible: false,
  blob: null,
  isAuthenticated: false,
  userPrincipal: null,
  canisterResponse: '',
  name: ''
});
const videoRef = ref(null);
const imageRef = ref(null);
const canvasRef = ref(null);
onMounted(() => {
  navigator.mediaDevices
    .getUserMedia({ video: true, audio: false })
    .then((stream) => {
      const video = videoRef.value;
      video.srcObject = stream;
      video.play();
      state.isButtonsVisible = true;
      state.isVideoVisible = true;
      state.isImageVisible = false;
    })
    .catch((err) => {
      state.isImageVisible = true;
      state.isButtonsVisible = false;
      console.error(`An error occurred: ${err}`);
      state.message = "Couldn't start camera, but you can upload photos.";
    });
});

const captureImage = async () => {
  const [image, width, height] = selectVisibleElement();
  const canvas = canvasRef.value;
  const context = canvas.getContext('2d');

  canvas.width = width;
  canvas.height = height;
  context.drawImage(image, 0, 0, width, height);

  const resizedCanvas = document.createElement('canvas');
  resizedCanvas.width = 320;
  resizedCanvas.height = 240;
  const scale = Math.min(
    resizedCanvas.width / canvas.width,
    resizedCanvas.height / canvas.height
  );
  const scaledWidth = canvas.width * scale;
  const scaledHeight = canvas.height * scale;
  const x = resizedCanvas.width / 2 - scaledWidth / 2;
  const y = resizedCanvas.height / 2 - scaledHeight / 2;

  const ctx = resizedCanvas.getContext('2d');
  ctx.drawImage(canvas, x, y, scaledWidth, scaledHeight);

  const blob = await serialize(resizedCanvas);

  if (videoRef.value.srcObject) {
    videoRef.value.srcObject.getTracks().forEach((track) => track.stop());
  }

  state.isVideoVisible = false;
  state.isImageVisible = false;
  state.isCanvasVisible = true;

  return [blob, { scale, x, y }];
};

const selectVisibleElement = () => {
  const video = videoRef.value;
  const image = imageRef.value;
  const canvas = canvasRef.value;
  if (!video.classList.contains('invisible')) {
    return [video, video.videoWidth, video.videoHeight];
  } else if (!image.classList.contains('invisible')) {
    return [image, image.width, image.height];
  } else {
    return [canvas, canvas.width, canvas.height];
  }
};

const onChangeUploadPhoto = async (e) => {
  const file = e.target.files[0]
  if (typeof file === 'undefined') {
    return
  }
  photo.value = await toDataURL(file)
  console.log(photo.value)
  store()
}

const recognize = async (event) => {
  event.preventDefault();
  state.isButtonsVisible = false;
  state.isLoaderVisible = true;
  state.message = 'Detecting face..';

  try {
    const [blob, scaling] = await captureImage();
    let result = await user.detect(new Uint8Array(blob));
    console.log(result,"Result blob")
    if (!result.Ok) throw new Error(result.Err.message);

    const face = await render(scaling, result.Ok);
    state.message = 'Face detected. Recognizing..';

    result = await user.recognize(new Uint8Array(face));
    if (!result.Ok) throw new Error(result.Err.message);

    const label = sanitize(result.Ok.label);
    const score = Math.round(result.Ok.score * 100) / 100;
    state.message = `${label}, difference=${score}`;
    console.log(label,score)
  } catch (err) {
    console.error(`An error occurred: ${err}`);
    state.message = err.toString();
    disableButton.value = true
  }

  state.isLoaderVisible = false;
  state.isRestartVisible = true;
};

const store = async (event) => {
  // event.preventDefault();
  state.isButtonsVisible = false;
  state.isLoaderVisible = true;
  state.message = 'Detecting face..';

  try {
    const [blob, scaling] = await captureImage();
    let result = await user.detect(new Uint8Array(blob));
    console.log(result, "result")
    if (!result.Ok) throw new Error(result.Err.message);

    const face = await render(scaling, result.Ok);
    const label = authStore.user.name
    console.log(face, "Face")
    if (!label) throw new Error('Cannot add without a name');

    const sanitizedLabel = sanitize(label);
    state.message = `Face detected. Adding ${sanitizedLabel}..`;

    result = await user.add(sanitizedLabel, new Uint8Array(face));
    if (!result.Ok) throw new Error(result.Err.message);

    state.message = `Successfully added ${sanitizedLabel}.`;
  } catch (err) {
    console.error(`An error occurred: ${err}`);
    state.message = `Failed to add the face: ${err.toString()}`;
  }

  state.isLoaderVisible = false;
  state.isRestartVisible = true;
};

const loadLocalImage = async (event) => {
  state.message = '';
  const image = imageRef.value;
  try {
    const file = event.target.files[0];
    if (!file) return;

    const url = await toDataURL(file);
    image.src = url;
  } catch (err) {
    state.message = `Failed to select photo: ${err.toString()}`;
  }

  state.isVideoVisible = false;
  state.isCanvasVisible = false;
  state.isImageVisible = true;
  state.isButtonsVisible = true;
};

const toDataURL = (blob) => {
  return new Promise((resolve) => {
    const fileReader = new FileReader();
    fileReader.readAsDataURL(blob);
    fileReader.onloadend = () => resolve(fileReader.result);
  });
};

const restart = (event) => {
  state.isRestartVisible = false;
  state.isCanvasVisible = false;
  state.message = '';
  navigator.mediaDevices
    .getUserMedia({ video: true, audio: false })
    .then((stream) => {
      const video = videoRef.value;
      video.srcObject = stream;
      video.play();
      state.isButtonsVisible = true;
      state.isVideoVisible = true;
    });
};

const render = async (scaling, box) => {
  box.left = Math.round((box.left * 320 - scaling.x) / scaling.scale);
  box.right = Math.round((box.right * 320 - scaling.x) / scaling.scale);
  box.top = Math.round((box.top * 240 - scaling.y) / scaling.scale);
  box.bottom = Math.round((box.bottom * 240 - scaling.y) / scaling.scale);

  const ctx = canvasRef.value.getContext('2d');
  ctx.beginPath();
  ctx.lineWidth = '4';
  ctx.strokeStyle = 'red';
  ctx.rect(box.left, box.top, box.right - box.left, box.bottom - box.top);
  ctx.stroke();

  const width = box.right - box.left;
  const height = box.bottom - box.top;

  const canvas = document.createElement('canvas');
  canvas.width = 160;
  canvas.height = 160;

  const ctx2 = canvas.getContext('2d');
  ctx2.drawImage(
    ctx.canvas,
    box.left,
    box.top,
    width,
    height,
    0,
    0,
    160,
    160
  );

  return serialize(canvas);
};

const serialize = (canvas) => {
  return new Promise((resolve) => {
    canvas.toBlob(
      (blob) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result);
        reader.readAsArrayBuffer(blob);
      },
      'image/png',
      0.95
    );
  });
};

const sanitize = (label) => label.trim();

const create = async () => {
  const start = new Date();
  const end = new Date(commit.value);

  // Calculate the difference in time
  const tenor = Math.abs(end - start);

  // Convert the time difference from milliseconds to days
  const diffDays = Math.ceil(tenor / (1000 * 60 * 60 * 24));

  const startWaiting = new Date(startDuration.value);
  const endWaiting = new Date(endDuration.value);

  // Calculate the difference in time
  const waitingTime = Math.abs(endWaiting - startWaiting);

  // Convert the time difference from milliseconds to days
  const diffDaysWait = Math.ceil(waitingTime / (1000 * 60 * 60 * 24));
  console.log(diffDaysWait)
  console.log(name.value, description.value, category.value.code, parseFloat(amount.value), diffDays, diffDaysWait, parseFloat(interest.value.code))
  loan.registerLoan(Principal.fromText(authStore.principalId) ,name.value, description.value, category.value.code, parseFloat(amount.value), diffDays, diffDaysWait, parseFloat(interest.value.code)).then((res) => {
    console.log(res)
  })
}
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
