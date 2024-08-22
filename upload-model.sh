dfx canister call user clear_face_detection_model_bytes
dfx canister call user clear_face_recognition_model_bytes
ic-file-uploader user append_face_detection_model_bytes version-RFB-320.onnx
ic-file-uploader user append_face_recognition_model_bytes face-recognition.onnx
dfx canister call user setup_models