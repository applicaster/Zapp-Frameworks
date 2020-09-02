//
//  BillingHelper.swift
//  IAP
//
//  Created by Roman Karpievich on 4/9/19.
//  Copyright © 2019 Roman Karpievich. All rights reserved.
//

import Foundation
import StoreKit

open class BillingHelper {
    
    public static let sharedInstance = BillingHelper()
    
    private let storeObserver = StoreObserver()
    
    private var productsQuery: ProductsQuery?
    private var receiptRefreshQuery: ReceiptRefreshQuery?
    
    public var downloadsCompletion: (([SKDownload]) -> Void)? {
        didSet {
            storeObserver.downloadsCompletion = downloadsCompletion
        }
    }
    
    private init() {
        
    }
    
    // MARK: - Public methods
    
    public func products(_ identifiers: Set<String>,
                         completion: @escaping (ProductsQueryResult) -> Void) {
        productsQuery = ProductsQuery(identifiers: identifiers) { [weak self] (result) in
            self?.productsQuery = nil
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        productsQuery?.start()
    }
    
    public func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func purchase(_ item: SKProduct,
                         amount: Int = 1,
                         finishing: Bool = true,
                         completion: @escaping (PurchaseResult) -> Void) {
        guard canMakePayments() == true else {
            let error = NSError(domain: SKErrorDomain,
                                code: SKError.paymentNotAllowed.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: "Payments are blocked on this device"])
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        let purchase = Purchase(item: item,
                                amount: amount,
                                finishing: finishing)
        storeObserver.buy(purchase,
                          completion: completion)
    }
    
    public func restore(finishing: Bool = true, completion: @escaping (RestoreResult) -> Void) {
        storeObserver.restore(finishing: finishing, completion: completion)
    }
    
    public func localReceiptData() -> Data? {
        guard let localReceiptURL = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        
        let data = try? Data(contentsOf: localReceiptURL)
        return data
    }
    
    public func refreshReceipt(receiptProperties: [String: Any]? = nil,
                               completion: @escaping (ReceiptRefreshResult) -> Void) {
        receiptRefreshQuery = ReceiptRefreshQuery(receiptProperties: receiptProperties,
                                                  completion: { [weak self] (result) in
            self?.receiptRefreshQuery = nil
            DispatchQueue.main.async {
                completion(result)
            }
        })
        
        receiptRefreshQuery?.start()
    }
    
    public func start(_ downloads: [SKDownload]) {
        SKPaymentQueue.default().start(downloads)
    }
    
    public func cancel(_ downloads: [SKDownload]) {
        SKPaymentQueue.default().cancel(downloads)
    }
    
    public func pause(_ downloads: [SKDownload]) {
        SKPaymentQueue.default().pause(downloads)
    }
    
    public func resume(_ downloads: [SKDownload]) {
        SKPaymentQueue.default().resume(downloads)
    }
    
    public func finishTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    public func unfinishedTransactions() -> [SKPaymentTransaction] {
        return SKPaymentQueue.default().transactions
    }
    
    public func unfinishedTransaction(_ transactionIdentifier:String) -> SKPaymentTransaction? {
        return unfinishedTransactions().first { (transaction) -> Bool in
            if let indentifier = transaction.transactionIdentifier,
                transactionIdentifier == indentifier {
                return true
            }
            return false
        }
    }
}
