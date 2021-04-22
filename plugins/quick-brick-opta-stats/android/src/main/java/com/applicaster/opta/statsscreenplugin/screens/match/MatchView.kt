package com.applicaster.opta.statsscreenplugin.screens.match

import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.screens.base.View

interface MatchView : View {
    fun getMatchSuccess(matches: MatchModel.Match)
    fun getMatchFailed(error: String?)
}