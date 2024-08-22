import Time "mo:base/Time";
import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import InvoiceTypes "types";

actor {
    type InvoiceId = Nat;
    private stable var nextInvoiceId: Nat = 0;

    // Custom hash function for Nat
    private func natHash(n: Nat): Hash.Hash {
        Text.hash(Nat.toText(n))
    };

    private var invoices = Map.HashMap<InvoiceId, InvoiceTypes.Invoice>(0, Nat.equal, natHash);

    public shared(msg) func registerInvoice(amount: Nat, dueDate: Time.Time): async Result.Result<InvoiceId, InvoiceTypes.ErrorInvoice> {
        let invoiceId = nextInvoiceId;
        nextInvoiceId += 1;

        switch (invoices.get(invoiceId)) {
            case (?_) { return #err(#AlreadyExists); };
            case (null) {
                let invoice: InvoiceTypes.Invoice = {
                    issuer = msg.caller;
                    amount = amount;
                    dueDate = dueDate;
                    status = #Pending;
                    createdAt = Time.now();
                };
                invoices.put(invoiceId, invoice);
                return #ok(invoiceId);
            };
        }
    };

    public query func getInvoice(invoiceId: InvoiceId): async Result.Result<InvoiceTypes.Invoice, InvoiceTypes.ErrorInvoice> {
        switch (invoices.get(invoiceId)) {
            case (null) { return #err(#NotFound); };
            case (?invoice) { return #ok(invoice); };
        }
    };

    public shared(_) func verifyInvoice(invoiceId: InvoiceId): async Result.Result<(), InvoiceTypes.ErrorInvoice> {
        switch (invoices.get(invoiceId)) {
            case (null) { return #err(#NotFound); };
            case (?invoice) {
                if (invoice.status != #Pending) {
                    return #err(#InvalidStatus);
                };
                let updatedInvoice = {
                    invoice with
                    status = #Verified;
                };
                invoices.put(invoiceId, updatedInvoice);
                return #ok();
            };
        }
    };

    public shared(msg) func updateInvoiceStatus(invoiceId: InvoiceId, newStatus: InvoiceTypes.InvoiceStatus): async Result.Result<(), InvoiceTypes.ErrorInvoice> {
        switch (invoices.get(invoiceId)) {
            case (null) { return #err(#NotFound); };
            case (?invoice) {
                if (invoice.issuer != msg.caller) {
                    return #err(#NotAuthorized);
                };
                let updatedInvoice = {
                    invoice with
                    status = newStatus;
                };
                invoices.put(invoiceId, updatedInvoice);
                return #ok();
            };
        }
    };

    public func checkOverdueInvoices(): async () {
        let currentTime = Time.now();
        for ((id, invoice) in invoices.entries()) {
            if (invoice.status == #Verified and invoice.dueDate < currentTime) {
                let updatedInvoice = {
                    invoice with
                    status = #Overdue;
                };
                invoices.put(id, updatedInvoice);
            };
        };
    };

    public query func getAllInvoices(): async [InvoiceTypes.Invoice] {
        Iter.toArray(invoices.vals())
    };
}
