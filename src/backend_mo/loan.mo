import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Int64 "mo:base/Int64";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Invoice "canister:invoice";
import Types "types";

actor {
    type LoanId = Nat;
    type Error = {
        #NotFound;
        #AlreadyExists;
        #NotAuthorized;
        #InvalidStatus;
        #TransferFailed;
        #InsufficientFunds;
        #WaitTimeNotEnded;
        #ClaimPeriodEnded;
    };

    type LenderInfo = {
        lender : Principal;
        amount : Nat64;
    };

    type Loan = {
        borrower : Principal;
        title: Text;
        category: Text;
        description: Text;
        lenders : [LenderInfo];
        totalAmount : Nat64;
        waitTime : Nat;
        tenor : Nat; // Duration in days
        interestRate : Float;
        status : LoanStatus;
        createdAt : Int;
        claimDeadline : Int;
        invoiceId : Types.InvoiceId;
    };

    type LoanStatus = {
        #Pending;
        #ReadyToClaim;
        #Claimed;
        #Repaid;
        #Defaulted;
        #Cancelled;
    };

    private func natHash(n : Nat) : Hash.Hash {
        Text.hash(Nat.toText(n));
    };

    private stable var nextLoanId : Nat = 0;
    private var loans = Map.HashMap<LoanId, Loan>(0, Nat.equal, natHash);

    let WALLET_CANISTER_ID : Text = ""; // Replace with your Wallet Canister ID
    let DAY_IN_NANOSECONDS : Int = 86_400_000_000_000;

    // 2vxsx-fae itu anonymous

    public shared (msg) func registerLoan(title: Text, description: Text, category: Text, amount : Nat64, tenor : Nat, waitTime : Nat, interestRate : Float) : async Result.Result<LoanId, Error> {
        let loanId = nextLoanId;
        nextLoanId += 1;

        let invoiceId = await Invoice.registerInvoice(10, Time.now());
        switch (invoiceId) {
            case (#err(_)) {
                return #err(#TransferFailed);
            };
            case (#ok(invId)) {
                let currentTime = Time.now();
                let loan : Loan = {
                    title = title;
                    description = description;
                    category = category;
                    borrower = msg.caller;
                    lenders = [];
                    totalAmount = amount;
                    waitTime = waitTime;
                    tenor = tenor;
                    interestRate = interestRate;
                    status = #Pending;
                    createdAt = currentTime;
                    claimDeadline = currentTime + Int64.toInt(Int64.fromNat64(Nat64.fromNat(waitTime + 3))) * DAY_IN_NANOSECONDS;
                    invoiceId = invId;
                };

                loans.put(loanId, loan);
                #ok(loanId);
            };
        };
    };

    public query func getLoan(loanId : LoanId) : async Result.Result<Loan, Error> {
        switch (loans.get(loanId)) {
            case (null) { #err(#NotFound) };
            case (?loan) { #ok(loan) };
        };
    };

    public shared (msg) func lendToLoan(loanId : LoanId, amount : Nat64) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case (null) { #err(#NotFound) };
            case (?loan) {
                if (loan.status != #Pending) {
                    return #err(#InvalidStatus);
                };

                // Transfer ICP from lender to contract (not directly to borrower)
                let walletCanister = actor (WALLET_CANISTER_ID) : actor {
                    transferICP : shared (Text, Nat64) -> async Result.Result<Nat64, Text>;
                };

                let contractAddress = WALLET_CANISTER_ID;
                let transferResult = await walletCanister.transferICP(contractAddress, amount);

                switch (transferResult) {
                    case (#err(message)) {
                        return #err(#TransferFailed);
                    };
                    case (#ok(_)) {
                        let newLenderInfo : LenderInfo = {
                            lender = msg.caller;
                            amount = amount;
                        };
                        let updatedLenders = Array.append(loan.lenders, [newLenderInfo]);
                        let updatedTotalAmount = loan.totalAmount + amount;
                        let updatedStatus = if (updatedTotalAmount >= loan.totalAmount and Time.now() >= loan.createdAt + Int64.toInt(Int64.fromNat64(Nat64.fromNat(loan.waitTime))) * DAY_IN_NANOSECONDS) {
                            #ReadyToClaim;
                        } else { #Pending };

                        let updatedLoan = {
                            loan with
                            lenders = updatedLenders;
                            totalAmount = updatedTotalAmount;
                            status = updatedStatus;
                        };
                        loans.put(loanId, updatedLoan);
                        #ok();
                    };
                };
            };
        };
    };

    public shared (msg) func claimLoan(loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case (null) { #err(#NotFound) };
            case (?loan) {
                if (loan.borrower != msg.caller) {
                    return #err(#NotAuthorized);
                };
                if (loan.status != #ReadyToClaim) {
                    return #err(#InvalidStatus);
                };
                let currentTime = Time.now();
                if (currentTime < loan.createdAt + Int64.toInt(Int64.fromNat64(Nat64.fromNat(loan.waitTime))) * DAY_IN_NANOSECONDS) {
                    return #err(#WaitTimeNotEnded);
                };
                if (currentTime > loan.claimDeadline) {
                    return #err(#ClaimPeriodEnded);
                };

                // Transfer ICP from contract to borrower
                let walletCanister = actor (WALLET_CANISTER_ID) : actor {
                    transferICP : shared (Text, Nat64) -> async Result.Result<Nat64, Text>;
                };

                let borrowerAddress = Principal.toText(loan.borrower);
                let transferResult = await walletCanister.transferICP(borrowerAddress, loan.totalAmount);

                switch (transferResult) {
                    case (#err(message)) {
                        return #err(#TransferFailed);
                    };
                    case (#ok(_)) {
                        let updatedLoan = {
                            loan with
                            status = #Claimed;
                        };
                        loans.put(loanId, updatedLoan);
                        #ok();
                    };
                };
            };
        };
    };

    public shared (msg) func cancelLoanAsBorrower(loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case (null) { #err(#NotFound) };
            case (?loan) {
                if (loan.borrower != msg.caller) {
                    return #err(#NotAuthorized);
                };
                if (loan.status != #Pending and loan.status != #ReadyToClaim) {
                    return #err(#InvalidStatus);
                };
                let currentTime = Time.now();
                if (currentTime >= loan.createdAt + Int64.toInt(Int64.fromNat64(Nat64.fromNat(loan.waitTime))) * DAY_IN_NANOSECONDS) {
                    return #err(#WaitTimeNotEnded);
                };

                // Return funds to lenders
                let walletCanister = actor (WALLET_CANISTER_ID) : actor {
                    transferICP : shared (Text, Nat64) -> async Result.Result<Nat64, Text>;
                };

                for (lenderInfo in loan.lenders.vals()) {
                    let lenderAddress = Principal.toText(lenderInfo.lender);
                    let transferResult = await walletCanister.transferICP(lenderAddress, lenderInfo.amount);

                    switch (transferResult) {
                        case (#err(message)) {
                            return #err(#TransferFailed);
                        };
                        case (#ok(_)) {
                            // Continue with next lender
                        };
                    };
                };

                let updatedLoan = {
                    loan with
                    status = #Cancelled;
                };
                loans.put(loanId, updatedLoan);
                #ok();
            };
        };
    };

    public shared (msg) func reclaimFundsAsLender(loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case (null) { #err(#NotFound) };
            case (?loan) {
                if (loan.status != #ReadyToClaim) {
                    return #err(#InvalidStatus);
                };
                let currentTime = Time.now();
                if (currentTime <= loan.claimDeadline) {
                    return #err(#ClaimPeriodEnded);
                };

                // Find the lender's contribution
                let lenderInfoOpt = Array.find(loan.lenders, func(info : LenderInfo) : Bool { info.lender == msg.caller });

                switch (lenderInfoOpt) {
                    case (null) { return #err(#NotAuthorized) };
                    case (?lenderInfo) {
                        // Return funds to lender
                        let walletCanister = actor (WALLET_CANISTER_ID) : actor {
                            transferICP : shared (Text, Nat64) -> async Result.Result<Nat64, Text>;
                        };

                        let lenderAddress = Principal.toText(msg.caller);
                        let transferResult = await walletCanister.transferICP(lenderAddress, lenderInfo.amount);

                        switch (transferResult) {
                            case (#err(message)) {
                                return #err(#TransferFailed);
                            };
                            case (#ok(_)) {
                                // Remove this lender from the loan
                                let updatedLenders = Array.filter(loan.lenders, func(info : LenderInfo) : Bool { info.lender != msg.caller });
                                let updatedTotalAmount = loan.totalAmount - lenderInfo.amount;
                                let updatedStatus = if (Array.size(updatedLenders) == 0) {
                                    #Cancelled;
                                } else { #ReadyToClaim };

                                let updatedLoan = {
                                    loan with
                                    lenders = updatedLenders;
                                    totalAmount = updatedTotalAmount;
                                    status = updatedStatus;
                                };
                                loans.put(loanId, updatedLoan);
                                #ok();
                            };
                        };
                    };
                };
            };
        };
    };

    public shared (msg) func repayLoan(loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case (null) { #err(#NotFound) };
            case (?loan) {
                if (loan.borrower != msg.caller) {
                    return #err(#NotAuthorized);
                };
                if (loan.status != #Claimed) {
                    return #err(#InvalidStatus);
                };

                // Calculate total repayment amount (principal + interest)
                let principal = Float.fromInt64(Int64.fromNat64(loan.totalAmount));
                let interestAmount = principal * loan.interestRate * (Float.fromInt(loan.tenor) / 365.0);
                let totalRepayment = principal + interestAmount;
                let repaymentAmount = Nat64.fromNat(Int.abs(Float.toInt(totalRepayment)));

                // Transfer ICP from borrower to each lender
                let walletCanister = actor (WALLET_CANISTER_ID) : actor {
                    transferICP : shared (Text, Nat64) -> async Result.Result<Nat64, Text>;
                };

                for (lenderInfo in loan.lenders.vals()) {
                    let lenderRepayment = (Float.fromInt64(Int64.fromNat64(lenderInfo.amount)) / principal) * Float.fromInt64(Int64.fromNat64(repaymentAmount));
                    let lenderRepaymentAmount = Nat64.fromNat(Int.abs(Float.toInt(lenderRepayment)));
                    let lenderAddress = Principal.toText(lenderInfo.lender);
                    let transferResult = await walletCanister.transferICP(lenderAddress, lenderRepaymentAmount);

                    switch (transferResult) {
                        case (#err(message)) {
                            return #err(#TransferFailed);
                        };
                        case (#ok(_)) {
                            // Continue with next lender
                        };
                    };
                };

                let updatedLoan = {
                    loan with
                    status = #Repaid;
                };
                loans.put(loanId, updatedLoan);
                #ok();
            };
        };
    };

    public query func getAllLoans() : async [(LoanId, Loan)] {
        Iter.toArray(loans.entries());
    };
};
