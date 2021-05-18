//
//  TeamCard.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 3/8/19.
//

import Foundation
import SwiftyJSON

struct TeamCard {
    var competition: Competition?
    var tournamentCalendar: TournamentCalendar?
    var contestantStat: ContestantStat?
    var lastUpdated: Date?
    var players: [Player]?

    init(json: JSON) {
        if let value = json["competition"].dictionary {
            competition = Competition()
            competition?.id = value["id"]?.string
            competition?.name = value["name"]?.string
        }

        if let value = json["tournamentCalendar"].dictionary {
            tournamentCalendar = TournamentCalendar()
            tournamentCalendar?.id = value["id"]?.string
            tournamentCalendar?.name = value["name"]?.string
            tournamentCalendar?.startDate = Helpers.shortDate(from: value["startDate"]?.string ?? "")
            tournamentCalendar?.endDate = Helpers.shortDate(from: value["endDate"]?.string ?? "")
        }

        if let value = json["contestant"].dictionary {
            contestantStat = ContestantStat()
            contestantStat?.id = value["id"]?.string
            contestantStat?.name = value["name"]?.string

            if let statArray = value["stat"]?.array {
                contestantStat?.stat = statArray.compactMap({ statJSON in
                    var stat = Stat()
                    stat.name = statJSON["name"].string
                    stat.value = Double(statJSON["value"].string ?? "0")
                    return stat
                })
            }
        }
        if let value = json["lastUpdated"].string {
            lastUpdated = Helpers.longDate(from: value) ?? Date()
        }
        if let playerArray = json["player"].array {
            players = playerArray.compactMap { playerJSON in
                var player = Player()
                player.id = playerJSON["id"].string
                player.position = playerJSON["position"].string
                player.shirtNumber = playerJSON["shirtNumber"].string
                player.firstName = playerJSON["firstName"].string
                player.lastName = playerJSON["lastName"].string
                player.matchName = playerJSON["matchName"].string

                if let statArray = playerJSON["stat"].array {
                    player.stats = statArray.compactMap { statJSON in
                        var stat = Stat()
                        stat.name = statJSON["name"].string
                        stat.value = Double(statJSON["value"].string ?? "0")
                        return stat
                    }
                }

                return player
            }
        }
    }
}
