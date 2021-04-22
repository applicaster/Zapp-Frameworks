package com.applicaster.opta.statsscreenplugin.screens.career

import com.applicaster.opta.statsscreenplugin.data.model.PlayerCareerModel
import com.applicaster.opta.statsscreenplugin.screens.base.View

interface PlayerCareerView : View {
    fun getPlayerCareerSuccess(playerCareer: PlayerCareerModel.PlayerCareer)
    fun getPlayerCareerFail(error: String?)
}