package com.applicaster.iap.reactnative

import android.util.Log
import com.applicaster.iap.reactnative.utils.*
import com.applicaster.iap.uni.api.*
import com.facebook.react.bridge.*

// todo: call restore on already owned error
// todo: revert purchase if not fulfilled by backend
// todo: skip expired subscriptions from restored

class IAPBridge(reactContext: ReactApplicationContext)
    : ReactContextBaseJavaModule(reactContext) {

    companion object {
        const val bridgeName = "ApplicasterIAPBridge"
        const val TAG = bridgeName

        const val subscription = "subscription"
        const val nonConsumable = "nonConsumable"
        const val consumable = "consumable"

        // map product fields for IAP library and update sky type lookup table
        private fun unwrapProductIdentifier(map: HashMap<String, String>,
                                            skuTypesCache: MutableMap<String, IBillingAPI.SkuType>
        ): Pair<String, IBillingAPI.SkuType> {
            val productId = map["productIdentifier"]!!
            val productType = map["productType"]!!
            val skuType = skuType(productType)
            skuTypesCache[productId] = skuType
            return Pair(productId, skuType)
        }

        private fun skuType(productType: String): IBillingAPI.SkuType {
            return when (productType) {
                subscription -> IBillingAPI.SkuType.subscription
                nonConsumable -> IBillingAPI.SkuType.nonConsumable
                consumable -> IBillingAPI.SkuType.consumable
                else -> throw IllegalArgumentException("Unknown SKU type ${productType}")
            }
        }
    }

    // todo: implement in api maybe? since we have it already, and its updated on every purchase
    // also we need to remove consumed consumables
    val purchases: MutableMap<String, Purchase> = mutableMapOf()

    private lateinit var api: IBillingAPI

    // lookup map to SkuDetails
    private val skuDetailsMap: MutableMap<String, Sku> = mutableMapOf()

    // cache for initial purchase type since Google billing does not distinguish consumables and non-consumables
    // and we do not keep it in the Sku class
    private val skuTypes: MutableMap<String, IBillingAPI.SkuType> = mutableMapOf()

    override fun getName(): String {
        return bridgeName
    }

    @ReactMethod
    fun isInitialized(result: Promise) = result.resolve(this::api::isInitialized)

    @ReactMethod
    fun initialize(vendor: String, result: Promise) {
        api = IBillingAPI.create(IBillingAPI.Vendor.valueOf(vendor))
        // todo: use js promise
        api.init(reactApplicationContext, object : InitializationListener {
            override fun onSuccess() {
                Log.d(TAG, "Billing client initialized")
                result.resolve(true)
            }
            override fun onBillingClientError(billingResult: IBillingAPI.IAPResult, description: String) {
                Log.e(TAG, "Billing client initialization failed $description")
                result.reject(billingResult.toString(), description)
            }
        })
    }

    @ReactMethod
    fun products(identifiers: ReadableArray, result: Promise) {
        val productIds = identifiers.toArrayList().map {
            unwrapProductIdentifier(it as HashMap<String, String>, skuTypes)
        }.toMap()
        api.loadSkuDetailsForAllTypes(productIds, SKUPromiseListener(result, skuDetailsMap))
    }

    /**
     * Purchase item
     * @param payload Dictionary with purchase data and flow information
     */
    @ReactMethod
    fun purchase(payload: ReadableMap, result: Promise) {
        val identifier = payload.getString("productIdentifier")!!
        val finishTransactionAfterPurchase = payload.getBoolean("finishing")
        val productType = payload.getString("productType")!!
        val skuType = skuType(productType)
        val sku = skuDetailsMap[identifier]
        if (null == sku) {
            result.reject(IllegalArgumentException("SKU $identifier not found"))
        } else {
            val listener = if(finishTransactionAfterPurchase) {
                FinishingPurchasePromiseListener(this, identifier, skuType, result)
            } else {
                PurchasePromiseListener(this, result, identifier)
            }
            api.purchase(
                    reactApplicationContext.currentActivity!!,
                    PurchaseRequest(identifier),
                    listener)
        }
    }

    /**
     * Restore Purchases
     */
    @ReactMethod
    fun restore(result: Promise) {
        api.restorePurchasesForAllTypes(RestorePromiseListener(result))
    }

    /**
     *  Acknowledge
     */
    @ReactMethod
    fun finishPurchasedTransaction(transaction: ReadableMap, result: Promise) {
        val identifier = transaction.getString("productIdentifier")!!
        val productType = transaction.getString("productType")!!
        val transactionIdentifier = transaction.getString("transactionIdentifier")!!
        val skuType = skuType(productType)
        acknowledge(identifier, transactionIdentifier, skuType, result)
    }

    private fun acknowledge(identifier: String,
                            transactionIdentifier: String,
                            skuType: IBillingAPI.SkuType,
                            result: Promise) {
        acknowledge(identifier, transactionIdentifier, skuType, AcknowledgePromiseListener(result))
    }

    fun acknowledge(identifier: String,
                    transactionIdentifier: String,
                    skuType: IBillingAPI.SkuType,
                    listener: PromiseListener) {
        if (IBillingAPI.SkuType.consumable == skuType) {
            api.consume(transactionIdentifier, listener)
        } else if (IBillingAPI.SkuType.subscription == skuType ||
                IBillingAPI.SkuType.nonConsumable == skuType) {
            api.acknowledge(transactionIdentifier, listener)
        }
    }

    fun restoreOwned(purchasePromiseListener: PurchasePromiseListener) {
        api.restorePurchasesForAllTypes(purchasePromiseListener)
    }

}