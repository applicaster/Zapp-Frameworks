package com.applicaster.plugin.xray.remote

class LogBatch(val device_id: String,
               val entries: List<String>)

class LogPack(val log_batch: LogBatch)
