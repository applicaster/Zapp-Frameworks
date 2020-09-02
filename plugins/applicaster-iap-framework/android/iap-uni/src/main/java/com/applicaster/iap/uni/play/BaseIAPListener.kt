package com.applicaster.iap.uni.play

import com.android.billingclient.api.SkuDetails
import com.applicaster.iap.BillingListener
import com.applicaster.iap.uni.api.IAPListener

// Provides error routing to simplify subclasses
open class BaseIAPListener(protected val listener: IAPListener) : BillingListener {

    override fun onPurchaseLoaded(purchases: List<com.android.billingclient.api.Purchase>) {
    }

    override fun onPurchaseLoadingFailed(statusCode: Int, description: String) {
        listener.onPurchaseFailed(Mappers.mapStatus(statusCode), description)
    }

    override fun onPurchasesRestored(purchases: List<com.android.billingclient.api.Purchase>) {
    }

    override fun onSkuDetailsLoaded(skuDetails: List<SkuDetails>) {
    }

    override fun onSkuDetailsLoadingFailed(statusCode: Int, description: String) {
        listener.onSkuDetailsLoadingFailed(Mappers.mapStatus(statusCode), description)
    }

    override fun onPurchaseConsumed(purchaseToken: String) {
    }

    override fun onPurchaseConsumptionFailed(statusCode: Int, description: String) {
        listener.onPurchaseConsumptionFailed(Mappers.mapStatus(statusCode), description)
    }

    override fun onBillingClientError(statusCode: Int, description: String) {
        listener.onBillingClientError(Mappers.mapStatus(statusCode), description)
    }

    override fun onPurchaseAcknowledgeFailed(statusCode: Int, description: String) {
        listener.onPurchaseAcknowledgeFailed(Mappers.mapStatus(statusCode), description)
    }

    override fun onPurchaseAcknowledged() {
    }


}