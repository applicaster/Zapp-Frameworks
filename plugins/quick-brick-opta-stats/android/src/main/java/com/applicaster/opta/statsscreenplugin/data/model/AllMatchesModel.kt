package com.applicaster.opta.statsscreenplugin.data.model


object AllMatchesModel {
    data class AllMatches(
            val competition: Competition,
            val matchDate: List<MatchDate>,
            val tournamentCalendar: TournamentCalendar
    )

    data class Competition(
            val competitionCode: String,
            val competitionFormat: String,
            val id: String,
            val lastUpdated: String,
            val name: String
    )

    data class MatchDate(
            val date: String,
            val match: List<Match>,
            val numberOfGames: String
    )

    data class Match(
            val coverageLevel: String,
            val date: String,
            val id: String,
            val time: String
    )

    data class TournamentCalendar(
            val endDate: String,
            val id: String,
            val lastUpdated: String,
            val name: String,
            val startDate: String
    )
}
