//
//  Purchase.swift
//  IAP
//
//  Created by Roman Karpievich on 4/11/19.
//  Copyright © 2019 Roman Karpievich. All rights reserved.
//

import Foundation
import StoreKit

struct PurchaseKeys {
    static var item = "item"
    static var finishing = "finishing"
    static var amount = "amount"
    static var transaction = "transaction"
}
open class Purchase {
    public let item: SKProduct
    public let finishing: Bool
    public let amount: Int
    public var transaction: SKPaymentTransaction?

    init(item: SKProduct,
         amount: Int = 1,
         finishing: Bool = true) {
        self.item = item
        self.amount = amount
        self.finishing = finishing
    }
}
