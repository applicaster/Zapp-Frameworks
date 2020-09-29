package com.applicaster.iap.uni.api

interface InitializationListener {
    fun onSuccess()
    fun onBillingClientError(result: IBillingAPI.IAPResult, description: String)
}