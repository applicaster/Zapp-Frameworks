package com.applicaster.plugin.xray.logadapters

import com.applicaster.util.logging.IAPLogger
import com.applicaster.xray.core.Logger

class APLoggerAdapter : IAPLogger {

    private val logger = Logger.get("ApplicasterSDK")

    override fun verbose(tag: String, msg: String) = logger.v(tag).message(msg)

    override fun debug(tag: String, msg: String) = logger.d(tag).message(msg)

    override fun info(tag: String, msg: String) = logger.i(tag).message(msg)

    override fun warn(tag: String, msg: String) = logger.w(tag).message(msg)

    override fun error(tag: String, msg: String) = logger.e(tag).message(msg)

    override fun error(tag: String, msg: String, t: Throwable) =
            logger.e(tag).exception(t).message(msg)
}