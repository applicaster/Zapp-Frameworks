package com.applicaster.opta.statsscreenplugin.screens.allmatches

import com.applicaster.opta.statsscreenplugin.data.model.MatchModel

class AllMatchesPresenter(private var allMatchesView: AllMatchesView?,
                          private val allMatchesInteractor: AllMatchesInteractor) :
        AllMatchesInteractor.OnFinishedListener {
    override fun onResultSuccess(allMatches: List<MatchModel.Match>) {
        allMatchesView?.hideProgress()
        allMatchesView?.getAllMatchesSuccess(allMatches)
    }

    fun getAllMatches() {
        allMatchesView?.showProgress()
        allMatchesInteractor.requestAllMatches(this)
    }

    fun onDestroy() {
        allMatchesView = null
        allMatchesInteractor.onDestroy()
    }

    override fun onResultFail(error: String?) {
        allMatchesView?.hideProgress()
        allMatchesView?.getAllMatchesFail(error)
    }

    fun getAllMatchesById(teamId: String) {
        allMatchesInteractor.requestAllMatchesByTeamId(this, teamId)
    }
}
