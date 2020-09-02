import Foundation
import React
import StoreKit

struct SKPaymentTransactionKeys {
    static let error = "error"
    static let transactionState = "transactionState"
    static let transactionIdentifier = "transactionIdentifier"
}

extension SKPaymentTransactionState {
    func toString() -> String {
        switch self {
        case .purchasing:
            return "purchasing"
        case .purchased:
            return "purchased"
        case .failed:
            return "failed"
        case .restored:
            return "restored"
        case .deferred:
            return "deferred"
        default:
            return "unknown"
        }
    }
}

extension SKPaymentTransaction {
    class func wrappTransactionToDictionary(paymentTransaction: SKPaymentTransaction) -> [String: Any] {
        var retVal: [String: Any] = [
            SKPaymentTransactionKeys.transactionState: paymentTransaction.transactionState.toString(),
        ]
        retVal[SKPaymentTransactionKeys.transactionIdentifier] = paymentTransaction.transactionIdentifier
        if let errorLocalizedDescription = paymentTransaction.error?.localizedDescription {
            retVal[SKPaymentTransactionKeys.error] = RCTMakeError("SKPaymentTransaction Error",
                                                                  errorLocalizedDescription,
                                                                  nil)
        }
        return retVal
    }
}
