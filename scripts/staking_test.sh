dfx identity use default
export DEPLOY_ID=$(dfx identity get-principal)
dfx canister call CDTP icrc1_transfer "(record { to = record { owner = principal \"$(dfx canister id staking)\";};  amount = 5_000_000_000;})"

dfx identity new staker
dfx identity use staker
export STAKER_ID=$(dfx identity get-principal)

dfx identity use default
dfx canister call CDTP icrc1_transfer "(record { to = record { owner = principal \"${STAKER_ID}\";};  amount = 10_000_000_0;})"

echo "Staker balance before stake: $(dfx canister call CDTP icrc1_balance_of "(record {owner = principal \"${STAKER_ID}\"; })")"
echo "Staking platform balance before stake: $(dfx canister call CDTP icrc1_balance_of "(record {owner = principal \"$(dfx canister id staking)\"; })")"

dfx identity use staker

# approve the token_transfer_from_backend canister to spend 100 tokens
dfx canister call --identity staker CDTP icrc2_approve "(
  record {
    spender= record {
      owner = principal \"$(dfx canister id staking)\";
    };
    amount = 10000000000: nat;
  }
)"
echo "done approve"

#staker doing staking
dfx canister call staking deposit '(10000000, 1)'

echo "Staker balance after deposit: $(dfx canister call CDTP icrc1_balance_of "(record {owner = principal \"${STAKER_ID}\"; })")"
echo "Staking platform balance after deposit: $(dfx canister call CDTP icrc1_balance_of "(record {owner = principal \"$(dfx canister id staking)\"; })")"

dfx canister call staking checkStakeStatistics '()'

#should cant withdraw
dfx canister call staking withdraw '()'

echo "Staker balance after withdraw: $(dfx canister call CDTP icrc1_balance_of "(record {owner = principal \"${STAKER_ID}\"; })")"
echo "Staking platform balance after withdraw: $(dfx canister call CDTP icrc1_balance_of "(record {owner = principal \"$(dfx canister id staking)\"; })")"
