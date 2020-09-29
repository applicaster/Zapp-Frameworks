import Foundation
import StoreKit

extension Purchase {
    func toDictionary() -> [String: Any] {
        var retVal: [String: Any] = [
            PurchaseKeys.item: SKProduct.wrappProductToDictionary(product: item),
            PurchaseKeys.finishing: finishing,
            PurchaseKeys.amount: amount,
        ]
        if let transaction = transaction {
            retVal[PurchaseKeys.transaction] = SKPaymentTransaction.wrappTransactionToDictionary(paymentTransaction: transaction)
        }
        return retVal
    }
}
