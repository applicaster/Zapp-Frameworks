package com.applicaster.iap.reactnative.utils

import android.util.Log
import com.applicaster.iap.reactnative.IAPBridge
import com.facebook.react.bridge.Promise

class ConsumePromiseListener(promise: Promise) : PromiseListener(promise) {

    override fun onPurchaseConsumed(purchaseToken: String) {
        Log.d(IAPBridge.TAG, "Purchases was consumed.")
        promise.resolve(purchaseToken)
    }
}
