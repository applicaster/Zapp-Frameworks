package com.applicaster.iap.uni.api

open class DummyIAPListener : IAPListener {

    override fun onSkuDetailsLoaded(skuDetails: List<Sku>) = Unit

    override fun onSkuDetailsLoadingFailed(result: IBillingAPI.IAPResult, description: String)
            = onAnyError(result, description)

    override fun onPurchased(purchase: Purchase)  = Unit

    override fun onPurchaseFailed(result: IBillingAPI.IAPResult, description: String)
            = onAnyError(result, description)

    override fun onPurchasesRestored(purchases: List<Purchase>) = Unit

    override fun onPurchaseRestoreFailed(result: IBillingAPI.IAPResult, description: String)
            = onAnyError(result, description)

    override fun onPurchaseConsumed(purchaseToken: String) = Unit

    override fun onPurchaseConsumptionFailed(result: IBillingAPI.IAPResult, description: String)
            = onAnyError(result, description)

    override fun onPurchaseAcknowledged()  = Unit

    override fun onPurchaseAcknowledgeFailed(result: IBillingAPI.IAPResult, description: String)
            = onAnyError(result, description)

    override fun onBillingClientError(result: IBillingAPI.IAPResult, description: String)
            = onAnyError(result, description)

    protected open fun onAnyError(result: IBillingAPI.IAPResult, description: String) = Unit
}