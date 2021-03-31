package com.applicaster.iap.reactnative.utils

import com.applicaster.iap.reactnative.IAPBridge
import com.applicaster.iap.uni.api.IBillingAPI
import com.applicaster.iap.uni.api.Purchase
import com.applicaster.util.APLogger
import com.facebook.react.bridge.Promise

class FinishingPurchasePromiseListener(bridge: IAPBridge,
                                       private val sku: String,
                                       private val skuType: IBillingAPI.SkuType,
                                       promise: Promise)
    : PurchasePromiseListener(bridge, promise, sku) {

    private lateinit var purchase: Purchase

    override fun onPurchased(purchase: Purchase) {
        APLogger.debug(IAPBridge.TAG, "Finishing transaction for $sku.")
        this.purchase = fix(purchase)
        bridge.acknowledge(
                sku,
                purchase.transactionIdentifier,
                skuType,
                this)
    }

    override fun onPurchaseConsumed(purchaseToken: String) {
        APLogger.debug(IAPBridge.TAG, "Transaction for $sku was finished.")
        promise.resolve(wrap(purchase))
    }

    override fun onPurchaseAcknowledged() {
        APLogger.debug(IAPBridge.TAG, "Failed to finish transaction for $sku.")
        promise.resolve(wrap(purchase))
    }
}
