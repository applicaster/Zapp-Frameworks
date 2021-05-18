package com.applicaster.opta.statsscreenplugin.screens.career

import com.applicaster.opta.statsscreenplugin.data.model.PlayerCareerModel
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.screens.base.Interactor
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class PlayerCareerInteractor : Interactor() {
    companion object {
        private val TAG: String = PlayerCareerInteractor::class.java.simpleName
    }

    interface OnFinishedListener {
        fun onResultSuccess(playerCareer: PlayerCareerModel.PlayerCareer)
        fun onResultFail(error: String?)
    }

    fun requestPlayerCareer(onFinishedListener: OnFinishedListener, personId: String) {
        disposable = copaAmericaApiService.getPlayerCareer(PluginDataRepository.INSTANCE.getToken(), referer,
                "c", "json", personId, ModelUtils.getLocalization())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        { result -> onFinishedListener.onResultSuccess(result) },
                        { error -> onFinishedListener.onResultFail(error.message) }
                )
    }

    fun onDestroy() {
        disposable?.dispose()
    }
}