//
//  Result.swift
//  IAP
//
//  Created by Roman Karpievich on 4/9/19.
//  Copyright © 2019 Roman Karpievich. All rights reserved.
//

import StoreKit

public enum Result<Success> {
    case success(Success)
    case failure(Error)
}

extension Result where Success == Void {
    static var success: Result {
        return .success(())
    }
}

public typealias PurchaseResult = Result<Purchase>
public typealias RestoreResult = Result<[SKPaymentTransaction]>
public typealias ReceiptRefreshResult = Result<Void>
public typealias ProductsQueryResult = Result<(products: [SKProduct], invalidIDs: [String])>


