package com.applicaster.opta.statsscreenplugin.data.model

import java.util.*

// todo: check date formats
object MatchModel {
    data class Match(var matchInfo: MatchInfo?, var liveData: LiveData?) {
        constructor() : this(null, null)
    }

    // region MatchInfo classes
    data class MatchInfo(var id: String, var date: String, var time: String, var lastUpdated: Date,
                         var description: String, var sport: GroupModel.Sport,
                         var ruleset: GroupModel.Ruleset, var competition: GroupModel.Competition,
                         var tournamentCalendar: GroupModel.TournamentCalendar,
                         var stage: GroupModel.Stage, var series: Series,
                         var contestant: List<Contestant>?, var venue: Venue?)

    data class Contestant(var id: String, var name: String, var shortName: String,
                          var officialName: String, var code: String, var position: String,
                          var country: Country)

    data class Country(var id: String, var name: String)

    data class Venue(var id: String, var neutral: String, var longName: String,
                     var shortName: String)

    data class Series(var id: String, var name: String)
    // endregion

    // region LiveData classes
    data class LiveData(var matchDetails: MatchDetails, var goal: List<Goal>?, var card: List<Card>?,
                        var substitute: List<Substitute>?, var lineUp: List<LineUp>?,
                        var matchDetailsExtra: MatchDetailsExtra?)

    // region MatchDetails classes
    data class MatchDetails(var periodId: Int, var matchStatus: String, var winner: String,
                            var matchLengthMin: Int?, var matchLengthSec: Int, var matchTime: Int?,
                            var period: List<Period?>?, var scores: Scores?)

    data class Period(var id: String, var start: Date, var end: Date, var lengthMin: Int,
                      var lengthSec: Int)

    data class Scores(var ht: Score, var ft: Score, var et: Score, var total: Score, var pen: Score?)

    data class Score(var home: Int, var away: Int)
    // endregion

    data class Goal(var contestantId: String, var periodId: Int, var timeMin: Int,
                    var lastUpdated: Date, var type: String, var scorerId: String,
                    var scorerName: String, var assistPlayerId: String, var assistPlayerName: String,
                    var optaEventId: String, var homeScore: Int, var awayScore: Int)

    data class Card(var contestantId: String, var periodId: Int, var timeMin: Int,
                    var lastUpdated: Date, var type: String, var playerId: String,
                    var playerName: String, var optaEventId: String)

    data class Substitute(var contestantId: String, var periodId: Int, var timeMin: Int,
                          var lastUpdated: Date, var playerOnId: String, var playerOnName: String,
                          var playerOffId: String, var playerOffName: String)

    // region LineUp classes
    data class LineUp(var contestantId: String, var player: List<Player>, var teamOfficial: TeamOfficial,
                      var stat: List<Stat>)
    data class Player(var playerId: String, var firstName: String, var lastName: String,
                      var matchName: String, var shirtNumber: Int, var position: String,
                      var positionSide: String, var stat: List<Stat>)
    data class TeamOfficial(var id: String, var firstName: String, var lastName: String,
                            var type: String)
    data class Stat(var fh: String, var sh: String, var type: String, var value: String)
    // endregion

    // region MatchDetailsExtra
    data class MatchDetailsExtra(var matchOfficial: List<MatchOfficial>)

    data class MatchOfficial(var id: String, var type: String, var firstName: String,
                             var lastName: String)
    // endregion
    //endregion
}