package com.applicaster.iap.uni


import android.util.Log
import androidx.test.core.app.launchActivity
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.runner.AndroidJUnit4
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.SkuDetails
import com.applicaster.iap.BillingListener
import com.applicaster.iap.GoogleBillingHelper
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.Semaphore


/**
 * Instrumented test, which will execute on an Android device.
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
@RunWith(AndroidJUnit4::class)
class GooglePlayTest {

    @Test
    fun useAppContext() {

        class TestListener(private var message: String) : BillingListener {

            private var event:Semaphore? = null

            public var skus: List<SkuDetails>? = null
            public var purchases: List<Purchase>? = null

            fun waitForEvent() {
                event = Semaphore(1)
                event?.acquire()
            }

            fun waitForResult() {
                event?.acquire()
                event?.release()
                event = null
            }

            private fun onResult(result: String) {
                Log.d("GooglePlayTest", "$message: $result")
                event?.release()
            }

            override fun onPurchaseLoaded(purchases: List<Purchase>) {
                this.purchases = purchases
                onResult("onPurchaseLoaded: ${purchases.size}")
            }

            override fun onPurchaseLoadingFailed(statusCode: Int, description: String) {
                onResult("onPurchaseLoadingFailed: $statusCode $description")
            }

            override fun onPurchasesRestored(purchases: List<Purchase>) {
                this.purchases = purchases
                onResult("onPurchaseLoaded: ${purchases.size}")
            }

            override fun onSkuDetailsLoaded(skuDetails: List<SkuDetails>) {
                this.skus = skuDetails
                onResult("onPurchaseLoaded: ${skuDetails.size}")
            }

            override fun onSkuDetailsLoadingFailed(statusCode: Int, description: String) {
                onResult("onPurchaseLoadingFailed: $statusCode $description")
            }

            override fun onPurchaseConsumed(purchaseToken: String) {
                onResult("onPurchaseConsumed: $purchaseToken")
            }

            override fun onPurchaseConsumptionFailed(statusCode: Int, description: String) {
                onResult("onPurchaseConsumptionFailed: $statusCode $description")
            }

            override fun onBillingClientError(statusCode: Int, description: String) {
                onResult("onBillingClientError: $statusCode $description")
            }

            override fun onPurchaseAcknowledgeFailed(statusCode: Int, description: String) {
                onResult("onPurchaseAcknowledgeFailed: $statusCode $description")
            }

            override fun onPurchaseAcknowledged() {
                onResult("onPurchaseAcknowledged")
            }
        }

        val appContext = InstrumentationRegistry.getInstrumentation().targetContext
        assertEquals("Need specific package name","com.applicaster.inplayerdemo", appContext.packageName)

        val mainListener = TestListener("mainListener")
        GoogleBillingHelper.init(appContext, mainListener)

        // Load SKUs
        val skuLoaded = TestListener("loadSkuDetails")
        skuLoaded.waitForEvent()
        GoogleBillingHelper.loadSkuDetails(BillingClient.SkuType.INAPP, arrayListOf("73149_17806"), skuLoaded)
        skuLoaded.waitForResult()

        // Try to purchase something
        val scenario = launchActivity<TestActivity>()
        scenario.onActivity { activity ->
            mainListener.waitForEvent()
            GoogleBillingHelper.purchase(activity, skuLoaded.skus!!.get(0))
        }
        mainListener.waitForResult() // wait outside onActivity!
        scenario.close()
    }
}