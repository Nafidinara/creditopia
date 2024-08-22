import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import CDTP "canister:CDTP";

actor StakingPlatform {

    // Define the staking data structure
    type StakeData = {
        user: Principal;
        amount: Nat;
        startTime: Time.Time;
        lockPeriod: Nat;
        dailyRewardRate: Nat;
        withdrawn: Bool;
    };

    // Storage for all stakes
    var stakes: [StakeData] = [];

    // Daily reward rates based on lock periods
    let dailyRewardRates: [(Nat, Nat)] = [
        (1 * 86400, 2),   // 1 day = 86400 seconds, daily reward = 2%
        (3 * 86400, 5),   // 3 days, daily reward = 5%
        (10 * 86400, 10)  // 10 days, daily reward = 10%
    ];

    // Function to deposit (stake) CDTP tokens
    public shared({caller}) func deposit(amount: Nat, lockDays: Nat): async Text {
        // Find the daily reward rate based on lock period
        let filteredRates = Iter.filter<(Nat, Nat)>(
            Iter.fromArray(dailyRewardRates), 
            func(pair: (Nat, Nat)): Bool { pair.0 == lockDays * 86400 }
        );

        let ratesArray = Iter.toArray(filteredRates);

        let dailyRewardRate = if (ratesArray.size() == 0) {
            return "Invalid lock period selected.";
        } else {
            let (period, rate) = ratesArray[0];
            rate;
        };

        let transferFromArgs : CDTP.TransferFromArgs = {
            from = {
                owner = caller;
                subaccount = null;
            };
            memo = null;
            amount = amount;
            spender_subaccount = null;
            fee = null;
            to = { owner = Principal.fromActor(StakingPlatform); subaccount = null };
            created_at_time = null;
        };

        // Transfer the tokens to the staking canister
        try {
            let transferRes = await CDTP.icrc2_transfer_from(transferFromArgs);
            Debug.print("success");
            Debug.print(debug_show(transferRes));
        } catch (error : Error) {
            Debug.print("Error: " # Error.message(error));
        };

        // Add the stake data
        let newStake = {
            user = caller;
            amount = amount;
            startTime = Time.now();
            lockPeriod = lockDays * 86400; // Convert days to seconds
            dailyRewardRate = dailyRewardRate;
            withdrawn = false;
        };
        stakes := Array.append(stakes, [newStake]);

        return "Staked successfully!";
    };

    // Function to calculate the total reward based on staking period
    private func calculateReward(stake: StakeData, currentTime: Time.Time): Nat {
        let elapsedTime = currentTime - stake.startTime;
        let daysStaked: Nat = Int.abs(elapsedTime / 86400);

        // Calculate reward as Nat
        let reward: Nat = (stake.amount * stake.dailyRewardRate * daysStaked) / 100;
        return reward;
    };

    public shared({caller}) func withdraw(): async Text {
            let currentTime = Time.now();

            // Find the user's active stake that has not been withdrawn
            let userStakeOpt = Array.find<StakeData>(stakes, func(stake: StakeData): Bool { stake.user == caller and not stake.withdrawn });

            // Handle the optional value from the find function
            switch (userStakeOpt) {
            case null {
                return "No active stake found or stake already withdrawn.";
            };
            case (?userStake) {
                if (currentTime < userStake.startTime + userStake.lockPeriod) {
                    return "Cannot withdraw before the lock period ends.";
                };

                let reward = calculateReward(userStake, currentTime);
                let totalAmount = userStake.amount + reward;

                let transferArgs : CDTP.TransferArg = {
                // can be used to distinguish between transactions
                memo = null;
                // the amount we want to transfer
                amount = totalAmount;
                // we want to transfer tokens from the default subaccount of the canister
                from_subaccount = null;
                // if not specified, the default fee for the canister is used
                fee = null;
                // the account we want to transfer tokens to
                to = {
                        owner = caller;
                        subaccount = null;
                    };
                // a timestamp indicating when the transaction was created by the caller; if it is not specified by the caller then this is set to the current ICP time
                created_at_time = null;
                };

                // Transfer the tokens back to the user
                try {
                    let transferResult = await CDTP.icrc1_transfer(transferArgs);
                    // Check if the transfer was successful
                    switch (transferResult) {
                        case (#Err(transferError)) {
                            return "Error: Couldn't transfer funds:\n" # debug_show(transferError);
                        };
                        case (#Ok(blockIndex)) { 
                            return "Transfer successful! Block index: " # Nat.toText(blockIndex);
                        };
                    };
                } catch (error: Error) {
                    throw Error.reject("Reject message: " # Error.message(error));
                };

                // Mark the stake as withdrawn
                stakes := Array.map<StakeData, StakeData>(stakes, func(stake: StakeData): StakeData {
                    if (stake.user == caller and stake == userStake) {
                        return { stake with withdrawn = true };
                    } else {
                        return stake;
                    }
                });

                return "Withdrawal successful! Total received: " # Nat.toText(totalAmount) # " CDTP.";
            };
        };
    };

    public shared({caller}) func checkStakeStatistics(): async ?{
        amount: Nat;
        startTime: Time.Time;
        lockPeriod: Nat;
        dailyRewardRate: Nat;
        withdrawn: Bool;
    } {
        // Find the user's active stake
        let userStakeOpt = Array.find<StakeData>(stakes, func(stake: StakeData): Bool {
            stake.user == caller
        });

        // If a stake is found, return its details
        switch (userStakeOpt) {
            case null {
                return null; // No active stake found for this user
            };
            case (?userStake) {
                return ?{
                    amount = userStake.amount;
                    startTime = userStake.startTime;
                    lockPeriod = userStake.lockPeriod;
                    dailyRewardRate = userStake.dailyRewardRate;
                    withdrawn = userStake.withdrawn;
                };
            };
        };
    };
}