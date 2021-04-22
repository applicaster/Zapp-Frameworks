package com.applicaster.opta.statsscreenplugin.data.model

object MatchDetailsModel {
    data class FullMatchDetails(
            val liveData: LiveData,
            val matchInfo: MatchInfo
    )

    data class Aggregate(
            val away: Int,
            val home: Int
    )

    data class Card(
            val contestantId: String,
            val lastUpdated: String,
            val optaEventId: String,
            val periodId: Int,
            val playerId: String,
            val playerName: String,
            val timeMin: Int,
            val timeMinSec: String,
            val type: String
    )

    data class Competition(
            val competitionCode: String,
            val competitionFormat: String,
            val country: Country,
            val id: String,
            val name: String
    )

    data class Contestant(
            val code: String,
            val country: Country,
            val id: String,
            val name: String,
            val officialName: String,
            val position: String,
            val shortName: String
    )

    data class Country(
            val id: String,
            val name: String
    )

    data class Ft(
            val away: Int,
            val home: Int
    )

    data class Goal(
            val awayScore: Int,
            val contestantId: String,
            val homeScore: Int,
            val lastUpdated: String,
            val optaEventId: String,
            val periodId: Int,
            val scorerId: String,
            val scorerName: String,
            val timeMin: Int,
            val timeMinSec: String,
            val type: String
    )

    data class Ht(
            val away: Int,
            val home: Int
    )

    data class Kit(
            val colour1: String,
            val id: String,
            val type: String
    )

    data class LineUp(
            val contestantId: String,
            val kit: Kit,
            val player: List<Player>,
            val stat: List<Stat>,
            val teamOfficial: TeamOfficial
    )

    data class LiveData(
            val card: List<Card>,
            val goal: List<Goal>,
            val lineUp: List<LineUp>,
            val matchDetails: MatchDetails,
            val matchDetailsExtra: MatchDetailsExtra,
            val substitute: List<Substitute>
    )

    data class MatchDetails(
            val matchLengthMin: Int,
            val matchLengthSec: Int,
            val matchStatus: String,
            val period: List<Period>,
            val periodId: Int,
            val relatedMatchId: String,
            val scores: Scores,
            val winner: String
    )


    data class MatchDetailsExtra(
            val attendance: String,
            val matchOfficial: List<MatchOfficial>
    )


    data class MatchInfo(
            val competition: Competition,
            val contestant: List<Contestant>,
            val date: String,
            val description: String,
            val id: String,
            val lastUpdated: String,
            val ruleset: Ruleset,
            val sport: Sport,
            val stage: Stage,
            val time: String,
            val tournamentCalendar: TournamentCalendar,
            val venue: Venue
    )

    data class MatchOfficial(
            val firstName: String,
            val id: String,
            val lastName: String,
            val type: String
    )

    data class Period(
            val end: String,
            val id: Int,
            val lengthMin: Int,
            val lengthSec: Int,
            val start: String
    )

    data class Player(
            val firstName: String,
            val lastName: String,
            val matchName: String,
            val playerId: String,
            val position: String,
            val positionSide: String,
            val shirtNumber: Int,
            val stat: List<Stat>,
            val subPosition: String
    )

    data class Ruleset(
            val id: String,
            val name: String
    )

    data class Scores(
            val aggregate: Aggregate,
            val ft: Ft,
            val ht: Ht,
            val total: Total
    )

    data class Sport(
            val id: String,
            val name: String
    )

    data class Stage(
            val endDate: String,
            val formatId: String,
            val id: String,
            val name: String,
            val startDate: String
    )

    data class Stat(
            val fh: String,
            val sh: String,
            val type: String,
            val value: String
    )

    data class Substitute(
            val contestantId: String,
            val lastUpdated: String,
            val periodId: Int,
            val playerOffId: String,
            val playerOffName: String,
            val playerOnId: String,
            val playerOnName: String,
            val timeMin: Int,
            val timeMinSec: String
    )

    data class TeamOfficial(
            val firstName: String,
            val id: String,
            val lastName: String,
            val type: String
    )

    data class Total(
            val away: Int,
            val home: Int
    )

    data class TournamentCalendar(
            val endDate: String,
            val id: String,
            val name: String,
            val startDate: String
    )

    data class Venue(
            val id: String,
            val longName: String,
            val neutral: String,
            val shortName: String
    )
}
