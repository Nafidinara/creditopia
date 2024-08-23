dfx start --clean --background

cd scripts
./deploy_ledger_icp.sh
cd ..
dfx deploy

sh upload-model.sh


npm start