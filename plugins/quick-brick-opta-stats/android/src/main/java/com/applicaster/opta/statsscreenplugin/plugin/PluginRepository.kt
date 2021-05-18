package com.applicaster.opta.statsscreenplugin.plugin

import android.graphics.Color

interface PluginRepository {

    fun getToken(): String

    fun setToken(token: String)

    fun getReferer(): String

    fun setReferer(referer: String)

    fun getCompetitionId(): String

    fun setCompetitionId(tournamentId: String)

    fun getNumberOfMatches(): String

    fun setNumberOfMatches(numberOfMatches: String)

    fun getCalendarId(): String

    fun setCalendarId(calendarId: String)

    fun isShowTeam() : Boolean

    fun setShowTeam(showTeam: Any?)

    fun getLogoUrl() : String

    fun setLogoUrl(logoUrl: String)

    fun getBackButtonUrl() : String

    fun setBackButtonUrl(backButtonUrl: String)

    fun getShieldImageBaseUrl(): String

    fun setShieldImageBaseUrl(url: String)

    fun getFlagImageBaseUrl(): String

    fun setFlagImageBaseUrl(url: String)

    fun getPersonImageBaseUrl(): String

    fun setPersonImageBaseUrl(url: String)

    fun getShirtImageBaseUrl(): String

    fun setShirtImageBaseUrl(url: String)

    fun getPartidosImageBaseUrl(): String

    fun setPartidosImageBaseUrl(url: String)

    fun setAppId(appId: String?)

    fun getAppId() : String

    fun getTeamsCount(): Int

    fun setTeamsCount(count: Int?)

    fun enablePlayerScreen(enabled: Boolean)

    fun isPlayerScreenEnabled(): Boolean

    fun setNavBarColor(colorHEX: Int)

    fun getNavBarColor() : Int
}