import Foundation
import os.log
import React
import StoreKit

let model_log = OSLog(subsystem: "com.applicaster.purchase.test", category: "Purchase")

@objc(ApplicasterIAPBridge)
class ApplicasterIAPBridge: NSObject, RCTBridgeModule {
    static var availibleProducts: Set<SKProduct> = []
    static func moduleName() -> String! {
        return "ApplicasterIAPBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    @objc func products(_ payload: [[String: Any]]?,
                        resolver: @escaping RCTPromiseResolveBlock,
                        rejecter: @escaping RCTPromiseRejectBlock) {
        guard let payload = payload else {
            rejecter(ApplicasterIAPBridgeErrors.generalError,
                     ApplicasterIAPBridgeErrors.noProducts,
                     nil)
            return
        }

        let products = Set(payload.map({ $0[ReactNativeProductsKeys.productIdentifier] as! String }))
        BillingHelper.sharedInstance.products(products) { (result: ProductsQueryResult) in
            switch result {
            case let .success(response):
                let products = response.products

                products.forEach({ ApplicasterIAPBridge.availibleProducts.insert($0) })

                resolver([
                    ReactNativeProductsResponseKeys.products: SKProduct.wrappProducts(products: products),
                    ReactNativeProductsResponseKeys.invalidIDs: response.invalidIDs,
                    ReactNativeProductsResponseKeys.payload: payload,
                ])
            case let .failure(error):
                rejecter(ApplicasterIAPBridgeErrors.generalError,
                         error.localizedDescription,
                         error)
            }
        }
    }

    @objc func purchase(_ payload: [String: Any]?,
                        resolver: @escaping RCTPromiseResolveBlock,
                        rejecter: @escaping RCTPromiseRejectBlock) {
        guard let payload = payload,
            let productIdentifier = payload[ReactNativeProductsKeys.productIdentifier] as? String,
            let product = ApplicasterIAPBridge.retrieveAvailableProduct(from: productIdentifier) else {
            rejecter(ApplicasterIAPBridgeErrors.generalError,
                     ApplicasterIAPBridgeErrors.canNotFindProduct,
                     nil)
            return
        }

        let finishing = payload[ReactNativeProductsKeys.finishing] as? Bool ?? true
        BillingHelper.sharedInstance.purchase(product,
                                              finishing: finishing) { (result: PurchaseResult) in
            switch result {
            case let .success(purchase):
                let purchaseDict = purchase.toDictionary()
                os_log("Receipt: [%@], item: [%@] )", log: model_log, type: .info, Utils.receiptInBase64String()!, purchase.item.productIdentifier)

                resolver([
                    ReacеNativePurchaseResponseKeys.receipt: Utils.receiptInBase64String() as Any,
                    ReacеNativePurchaseResponseKeys.productIdentifier: purchase.item.productIdentifier,
                    ReacеNativePurchaseResponseKeys.transactionIdentifier: purchase.transaction?.transactionIdentifier as Any,
                    ReacеNativePurchaseResponseKeys.appleInfo: purchaseDict,
                    ReacеNativePurchaseResponseKeys.payload: payload,
                ])

            case let .failure(error):
                rejecter(ApplicasterIAPBridgeErrors.generalError,
                         error.localizedDescription,
                         error)
            }
        }
    }

    @objc func restore(_ resolver: @escaping RCTPromiseResolveBlock,
                       rejecter: @escaping RCTPromiseRejectBlock) {
        BillingHelper.sharedInstance.restore { (result: RestoreResult) in
            switch result {
            case let .success(transactions):
                let purchasedItemIDs = transactions.map({ $0.payment.productIdentifier })
                resolver([
                    ReacеNativeRestorePurchasesKeys.receipt: Utils.receiptInBase64String() as Any,
                    ReacеNativeRestorePurchasesKeys.restoreProductsIDs: purchasedItemIDs,
                ])
            case let .failure(error):
                rejecter(ApplicasterIAPBridgeErrors.generalError,
                         error.localizedDescription,
                         error)
            }
        }
    }

    class func retrieveAvailableProduct(from productIdentifier: String) -> SKProduct? {
        return availibleProducts.first { (product) -> Bool in
            product.productIdentifier == productIdentifier
        }
    }

    @objc func finishPurchasedTransaction(_ payload: [String: Any]?,
                                          resolver: @escaping RCTPromiseResolveBlock,
                                          rejecter: @escaping RCTPromiseRejectBlock) {
        guard let payload = payload,
            let identifier = payload["transactionIdentifier"] as? String,
            let unfinishedTransaction = BillingHelper.sharedInstance.unfinishedTransaction(identifier) else {
            rejecter(ApplicasterIAPBridgeErrors.generalError,
                     ApplicasterIAPBridgeErrors.canNotFinishPurchasedTransaction,
                     nil)
            return
        }

        BillingHelper.sharedInstance.finishTransaction(unfinishedTransaction)
        resolver(true)
    }
}
