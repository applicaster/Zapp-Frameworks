package com.applicaster.plugin.xray.remote

data class LogBatch(
        val device_id: String,
        val entries: List<String>
)

data class LogPack(val log_batch: LogBatch)
