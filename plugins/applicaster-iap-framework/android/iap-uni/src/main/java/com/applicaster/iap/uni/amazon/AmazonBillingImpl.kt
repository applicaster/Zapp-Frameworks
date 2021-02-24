package com.applicaster.iap.uni.amazon

import android.app.Activity
import android.content.Context
import android.util.Log
import com.amazon.device.iap.PurchasingListener
import com.amazon.device.iap.PurchasingService
import com.amazon.device.iap.model.*
import com.applicaster.iap.uni.api.*
import com.applicaster.util.APLogger

class AmazonBillingImpl : IBillingAPI, PurchasingListener {

    data class PurchaseRequests(
            val sku: String,
            val listener: IAPListener
    )

    companion object {
        const val TAG = "AmazonBilling"
    }

    private var userData: UserData? = null
    private lateinit var receipts: ReceiptStorage
    private val skuRequests: MutableMap<RequestId, IAPListener> = mutableMapOf()
    private val purchaseRequests: MutableMap<RequestId, PurchaseRequests> = mutableMapOf()
    private var restoreObserver: IAPListener? = null
    private var initializationListener: InitializationFlow? = null

    // todo: use specific interface for update,
    //  so we do not deserialize purchases from the storage
    interface IUpdateListener {
        fun onRestored()
        fun onFailed()
    }

    inner class InitializationFlow(callback: InitializationListener)
        : DummyIAPListener() {

        private var callback: InitializationListener? = callback

        init {
            PurchasingService.getUserData()
        }

        fun onUserDataLoaded() {
            APLogger.debug(TAG, "User data received")
            restoreObserver = initializationListener
            PurchasingService.getPurchaseUpdates(receipts.hasPurchases())
        }

        override fun onPurchasesRestored(purchases: List<Purchase>) {
            callback?.onSuccess()
            nullify()
        }

        public override fun onAnyError(result: IBillingAPI.IAPResult, description: String) {
            callback?.onBillingClientError(result, description)
            nullify()
        }

        // only allow callback to be called once
        // (should not happen since we nullify listener pointers, but anyway)
        private fun nullify() {
            callback = null
            initializationListener = null
            if (restoreObserver == this) {
                restoreObserver = null
            }
        }

    }

    // region IAPAPI

    override fun init(applicationContext: Context,
                      updateCallback: InitializationListener) {
        receipts = ReceiptStorage(applicationContext)
        PurchasingService.registerListener(applicationContext, this)
        initializationListener = InitializationFlow(updateCallback)
    }

    override fun loadSkuDetails(skuType: IBillingAPI.SkuType, skusList: List<String>, callback: IAPListener?) {
        val request = PurchasingService.getProductData(HashSet<String>(skusList))
        if (null != callback) {
            skuRequests[request] = callback
        }
    }

    override fun loadSkuDetailsForAllTypes(skus: Map<String, IBillingAPI.SkuType>, callback: IAPListener?) {
        val request = PurchasingService.getProductData(HashSet<String>(skus.keys))
        if (null != callback) {
            skuRequests[request] = callback
        }
    }

    override fun restorePurchasesForAllTypes(callback: IAPListener?) {
        receipts.reset()
        restoreObserver = callback
        PurchasingService.getPurchaseUpdates(true)
    }

    override fun purchase(activity: Activity, request: PurchaseRequest, callback: IAPListener?) {
        val requestId = PurchasingService.purchase(request.productIdentifier)
        if (null != callback) {
            purchaseRequests[requestId] = PurchaseRequests(request.productIdentifier, callback)
        }
    }

    override fun consume(purchaseItem: Purchase, callback: IAPListener?) {
        consume(purchaseItem.receipt, callback)
    }

    override fun consume(purchaseToken: String, callback: IAPListener?) {
        PurchasingService.notifyFulfillment(purchaseToken, FulfillmentResult.FULFILLED)
        callback?.onPurchaseConsumed(purchaseToken)
    }

