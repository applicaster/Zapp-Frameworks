package com.applicaster.iap.uni.amazon

import android.app.Activity
import android.content.Context
import android.util.Log
import com.amazon.device.iap.PurchasingListener
import com.amazon.device.iap.PurchasingService
import com.amazon.device.iap.model.*
import com.applicaster.iap.uni.api.*
import com.applicaster.iap.uni.play.PlayBillingImpl

class AmazonBillingImpl : IBillingAPI, PurchasingListener {

    private var userData: UserData? = null
    private lateinit var receipts: ReceiptStorage
    private val skuRequests: MutableMap<RequestId, IAPListener> = mutableMapOf()
    private val purchaseRequests: MutableMap<RequestId, IAPListener> = mutableMapOf()
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
            purchaseRequests[requestId] = callback
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
            Log.e(PlayBillingImpl.TAG, "onSkuDetailsLoadingFailed: ${response.requestStatus}")
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
            Log.e(PlayBillingImpl.TAG, "onPurchaseFailed: ${response.requestStatus}")
            val iapResult =
                    if (PurchaseResponse.RequestStatus.ALREADY_PURCHASED == response.requestStatus)
                        IBillingAPI.IAPResult.alreadyOwned
                    else
                        IBillingAPI.IAPResult.generalError
            request?.onPurchaseFailed(
                    iapResult,
                    response.requestStatus.toString())
            return
        }
        val receipt = response.receipt
        receipts.update(listOf(receipt), userData?.userId)
        request?.onPurchased(
                Purchase(
                        receipt.sku,
                        receipt.receiptId,
                        receipt.toJSON().toString(),
                        userData?.userId
                )
        )
    }

    override fun onPurchaseUpdatesResponse(response: PurchaseUpdatesResponse?) {
        if (null != response) {
            if (response.requestStatus != PurchaseUpdatesResponse.RequestStatus.SUCCESSFUL) {
                Log.e(PlayBillingImpl.TAG, "onPurchaseUpdatesResponse: ${response.requestStatus}")
                restoreObserver?.onPurchaseRestoreFailed(
                    IBillingAPI.IAPResult.generalError,
                    response.requestStatus.toString()
                )
                return
            }
            receipts.update(response.receipts, userData?.userId)
            if (response.hasMore()) {
                PurchasingService.getPurchaseUpdates(false)
                return
            }
        }
        restoreObserver?.onPurchasesRestored(receipts.getPurchases())
        restoreObserver = null
    }

    override fun onUserDataResponse(userDataResponse: UserDataResponse?) {
        if(null == userDataResponse) {
            initializationListener?.onAnyError(IBillingAPI.IAPResult.generalError, "Failed to load user data: got null")
            return
        }
        if (userDataResponse.requestStatus != UserDataResponse.RequestStatus.SUCCESSFUL) {
            Log.e(PlayBillingImpl.TAG, "onPurchaseUpdatesResponse: ${userDataResponse.requestStatus}")
            initializationListener?.onAnyError(IBillingAPI.IAPResult.generalError, "Failed to load user data")
            return
        }
        userData = userDataResponse.userData
        initializationListener?.onUserDataLoaded()
        // nothing yet
    }

    // endregion PurchasingListener
}