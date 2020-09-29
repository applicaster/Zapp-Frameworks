//
//  StoreObserver.swift
//  IAP
//
//  Created by Roman Karpievich on 4/11/19.
//  Copyright © 2019 Roman Karpievich. All rights reserved.
//

import Foundation
import StoreKit

// Buy Item
// Wait finish trasaction -> completed
// no internet ->
// Call Validate Inplayer
// Transaction -> Finish

class StoreObserver: NSObject, SKPaymentTransactionObserver {
    typealias PurchaseCompletion = (PurchaseResult) -> Void
    typealias RestoreCompletion = (RestoreResult) -> Void
    typealias DownloadsCompletion = ([SKDownload]) -> Void

    private var activePurchases: [String: (Purchase, PurchaseCompletion)] = [:]

    private var restoredPurchases: [SKPaymentTransaction] = []
    private var restoreCompletion: RestoreCompletion?
    private var finishing: Bool = true

    public var downloadsCompletion: DownloadsCompletion?

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    // MARK: - Public methods

    public func buy(_ purchase: Purchase, completion: @escaping (PurchaseResult) -> Void) {
        let payment = SKMutablePayment(product: purchase.item)
        payment.quantity = purchase.amount

        SKPaymentQueue.default().add(payment)

        activePurchases[purchase.item.productIdentifier] = (purchase, completion)
    }

    public func restore(finishing: Bool = true, completion: @escaping RestoreCompletion) {
        restoreCompletion = completion
        self.finishing = finishing
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // MARK: - Private methods

    private func purchased(transaction: SKPaymentTransaction) {
        let identifier = transaction.payment.productIdentifier
        guard let (purchase, completion) = activePurchases[identifier] else {
            return
        }
        activePurchases.removeValue(forKey: identifier)

        purchase.transaction = transaction

        let result = PurchaseResult.success(purchase)
        DispatchQueue.main.async {
            completion(result)
        }

        if purchase.finishing == true {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }

    private func failed(transaction: SKPaymentTransaction) {
        let identifier = transaction.payment.productIdentifier
        SKPaymentQueue.default().finishTransaction(transaction)

        guard let (_, completion) = activePurchases[identifier] else {
            return
        }

        SKPaymentQueue.default().finishTransaction(transaction)
        activePurchases.removeValue(forKey: identifier)

        guard let error = transaction.error else {
            return
        }

        let result = PurchaseResult.failure(error)
        DispatchQueue.main.async {
            completion(result)
        }
    }

    private func restored(transaction: SKPaymentTransaction) {
        if restoreCompletion == nil {
            SKPaymentQueue.default().finishTransaction(transaction)
        } else {
            restoredPurchases.append(transaction)
        }
    }

    // MARK: - SKPaymentTransactionObserver methods

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .purchased:
                purchased(transaction: transaction)
            case .failed:
                failed(transaction: transaction)
            case .restored:
                restored(transaction: transaction)
            case .deferred:
                break
           @unknown default: fatalError("unknownPaymentTransaction")
            }
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoreCompletion?(.failure(error))
        restoreCompletion = nil
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        restoreCompletion?(.success(restoredPurchases))

        if finishing == true {
            for purchase in restoredPurchases {
                SKPaymentQueue.default().finishTransaction(purchase)
            }
        }

        restoredPurchases.removeAll()
        restoreCompletion = nil
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        downloadsCompletion?(downloads)
    }
}
