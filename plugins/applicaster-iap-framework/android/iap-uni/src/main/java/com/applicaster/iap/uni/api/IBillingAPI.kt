package com.applicaster.iap.uni.api

import android.app.Activity
import android.content.Context
import com.applicaster.iap.uni.amazon.AmazonBillingImpl
import com.applicaster.iap.uni.play.PlayBillingImpl

interface IBillingAPI {

    enum class Vendor {
        play, amazon
    }

    enum class SkuType {
        subscription,
        consumable,
        nonConsumable
    }

    enum class IAPResult {
        success,
        alreadyOwned,
        generalError
    }

    // todo: init should have listener
    //  (errors are not returned right now in init, so we fine for now)
    fun init(applicationContext: Context)

    fun loadSkuDetails(
            skuType: SkuType,
            skusList: List<String>,
            callback: IAPListener? = null
    )

    fun loadSkuDetailsForAllTypes(
            skus: Map<String, SkuType>,
            callback: IAPListener? = null
    )

    fun restorePurchases(
            skuType: SkuType,
            callback: IAPListener? = null
    )

    fun restorePurchasesForAllTypes(callback: IAPListener? = null)

    fun purchase(
            activity: Activity,
            request: PurchaseRequest,
            callback: IAPListener?
    )

    fun consume(purchaseItem: Purchase, callback: IAPListener?)

    fun consume(
            purchaseToken: String,
            callback: IAPListener? = null
    )

    fun acknowledge(
            purchaseToken: String,
            callback: IAPListener?
    )

    companion object {
        fun create(vendor: Vendor): IBillingAPI = when (vendor) {
            Vendor.play -> PlayBillingImpl()
            Vendor.amazon -> AmazonBillingImpl()
        }
    }
}
