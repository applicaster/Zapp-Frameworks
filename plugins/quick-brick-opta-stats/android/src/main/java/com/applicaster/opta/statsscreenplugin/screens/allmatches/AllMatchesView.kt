package com.applicaster.opta.statsscreenplugin.screens.allmatches

import com.applicaster.opta.statsscreenplugin.data.model.MatchModel
import com.applicaster.opta.statsscreenplugin.screens.base.View

interface AllMatchesView : View {
    fun getAllMatchesSuccess(allMatches: List<MatchModel.Match>)
    fun getAllMatchesFail(error: String?)
}
