package com.applicaster.iap.reactnative.utils

import com.applicaster.iap.reactnative.IAPBridge
import com.applicaster.iap.uni.api.IBillingAPI
import com.applicaster.iap.uni.api.Purchase
import com.applicaster.util.APLogger
import com.facebook.react.bridge.Promise

open class PurchasePromiseListener(protected val bridge: IAPBridge,
                                   promise: Promise,
                                   private val sku: String) : PromiseListener(promise) {

    override fun onPurchased(purchase: Purchase) {
        promise.resolve(wrap(fix(purchase)))
    }

    override fun onPurchaseFailed(result: IBillingAPI.IAPResult, description: String) {
        if(IBillingAPI.IAPResult.alreadyOwned == result) {
            APLogger.debug(IAPBridge.TAG, "Handling already owned error for $sku.")
            val purchase = bridge.purchases[sku]
            if(null != purchase) {
                APLogger.debug(IAPBridge.TAG, "Purchase $sku was found in already loaded.")
                promise.resolve(wrap(fix(purchase)))
            } else {
                APLogger.debug(IAPBridge.TAG, "Purchase $sku was not found in already loaded. Attempting to restore.")
                bridge.restoreOwned(this)
            }
        }
        else {
            super.onPurchaseFailed(result, description)
        }
    }

    override fun onPurchasesRestored(purchases: List<Purchase>) {
        super.onPurchasesRestored(purchases)
        // amazon hack, too: in restore we will receive this sku
        purchases.find { it.productIdentifier.startsWith(sku) }?.let {
            APLogger.debug(IAPBridge.TAG, "Purchase $sku was successfully restored")
            promise.resolve(wrap(fix(it)))
        }
    }

    // hack for Amazon: actual purchase for subscriptions will have another SKU (Parent one)
    protected fun fix(purchase: Purchase) =
            purchase.copy(productIdentifier = sku)
}
