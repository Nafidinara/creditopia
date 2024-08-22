echo "============================"
echo "===== DEPLOYING ctICP ======"
echo "============================"

TOKEN_NAME="ctICP"

ROOT_PUBLIC_KEY="principal \"$(dfx identity get-principal)\""

dfx canister create $TOKEN_NAME
dfx build $TOKEN_NAME
dfx canister install --mode=upgrade $TOKEN_NAME --argument="(\"https://i.ibb.co.com/nr9Ccwp/Variation-5.png\", \"Creditopia ICP\", \"ctICP\", 8, 10000000000000000, $ROOT_PUBLIC_KEY, 10000)"
# set fee structure. Need Home prefix since this is location of our identity
dfx canister call $TOKEN_NAME setFeeTo "($ROOT_PUBLIC_KEY)"
#deflationary
dfx canister call $TOKEN_NAME setFee "(420)" 
# get balance. Congrats you are rich
dfx canister call $TOKEN_NAME balanceOf "($ROOT_PUBLIC_KEY)"

echo "ctICP id: $(dfx canister id ctICP)"
echo "Principal: $ROOT_PUBLIC_KEY"

echo "============================"
echo "=== FINISH DEPLOY ctICP ===="
echo "============================"