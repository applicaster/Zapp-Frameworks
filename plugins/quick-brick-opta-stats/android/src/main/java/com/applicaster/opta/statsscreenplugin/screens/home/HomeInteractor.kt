package com.applicaster.opta.statsscreenplugin.screens.home

import android.util.Log
import com.applicaster.opta.statsscreenplugin.data.model.AllMatchesModel
import com.applicaster.opta.statsscreenplugin.data.model.GroupModel
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.screens.base.Interactor
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import retrofit2.Response

class HomeInteractor : Interactor() {

    companion object {
        private val TAG: String = "CopaHomeInteractor"
    }

    interface OnFinishedListener {
        fun onGetGroupsSuccess(groupCards: GroupModel.Group)
        fun onGetGroupsFail(error: String?)

        fun onAllMatchesSuccess(allMatchesFromDate: AllMatchesModel.AllMatches)
    }

    fun requestGroupCards(onFinishedListener: OnFinishedListener) {
        disposable = copaAmericaApiService.getGroupCards(PluginDataRepository.INSTANCE.getToken(), referer,
                "c", "json", calendarId, ModelUtils.getLocalization())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(fun(result: Response<GroupModel.Group>) {
                    val body = result.body()
                    Log.d(TAG, "getGroupCards ${result.headers()}")
                    body?.apply { onFinishedListener.onGetGroupsSuccess(body) }
                },
                        { error -> onFinishedListener.onGetGroupsFail(error.message) }
                )
    }

    fun requestAllMatches(onFinishedListener: OnFinishedListener) {
        disposable = copaAmericaApiService.getAllMatches(PluginDataRepository.INSTANCE.getToken(), referer,
                "c", "json", calendarId, ModelUtils.getLocalization())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        { result -> onFinishedListener.onAllMatchesSuccess(result) },
                        { error -> onFinishedListener.onGetGroupsFail(error.message) }
                )
    }

    fun onDestroy() {
        disposable?.dispose()
    }
}