    override fun acknowledge(purchaseToken: String, callback: IAPListener?) {
        PurchasingService.notifyFulfillment(purchaseToken, FulfillmentResult.FULFILLED)
        callback?.onPurchaseAcknowledged()
    }

    // endregion IAPAPI

    // region PurchasingListener

    override fun onProductDataResponse(response: ProductDataResponse?) {
        if (null == response) {
            return
        }

        val request = skuRequests.remove(response.requestId)
        if (ProductDataResponse.RequestStatus.SUCCESSFUL != response.requestStatus) {
            APLogger.error(TAG, "onSkuDetailsLoadingFailed: ${response.requestStatus}")
            skuRequests[response.requestId]?.onSkuDetailsLoadingFailed(
                IBillingAPI.IAPResult.generalError,
                response.requestStatus.toString()
            )
            return
        }
        val skus =
            response.productData.values.map { Sku(it.sku, it.price, it.title, it.description) }
        request?.onSkuDetailsLoaded(skus)
    }

    override fun onPurchaseResponse(response: PurchaseResponse?) {
        if (null == response) {
            return
        }
        val request = purchaseRequests.remove(response.requestId)
        if (PurchaseResponse.RequestStatus.SUCCESSFUL != response.requestStatus) {
            APLogger.error(TAG, "onPurchaseFailed: ${response.requestStatus}")
            if(null != request) {
                // for items that ara not fulfilled we do not get alreadyOwned, but just error
                // try to handle it
                if (PurchaseResponse.RequestStatus.FAILED == response.requestStatus) {
                    val ownedPurchase = receipts.getPurchase(request.sku)
                    if (null != ownedPurchase) {
                        APLogger.info(TAG, "Already owned purchase found in storage: ${request.sku}")
                        request.listener.onPurchased(ownedPurchase)
                        return
                    }
                }
                val iapResult =
                        if (PurchaseResponse.RequestStatus.ALREADY_PURCHASED == response.requestStatus)
                            IBillingAPI.IAPResult.alreadyOwned
                        else
                            IBillingAPI.IAPResult.generalError
                request.listener.onPurchaseFailed(
                        iapResult,
                        response.requestStatus.toString())
            }
            return
        }
        val receipt = response.receipt
        receipts.update(listOf(receipt), response.userData?.userId)
        request?.listener?.onPurchased(
                Purchase(
                        receipt.sku,
                        receipt.receiptId,
                        receipt.receiptId,
                        response.userData?.userId
                )
        )
    }

    override fun onPurchaseUpdatesResponse(response: PurchaseUpdatesResponse?) {
        if (null != response) {
            if (response.requestStatus != PurchaseUpdatesResponse.RequestStatus.SUCCESSFUL) {
                APLogger.error(TAG, "onPurchaseUpdatesResponse: ${response.requestStatus}")
                restoreObserver?.onPurchaseRestoreFailed(
                    IBillingAPI.IAPResult.generalError,
                    response.requestStatus.toString()
                )
                return
            }
            APLogger.debug(TAG, "Got PurchaseUpdatesResponse")
            receipts.update(response.receipts, response.userData?.userId)
            if (response.hasMore()) {
                PurchasingService.getPurchaseUpdates(false)
                return
            }
        }
        APLogger.debug(TAG, "PurchaseUpdatesResponse completed")
        restoreObserver?.onPurchasesRestored(receipts.getPurchases())
        restoreObserver = null
    }

    override fun onUserDataResponse(userDataResponse: UserDataResponse?) {
        if(null == userDataResponse) {
            initializationListener?.onAnyError(IBillingAPI.IAPResult.generalError, "Failed to load user data: got null")
            return
        }
        if (userDataResponse.requestStatus != UserDataResponse.RequestStatus.SUCCESSFUL) {
            APLogger.error(TAG, "onPurchaseUpdatesResponse: ${userDataResponse.requestStatus}")
            initializationListener?.onAnyError(IBillingAPI.IAPResult.generalError, "Failed to load user data")
            return
        }
        userData = userDataResponse.userData
        initializationListener?.onUserDataLoaded()
        // nothing yet
    }

    // endregion PurchasingListener
}