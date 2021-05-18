//
//  GroupCard.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/11/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import SwiftyJSON

struct GroupCard {
    var sport = Sport()
    var ruleSet = RuleSet()
    var competition = Competition()
    var tournamentCalendar = TournamentCalendar()
    var stage = Stage()
    var lastUpdated: Date?

    init(json: JSON) {
        if let value = json["sport"].dictionary {
            sport.id = value["id"]?.string
            sport.name = value["name"]?.string
        }
        if let value = json["ruleset"].dictionary {
            ruleSet.id = value["id"]?.string
            ruleSet.name = value["name"]?.string
        }
        if let value = json["competition"].dictionary {
            competition.id = value["id"]?.string
            competition.name = value["name"]?.string
        }
        if let value = json["tournamentCalendar"].dictionary {
            tournamentCalendar.id = value["id"]?.string
            tournamentCalendar.name = value["name"]?.string
            tournamentCalendar.startDate = Helpers.shortDate(from: value["startDate"]?.string ?? "")
            tournamentCalendar.endDate = Helpers.shortDate(from: value["endDate"]?.string ?? "")
        }
        if let value = json["lastUpdated"].string {
            lastUpdated = Helpers.longDate(from: value)
        }

        if let value = json["stage"].array, let stageObject = value.first {
            stage.id = stageObject["id"].string
            stage.formatId = stageObject["formatId"].string
            stage.name = stageObject["name"].string
            stage.vertical = stageObject["id"].intValue
            stage.startDate = Helpers.shortDate(from: stageObject["startDate"].string ?? "")
            stage.endDate = Helpers.shortDate(from: stageObject["endDate"].string ?? "")

            var divisions = [Division]()

            if let divisionsObject = stageObject["division"].array {
                for divisionObject in divisionsObject {
                    var division = Division()

                    division.type = divisionObject["type"].string
                    division.groupID = divisionObject["groupId"].string
                    division.groupName = divisionObject["groupName"].string
                    division.horizontal = divisionObject["horizontal"].intValue

                    var rankings = [Ranking]()

                    if let rankingsObject = divisionObject["ranking"].array {
                        for rankingObject in rankingsObject {
                            var ranking = Ranking()

                            ranking.rank = rankingObject["rank"].int
                            ranking.rankStatus = rankingObject["rankStatus"].string
                            ranking.rankID = rankingObject["rankId"].string
                            ranking.contestantID = rankingObject["contestantId"].string
                            ranking.contestantName = rankingObject["contestantName"].string
                            ranking.contestantShortName = rankingObject["contestantShortName"].string
                            ranking.contestantClubName = rankingObject["contestantClubName"].string
                            ranking.contestantCode = rankingObject["contestantCode"].string
                            ranking.points = rankingObject["points"].int
                            ranking.matchesPlayed = rankingObject["matchesPlayed"].int
                            ranking.matchesWon = rankingObject["matchesWon"].int
                            ranking.matchesLost = rankingObject["matchesLost"].int
                            ranking.matchesDrawn = rankingObject["matchesDrawn"].int
                            ranking.goalsFor = rankingObject["goalsFor"].int
                            ranking.goalsAgainst = rankingObject["goalsAgainst"].int
                            ranking.goalDifference = rankingObject["goaldifference"].string

                            rankings.append(ranking)
                        }

                        division.rankings = rankings
                    }

                    divisions.append(division)
                }
            }

            stage.divisions = divisions
        }
    }
}
