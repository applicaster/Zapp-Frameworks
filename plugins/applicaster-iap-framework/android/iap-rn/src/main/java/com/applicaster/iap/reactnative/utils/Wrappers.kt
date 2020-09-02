package com.applicaster.iap.reactnative.utils;

import com.applicaster.iap.uni.api.Purchase
import com.applicaster.iap.uni.api.Sku
import com.facebook.react.bridge.WritableNativeMap

// should I make these Extensions?

fun wrap(skuDetails: Sku): WritableNativeMap {
    val skuDetail = WritableNativeMap()
    skuDetail.putString("productIdentifier", skuDetails.productIdentifier)
    skuDetail.putString("price", skuDetails.price)
    skuDetail.putString("title", skuDetails.title)
    skuDetail.putString("description", skuDetails.description)
    return skuDetail
}

fun wrap(purchase: Purchase): WritableNativeMap {
    val nativeMap = WritableNativeMap()
    nativeMap.putString("productIdentifier", purchase.productIdentifier)
    nativeMap.putString("transactionIdentifier", purchase.transactionIdentifier)
    nativeMap.putString("receipt", purchase.receipt)
    return nativeMap
}
