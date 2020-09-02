package com.applicaster.iap.uni.play;

import com.android.billingclient.api.BillingClient;
import com.applicaster.iap.uni.api.IBillingAPI;

public class Mappers {
    public static IBillingAPI.IAPResult mapStatus(int statusCode) {
        if (BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED == statusCode)
            return IBillingAPI.IAPResult.alreadyOwned;
        return IBillingAPI.IAPResult.generalError;
    }

}
