package com.applicaster.iap.reactnative.utils

import com.applicaster.iap.uni.api.Sku
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.WritableNativeArray
import com.facebook.react.bridge.WritableNativeMap

class SKUPromiseListener(promise: Promise, private val skuDetailsMap: MutableMap<String, Sku>) : PromiseListener(promise) {

    override fun onSkuDetailsLoaded(skuDetails: List<Sku>) {
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
