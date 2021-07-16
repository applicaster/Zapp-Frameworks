package com.applicaster.plugin.xray.logadapters

import com.applicaster.util.logging.IAPLogger
import com.applicaster.xray.core.Logger

class APLoggerAdapter : IAPLogger {

    // todo: make Logger.makeBuilder public (or add new method event(String tag, LogLevel level))
    private val logger = Logger.get("ApplicasterSDK")

    override fun verbose(tag: String, msg: String) = logger.v(tag).message(msg)

    override fun verbose(tag: String, msg: String, data: Map<String, Any>?) = when (data) {
        null -> verbose(tag, msg)
        else -> logger.v(tag).putData(data).message(msg)
    }

    override fun debug(tag: String, msg: String) = logger.d(tag).message(msg)

    override fun debug(tag: String, msg: String, data: Map<String, Any>?) = when (data) {
        null -> debug(tag, msg)
        else -> logger.d(tag).putData(data).message(msg)
    }

    override fun info(tag: String, msg: String) = logger.i(tag).message(msg)

    override fun info(tag: String, msg: String, data: Map<String, Any>?) = when (data) {
        null -> info(tag, msg)
        else -> logger.i(tag).putData(data).message(msg)
    }

    override fun warn(tag: String, msg: String) = logger.w(tag).message(msg)

    override fun warn(tag: String, msg: String, data: Map<String, Any>?) = when (data) {
        null -> warn(tag, msg)
        else -> logger.w(tag).putData(data).message(msg)
    }

    override fun error(tag: String, msg: String) = logger.e(tag).message(msg)

    override fun error(tag: String, msg: String, t: Throwable?) = when (t) {
        null -> error(tag, msg)
        else -> logger.e(tag).exception(t).message(msg)
    }

    override fun error(tag: String, msg: String, data: Map<String, Any>?) = when (data) {
        null -> error(tag, msg)
        else -> logger.e(tag).putData(data).message(msg)
    }

    override fun error(tag: String, msg: String, t: Throwable?, data: Map<String, Any>?) =
            when (data) {
                null -> error(tag, msg, t)
                else -> when (t) {
                    null -> error(tag, msg)
                    else -> logger.e(tag).exception(t).message(msg)
                }
            }
}