package com.applicaster.iap.reactnative.utils

import com.facebook.react.bridge.Promise

class ConsumePromiseListener(promise: Promise) : PromiseListener(promise) {

    override fun onPurchaseConsumed(purchaseToken: String) {
        promise.resolve(purchaseToken)
    }
}
