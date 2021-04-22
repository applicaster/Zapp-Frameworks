package com.applicaster.opta.statsscreenplugin.screens.match

import android.util.Log
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.screens.base.Interactor
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import retrofit2.Response

class MatchInteractor : Interactor() {
    companion object {
        private val TAG: String = MatchInteractor::class.java.simpleName
    }

    interface OnFinishedListener {
        fun onResultSuccess(matches: MatchModel.Match)
        fun onResultFail(error: String?)
    }

    fun requestMatches(onFinishedListener: OnFinishedListener, matchId: String) {
        disposable = copaAmericaApiService.getMatches(PluginDataRepository.INSTANCE.getToken(), referer,
                "c", "json", matchId, "yes", ModelUtils.getLocalization())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        fun(result: Response<MatchModel.Match>) {
                            val body = result.body()
                            Log.d(TAG, "getMatches ${result.headers()}")
                            body?.apply { onFinishedListener.onResultSuccess(body) }
                        },
                        { error -> onFinishedListener.onResultFail(error.message) }
                )
    }

    fun onDestroy() {
        disposable?.dispose()
    }
}