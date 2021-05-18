package com.applicaster.opta.statsscreenplugin.screens.allmatches

import com.applicaster.opta.statsscreenplugin.data.model.AllMatchesWithDetailsModel
import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.plugin.PluginDataRepository
import com.applicaster.opta.statsscreenplugin.screens.base.Interactor
import com.applicaster.opta.statsscreenplugin.utils.ModelUtils
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers

class AllMatchesInteractor : Interactor() {
    interface OnFinishedListener {
        fun onResultSuccess(allMatches: List<MatchModel.Match>)
        fun onResultFail(error: String?)
    }

    // todo: urgent - for other tournaments that have more than 50 games this will not work
    fun requestAllMatches(onFinishedListener: OnFinishedListener) {
        disposable = copaAmericaApiService.getAllMatchesWithDetails(PluginDataRepository.INSTANCE.getToken(), referer,
                "c", "json", calendarId, "yes", "asc", "1", "50",
                ModelUtils.getLocalization())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        { result -> onFinishedListener.onResultSuccess(result.match) },
                        { error -> onFinishedListener.onResultFail(error.message) }
                )
    }

    fun onDestroy() {
        disposable?.dispose()
    }

    fun requestAllMatchesByTeamId(onFinishedListener: OnFinishedListener, teamId: String) {
        disposable = copaAmericaApiService.getAllMatchesWithDetails(PluginDataRepository.INSTANCE.getToken(), referer,
                "c", "json", calendarId, "yes", "asc", "1", "50",
                ModelUtils.getLocalization())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe(
                        { result ->
                            val anotherResult = getAllMatchesById(teamId, result)
                            onFinishedListener.onResultSuccess(anotherResult)
                        },
                        { error -> onFinishedListener.onResultFail(error.message) }
                )
    }


    private fun getAllMatchesById(teamId: String, result: AllMatchesWithDetailsModel.AllMatchesWithDetails?):
            List<MatchModel.Match> {
        val teamIdMatches: MutableList<MatchModel.Match> = ArrayList()
        result?.let {
            for(match in result.match) {
                match.matchInfo?.contestant?.let {
                    if(it[0].id   == teamId || it[1].id == teamId) {
                        teamIdMatches.add(match)
                    }
                }
            }
        }
        return teamIdMatches
    }
}
