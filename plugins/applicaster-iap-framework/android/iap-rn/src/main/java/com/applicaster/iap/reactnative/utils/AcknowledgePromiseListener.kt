package com.applicaster.iap.reactnative.utils

import com.facebook.react.bridge.Promise

class AcknowledgePromiseListener(promise: Promise) : PromiseListener(promise) {

    override fun onPurchaseAcknowledged() {
        promise.resolve(true)
    }

}