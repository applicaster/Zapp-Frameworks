package com.applicaster.opta.statsscreenplugin.data.model

import java.util.*

object GroupModel {
    data class Group(val sport: Sport, val ruleset: Ruleset, val competition: Competition,
                     val tournamentCalendar: TournamentCalendar, val stage: List<Stage>,
                     val lastUpdated: Date)

    data class Sport(val id: String, val name: String)

    data class Ruleset(val id: String, val name: String)

    data class Competition(val id: String, val name: String)

    data class TournamentCalendar(val id: String, val startDate: String, val endDate: String,
                                  val name: String)

    data class Stage(val id: String, val formatId: String, val name: String, val vertical: Int,
                     val startDate: Date, val endDate: Date, val division: List<Division>)

    data class Division(val type: String, val groupId: String, val groupName: String,
                        val horizontal: Int, val ranking: List<Ranking>)

    data class Ranking(val rank: Int, val contestantId: String, val contestantName: String,
                       val contestantShortName: String, val contestantClubName: String,
                       val contestantCode: String, val points: Int, val matchesPlayed: Int,
                       val matchesWon: Int, val matchesLost: Int, val matchesDrawn: Int,
                       val goalsFor: Int, val goalsAgainst: Int, val goaldifference: String)
}