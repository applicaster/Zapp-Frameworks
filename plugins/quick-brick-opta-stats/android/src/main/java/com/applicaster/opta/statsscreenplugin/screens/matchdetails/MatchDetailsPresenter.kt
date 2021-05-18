package com.applicaster.opta.statsscreenplugin.screens.matchdetails

import com.applicaster.opta.statsscreenplugin.data.model.MatchModel

class MatchDetailsPresenter(private var matchDetailsView: MatchDetailsView?,
                            private val matchDetailsInteractor: MatchDetailsInteractor) :
        MatchDetailsInteractor.OnFinishedListener {

    fun getMatchDetails(matchId: String) {
        matchDetailsView?.showProgress()
        matchDetailsInteractor.requestMatchDetails(this, matchId)
    }

    fun onDestroy() {
        matchDetailsView = null
        matchDetailsInteractor.onDestroy()
    }

    override fun onResultSuccess(matchDetails: MatchModel.Match) {
        matchDetailsView?.hideProgress()
        matchDetailsView?.getMatchDetailsSuccess(matchDetails)
    }

    override fun onResultFail(error: String?) {
        matchDetailsView?.hideProgress()
        matchDetailsView?.getMatchDetailsFail(error)
    }

}