package com.applicaster.opta.statsscreenplugin.screens.team

import android.util.Log
import com.applicaster.opta.statsscreenplugin.data.model.PlayerSquadModel
import com.applicaster.opta.statsscreenplugin.data.model.TeamModel
import com.applicaster.opta.statsscreenplugin.data.model.TrophiesModel
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.screens.base.Interactor
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import retrofit2.Response

class TeamInteractor : Interactor() {
    protected var extraDisposable1: Disposable? = null
    protected var extraDisposable2: Disposable? = null

    companion object {
        private val TAG = "TeamInteractor"
    }

    interface OnFinishedListener {
        fun onGetTeamStatsSuccess(team: TeamModel.Team)
        fun onGetTeamStatsFail(error: String?)
        fun onGetTeamSquadSuccess(teamSquad: PlayerSquadModel.PlayerSquad)
        fun onGetTeamSquadFail(error: String?)
        fun onGetTrophiesSuccess(trophies: TrophiesModel.Trophies)
        fun onGetTrophiesFailed(error: String?)
    }

    fun requestTeamStats(onFinishedListener: OnFinishedListener, teamId: String) {
        // right now is not possible to get data from opta of the Copa America 2019 so we are using
        // old calendar and contestant ids
        disposable = copaAmericaApiService.getTeamStats(PluginDataRepository.INSTANCE.getToken(), referer,
                "c", "json", calendarId, teamId, "yes", ModelUtils.getLocalization())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        fun(result: Response<TeamModel.Team>) {
                            val body = result.body()
                            Log.d(TAG, "getTeamStats ${result.headers()}")
                            body?.apply { onFinishedListener.onGetTeamStatsSuccess(body) }
                        },
                        { error -> onFinishedListener.onGetTeamStatsFail(error.message) }
                )
    }

    fun requestTeamSquad(onFinishedListener: OnFinishedListener, teamId: String) {
        extraDisposable1 = copaAmericaApiService.getSquads(PluginDataRepository.INSTANCE.getToken(), referer,
                "c", "json", calendarId, teamId, "yes", ModelUtils.getLocalization())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        fun(result: Response<PlayerSquadModel.PlayerSquad>) {
                            val body = result.body()
                            Log.d(TAG, "getSquads ${result.headers()}")
                            body?.apply { onFinishedListener.onGetTeamSquadSuccess(body) }
                        },
                        { error -> onFinishedListener.onGetTeamSquadFail(error.message) }
                )
    }

    fun requestTrophies(onFinishedListener: OnFinishedListener) {
        extraDisposable2 = copaAmericaApiService.getTrophies(PluginDataRepository.INSTANCE.getToken(), referer,
                PluginDataRepository.INSTANCE.getCompetitionId(), "json", "c",
                ModelUtils.getLocalization())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        { result -> onFinishedListener.onGetTrophiesSuccess(result) },
                        { error -> onFinishedListener.onGetTrophiesFailed(error.message) }
                )
    }

    fun onDestroy() {
        disposable?.dispose()
        extraDisposable1?.dispose()
        extraDisposable2?.dispose()
    }
}