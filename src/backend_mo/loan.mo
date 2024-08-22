import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Int64 "mo:base/Int64";

import Account "./account/account";
import Ledger "canister:icp_ledger_canister";
import Invoice "canister:invoice";

actor class P2PLendingComplex() = this {
    let ledger : Principal = Principal.fromActor(Ledger);
    let icp_fee : Nat = 10_000;

    type LoanId = Nat32;
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
        id : LoanId;
        borrower : Principal;
        title : Text;
        category : Text;
        description : Text;
        lenders : [LenderInfo];
        totalAmount : Nat64;
        fundedAmount : Nat64;
        waitTime : Nat;
        tenor : Nat;
        interestRate : Float;
        status : LoanStatus;
        createdAt : Int;
        claimDeadline : Int;
        invoiceId : Nat;
    };

    type LoanStatus = {
        #Pending;
        #ReadyToClaim;
        #Claimed;
        #Repaid;
        #Defaulted;
        #Cancelled;
    };

    private stable var nextLoanId : LoanId = 0;
    private var loans = HashMap.HashMap<LoanId, Loan>(10, Nat32.equal, func(x) { x });

    // User balance datastructure
    private var balances = HashMap.HashMap<Principal, Nat>(10, Principal.equal, Principal.hash);
    private stable var balances_stable : [(Principal, Nat)] = [];

    let DAY_IN_NANOSECONDS : Int = 86_400_000_000_000;

    // ===== LOAN FUNCTIONS =====
    public shared func registerLoan(caller : Principal, title : Text, description : Text, category : Text, amount : Nat64, tenor : Nat, waitTime : Nat, interestRate : Float) : async Result.Result<LoanId, Error> {
        let id = nextLoanId;
        nextLoanId += 1;

        let invoiceId = await Invoice.registerInvoice(10, Time.now());
        switch (invoiceId) {
            case (#err(_)) {
                return #err(#TransferFailed);
            };
            case (#ok(invId)) {
                let currentTime = Time.now();
                let loan : Loan = {
                    id = id;
                    title = title;
                    description = description;
                    category = category;
                    borrower = caller;
                    lenders = [];
                    totalAmount = amount;
                    fundedAmount = 0;
                    waitTime = waitTime;
                    tenor = tenor;
                    interestRate = interestRate;
                    status = #Pending;
                    createdAt = currentTime;
                    claimDeadline = currentTime + Int64.toInt(Int64.fromNat64(Nat64.fromNat(waitTime + 3))) * DAY_IN_NANOSECONDS;
                    invoiceId = invId;
                };

                loans.put(id, loan);
                return #ok(id);
            };
        };
    };

    public shared func lendToLoan(caller : Principal, loan_id : LoanId, amount : Nat64) : async Result.Result<(), Error> {
        switch (loans.get(loan_id)) {
            case null { return #err(#NotFound) };
            case (?loan) {
                if (loan.status != #Pending) {
                    return #err(#InvalidStatus);
                };

                switch (balances.get(caller)) {
                    case null { return #err(#InsufficientFunds) };
                    case (?balance) {
                        if (Nat64.fromNat(balance) < amount) {
                            return #err(#InsufficientFunds);
                        };

                        let new_balance = balance - Nat64.toNat(amount);
                        balances.put(caller, new_balance);

                        let new_funded_amount = loan.fundedAmount + amount;
                        let new_lenders = Array.append(loan.lenders, [{ lender = caller; amount = amount }]);

                        let updatedStatus = if (new_funded_amount >= loan.totalAmount and Time.now() >= loan.createdAt + Int64.toInt(Int64.fromNat64(Nat64.fromNat(loan.waitTime))) * DAY_IN_NANOSECONDS) {
                            #ReadyToClaim;
                        } else { #Pending };

                        let updated_loan : Loan = {
                            loan with
                            lenders = new_lenders;
                            fundedAmount = new_funded_amount;
                            status = updatedStatus;
                        };

                        loans.put(loan_id, updated_loan);
                        return #ok();
                    };
                };
            };
        };
    };

    public shared func claimLoan(caller : Principal, loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case null { return #err(#NotFound) };
            case (?loan) {
                if (loan.borrower != caller) {
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
                let withdraw_account = Account.accountIdentifier(caller, Account.defaultSubaccount());
                let icp_receipt = await Ledger.transfer({
                    memo = 0;
                    from_subaccount = ?Account.defaultSubaccount();
                    to = withdraw_account;
                    amount = { e8s = loan.fundedAmount };
                    fee = { e8s = Nat64.fromNat(icp_fee) };
                    created_at_time = ?{
                        timestamp_nanos = Nat64.fromNat(Int.abs(Time.now()));
                    };
                });

                switch icp_receipt {
                    case (#Err _) {
                        return #err(#TransferFailed);
                    };
                    case _ {
                        let updatedLoan = {
                            loan with
                            status = #Claimed;
                        };
                        loans.put(loanId, updatedLoan);
                        return #ok();
                    };
                };
            };
        };
    };

    public shared func cancelLoanAsBorrower(caller : Principal, loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case null { return #err(#NotFound) };
            case (?loan) {
                if (loan.borrower != caller) {
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
                for (lenderInfo in loan.lenders.vals()) {
                    let current_balance = switch (balances.get(lenderInfo.lender)) {
                        case null 0;
                        case (?balance) balance;
                    };
                    balances.put(lenderInfo.lender, current_balance + Nat64.toNat(lenderInfo.amount));
                };

                let updatedLoan = {
                    loan with
                    status = #Cancelled;
                };
                loans.put(loanId, updatedLoan);
                return #ok();
            };
        };
    };

    public shared func reclaimFundsAsLender(caller : Principal, loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case null { return #err(#NotFound) };
            case (?loan) {
                if (loan.status != #ReadyToClaim) {
                    return #err(#InvalidStatus);
                };
                let currentTime = Time.now();
                if (currentTime <= loan.claimDeadline) {
                    return #err(#ClaimPeriodEnded);
                };

                // Find the lender's contribution
                let lenderInfoOpt = Array.find(loan.lenders, func(info : LenderInfo) : Bool { info.lender == caller });

                switch (lenderInfoOpt) {
                    case null { return #err(#NotAuthorized) };
                    case (?lenderInfo) {
                        // Return funds to lender's balance
                        let current_balance = switch (balances.get(caller)) {
                            case null 0;
                            case (?balance) balance;
                        };
                        balances.put(caller, current_balance + Nat64.toNat(lenderInfo.amount));

                        // Remove this lender from the loan
                        let updated_lenders = Array.filter(loan.lenders, func(info : LenderInfo) : Bool { info.lender != caller });
                        let updatedLoan = {
                            loan with
                            lenders = updated_lenders;
                        };

                        loans.put(loanId, updatedLoan);
                        return #ok();
                    };
                };
            };
        };
    };

    // Other functions like querying loans, updating loan statuses, etc. can be added here
};
