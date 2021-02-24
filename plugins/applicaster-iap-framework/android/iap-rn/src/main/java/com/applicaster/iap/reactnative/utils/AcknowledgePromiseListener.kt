package com.applicaster.iap.reactnative.utils

import com.applicaster.iap.reactnative.IAPBridge
import com.applicaster.util.APLogger
import com.facebook.react.bridge.Promise

class AcknowledgePromiseListener(promise: Promise) : PromiseListener(promise) {

    override fun onPurchaseAcknowledged() {
        APLogger.debug(IAPBridge.TAG, "Purchases was acknowledged.")
        promise.resolve(true)
    }

}