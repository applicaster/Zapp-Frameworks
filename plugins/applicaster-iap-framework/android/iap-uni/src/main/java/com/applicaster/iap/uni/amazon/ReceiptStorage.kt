package com.applicaster.iap.uni.amazon

import android.content.Context
import com.amazon.device.iap.model.Receipt
import com.applicaster.iap.uni.api.Purchase
import org.json.JSONObject

private fun fromJSON(json: JSONObject): Purchase {
    return Purchase(
            json.getString("productIdentifier"),
            json.getString("transactionIdentifier"),
            json.getString("receipt"),
            json.getString("userId"))
}

private fun Purchase.toJSON(): String {
    return  JSONObject().let {
        it.put("productIdentifier", this.productIdentifier)
        it.put("transactionIdentifier", this.transactionIdentifier)
        it.put("receipt", this.receipt)
        it.put("userId", this.userId)
    }.toString()
}

private const val sPreferencesName = "amazon.purchases"

class ReceiptStorage(context: Context) {

    private val store = context.getSharedPreferences(sPreferencesName, 0)

    fun hasPurchases(): Boolean = store.all.isNotEmpty()

    fun update(receipts: List<Receipt>, userId: String?) {
        val edit = store.edit()
        for (r in receipts) {
            if(null != r.cancelDate) {
                // its expired or cancelled subscription
                edit.remove(r.sku)
            }
            else {
                // Receipt only has toJSON, but not from, so we use our own Purchase class
                val purchase = Purchase(
                        r.sku,
                        r.receiptId,
                        r.toJSON().toString(),
                        userId)
                edit.putString(r.sku, purchase.toJSON())
            }
        }
        edit.apply()
    }

    fun getPurchase(sku: String) : Purchase? {
        val json = store.getString(sku, null) ?: return null
        val jsonObject = JSONObject(json)
        return fromJSON(jsonObject)
    }

    // called if purchases are about to be restored from scratch
    fun reset() {
        store.edit().clear().apply()
    }

    fun getPurchases(): List<Purchase> {
        // todo: add a cache probably
        return store.all.values
                .map { fromJSON(JSONObject(it as String)) }
                .toList()
    }
}

