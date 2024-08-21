#!/bin/bash

# Example script on how to deploy your own dip20 token

# cd src/DIP20/
#remove old content
# dfx stop
rm -rf .dfx
#create canisters
dfx canister create --all
# create principal idea that is inital owner of tokens
# ROOT_HOME=$(mktemp -d)  

# dfxvm default 0.22.0

ROOT_PUBLIC_KEY="principal \"$(dfx identity get-principal)\""

echo ROOT_PUBLIC_KEY = $ROOT_PUBLIC_KEY
#build token canister
dfx build
# deploy token
dfx canister install DIP20 --argument="(\"https://dogbreedslist.com/wp-content/uploads/2019/08/Are-Golden-Retrievers-easy-to-train.png\", \"Golden Coin\", \"DOG\", 8, 10000000000000000, $ROOT_PUBLIC_KEY, 10000)"

# set fee structure. Need Home prefix since this is location of our identity
dfx canister call DIP20 setFeeTo "($ROOT_PUBLIC_KEY)"
#deflationary
dfx canister call DIP20 setFee "(420)" 
# get balance. Congrats you are rich
dfx canister call DIP20 balanceOf "($ROOT_PUBLIC_KEY)"

dfx canister call DIP20 balanceOf "(principal \"pijkx-rzclc-f7cd2-iyme3-pnukq-ejweg-oc6iq-5rprv-zhcnj-a62ex-vqe\")"
