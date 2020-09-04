package com.applicaster.iap.reactnative.utils

import android.util.Log
import com.applicaster.iap.reactnative.IAPBridge
import com.facebook.react.bridge.Promise

class AcknowledgePromiseListener(promise: Promise) : PromiseListener(promise) {

    override fun onPurchaseAcknowledged() {
        Log.d(IAPBridge.TAG, "Purchases was acknowledged.")
        promise.resolve(true)
    }

}