package com.applicaster.iap.reactnative.utils

import android.util.Log
import com.applicaster.iap.reactnative.IAPBridge
import com.applicaster.iap.uni.api.Purchase
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.WritableNativeArray

class RestorePromiseListener(promise: Promise) : PromiseListener(promise) {

    override fun onPurchasesRestored(purchases: List<Purchase>) {
        Log.d(IAPBridge.TAG, "${purchases.size} purchases were restored.")
        val purchasesArray = WritableNativeArray()
        purchases.forEach { purchasesArray.pushMap(wrap(it)) }
        promise.resolve(purchasesArray)
    }
}