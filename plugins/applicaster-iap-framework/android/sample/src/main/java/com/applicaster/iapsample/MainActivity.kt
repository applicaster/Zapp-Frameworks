package com.applicaster.iapsample

import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.SkuDetails
import com.applicaster.iap.BillingListener
import com.applicaster.iap.GoogleBillingHelper
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity(), BillingListener {

    private val TAG = MainActivity::class.java.simpleName

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        btn_purchase.setOnClickListener {
            GoogleBillingHelper.init(this, this)
            GoogleBillingHelper.loadSkuDetails(BillingClient.SkuType.INAPP, arrayListOf("android.test.purchased"))
            tv_result.text = "Starting purchase flow..."
        }
    }

    override fun onPurchaseLoaded(purchases: List<Purchase>) {
        if (purchases.isNotEmpty()) {
            GoogleBillingHelper.consume(purchases[0])
            tv_result.text = "Consumed. Purchase token: ${purchases[0].purchaseToken}"
        }
    }

    override fun onPurchaseLoadingFailed(statusCode: Int, description: String) {
        Log.e(TAG, "status code: $statusCode, description: $description")
        tv_result.text = "Error: $description"
    }

    override fun onPurchasesRestored(purchases: List<Purchase>) {
        TODO("Not yet implemented")
    }

    override fun onSkuDetailsLoaded(skuDetails: List<SkuDetails>) {
        GoogleBillingHelper.purchase(this, skuDetails[0])
    }

    override fun onSkuDetailsLoadingFailed(statusCode: Int, description: String) {
        Log.e(TAG, "status code: $statusCode, description: $description")
        tv_result.text = "Error: $description"
    }

    override fun onPurchaseConsumed(purchaseToken: String) {
        Log.i(TAG, "Purchase was consumed. Out token: $purchaseToken")
    }

    override fun onPurchaseConsumptionFailed(statusCode: Int, description: String) {
        Log.e(TAG, "status code: $statusCode, description: $description")
        tv_result.text = "Error: $description"
    }

    override fun onBillingClientError(statusCode: Int, description: String) {
        TODO("Not yet implemented")
    }

    override fun onPurchaseAcknowledgeFailed(statusCode: Int, description: String) {
        TODO("Not yet implemented")
    }

    override fun onPurchaseAcknowledged() {
        TODO("Not yet implemented")
    }
}
