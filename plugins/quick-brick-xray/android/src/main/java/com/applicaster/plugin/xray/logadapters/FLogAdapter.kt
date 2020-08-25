package com.applicaster.plugin.xray.logadapters

import android.util.Log
import com.applicaster.xray.core.Logger
import com.facebook.common.logging.LoggingDelegate

class FLogAdapter : LoggingDelegate {

    private val logger = Logger.get("ReactNative")

    private var level = Log.DEBUG // log at debug level since we have our own filters

    override fun wtf(tag: String?, msg: String?) {
        this.logger.e(tag!!).message(msg!!)
    }

    override fun wtf(tag: String?, msg: String?, tr: Throwable?) {
        this.logger.e(tag!!).exception(tr!!).message(msg!!)
    }

    override fun getMinimumLoggingLevel(): Int = level

    override fun w(tag: String?, msg: String?) {
        this.logger.w(tag!!).message(msg!!)
    }

    override fun w(tag: String?, msg: String?, tr: Throwable?) {
        this.logger.w(tag!!).exception(tr!!).message(msg!!)
    }

    override fun v(tag: String?, msg: String?) {
        this.logger.v(tag!!).message(msg!!)
    }

    override fun v(tag: String?, msg: String?, tr: Throwable?) {
        this.logger.v(tag!!).exception(tr!!).message(msg!!)
    }

    override fun log(priority: Int, tag: String?, msg: String?) {
        this.logger.e(tag!!).message(msg!!)
    }

    override fun setMinimumLoggingLevel(level: Int) {
        this.level = level
    }

    override fun isLoggable(level: Int): Boolean {
        return this.level >= level
    }

    override fun i(tag: String?, msg: String?) {
        this.logger.i(tag!!).message(msg!!)
    }

    override fun i(tag: String?, msg: String?, tr: Throwable?) {
        this.logger.i(tag!!).exception(tr!!).message(msg!!)
    }

    override fun e(tag: String?, msg: String?) {
        this.logger.e(tag!!).message(msg!!)
    }

    override fun e(tag: String?, msg: String?, tr: Throwable?) {
        this.logger.e(tag!!).exception(tr!!).message(msg!!)
    }

    override fun d(tag: String?, msg: String?) {
        this.logger.d(tag!!).message(msg!!)
    }

    override fun d(tag: String?, msg: String?, tr: Throwable?) {
        this.logger.d(tag!!).exception(tr!!).message(msg!!)
    }

}
