package com.applicaster.iap.uni.play

import android.app.Activity
import android.content.Context
import android.util.Log
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.SkuDetails
import com.applicaster.iap.BillingListener
import com.applicaster.iap.GoogleBillingHelper
import com.applicaster.iap.uni.api.IBillingAPI
import com.applicaster.iap.uni.api.IAPListener
import com.applicaster.iap.uni.api.Purchase
import com.applicaster.iap.uni.api.PurchaseRequest

class PlayBillingImpl: IBillingAPI, BillingListener {

    companion object {
        const val TAG = "PlayBilling"
    }

    private val purchasesMap: MutableMap<String, com.android.billingclient.api.Purchase> = hashMapOf()
    private val purchaseListeners: MutableMap<String, IAPListener> = hashMapOf()

    // sku details cache
    private val skuDetails: MutableMap<String, SkuDetails> = hashMapOf()

    // region IAPAPI

    override fun init(applicationContext: Context,
                      updateCallback: IAPListener?) {
        val restorePromiseListener =
                if (null != updateCallback) RestorePromiseListener(updateCallback) else null
        GoogleBillingHelper.init(applicationContext, this)
        GoogleBillingHelper.restorePurchasesForAllTypes(restorePromiseListener)
    }

    override fun loadSkuDetails(
        skuType: IBillingAPI.SkuType,
        skusList: List<String>,
        callback: IAPListener?
    ) {
        val type = mapSkuType(skuType)
        GoogleBillingHelper.loadSkuDetails(
            type, skusList,
            if (null == callback) null else SKUPromiseListener(callback)
        )
    }

    private fun mapSkuType(skuType: IBillingAPI.SkuType): String {
        return when (skuType) {
            IBillingAPI.SkuType.subscription -> BillingClient.SkuType.SUBS
            IBillingAPI.SkuType.nonConsumable -> BillingClient.SkuType.INAPP
            IBillingAPI.SkuType.consumable -> BillingClient.SkuType.INAPP
        }
    }

    override fun loadSkuDetailsForAllTypes(skus: Map<String, IBillingAPI.SkuType>,
                                           callback: IAPListener?) {
        val playSKUs = skus.map { Pair(it.key, mapSkuType(it.value)) }.toMap()
        GoogleBillingHelper.loadSkuDetailsForAllTypes(
                playSKUs,
                if (null == callback) null else SKUPromiseListener(callback))
    }

    override fun restorePurchasesForAllTypes(callback: IAPListener?) {
        GoogleBillingHelper.restorePurchasesForAllTypes(
            if (null == callback) null else RestorePromiseListener(callback))
    }

    override fun purchase(activity: Activity, request: PurchaseRequest, callback: IAPListener?) {
        // todo: check loaded
        val sku = skuDetails[request.productIdentifier]
        if (null == sku) {
            callback?.onPurchaseFailed(IBillingAPI.IAPResult.generalError,"SKU ${request.productIdentifier} not found")
        } else {
            // in fact, only one purchase process can be running at a time, so its not needed
            if(purchaseListeners.containsKey(sku.sku)) {
                callback?.onPurchaseFailed(IBillingAPI.IAPResult.generalError,"Another purchase is in progress for SKU ${request.productIdentifier}")
                return
            }
            if(null != callback) {
                this.purchaseListeners[sku.sku] = callback
            }
            GoogleBillingHelper.purchase(activity, sku)
        }
    }

    override fun consume(purchaseItem: Purchase, callback: IAPListener?) {
        consume(purchaseItem.transactionIdentifier, callback)
    }

    override fun consume(purchaseToken: String, callback: IAPListener?) {
        GoogleBillingHelper.consume(
            purchaseToken,
            if (null == callback) null else ConsumePromiseListener(callback))
    }

    override fun acknowledge(purchaseToken: String, callback: IAPListener?) {
        GoogleBillingHelper.acknowledge(purchaseToken,
            if (null == callback) null else AcknowledgePromiseListener(callback))
    }

    // endregion IAPAPI

    // region PurchasingListener

    override fun onPurchaseLoaded(purchases: List<com.android.billingclient.api.Purchase>) {
        // the only listener that can't be passed as callback to the billing library
        purchases.forEach { purchase ->
            purchaseListeners.remove(purchase.sku)
                ?.onPurchased(Purchase(purchase.sku, purchase.purchaseToken, purchase.originalJson))
        }
        purchasesMap.putAll(purchases.map { it.sku to it })
    }

    override fun onPurchaseLoadingFailed(statusCode: Int, description: String) {
        Log.e(TAG, "onPurchaseLoadingFailed: $statusCode $description")
        // there will be only single at a time item, I suppose, but just to have generic code
        purchaseListeners.values.forEach {
            it.onPurchaseFailed(Mappers.mapStatus(statusCode), description)
        }
        purchaseListeners.clear()
    }

    override fun onPurchasesRestored(purchases: List<com.android.billingclient.api.Purchase>) {
        purchasesMap.putAll(purchases.map { it.sku to it })
    }

    override fun onSkuDetailsLoaded(skuDetails: List<SkuDetails>) {
        this.skuDetails += skuDetails.map { Pair(it.sku, it) }
    }

    override fun onSkuDetailsLoadingFailed(statusCode: Int, description: String) {
        Log.e(TAG, "onSkuDetailsLoadingFailed: $statusCode $description")
    }

    override fun onPurchaseConsumed(purchaseToken: String) {
    }

    override fun onPurchaseConsumptionFailed(statusCode: Int, description: String) {
        Log.e(TAG, "onPurchaseConsumptionFailed: $statusCode $description")
    }

    override fun onBillingClientError(statusCode: Int, description: String) {
        Log.e(TAG, "onBillingClientError: $statusCode $description")
        purchaseListeners.values.forEach{ it.onBillingClientError(Mappers.mapStatus(statusCode), description)}
        purchaseListeners.clear()
    }

    override fun onPurchaseAcknowledgeFailed(statusCode: Int, description: String) {
        Log.e(TAG, "onPurchaseAcknowledgeFailed: $statusCode $description")
    }

    override fun onPurchaseAcknowledged() {
    }

    // endregion PurchasingListener
}