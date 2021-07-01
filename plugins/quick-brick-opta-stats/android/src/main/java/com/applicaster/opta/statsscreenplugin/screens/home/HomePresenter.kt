package com.applicaster.opta.statsscreenplugin.screens.home

import com.applicaster.opta.statsscreenplugin.data.model.AllMatchesModel
import com.applicaster.opta.statsscreenplugin.data.model.GroupModel

class HomePresenter(private var homeView: HomeView?,
                    private val homeInteractor: HomeInteractor):
        HomeInteractor.OnFinishedListener {

    fun getGroups() {
        homeView?.showProgress()
        homeInteractor.requestGroupCards(this)
    }

    fun getAllMatchesFromDate() {
        homeView?.showProgress()
        homeInteractor.requestAllMatches(this)
    }

    fun onDestroy() {
        homeView = null
        homeInteractor.onDestroy()
    }

    override fun onGetGroupsSuccess(groupCards: GroupModel.Group) {
        homeView?.hideProgress()
        homeView?.getGroupsSuccess(groupCards)
    }

    override fun onAllMatchesSuccess(allMatchesFromDate: AllMatchesModel.AllMatches) {
        homeView?.hideProgress()
        homeView?.getAllMatchesSuccess(allMatchesFromDate)
    }

    override fun onGetGroupsFail(error: String?) {
        homeView?.hideProgress()
        homeView?.getGroupsFail(error)
    }

}