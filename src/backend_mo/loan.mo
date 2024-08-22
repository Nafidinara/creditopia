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
    public shared (msg) func registerLoan(title : Text, description : Text, category : Text, amount : Nat64, tenor : Nat, waitTime : Nat, interestRate : Float) : async Result.Result<LoanId, Error> {
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
                    borrower = msg.caller;
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
                #ok(id);
            };
        };
    };

    public shared (msg) func lendToLoan(loan_id : LoanId, amount : Nat64) : async Result.Result<(), Error> {
        switch (loans.get(loan_id)) {
            case null #err(#NotFound);
            case (?loan) {
                if (loan.status != #Pending) {
                    return #err(#InvalidStatus);
                };

                switch (balances.get(msg.caller)) {
                    case null return #err(#InsufficientFunds);
                    case (?balance) {
                        if (Nat64.fromNat(balance) < amount) {
                            return #err(#InsufficientFunds);
                        };

                        let new_balance = balance - Nat64.toNat(amount);
                        balances.put(msg.caller, new_balance);

                        let new_funded_amount = loan.fundedAmount + amount;
                        let new_lenders = Array.append(loan.lenders, [{ lender = msg.caller; amount = amount }]);

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
                        #ok();
                    };
                };
            };
        };
    };

    public shared (msg) func claimLoan(loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case null { #err(#NotFound) };
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
                let withdraw_account = Account.accountIdentifier(msg.caller, Account.defaultSubaccount());
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
                        #ok();
                    };
                };
            };
        };
    };

    public shared (msg) func cancelLoanAsBorrower(loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case null { #err(#NotFound) };
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
                #ok();
            };
        };
    };

    public shared (msg) func reclaimFundsAsLender(loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case null { #err(#NotFound) };
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
                    case null { return #err(#NotAuthorized) };
                    case (?lenderInfo) {
                        // Return funds to lender's balance
                        let current_balance = switch (balances.get(msg.caller)) {
                            case null 0;
                            case (?balance) balance;
                        };
                        balances.put(msg.caller, current_balance + Nat64.toNat(lenderInfo.amount));

                        // Remove this lender from the loan
                        let updatedLenders = Array.filter(loan.lenders, func(info : LenderInfo) : Bool { info.lender != msg.caller });
                        let updatedFundedAmount = loan.fundedAmount - lenderInfo.amount;
                        let updatedStatus = if (Array.size(updatedLenders) == 0) {
                            #Cancelled;
                        } else { #ReadyToClaim };

                        let updatedLoan = {
                            loan with
                            lenders = updatedLenders;
                            fundedAmount = updatedFundedAmount;
                            status = updatedStatus;
                        };
                        loans.put(loanId, updatedLoan);
                        #ok();
                    };
                };
            };
        };
    };

    public shared (msg) func repayLoan(loanId : LoanId) : async Result.Result<(), Error> {
        switch (loans.get(loanId)) {
            case null { #err(#NotFound) };
            case (?loan) {
                if (loan.borrower != msg.caller) {
                    return #err(#NotAuthorized);
                };
                if (loan.status != #Claimed) {
                    return #err(#InvalidStatus);
                };

                // Calculate total repayment amount (principal + interest)
                let principal = Float.fromInt64(Int64.fromNat64(loan.fundedAmount));
                let interestAmount = principal * loan.interestRate * (Float.fromInt(loan.tenor) / 365.0);
                let totalRepayment = principal + interestAmount;
                let repaymentAmount = Nat64.fromNat(Int.abs(Float.toInt(totalRepayment)));

                // Check if borrower has sufficient balance
                switch (balances.get(msg.caller)) {
                    case null return #err(#InsufficientFunds);
                    case (?balance) {
                        if (Nat64.fromNat(balance) < repaymentAmount) {
                            return #err(#InsufficientFunds);
                        };

                        // Deduct repayment from borrower's balance
                        let new_balance = balance - Nat64.toNat(repaymentAmount);
                        balances.put(msg.caller, new_balance);

                        // Distribute repayment to lenders
                        for (lenderInfo in loan.lenders.vals()) {
                            let lenderRepayment = (Float.fromInt64(Int64.fromNat64(lenderInfo.amount)) / principal) * Float.fromInt64(Int64.fromNat64(repaymentAmount));
                            let lenderRepaymentAmount = Nat64.fromNat(Int.abs(Float.toInt(lenderRepayment)));
                            let current_lender_balance = switch (balances.get(lenderInfo.lender)) {
                                case null 0;
                                case (?balance) balance;
                            };
                            balances.put(lenderInfo.lender, current_lender_balance + Nat64.toNat(lenderRepaymentAmount));
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
        };
    };

    // ===== DEPOSIT FUNCTIONS =====
    public shared (msg) func getDepositAddress() : async Blob {
        Account.accountIdentifier(Principal.fromActor(this), Account.principalToSubaccount(msg.caller));
    };

    public shared (msg) func deposit() : async Result.Result<Nat, Error> {
        let source_account = Account.accountIdentifier(Principal.fromActor(this), Account.principalToSubaccount(msg.caller));
        let balance = await Ledger.account_balance({ account = source_account });

        Debug.print(
            "Balance "
            # debug_show (balance)
            # "account "
            # debug_show (source_account)
        );

        if (Nat64.toNat(balance.e8s) <= icp_fee) {
            return #err(#InsufficientFunds);
        };

        let transfer_amount = Nat64.toNat(balance.e8s) - icp_fee;

        let icp_receipt = await Ledger.transfer({
            memo : Nat64 = 0;
            from_subaccount = ?Account.principalToSubaccount(msg.caller);
            to = Account.accountIdentifier(Principal.fromActor(this), Account.defaultSubaccount());
            amount = { e8s = Nat64.fromNat(transfer_amount) };
            fee = { e8s = Nat64.fromNat(icp_fee) };
            created_at_time = ?{
                timestamp_nanos = Nat64.fromNat(Int.abs(Time.now()));
            };
        });

        switch icp_receipt {
            case (#Err _) {
                return #err(#TransferFailed);
            };
            case _ {};
        };

        let current_balance = switch (balances.get(msg.caller)) {
            case null 0;
            case (?balance) balance;
        };
        balances.put(msg.caller, current_balance + transfer_amount);

        #ok(transfer_amount);
    };

    // ===== WITHDRAW FUNCTIONS =====
    public shared (msg) func withdraw(amount : Nat) : async Result.Result<Nat, Error> {
        switch (balances.get(msg.caller)) {
            case null return #err(#InsufficientFunds);
            case (?balance) {
                if (balance < amount) {
                    return #err(#InsufficientFunds);
                };

                // Perform transfer
                let withdraw_account = Account.accountIdentifier(msg.caller, Account.defaultSubaccount());
                let icp_receipt = await Ledger.transfer({
                    memo = 0;
                    from_subaccount = ?Account.defaultSubaccount();
                    to = withdraw_account;
                    amount = { e8s = Nat64.fromNat(amount) };
                    fee = { e8s = Nat64.fromNat(icp_fee) };
                    created_at_time = ?{
                        timestamp_nanos = Nat64.fromNat(Int.abs(Time.now()));
                    };
                });

                switch icp_receipt {
                    case (#Err _) {
                        return #err(#TransferFailed);
                    };
                    case _ {};
                };

                // Update user's balance
                let new_balance = balance - amount;
                balances.put(msg.caller, new_balance);

                #ok(amount);
            };
        };
    };

    // ===== QUERY FUNCTIONS =====
    public query func getLoan(loanId : LoanId) : async Result.Result<Loan, Error> {
        switch (loans.get(loanId)) {
            case null { #err(#NotFound) };
            case (?loan) { #ok(loan) };
        };
    };

    public query func getBalance(user : Principal) : async Nat {
        switch (balances.get(user)) {
            case null 0;
            case (?balance) balance;
        };
    };

    public query func getAllLoans() : async [(LoanId, Loan)] {
        Iter.toArray(loans.entries());
    };

    public query func getLoansByBorrower(borrower : Principal) : async [Loan] {
        Iter.toArray(
            Iter.filter(
                loans.vals(),
                func(loan : Loan) : Bool {
                    loan.borrower == borrower;
                },
            )
        );
    };

    // 2. Get all loans funded by the lender
    public query func getLoansByLender(lender : Principal) : async [Loan] {
        Iter.toArray(
            Iter.filter(
                loans.vals(),
                func(loan : Loan) : Bool {
                    Array.find(loan.lenders, func(info : LenderInfo) : Bool { info.lender == lender }) != null;
                },
            )
        );
    };

    // 3. Get the total amount of ICP the lender has given
    public query func getTotalLentAmount(lender : Principal) : async Nat64 {
        var total : Nat64 = 0;
        for (loan in loans.vals()) {
            for (lenderInfo in loan.lenders.vals()) {
                if (lenderInfo.lender == lender) {
                    total += lenderInfo.amount;
                };
            };
        };
        total;
    };

    // ===== SYSTEM FUNCTIONS =====
    // system func preupgrade() {
    //     balances_stable := Iter.toArray(balances.entries());
    // };

    // system func postupgrade() {
    //     balances := HashMap.fromIter<Principal, Nat>(balances_stable.vals(), 10, Principal.equal, Principal.hash);
    //     balances_stable := [];
    // };

};
