package com.applicaster.iap.reactnative.utils

import com.applicaster.iap.reactnative.IAPBridge
import com.applicaster.util.APLogger
import com.facebook.react.bridge.Promise

class ConsumePromiseListener(promise: Promise) : PromiseListener(promise) {

    override fun onPurchaseConsumed(purchaseToken: String) {
        APLogger.debug(IAPBridge.TAG, "Purchases was consumed.")
        promise.resolve(purchaseToken)
    }
}
