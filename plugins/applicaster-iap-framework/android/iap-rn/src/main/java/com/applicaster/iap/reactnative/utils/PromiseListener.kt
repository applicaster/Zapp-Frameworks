package com.applicaster.iap.reactnative.utils


import com.applicaster.iap.reactnative.IAPBridge
import com.applicaster.iap.uni.api.IAPListener
import com.applicaster.iap.uni.api.IBillingAPI
import com.applicaster.iap.uni.api.Purchase
import com.applicaster.iap.uni.api.Sku
import com.applicaster.util.APLogger
import com.facebook.react.bridge.Promise

abstract class PromiseListener(protected val promise: Promise) : IAPListener {

    override fun onPurchased(purchase: Purchase) = Unit

    override fun onPurchasesRestored(purchases: List<Purchase>) = Unit

    override fun onSkuDetailsLoaded(skuDetails: List<Sku>) = Unit

    override fun onPurchaseConsumed(purchaseToken: String) = Unit

    override fun onPurchaseAcknowledged() = Unit

    override fun onSkuDetailsLoadingFailed(result: IBillingAPI.IAPResult, description: String) =
            reportError("SkuDetails", result, description)

    override fun onPurchaseRestoreFailed(result: IBillingAPI.IAPResult, description: String) =
            reportError("PurchaseRestore", result, description)

    override fun onPurchaseFailed(result: IBillingAPI.IAPResult, description: String) =
            reportError("Purchase", result, description)

    override fun onPurchaseConsumptionFailed(result: IBillingAPI.IAPResult, description: String) =
            reportError("PurchaseConsumption", result, description)

    override fun onBillingClientError(result: IBillingAPI.IAPResult, description: String) =
            reportError("Billing client", result, description)

    override fun onPurchaseAcknowledgeFailed(result: IBillingAPI.IAPResult, description: String) =
            reportError("PurchaseAcknowledge", result, description)

    private fun reportError(operation: String, result: IBillingAPI.IAPResult, description: String) {
        APLogger.error(IAPBridge.TAG, "$operation failed with result $result: $description")
        promise.reject(result.toString(), description)
    }
}
