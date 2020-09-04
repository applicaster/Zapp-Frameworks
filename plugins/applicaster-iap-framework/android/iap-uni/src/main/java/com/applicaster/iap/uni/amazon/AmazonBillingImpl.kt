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

    private lateinit var receipts: ReceiptStorage
    private val skuRequests: MutableMap<RequestId, IAPListener> = mutableMapOf()
    private val purchaseRequests: MutableMap<RequestId, IAPListener> = mutableMapOf()
    private var restoreObserver: IAPListener? = null

    interface IRestoreListener {
        fun onRestored()
        fun onFailed()
    }

    // region IAPAPI

    override fun init(applicationContext: Context,
                      updateCallback: InitializationListener) {
        receipts = ReceiptStorage(applicationContext)
        PurchasingService.registerListener(applicationContext, this)
        restoreObserver = object : DummyIAPListener() {
            override fun onPurchasesRestored(purchases: List<Purchase>) {
                updateCallback.onSuccess()
            }

            override fun onAnyError(result: IBillingAPI.IAPResult, description: String) {
                updateCallback.onBillingClientError(result, description)
            }
        }
        PurchasingService.getPurchaseUpdates(receipts.hasPurchases())
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
        receipts.update(listOf(receipt))
        request?.onPurchased(
            Purchase(
                receipt.sku,
                receipt.receiptId,
                receipt.toJSON().toString()
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
            receipts.update(response.receipts)
            if (response.hasMore()) {
                PurchasingService.getPurchaseUpdates(false)
                return
            }
        }
        restoreObserver?.onPurchasesRestored(receipts.getPurchases())
        restoreObserver = null
    }

    override fun onUserDataResponse(userDataResponse: UserDataResponse?) {
        // nothing yet
    }

    // endregion PurchasingListener
}