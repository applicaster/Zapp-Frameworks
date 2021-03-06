package com.applicaster.iap.reactnative

import com.applicaster.iap.reactnative.utils.*
import com.applicaster.iap.uni.api.*
import com.applicaster.util.APLogger
import com.facebook.react.bridge.*


class IAPBridge(reactContext: ReactApplicationContext)
    : ReactContextBaseJavaModule(reactContext) {

    companion object {
        const val bridgeName = "ApplicasterIAPBridge"
        const val TAG = bridgeName

        const val subscription = "subscription"
        const val nonConsumable = "nonConsumable"
        const val consumable = "consumable"

        // map product fields for IAP library and update sky type lookup table
        private fun unwrapProductIdentifier(map: HashMap<String, String>)
                : Pair<String, IBillingAPI.SkuType> {
            val productId = map["productIdentifier"]!!
            val productType = map["productType"]!!
            val skuType = skuType(productType)
            return Pair(productId, skuType)
        }

        private fun skuType(productType: String): IBillingAPI.SkuType {
            return when (productType) {
                subscription -> IBillingAPI.SkuType.subscription
                nonConsumable -> IBillingAPI.SkuType.nonConsumable
                consumable -> IBillingAPI.SkuType.consumable
                else -> throw IllegalArgumentException("Unknown SKU type $productType")
            }
        }
    }

    // todo: implement in api maybe? since we have it already, and its updated on every purchase
    // also we need to remove consumed consumables
    val purchases: MutableMap<String, Purchase> = mutableMapOf()

    private lateinit var api: IBillingAPI

    // lookup map to SkuDetails
    private val skuDetailsMap: MutableMap<String, Sku> = mutableMapOf()

    override fun getName(): String {
        return bridgeName
    }

    @ReactMethod
    fun isInitialized(result: Promise) = result.resolve(::api.isInitialized)

    @ReactMethod
    fun initialize(vendor: String, result: Promise) {
        reactApplicationContext.runOnUiQueueThread {
            APLogger.debug(TAG, "Initializing Billing client for $vendor")
            api = IBillingAPI.create(IBillingAPI.Vendor.valueOf(vendor))
            api.init(reactApplicationContext, object : InitializationListener {
                override fun onSuccess() {
                    APLogger.debug(TAG, "Billing client initialized")
                    result.resolve(true)
                }
                override fun onBillingClientError(billingResult: IBillingAPI.IAPResult, description: String) {
                    APLogger.error(TAG, "Billing client initialization failed $description")
                    result.reject(billingResult.toString(), description)
                }
            })
        }
    }

    @ReactMethod
    fun products(identifiers: ReadableArray, result: Promise) {
        val productIds = identifiers.toArrayList().map {
            unwrapProductIdentifier(it as HashMap<String, String>)
        }.toMap()
        reactApplicationContext.runOnUiQueueThread {
            api.loadSkuDetailsForAllTypes(productIds, SKUPromiseListener(result, skuDetailsMap))
        }
    }

    /**
     * Purchase item
     * @param payload Dictionary with purchase data and flow information
     */
    @ReactMethod
    fun purchase(payload: ReadableMap, result: Promise) {
        val identifier = payload.getString("productIdentifier")!!
        val finishTransaction = payload.getBoolean("finishing")
        val productType = payload.getString("productType")!!
        val skuType = skuType(productType)
        val sku = skuDetailsMap[identifier]
        if (null == sku) {
            result.reject(IllegalArgumentException("SKU $identifier not found"))
        } else {
            val listener = if(finishTransaction) {
                FinishingPurchasePromiseListener(this, identifier, skuType, result)
            } else {
                PurchasePromiseListener(this, result, identifier)
            }
            reactApplicationContext.runOnUiQueueThread {
                api.purchase(
                        reactApplicationContext.currentActivity!!,
                        PurchaseRequest(identifier),
                        listener)
            }
        }
    }

    /**
     * Restore Purchases
     */
    @ReactMethod
    fun restore(result: Promise) {
        reactApplicationContext.runOnUiQueueThread {
            api.restorePurchasesForAllTypes(RestorePromiseListener(result))
        }
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
        reactApplicationContext.runOnUiQueueThread {
            acknowledge(identifier, transactionIdentifier, skuType, result)
        }
    }

    fun acknowledge(identifier: String,
                    transactionIdentifier: String,
                    skuType: IBillingAPI.SkuType,
                    listener: PromiseListener) {
        reactApplicationContext.runOnUiQueueThread {
            if (IBillingAPI.SkuType.consumable == skuType) {
                api.consume(transactionIdentifier, listener)
            } else if (IBillingAPI.SkuType.subscription == skuType ||
                    IBillingAPI.SkuType.nonConsumable == skuType) {
                api.acknowledge(transactionIdentifier, listener)
            }
        }
    }

    private fun acknowledge(identifier: String,
                            transactionIdentifier: String,
                            skuType: IBillingAPI.SkuType,
                            result: Promise) {
        val listener =
                when (skuType) {
                    IBillingAPI.SkuType.consumable -> ConsumePromiseListener(result)
                    else -> AcknowledgePromiseListener(result)
                }
        acknowledge(identifier, transactionIdentifier, skuType, listener)
    }

    fun restoreOwned(purchasePromiseListener: PurchasePromiseListener) {
        api.restorePurchasesForAllTypes(purchasePromiseListener)
    }

}