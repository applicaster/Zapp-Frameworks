package com.applicaster.iap.uni.api


interface IAPListener {

    // SKU loading
    fun onSkuDetailsLoaded(skuDetails: List<Sku>)

    fun onSkuDetailsLoadingFailed(result: IBillingAPI.IAPResult, description: String)

    // Purchase flow
    fun onPurchased(purchase: Purchase)

    fun onPurchaseFailed(result: IBillingAPI.IAPResult, description: String)

    // Restore flow
    fun onPurchasesRestored(purchases: List<Purchase>)

    fun onPurchaseRestoreFailed(result: IBillingAPI.IAPResult, description: String)

    // Consumption flow
    fun onPurchaseConsumed(purchaseToken: String)

    fun onPurchaseConsumptionFailed(result: IBillingAPI.IAPResult, description: String)

    // Acknowledge flow
    fun onPurchaseAcknowledged()

    fun onPurchaseAcknowledgeFailed(result: IBillingAPI.IAPResult, description: String)

    // General error
    fun onBillingClientError(result: IBillingAPI.IAPResult, description: String)

    // Amazon specific
    fun onAmazonUserId(userId: String, marketplace: String) {

    }

}
