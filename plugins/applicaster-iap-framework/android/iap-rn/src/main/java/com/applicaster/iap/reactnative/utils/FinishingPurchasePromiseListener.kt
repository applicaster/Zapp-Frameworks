package com.applicaster.iap.reactnative.utils

import com.applicaster.iap.reactnative.IAPBridge
import com.applicaster.iap.uni.api.IBillingAPI
import com.applicaster.iap.uni.api.Purchase
import com.facebook.react.bridge.Promise

class FinishingPurchasePromiseListener(bridge: IAPBridge,
                                       private val sku: String,
                                       private val skuType: IBillingAPI.SkuType,
                                       promise: Promise)
    : PurchasePromiseListener(bridge, promise, sku) {

    private lateinit var purchase: Purchase

    override fun onPurchased(purchase: Purchase) {
        this.purchase = fix(purchase)
        bridge.acknowledge(
                sku,
                purchase.transactionIdentifier,
                skuType,
                this)
    }

    override fun onPurchaseConsumed(purchaseToken: String) {
        promise.resolve(wrap(purchase))
    }

    override fun onPurchaseAcknowledged() {
        promise.resolve(wrap(purchase))
    }
}
