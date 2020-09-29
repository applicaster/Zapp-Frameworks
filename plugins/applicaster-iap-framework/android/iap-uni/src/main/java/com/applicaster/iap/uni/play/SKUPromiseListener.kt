package com.applicaster.iap.uni.play

import com.android.billingclient.api.SkuDetails
import com.applicaster.iap.uni.api.IAPListener
import com.applicaster.iap.uni.api.Sku

class SKUPromiseListener(listener: IAPListener) : BaseIAPListener(listener) {
    override fun onSkuDetailsLoaded(skuDetails: List<SkuDetails>) {
        super.onSkuDetailsLoaded(skuDetails)
        val skus = skuDetails.map { Sku(it.sku, it.price, it.title, it.description) }
        listener.onSkuDetailsLoaded(skus)
    }
}