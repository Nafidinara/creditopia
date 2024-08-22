dfx identity use default
export DEPLOY_ID=$(dfx identity get-principal)

echo "Symbol: $(dfx canister call CDTP icrc1_symbol '()')"

echo "Supply: $(dfx canister call CDTP icrc1_total_supply '()')"

dfx canister call CDTP icrc1_balance_of "(record {owner = principal \"${DEPLOY_ID}\"; })"

export ALFARA=vwygo-y7rv6-2tow4-qobul-gtue6-w2lb2-dh2jp-lyand-v6c23-p5qht-hae
export ALFARA_2=x63e6-kvyog-6nzvu-2gvqn-zsyub-7ysfo-xr4mk-nejio-a2cvw-woczx-2ae

# transfer to alfara
dfx canister call CDTP icrc1_transfer "(record { to = record { owner = principal \"${ALFARA}\";};  amount = 10_000_000_0;})"
# trasfer to alfara 2
dfx canister call CDTP icrc1_transfer "(record { to = record { owner = principal \"${ALFARA_2}\";};  amount = 10_000_000_0;})"

dfx canister call CDTP icrc1_balance_of "(record {owner = principal \"${DEPLOY_ID}\"; })"