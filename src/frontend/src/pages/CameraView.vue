<template>
  <div class="container">
    <p>asdsd</p>
    <h1>ICP Bitfinity Wallet Integration</h1>
    <div v-if="isAuthenticated">
      <p>Connected as: {{ userPrincipal }}</p>
      <p>Canister Response: {{ canisterResponse }}</p>
    </div>
    <div v-else>
      <button @click="connectToBitfinityWallet">Connect Bitfinity Wallet</button>
    </div>
    <input id="name" type="text" v-model="name" />
    <button @click="onSubmit">Submit</button>
    <h1>
      On-chain ICP
      <img id="inline-logo" src="logo_small.png" alt="ICP Logo" />
      face recognition
    </h1>
    <div>
      <label id="filelabel" for="file" class="clickable">
        <div id="camera">
          <img
            id="image"
            ref="imageRef"
            src="logo_transparent.png"
            :class="{ invisible: !isImageVisible }"
            alt="Placeholder"
          />
          <video
            id="video"
            ref="videoRef"
            :class="{ invisible: !isVideoVisible }"
            playsinline
          ></video>
          <canvas
            id="canvas"
            ref="canvasRef"
            :class="{ invisible: !isCanvasVisible }"
          ></canvas>
        </div>
      </label>
      <div class="controls">
        <div id="buttons" :class="{ invisible: !isButtonsVisible }">
          <button class="clickable" @click="recognize">Recognize face</button>
          <button class="clickable" @click="store">Add face</button>
        </div>
        <div id="loader" :class="{ invisible: !isLoaderVisible }">
          <img id="loader" src="loader.gif" alt="Loader" />
        </div>
        <div id="restart" :class="{ invisible: !isRestartVisible }">
          <button class="clickable" @click="restart">Detect another face</button>
        </div>
      </div>
    </div>
    <p id="message">{{ message }}</p>
  </div>
</template>

<script>
import { ref, onMounted, reactive } from "vue";
import { backend_rust } from "../../../";
import { AuthClient } from "@dfinity/auth-client";

