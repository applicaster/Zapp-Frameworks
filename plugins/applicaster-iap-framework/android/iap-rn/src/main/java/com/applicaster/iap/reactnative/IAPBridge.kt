package com.applicaster.iap.reactnative

import com.applicaster.iap.reactnative.utils.*
import com.applicaster.iap.uni.api.IBillingAPI
import com.applicaster.iap.uni.api.PurchaseRequest
import com.applicaster.iap.uni.api.Sku
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
            val skuType = when (map["productType"]!!) {
                subscription -> IBillingAPI.SkuType.subscription
                nonConsumable -> IBillingAPI.SkuType.nonConsumable
                consumable -> IBillingAPI.SkuType.consumable
                else -> throw IllegalArgumentException("Unknown SKU type ${map["productType"]}")
            }
            skuTypesCache[productId] = skuType
            return Pair(productId, skuType)
        }
    }

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
    fun init(vendor: String) {
        api = IBillingAPI.create(IBillingAPI.Vendor.valueOf(vendor))
        api.init(reactApplicationContext)
        api.restorePurchasesForAllTypes()
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
        val sku = skuDetailsMap[identifier]
        if (null == sku) {
            result.reject(IllegalArgumentException("SKU $identifier not found"))
        } else {
            val listener = if(finishTransactionAfterPurchase) {
                FinishingPurchasePromiseListener(this, identifier, result)
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
        val transactionIdentifier = transaction.getString("transactionIdentifier")!!
        acknowledge(identifier, transactionIdentifier, result)
    }

    private fun acknowledge(identifier: String, transactionIdentifier: String, result: Promise) {
        val skuDetails = skuTypes[identifier]
        if (null == skuDetails) {
            result.reject(IllegalArgumentException("SKU details are not loaded $transactionIdentifier"))
            return
        }
        if (IBillingAPI.SkuType.consumable == skuDetails) {
            api.consume(transactionIdentifier, ConsumePromiseListener(result))
        } else if (IBillingAPI.SkuType.subscription == skuDetails ||
                IBillingAPI.SkuType.nonConsumable == skuDetails) {
            api.acknowledge(transactionIdentifier, AcknowledgePromiseListener(result))
        }
    }

    fun acknowledge(identifier: String,
                    transactionIdentifier: String,
                    listener: PromiseListener) {
        val skuDetails = skuTypes[identifier]
        if (null == skuDetails) {
            listener.onPurchaseAcknowledgeFailed(
                    IBillingAPI.IAPResult.generalError,
                    "SKU details are not loaded $transactionIdentifier")
            return
        }
        if (IBillingAPI.SkuType.consumable == skuDetails) {
            api.consume(transactionIdentifier, listener)
        } else if (IBillingAPI.SkuType.subscription == skuDetails ||
                IBillingAPI.SkuType.nonConsumable == skuDetails) {
            api.acknowledge(transactionIdentifier, listener)
        }
    }

    fun restoreOwned(purchasePromiseListener: PurchasePromiseListener) {
        api.restorePurchasesForAllTypes(purchasePromiseListener)
    }

}