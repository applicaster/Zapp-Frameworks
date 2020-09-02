package com.applicaster.iap.uni.play

import com.applicaster.iap.uni.api.IAPListener

class AcknowledgePromiseListener(listener: IAPListener) : BaseIAPListener(listener) {
    override fun onPurchaseAcknowledged() {
        super.onPurchaseAcknowledged()
        listener.onPurchaseAcknowledged()
    }
}