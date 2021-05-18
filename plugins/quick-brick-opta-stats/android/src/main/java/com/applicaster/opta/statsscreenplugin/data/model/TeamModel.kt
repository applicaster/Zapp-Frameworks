package com.applicaster.opta.statsscreenplugin.data.model

import java.util.*

object TeamModel {
    data class Team(var competition: GroupModel.Competition,
                    var tournamentCalendar: GroupModel.TournamentCalendar,
                    var contestant: Contestant, var lastUpdated: Date, var player: List<Player>)

    data class Contestant(var id: String, var name: String, var stat: List<Stat>)

    data class Player(var position: String, var id: String, var shirtNumber: String,
                      var firstName: String, var lastName: String, var matchName: String,
                      var stat: List<Stat>)

    data class Stat(var name: String, var value: String)
}