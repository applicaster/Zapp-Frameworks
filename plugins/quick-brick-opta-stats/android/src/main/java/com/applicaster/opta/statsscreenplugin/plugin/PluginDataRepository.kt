package com.applicaster.opta.statsscreenplugin.plugin

import com.applicaster.opta.statsscreenplugin.R
import com.applicaster.opta.statsscreenplugin.utils.Constants.DEFAULT_BACK_BUTTON_URL
import com.applicaster.opta.statsscreenplugin.utils.Constants.DEFAULT_LOGO_URL
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_APP_ID
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_BACK_BUTTON_URL
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_CALENDAR_ID
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_COMPETITION_ID
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_ENABLE_PLAYER_SCREEN
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_FLAG_IMAGE_BASE_URL
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_LOGO_URL
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_NAV_BAR_COLOR
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_NUMBER_OF_MATCHES
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_PARTIDOS_IMAGE_BASE_URL
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_PERSON_IMAGE_BASE_URL
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_REFERER
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_SHIELD_IMAGE_BASE_URL
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_SHIRT_IMAGE_BASE_URL
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_SHOW_TEAM
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_TEAMS_COUNT
import com.applicaster.opta.statsscreenplugin.utils.Constants.PARAM_TOKEN
import com.applicaster.util.AppContext
import com.applicaster.util.PreferenceUtil

enum class PluginDataRepository : PluginRepository {
    INSTANCE;

    override fun getToken(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_TOKEN, null)
    }

    override fun setToken(token: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_TOKEN, token)
    }

    override fun getReferer(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_REFERER, null)
    }

    override fun setReferer(referer: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_REFERER, referer)
    }

    override fun getCompetitionId(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_COMPETITION_ID, null)
    }

    override fun setCompetitionId(tournamentId: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_COMPETITION_ID, tournamentId)
    }

    override fun getCalendarId(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_CALENDAR_ID, null)
    }

    override fun setCalendarId(calendarId: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_CALENDAR_ID, calendarId)
    }

    override fun isShowTeam(): Boolean {
        return PreferenceUtil.getInstance().getBooleanPref(PARAM_SHOW_TEAM, false)
    }

    override fun setShowTeam(showTeam: Any?) {
        val showTeamBoolean = showTeam ?: "0"
        PreferenceUtil.getInstance().setBooleanPref(PARAM_SHOW_TEAM, (showTeamBoolean == "1" || showTeamBoolean == true))
    }

    override fun getNumberOfMatches(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_NUMBER_OF_MATCHES, "3")
    }

    override fun setNumberOfMatches(numberOfMatches: String) {
        if (numberOfMatches.equals("null", true) || numberOfMatches.isEmpty()) {
            PreferenceUtil.getInstance().setStringPref(PARAM_NUMBER_OF_MATCHES, "3")
        } else {
            PreferenceUtil.getInstance().setStringPref(PARAM_NUMBER_OF_MATCHES, numberOfMatches)
        }
    }

    override fun getLogoUrl(): String {
        // todo: implement fallback
        return PreferenceUtil.getInstance().getStringPref(PARAM_LOGO_URL, DEFAULT_LOGO_URL)
    }

    override fun setLogoUrl(logoUrl: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_LOGO_URL, logoUrl)
    }

    override fun getBackButtonUrl(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_BACK_BUTTON_URL, DEFAULT_BACK_BUTTON_URL)
    }

    override fun setBackButtonUrl(backButtonUrl: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_BACK_BUTTON_URL, backButtonUrl)
    }

    override fun setAppId(appId: String?) {
        appId?.let { PreferenceUtil.getInstance().setStringPref(PARAM_APP_ID, it) }
    }

    override fun getAppId(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_APP_ID, "")
    }

    override fun getShieldImageBaseUrl(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_SHIELD_IMAGE_BASE_URL, null)
    }

    override fun setShieldImageBaseUrl(url: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_SHIELD_IMAGE_BASE_URL, url)
    }

    override fun getFlagImageBaseUrl(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_FLAG_IMAGE_BASE_URL, null)
    }

    override fun setFlagImageBaseUrl(url: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_FLAG_IMAGE_BASE_URL, url)
    }

    override fun getPersonImageBaseUrl(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_PERSON_IMAGE_BASE_URL, null)
    }

    override fun setPersonImageBaseUrl(url: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_PERSON_IMAGE_BASE_URL, url)
    }

    override fun getShirtImageBaseUrl(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_SHIRT_IMAGE_BASE_URL, null)
    }

    override fun setShirtImageBaseUrl(url: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_SHIRT_IMAGE_BASE_URL, url)
    }

    override fun getPartidosImageBaseUrl(): String {
        return PreferenceUtil.getInstance().getStringPref(PARAM_PARTIDOS_IMAGE_BASE_URL, null)
    }

    override fun setPartidosImageBaseUrl(url: String) {
        PreferenceUtil.getInstance().setStringPref(PARAM_PARTIDOS_IMAGE_BASE_URL, url)
    }

    override fun getTeamsCount(): Int {
        return PreferenceUtil.getInstance().getIntPref(PARAM_TEAMS_COUNT, 10)
    }

    override fun setTeamsCount(count: Int?) {
        count?.let { PreferenceUtil.getInstance().setIntPref(PARAM_TEAMS_COUNT, if (it < 4) 4 else it) }
    }

    override fun enablePlayerScreen(enabled: Boolean) {
        PreferenceUtil.getInstance().setBooleanPref(PARAM_ENABLE_PLAYER_SCREEN, enabled)
    }

    override fun isPlayerScreenEnabled(): Boolean {
        return PreferenceUtil.getInstance().getBooleanPref(PARAM_ENABLE_PLAYER_SCREEN, false)
    }

    override fun setNavBarColor(colorHEX: Int) {
        PreferenceUtil.getInstance().setIntPref(PARAM_NAV_BAR_COLOR, colorHEX)
    }

    override fun getNavBarColor(): Int {
        return PreferenceUtil.getInstance().getIntPref(
                PARAM_NAV_BAR_COLOR,
                AppContext.get().resources.getColor(R.color.bg_toolbar))
    }
}