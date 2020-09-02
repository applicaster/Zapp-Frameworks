package com.applicaster.iap.uni.play

import com.applicaster.iap.uni.api.IAPListener
import com.applicaster.iap.uni.api.Purchase
import com.android.billingclient.api.Purchase as GooglePurchase

class RestorePromiseListener(listener: IAPListener) : BaseIAPListener(listener) {
    override fun onPurchasesRestored(purchases: List<GooglePurchase>) {
        super.onPurchasesRestored(purchases)
        listener.onPurchasesRestored(purchases.map { Purchase(it.sku, it.purchaseToken, it.originalJson) })
    }
}
