package com.applicaster.iap.uni


import android.content.Context
import android.util.Log
import androidx.test.core.app.launchActivity
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.runner.AndroidJUnit4
import com.applicaster.iap.uni.api.*
import org.junit.Assert.*
import org.junit.Test
import org.junit.runner.RunWith
import java.util.concurrent.Semaphore


/**
 * Not really an automatic unit test, but more like test bench
 * For Amazon, follow https://developer.amazon.com/docs/in-app-purchasing/iap-install-and-configure-app-tester.html
 * For Google, create test user for application with application Id been tested
 */
@RunWith(AndroidJUnit4::class)
class UnifiedApiTest {

    class TestListener(private var message: String) : IAPListener {

        private var event: Semaphore? = null

        var skus: List<Sku>? = null
        var purchases: List<Purchase>? = null
        var lastError: IBillingAPI.IAPResult? = null

        fun waitForEvent() {
            lastError = null
            event = Semaphore(1)
            event?.acquire()
        }

        fun waitForResult() {
            event?.acquire()
            event?.release()
            event = null
        }

        private fun onResult(result: String) {
            Log.d("UnifiedAPITest", "$message: $result")
            event?.release()
        }

        override fun onPurchasesRestored(purchases: List<Purchase>) {
            this.purchases = purchases
            lastError = null
            onResult("onPurchasesRestored: ${purchases.size}")
        }

        override fun onSkuDetailsLoaded(skuDetails: List<Sku>) {
            this.skus = skuDetails
            lastError = null
            onResult("onSkuDetailsLoaded: ${skuDetails.size}")
        }

        override fun onSkuDetailsLoadingFailed(
            result: IBillingAPI.IAPResult,
            description: String
        ) {
            lastError = result
            onResult("onSkuDetailsLoadingFailed: $result $description")
        }

        override fun onPurchased(purchase: Purchase) {
            lastError = null
            this.purchases = listOf(purchase)
            onResult("onPurchased: ${purchase.productIdentifier}")
        }

        override fun onPurchaseFailed(result: IBillingAPI.IAPResult, description: String) {
            lastError = result
            onResult("onPurchaseFailed: $result $description")
        }

        override fun onPurchaseRestoreFailed(
            result: IBillingAPI.IAPResult,
            description: String
        ) {
            lastError = result
            onResult("onPurchaseRestoreFailed: $result $description")
        }

        override fun onPurchaseConsumed(purchaseToken: String) {
            lastError = null
            onResult("onPurchaseConsumed: $purchaseToken")
        }

        override fun onPurchaseConsumptionFailed(
            result: IBillingAPI.IAPResult,
            description: String
        ) {
            lastError = result
            onResult("onPurchaseConsumptionFailed: $result $description")
        }

        override fun onPurchaseAcknowledgeFailed(
            result: IBillingAPI.IAPResult,
            description: String
        ) {
            lastError = result
            onResult("onPurchaseAcknowledgeFailed: $result $description")
        }

        override fun onPurchaseAcknowledged() {
            lastError = null
            onResult("onPurchaseAcknowledged")
        }

        override fun onBillingClientError(result: IBillingAPI.IAPResult, description: String) {
            lastError = result
            onResult("onBillingClientError: $result $description")
        }
    }

    @Test
    fun useAppContext() {
        val appContext = InstrumentationRegistry.getInstrumentation().targetContext
        assertEquals("Need specific package name","com.applicaster.inplayerdemo", appContext.packageName)

        testApi(IBillingAPI.Vendor.amazon, appContext, IBillingAPI.SkuType.subscription, "72348_17073")
        testApi(IBillingAPI.Vendor.play, appContext, IBillingAPI.SkuType.subscription,"72348_17073")
    }

    private fun testApi(
        vendor: IBillingAPI.Vendor,
        appContext: Context,
        skuType: IBillingAPI.SkuType,
        sku: String
    ) {
        val api = IBillingAPI.create(vendor)
        // Initiate the API
        api.init(appContext)

        // Load SKUs
        val skuLoaded = TestListener("loadSkuDetails")
        skuLoaded.waitForEvent()
        api.loadSkuDetails(skuType, arrayListOf(sku), skuLoaded)
        skuLoaded.waitForResult()

        assertNotNull(skuLoaded.skus)
        assertEquals(1, skuLoaded.skus!!.size)
        val skuDetails = skuLoaded.skus!![0]

        // Restore purchases
        val restoreListener = TestListener("restoreListener")
        restoreListener.waitForEvent()
        api.restorePurchasesForAllTypes(restoreListener)
        restoreListener.waitForResult()

        val alreadyOwned = restoreListener.purchases?.find { it.productIdentifier == sku }

        val allowConsume = true
        if(null != alreadyOwned && IBillingAPI.SkuType.consumable == skuType && allowConsume) {
            val consumeListener = TestListener("consumeListener")
            consumeListener.waitForEvent()
            api.consume(alreadyOwned.transactionIdentifier, consumeListener)
            consumeListener.waitForResult()
        }
        else {
            assertNull("No previous purchase active", alreadyOwned)
        }

        // Try to purchase something
        val scenario = launchActivity<TestActivity>()
        val purchaseListener = TestListener("purchaseListener")
        scenario.onActivity { activity ->
            purchaseListener.waitForEvent()
            api.purchase(
                activity,
                PurchaseRequest(skuDetails.productIdentifier),
                purchaseListener
            )
        }
        purchaseListener.waitForResult() // wait outside onActivity!
        scenario.close()
        assertNotNull(purchaseListener.purchases)
        assertEquals(1, purchaseListener.purchases!!.size)

        // Acknowledge the purchase
        val acknowledge = TestListener("acknowledge")
        acknowledge.waitForEvent()
        api.acknowledge(purchaseListener.purchases!![0].transactionIdentifier, acknowledge)
        acknowledge.waitForResult()
    }
}
