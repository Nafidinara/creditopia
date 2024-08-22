import React, { useState, useEffect, useRef } from "react";
import { backend_rust } from "../../declarations/backend_rust";
// import "./main.css"; // Assuming you have a CSS file
import { AuthClient } from "@dfinity/auth-client";
// import { HttpAgent, Actor } from "@dfinity/agent";
// import { idlFactory, canisterId } from "./";
// Whitelist
const whitelist = ['bkyz2-fmaaa-aaaaa-qaaaq-cai','bd3sg-teaaa-aaaaa-qaaba-cai','be2us-64aaa-aaaaa-qaabq-cai','br5f7-7uaaa-aaaaa-qaaca-cai'];

function App() {
  const [message, setMessage] = useState("");
  const [isVideoVisible, setIsVideoVisible] = useState(false);
  const [isImageVisible, setIsImageVisible] = useState(true);
  const [isCanvasVisible, setIsCanvasVisible] = useState(false);
  const [isButtonsVisible, setIsButtonsVisible] = useState(false);
  const [isLoaderVisible, setIsLoaderVisible] = useState(false);
  const [isRestartVisible, setIsRestartVisible] = useState(false);
  const [blob, setBlob] = useState(null);

  const videoRef = useRef(null);
  const imageRef = useRef(null);
  const canvasRef = useRef(null);
  const fileInputRef = useRef(null);
  const fileInputRecognizeRef = useRef(null);


  useEffect(() => {
    navigator.mediaDevices
      .getUserMedia({ video: true, audio: false })
      .then((stream) => {
        const video = videoRef.current;
        video.srcObject = stream;
        video.play();
        setIsButtonsVisible(true);
        setIsVideoVisible(true);
        setIsImageVisible(false);
      })
      .catch((err) => {
        setIsImageVisible(true);
        setIsButtonsVisible(false);
        console.error(`An error occurred: ${err}`);
        setMessage("Couldn't start camera, but you can upload photos.");
      });
  }, []);

  const captureImage = async () => {
    const [image, width, height] = selectVisibleElement();
    const canvas = canvasRef.current;
    const context = canvas.getContext("2d");

    canvas.width = width;
    canvas.height = height;
    context.drawImage(image, 0, 0, width, height);

    const resizedCanvas = document.createElement("canvas");
    resizedCanvas.width = 320;
    resizedCanvas.height = 240;
    const scale = Math.min(resizedCanvas.width / canvas.width, resizedCanvas.height / canvas.height);
    const scaledWidth = canvas.width * scale;
    const scaledHeight = canvas.height * scale;
    const x = resizedCanvas.width / 2 - scaledWidth / 2;
    const y = resizedCanvas.height / 2 - scaledHeight / 2;

    const ctx = resizedCanvas.getContext("2d");
    ctx.drawImage(canvas, x, y, scaledWidth, scaledHeight);

    const blob = await serialize(resizedCanvas);

    if (videoRef.current.srcObject) {
      videoRef.current.srcObject.getTracks().forEach((track) => track.stop());
    }

    setIsVideoVisible(false);
    setIsImageVisible(false);
    setIsCanvasVisible(true);
    
    return [blob, { scale, x, y }];
  };

  const selectVisibleElement = () => {
    const video = videoRef.current;
    const image = imageRef.current;
    const canvas = canvasRef.current;
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
    setIsButtonsVisible(false);
    setIsLoaderVisible(true);
    setMessage("Detecting face..");

    try {
      const [blob, scaling] = await captureImage();
      let result = await backend_rust.detect(new Uint8Array(blob));

      if (!result.Ok) throw new Error(result.Err.message);

      const face = await render(scaling, result.Ok);
      setMessage("Face detected. Recognizing..");

      result = await backend_rust.recognize(new Uint8Array(face));
      if (!result.Ok) throw new Error(result.Err.message);

      const label = sanitize(result.Ok.label);
      const score = Math.round(result.Ok.score * 100) / 100;
      setMessage(`${label}, difference=${score}`);
    } catch (err) {
      console.error(`An error occurred: ${err}`);
      setMessage(err.toString());
    }

    setIsLoaderVisible(false);
    setIsRestartVisible(true);
  };

  const store = async (event) => {
    event.preventDefault();
    setIsButtonsVisible(false);
    setIsLoaderVisible(true);
    setMessage("Detecting face..");

    try {
      const [blob, scaling] = await captureImage();
      let result = await backend_rust.detect(new Uint8Array(blob));

      if (!result.Ok) throw new Error(result.Err.message);

      const face = await render(scaling, result.Ok);
      const label = prompt("Enter name of the person");

      if (!label) throw new Error("Cannot add without a name");

      const sanitizedLabel = sanitize(label);
      setMessage(`Face detected. Adding ${sanitizedLabel}..`);

      result = await backend_rust.add(sanitizedLabel, new Uint8Array(face));
      if (!result.Ok) throw new Error(result.Err.message);

      setMessage(`Successfully added ${sanitizedLabel}.`);
    } catch (err) {
      console.error(`An error occurred: ${err}`);
      setMessage(`Failed to add the face: ${err.toString()}`);
    }

    setIsLoaderVisible(false);
    setIsRestartVisible(true);
  };

  const loadLocalImage = async (event) => {
    setMessage("");
    const image = imageRef.current;
    try {
      const file = event.target.files[0];
      if (!file) return;

      const url = await toDataURL(file);
      image.src = url;
    } catch (err) {
      setMessage(`Failed to select photo: ${err.toString()}`);
    }

    setIsVideoVisible(false);
    setIsCanvasVisible(false);
    setIsImageVisible(true);
    setIsButtonsVisible(true);
  };

  const toDataURL = (blob) => {
    return new Promise((resolve) => {
      const fileReader = new FileReader();
      fileReader.readAsDataURL(blob);
      fileReader.onloadend = () => resolve(fileReader.result);
    });
  };

  const restart = (event) => {
    setIsRestartVisible(false);
    setMessage("");
    navigator.mediaDevices
      .getUserMedia({ video: true, audio: false })
      .then((stream) => {
        const video = videoRef.current;
        video.srcObject = stream;
        video.play();
        setIsButtonsVisible(true);
        setIsVideoVisible(true);
      });
  };

  const render = async (scaling, box) => {
    box.left = Math.round((box.left * 320 - scaling.x) / scaling.scale);
    box.right = Math.round((box.right * 320 - scaling.x) / scaling.scale);
    box.top = Math.round((box.top * 240 - scaling.y) / scaling.scale);
    box.bottom = Math.round((box.bottom * 240 - scaling.y) / scaling.scale);

    const canvas = canvasRef.current;

    const small = document.createElement("canvas");
    small.width = 160;
    small.height = 160;
    const ctx2 = small.getContext("2d");
    ctx2.drawImage(canvas, box.left, box.top, box.right - box.left, box.bottom - box.top, 0, 0, 140, 140);
    const bytes = await serialize(small);

    const ctx = canvas.getContext("2d");
    ctx.strokeStyle = "#0f3";
    ctx.lineWidth = 5;
    ctx.beginPath();
    ctx.rect(box.left, box.top, box.right - box.left, box.bottom - box.top);
    ctx.stroke();

    return bytes;
  };

  const serialize = (canvas) => {
    return new Promise((resolve) => {
      canvas.toBlob((blob) => blob.arrayBuffer().then(resolve), "image/png", 0.9);
    });
  };

  const sanitize = (name) => {
    return name.match(/[\p{L}\p{N}\s_-]/gu).join("");
  };
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userPrincipal, setUserPrincipal] = useState(null);
  const [canisterResponse, setCanisterResponse] = useState("");

  async function connectToBitfinityWallet() {
    // Canister Ids
  // const nnsCanisterId = 'qoctq-giaaa-aaaaa-aaaea-cai';

  // Whitelist
  // const whitelist = [nnsCanisterId];

  // Make the request
  await window.ic.infinityWallet.requestConnect({
    whitelist,
  });

  // Get the user principal id
  const principalId = await window.ic.infinityWallet.getPrincipal();

  console.log(`InfinityWallet's user principal Id is ${principalId}`);
 
  }

    const handleFileChange = (event) => {
    const file = event.target.files[0];
    if (file) {
      // Create a FileReader to read the file as a data URL
      const reader = new FileReader();
      
      reader.onload = () => {
        // Convert the file data to a Blob
        const arrayBuffer = reader.result;
        const blob = new Blob([arrayBuffer], { type: file.type });
        setBlob(blob);
        console.log('Blob:', blob);
      };

      reader.readAsArrayBuffer(file);
    }
  };

  const onSubmit = async () => {
    const name = document.getElementById("name").value;
    let result = await backend_rust.detect(new Uint8Array(blob));

    if (!result.Ok) throw new Error(result.Err.message);

    const face = await render(scaling, result.Ok);
    const register = await backend_rust.create_user(principalId,name,"lender",file,file);
  }
  return (
    <div className="container">
      <p>asdsd</p>
      <h1>ICP Bitfinity Wallet Integration</h1>
      {isAuthenticated ? (
        <div>
          <p>Connected as: {userPrincipal}</p>
          <p>Canister Response: {canisterResponse}</p>
        </div>
      ) : (
        <button onClick={connectToBitfinityWallet}>Connect Bitfinity Wallet</button>
      )}
      <input id="name" type="text" />
      {/* <input id="file" ref={fileInputRef} type="file" className="invisible" accept="image/*" onChange={loadLocalImage} /> */}
      {/* <input id="fileRecognize" ref={fileInputRecognizeRef} type="file" className="invisible" accept="image/*" onChange={loadLocalImage} /> */}

      <button onClick={()=> onSubmit()}>Submit</button>
      <h1>
        On-chain ICP{" "}
        <img id="inline-logo" src="logo_small.png" alt="ICP Logo" /> face
        recognition
      </h1>
      <div>
        <label id="filelabel" htmlFor="file" className="clickable">
          <div id="camera">
            <img id="image" ref={imageRef} src="logo_transparent.png" className={isImageVisible ? "" : "invisible"} alt="Placeholder" />
            <video
              id="video"
              ref={videoRef}
              className={isVideoVisible ? "" : "invisible"}
              playsInline
            ></video>
            <canvas
              id="canvas"
              ref={canvasRef}
              className={isCanvasVisible ? "" : "invisible"}
            ></canvas>
          </div>
        </label>
        <div className="controls">
          <div id="buttons" className={isButtonsVisible ? "" : "invisible"}>
            <button className="clickable" onClick={recognize}>
              Recognize face
            </button>
            <button className="clickable" onClick={store}>
              Add face
            </button>
          </div>
          <div id="loader" className={isLoaderVisible ? "" : "invisible"}>
            <img id="loader" src="loader.gif" alt="Loader" />
          </div>
          <div id="restart" className={isRestartVisible ? "" : "invisible"}>
            <button className="clickable" onClick={restart}>
              Detect another face
            </button>
          </div>
        </div>
      </div>
      <p id="message">{message}</p>
    </div>
  );
}

export default App;
