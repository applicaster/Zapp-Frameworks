package com.applicaster.opta.statsscreenplugin.screens.home

import com.applicaster.opta.statsscreenplugin.data.model.AllMatchesModel
import com.applicaster.opta.statsscreenplugin.data.model.GroupModel
import com.applicaster.opta.statsscreenplugin.screens.base.View

interface HomeView : View {
    fun getGroupsSuccess(groupCards: GroupModel.Group)
    fun getGroupsFail(error: String?)
    fun getAllMatchesFromDateSuccess(allMatchesFromDate: AllMatchesModel.AllMatches)
}