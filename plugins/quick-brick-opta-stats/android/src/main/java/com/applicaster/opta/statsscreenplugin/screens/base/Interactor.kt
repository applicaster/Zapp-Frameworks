package com.applicaster.opta.statsscreenplugin.screens.base

import com.applicaster.opta.statsscreenplugin.data.api.OptaApiService
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import io.reactivex.disposables.Disposable

open class Interactor {
    protected var disposable: Disposable? = null

    protected var referer = PluginDataRepository.INSTANCE.getReferer()
    protected var calendarId = PluginDataRepository.INSTANCE.getCalendarId()

    protected val copaAmericaApiService by lazy {
        OptaApiService.create()
    }
}