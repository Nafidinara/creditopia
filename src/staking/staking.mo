import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
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
        let _ = await CDTP.icrc2_transfer_from(transferFromArgs);

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
        let daysStaked = elapsedTime / 86400;

        // Calculate reward as Nat
        let reward = (stake.amount * stake.dailyRewardRate * daysStaked) / 100;

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
            from = { owner = Principal.fromActor(StakingPlatform); subaccount = null };
            to = { owner = caller; subaccount = null };
            amount = totalAmount;
            fee = null;
            memo = null;
            created_at_time = null;
        };

        // Transfer the tokens back to the user
        let transferResult = await CDTP.icrc1_transfer(transferArgs);

        // Mark the stake as withdrawn
        stakes := Array.map<StakeData>(stakes, func(stake: StakeData): StakeData {
            if (stake.user == caller and stake == userStake) {
                return { stake with withdrawn = true };
            } else {
                return stake;
            }
        });

        return "Withdrawal successful! Total received: " # Text.fromNat(totalAmount) # " CDTP.";
    };
};
}

    // Other functions (calculateReward, checkStake, etc.) remain unchanged
}