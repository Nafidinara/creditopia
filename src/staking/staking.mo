import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Option "mo:base/Option";
import ICRCLedger "canister:icrc1_ledger_canister";

// Assume CDTP is the ICRC token interface
// import CDTP "path/to/your/icrc_token"

actor StakingPlatform {

    // Define the staking data structure
    type StakeData = {
        user: Principal;
        amount: Nat;
        startTime: Time.Time;
        lockPeriod: Nat;
        rewardRate: Nat;
        withdrawn: Bool;
    };

    // Storage for all stakes
    var stakes: [StakeData] = [];

    // Reward rates based on lock periods
    let rewardRates: [(Nat, Nat)] = [
        (1 * 86400, 2),   // 1 day = 86400 seconds, reward = 2%
        (3 * 86400, 5),   // 3 days, reward = 5%
        (10 * 86400, 10)  // 10 days, reward = 10%
    ];

    // Function to deposit (stake) CDTP tokens
    public func deposit(amount: Nat, lockDays: Nat): async Text {
        // Find the reward rate based on lock period
        let rewardRate = switch (Array.findOpt<Nat>(rewardRates, func(pair: (Nat, Nat)): Bool { pair.0 == lockDays * 86400 })) {
            case (?rate) rate.1;
            case null return "Invalid lock period selected.";
        };

        // Assume the transfer function is implemented in the CDTP token canister
        // let transferResult = await CDTP.transferFrom(ic.caller(), this, amount);

        // Add the stake data
        let newStake = {
            user = ic.caller();
            amount = amount;
            startTime = Time.now();
            lockPeriod = lockDays * 86400; // Convert days to seconds
            rewardRate = rewardRate;
            withdrawn = false;
        };
        stakes := Array.append(stakes, [newStake]);

        return "Staked successfully!";
    };

    // Function to withdraw CDTP tokens after lock period
    public func withdraw(): async Text {
        let currentTime = Time.now();

        let userStakeOpt = Array.findOpt<StakeData>(stakes, func(stake: StakeData): Bool { stake.user == ic.caller() and not stake.withdrawn });

        switch (userStakeOpt) {
            case (null) return "No active stake found or stake already withdrawn.";
            case (?userStake) {
                if (currentTime < userStake.startTime + userStake.lockPeriod) {
                    return "Cannot withdraw before the lock period ends.";
                };

                let reward = (userStake.amount * userStake.rewardRate) / 100;
                let totalAmount = userStake.amount + reward;

                // Assume the transfer function is implemented in the CDTP token canister
                // let transferResult = await CDTP.transfer(ic.caller(), totalAmount);

                // Mark the stake as withdrawn
                stakes := Array.map<StakeData>(stakes, func(stake: StakeData): StakeData {
                    if (stake.user == ic.caller() and stake == userStake) {
                        return { stake with withdrawn = true };
                    } else {
                        return stake;
                    }
                });

                return "Withdrawal successful! Total received: " # Text.fromNat(totalAmount) # " CDTP.";
            };
        };
    };

    // Function to check user's active stake
    public query func checkStake(): async Option<StakeData> {
        Array.findOpt<StakeData>(stakes, func(stake: StakeData): Bool { stake.user == ic.caller() and not stake.withdrawn })
    };
}