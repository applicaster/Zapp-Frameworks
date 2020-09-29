package com.applicaster.iap.uni.play

import com.applicaster.iap.uni.api.IAPListener

class ConsumePromiseListener(listener: IAPListener) : BaseIAPListener(listener) {
    override fun onPurchaseConsumed(purchaseToken: String) {
        super.onPurchaseConsumed(purchaseToken)
        listener.onPurchaseConsumed(purchaseToken)
    }
}
