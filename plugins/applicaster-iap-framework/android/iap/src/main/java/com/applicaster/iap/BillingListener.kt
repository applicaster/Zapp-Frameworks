package com.applicaster.iap

import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.SkuDetails

/**
 * Callback for general billing events
 */
interface BillingListener {

    /**
     * Implement this function to get list of [com.android.billingclient.api.Purchase]
     * Will be called as a result of [BillingHelper.restorePurchases] function or
     * as a result of succeeded purchase flow or as the result of [BillingHelper.validatePurchases].
     * For [BillingHelper.validatePurchases] call this callback will be contain only verified purchases
     *
     * @param purchases List of updated purchases if present
     */
    fun onPurchaseLoaded(purchases: List<Purchase>)

    /**
     * Implement this function to get error status code and error description if [BillingHelper.restorePurchases]
     * function will be failed
     *
     * @param statusCode An error status code of purchase response [com.android.billingclient.api.BillingClient.BillingResponse]
     * @param description A detailed error description
     */
    fun onPurchaseLoadingFailed(@BillingClient.BillingResponseCode statusCode: Int, description: String)

    /**
     * Implement this function to get restored purchases.
     *
     * @param purchases List of purchased items.
     */
    fun onPurchasesRestored(purchases: List<Purchase>)

    /**
     * Implement this function to get list of In-app product's or subscription's details.
     * Will be called as a result of [BillingHelper.loadSkuDetails] function.
     *
     * @param skuDetails In-app product's or subscription's details
     */
    fun onSkuDetailsLoaded(skuDetails: List<SkuDetails>)

    /**
     * Implement this function to get error status code and error description if [BillingHelper.loadSkuDetails]
     * function will be failed
     *
     * @param statusCode An error status code of purchase response [com.android.billingclient.api.BillingClient.BillingResponse]
     * @param description A detailed error description
     */
    fun onSkuDetailsLoadingFailed(@BillingClient.BillingResponseCode statusCode: Int, description: String)

    /**
     * Implement this function to get purchase token of purchased item.
     *
     * @param purchaseToken The purchase token that was (or was to be) consumed.
     */
    fun onPurchaseConsumed(purchaseToken: String)

    /**
     * Implement this function to get error status code and error description if [BillingHelper.consume]
     * function will be failed
     *
     * @param statusCode An error status code of purchase response [com.android.billingclient.api.BillingClient.BillingResponse]
     * @param description A detailed error description
     */
    fun onPurchaseConsumptionFailed(@BillingClient.BillingResponseCode statusCode: Int, description: String)

    /**
     * Implement this function to obtain error status code and error description if BillingClient sent
     * an initialization error.
     *
     * @param statusCode An error status code of purchase response [com.android.billingclient.api.BillingClient.BillingResponse]
     * @param description A detailed error description
     */
    fun onBillingClientError(@BillingClient.BillingResponseCode statusCode: Int, description: String)

    fun onPurchaseAcknowledgeFailed(statusCode: Int, description: String)

    fun onPurchaseAcknowledged()
}