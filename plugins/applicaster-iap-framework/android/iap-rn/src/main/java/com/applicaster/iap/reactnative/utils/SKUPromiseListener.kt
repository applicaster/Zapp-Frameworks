package com.applicaster.iap.reactnative.utils

import android.util.Log
import com.applicaster.iap.reactnative.IAPBridge
import com.applicaster.iap.uni.api.Sku
import com.applicaster.util.APLogger
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap

class SKUPromiseListener(promise: Promise,
                         private val skuDetailsMap: MutableMap<String, Sku>)
    : PromiseListener(promise) {

    override fun onSkuDetailsLoaded(skuDetails: List<Sku>) {
        APLogger.debug(IAPBridge.TAG, "${skuDetails.size} SKU details were loaded.")
        val products = WritableNativeArray()
        skuDetails.forEach {
            products.pushMap(wrap(it))
            skuDetailsMap[it.productIdentifier] = it
        }
        val resolved = WritableNativeMap()
        resolved.putArray("products", products)
        promise.resolve(resolved)
    }
}
