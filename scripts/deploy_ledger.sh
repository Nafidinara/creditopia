echo "============================"
echo "===== DEPLOYING LEDGER ====="
echo "============================"

dfx identity new minter
dfx identity use minter
export MINT_ACC=$(dfx ledger account-id)

dfx identity use default
export LEDGER_ACC=$(dfx ledger account-id)

dfx deploy ledger --argument "
  (variant {
    Init = record {
      minting_account = \"$MINT_ACC\";
      initial_values = vec {
        record {
          \"$LEDGER_ACC\";
          record {
            e8s = 10_000_000_000 : nat64;
          };
        };
      };
      send_whitelist = vec {};
      transfer_fee = opt record {
        e8s = 10_000 : nat64;
      };
      token_symbol = opt \"LICP\";
      token_name = opt \"Local ICP\";
    }
  })
"

export LEDGER_ID=$(dfx canister id ledger)

echo "Minter ACC: $MINT_ACC"
echo "Ledger ACC: $LEDGER_ACC"
echo "Ledger ID: $LEDGER_ID"

echo "============================"
echo "=== FINISH DEPLOY LEDGER ==="
echo "============================"