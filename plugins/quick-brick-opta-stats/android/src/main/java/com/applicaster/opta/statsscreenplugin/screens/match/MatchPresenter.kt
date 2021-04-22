package com.applicaster.opta.statsscreenplugin.screens.match

import com.applicaster.opta.statsscreenplugin.data.model.MatchModel

class MatchPresenter(private var matchView: MatchView?,
                     private val matchInteractor: MatchInteractor):
        MatchInteractor.OnFinishedListener {

    fun getMatchDetails(matchId: String) {
        matchView?.hideProgress()
        matchInteractor.requestMatches(this, matchId)
    }

    fun onDestroy() {
        matchView = null
        matchInteractor.onDestroy()
    }

    override fun onResultSuccess(matches: MatchModel.Match) {
        matchView?.hideProgress()
        matchView?.getMatchSuccess(matches)
    }

    override fun onResultFail(error: String?) {
        matchView?.hideProgress()
        matchView?.getMatchFailed(error)
    }

}