export default {
  name: "App",
  setup() {
    const message = ref("");
    const isVideoVisible = ref(false);
    const isImageVisible = ref(true);
    const isCanvasVisible = ref(false);
    const isButtonsVisible = ref(false);
    const isLoaderVisible = ref(false);
    const isRestartVisible = ref(false);
    const blob = ref(null);
    const name = ref("");
    const isAuthenticated = ref(false);
    const userPrincipal = ref(null);
    const canisterResponse = ref("");
    const videoRef = ref(null);
    const imageRef = ref(null);
    const canvasRef = ref(null);

    const whitelist = [
      "bkyz2-fmaaa-aaaaa-qaaaq-cai",
      "bd3sg-teaaa-aaaaa-qaaba-cai",
      "be2us-64aaa-aaaaa-qaabq-cai",
      "br5f7-7uaaa-aaaaa-qaaca-cai",
    ];

    onMounted(() => {
      navigator.mediaDevices
        .getUserMedia({ video: true, audio: false })
        .then((stream) => {
          const video = videoRef.value;
          video.srcObject = stream;
          video.play();
          isButtonsVisible.value = true;
          isVideoVisible.value = true;
          isImageVisible.value = false;
        })
        .catch((err) => {
          isImageVisible.value = true;
          isButtonsVisible.value = false;
          console.error(`An error occurred: ${err}`);
          message.value = "Couldn't start camera, but you can upload photos.";
        });
    });

    const captureImage = async () => {
      const [image, width, height] = selectVisibleElement();
      const canvas = canvasRef.value;
      const context = canvas.getContext("2d");

      canvas.width = width;
      canvas.height = height;
      context.drawImage(image, 0, 0, width, height);

      const resizedCanvas = document.createElement("canvas");
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

      const ctx = resizedCanvas.getContext("2d");
      ctx.drawImage(canvas, x, y, scaledWidth, scaledHeight);

      const blobData = await serialize(resizedCanvas);

      if (videoRef.value.srcObject) {
        videoRef.value.srcObject.getTracks().forEach((track) => track.stop());
      }

      isVideoVisible.value = false;
      isImageVisible.value = false;
      isCanvasVisible.value = true;

      return [blobData, { scale, x, y }];
    };

    const selectVisibleElement = () => {
      const video = videoRef.value;
      const image = imageRef.value;
      const canvas = canvasRef.value;
      if (!video.classList.contains("invisible")) {
        return [video, video.videoWidth, video.videoHeight];
      } else if (!image.classList.contains("invisible")) {
        return [image, image.width, image.height];
      } else {
        return [canvas, canvas.width, canvas.height];
      }
    };

    const recognize = async (event) => {
      event.preventDefault();
      isButtonsVisible.value = false;
      isLoaderVisible.value = true;
      message.value = "Detecting face..";

      try {
        const [blobData, scaling] = await captureImage();
        let result = await backend_rust.detect(new Uint8Array(blobData));

        if (!result.Ok) throw new Error(result.Err.message);

        const face = await render(scaling, result.Ok);
        message.value = "Face detected. Recognizing..";

        result = await backend_rust.recognize(new Uint8Array(face));
        if (!result.Ok) throw new Error(result.Err.message);

        const label = sanitize(result.Ok.label);
        const score = Math.round(result.Ok.score * 100) / 100;
        message.value = `${label}, difference=${score}`;
      } catch (err) {
        console.error(`An error occurred: ${err}`);
        message.value = err.toString();
      }

      isLoaderVisible.value = false;
      isRestartVisible.value = true;
    };

    const store = async (event) => {
      event.preventDefault();
      isButtonsVisible.value = false;
      isLoaderVisible.value = true;
      message.value = "Detecting face..";

      try {
        const [blobData, scaling] = await captureImage();
        let result = await backend_rust.detect(new Uint8Array(blobData));

        if (!result.Ok) throw new Error(result.Err.message);

        const face = await render(scaling, result.Ok);
        const label = prompt("Enter name of the person");

        if (!label) throw new Error("Cannot add without a name");

        const sanitizedLabel = sanitize(label);
        message.value = `Face detected. Adding ${sanitizedLabel}..`;

        result = await backend_rust.add(sanitizedLabel, new Uint8Array(face));
        if (!result.Ok) throw new Error(result.Err.message);

        message.value = `Successfully added ${sanitizedLabel}.`;
      } catch (err) {
        console.error(`An error occurred: ${err}`);
        message.value = `Failed to add the face: ${err.toString()}`;
      }

      isLoaderVisible.value = false;
      isRestartVisible.value = true;
    };

    const loadLocalImage = async (event) => {
      message.value = "";
      const image = imageRef.value;
      try {
        const file = event.target.files[0];
        if (!file) return;

        const url = await toDataURL(file);
        image.src = url;
      } catch (err) {
        message.value = `Failed to select photo: ${err.toString()}`;
      }

      isVideoVisible.value = false;
      isCanvasVisible.value = false;
      isImageVisible.value = true;
      isButtonsVisible.value = true;
    };

    const toDataURL = (blob) => {
      return new Promise((resolve) => {
        const fileReader = new FileReader();
        fileReader.readAsDataURL(blob);
        fileReader.onloadend = () => resolve(fileReader.result);
      });
    };

    const restart = (event) => {
      isRestartVisible.value = false;
      message.value = "";
      navigator.mediaDevices
        .getUserMedia({ video: true, audio: false })
        .then((stream) => {
          const video = videoRef.value;
          video.srcObject = stream;
          video.play();
          isButtonsVisible.value = true;
          isVideoVisible.value = true;
        });
    };

    const render = async (scaling, box) => {
      box.left = Math.round((box.left * 320 - scaling.x) / scaling.scale);
      box.right = Math.round((box.right * 320 - scaling.x) / scaling.scale);
      box.top = Math.round((box.top * 240 - scaling.y) / scaling.scale);
      box.bottom = Math.round((box.bottom * 240 - scaling.y) / scaling.scale);

      const image = canvasRef.value;
      const canvas = document.createElement("canvas");
      canvas.width = box.right - box.left;
      canvas.height = box.bottom - box.top;
      const context = canvas.getContext("2d");
      context.drawImage(
        image,
        box.left,
        box.top,
        canvas.width,
        canvas.height,
        0,
        0,
        canvas.width,
        canvas.height
      );

      const blobData = await serialize(canvas);

      context.strokeStyle = "#00FF00";
      context.lineWidth = 4;
      context.strokeRect(0, 0, canvas.width, canvas.height);

      isCanvasVisible.value = true;

      return blobData;
    };

    const sanitize = (str) => {
      return str.replace(/[^\w]/g, "");
    };

    const serialize = (canvas) => {
      return new Promise((resolve) =>
        canvas.toBlob((blob) => blob.arrayBuffer().then(resolve), "image/jpeg")
      );
    };

    const connectToBitfinityWallet = async () => {
      const authClient = await AuthClient.create();

      await new Promise((resolve, reject) => {
        authClient.login({
          identityProvider:
            "https://identity.ic0.app/#authorize",
          onSuccess: resolve,
          onError: reject,
        });
      });

      const identity = authClient.getIdentity();
      const principal = identity.getPrincipal();

      isAuthenticated.value = true;
      userPrincipal.value = principal.toText();

      const actor = backend_rust.createActor({
        agentOptions: {
          identity,
        },
      });

      const response = await actor.getMessage();
      canisterResponse.value = response;
    };

    const onSubmit = async () => {
      message.value = `You have submitted: ${name.value}`;
    };

    return {
      message,
      name,
      isAuthenticated,
      userPrincipal,
      canisterResponse,
      connectToBitfinityWallet,
      onSubmit,
      captureImage,
      recognize,
      store,
      loadLocalImage,
      restart,
      videoRef,
      imageRef,
      canvasRef,
      isVideoVisible,
      isImageVisible,
      isCanvasVisible,
      isButtonsVisible,
      isLoaderVisible,
      isRestartVisible,
    };
  },
};
</script>

<style scoped>
/* Add your styles here */
</style>
