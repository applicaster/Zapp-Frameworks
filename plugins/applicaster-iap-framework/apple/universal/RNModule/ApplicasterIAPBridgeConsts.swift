//
//  ApplicasterIAPBridgeConsts.swift
//  ApplicasterIAP
//
//  Created by Anton Kononenko on 6/5/20.
//  Copyright © 2020 Roman Karpievich. All rights reserved.
//

struct ApplicasterIAPBridgeErrors {
    static let generalError = "ApplicasterIAPBridgeError"
    static let noProducts = "Products Ids do not exist"
    static let canNotFindProduct = "Can not find availible identifier:"
    static let canNotFinishPurchasedTransaction = "Can not finish purchased transaction for identifier:"
}

struct ReactNativeProductsKeys {
    static let productIdentifier = "productIdentifier"
    static let productType = "productType"
    static let finishing = "finishing"
    struct ProductType {
        static let consumable = "consumable"
        static let nonConsumable = "nonConsumable"
        static let subscription = "subscription"
    }
}

struct ReactNativeProductsResponseKeys {
    static let payload = "payload"
    static let invalidIDs = "invalidIDs"
    static let products = "products"
}

struct ReacеNativePurchaseResponseKeys {
    static let receipt = "receipt"
    static let productIdentifier = "productIdentifier"
    static let transactionIdentifier = "transactionIdentifier"
    static let payload = "payload"
    static let appleInfo = "appleInfo"
}

struct ReacеNativeRestorePurchasesKeys {
    static let receipt = "receipt"
    static let restoreProductsIDs = "restoredProducts"
}
