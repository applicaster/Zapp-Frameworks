package com.applicaster.opta.statsscreenplugin.data.model

object TrophiesModel {
    data class Trophies(
            val competition: List<Competition>,
            val lastUpdated: String
    )
    data class Competition(
            val competitionFormat: String,
            val id: String,
            val name: String,
            val trophy: List<Trophy>,
            val type: String
    )
    data class Trophy(
            val runnerUpContestantCountry: String,
            val runnerUpContestantCountryId: String,
            val runnerUpContestantId: String,
            val runnerUpContestantName: String,
            val tournamentCalendarEndDate: String,
            val tournamentCalendarId: String,
            val tournamentCalendarName: String,
            val tournamentCalendarStartDate: String,
            val winnerContestantCountry: String,
            val winnerContestantCountryId: String,
            val winnerContestantId: String,
            val winnerContestantName: String
    )
}
