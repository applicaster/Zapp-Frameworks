package com.applicaster.iap.reactnative.utils

import com.applicaster.iap.reactnative.IAPBridge
import com.applicaster.iap.uni.api.IBillingAPI
import com.applicaster.iap.uni.api.Purchase
import com.facebook.react.bridge.Promise

open class PurchasePromiseListener(protected val bridge: IAPBridge,
                                   promise: Promise,
                                   private val sku: String) : PromiseListener(promise) {

    override fun onPurchased(purchase: Purchase) {
        val purchase = fix(purchase)
        promise.resolve(wrap(purchase))
    }

    override fun onPurchaseFailed(result: IBillingAPI.IAPResult, description: String) {
        if(IBillingAPI.IAPResult.alreadyOwned == result) {
            bridge.restoreOwned(this)
        }
        else {
            super.onPurchaseFailed(result, description)
        }
    }

    override fun onPurchasesRestored(purchases: List<Purchase>) {
        super.onPurchasesRestored(purchases)
        // amazon hack, too: in restore we will receive this sku
        purchases.find { it.productIdentifier.startsWith(sku) }?.let {
            promise.resolve(wrap(fix(it)))
        }
    }

    // hack for Amazon: actual purchase for subscriptions will have another SKU (Parent one)
    protected fun fix(purchase: Purchase) =
            Purchase(sku, purchase.transactionIdentifier, purchase.receipt)
}
