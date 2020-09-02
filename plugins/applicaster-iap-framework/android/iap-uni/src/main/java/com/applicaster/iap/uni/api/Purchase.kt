package com.applicaster.iap.uni.api

data class Purchase(
    val productIdentifier: String,
    val transactionIdentifier: String,
    val receipt: String
)
