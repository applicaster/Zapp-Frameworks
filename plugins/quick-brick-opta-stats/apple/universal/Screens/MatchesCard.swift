//
//  MatchesCard.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/11/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MatchesCard {
    var competition = Competition()
    var tournamentCalendar = TournamentCalendar()
    var matchDates = [MatchDate]()

    init(json: JSON) {
        if let value = json["competition"].dictionary {
            competition.id = value["id"]?.string
            competition.name = value["name"]?.string
            competition.code = value["competitionCode"]?.string
            competition.format = value["competitionFormat"]?.string
            competition.lastUpdated = Helpers.longDate(from: value["lastUpdated"]?.string ?? "")
        }

        if let value = json["tournamentCalendar"].dictionary {
            tournamentCalendar = TournamentCalendar()
            tournamentCalendar.id = value["id"]?.string
            tournamentCalendar.startDate = Helpers.shortDate(from: value["startDate"]?.string ?? "")
            tournamentCalendar.endDate = Helpers.shortDate(from: value["endDate"]?.string ?? "")
            tournamentCalendar.name = value["name"]?.string
        }

        matchDates.removeAll()

        if let matchDateList = json["matchDate"].array {
            for matchDateInfo in matchDateList {
                guard let matchDateInfo = matchDateInfo.dictionary else {
                    continue
                }

                var matchDate = MatchDate()

                matchDate.date = Helpers.shortDate(from: matchDateInfo["date"]?.string ?? "")
                matchDate.numberOfGames = matchDateInfo["numberOfGames"]?.string

                var matches = [Match]()

                if let matchInfoList = matchDateInfo["match"]?.array {
                    for matchInfoItem in matchInfoList {
                        guard let matchInfo = matchInfoItem.dictionary else {
                            continue
                        }

                        var match = Match()

                        match.id = matchInfo["id"]?.string
                        match.coverageLevel = matchInfo["coverageLevel"]?.string
                        match.date = Helpers.dateAndTime(matchInfo["date"]?.string, time: matchInfo["time"]?.string)
                        match.homeContestantId = matchInfo["homeContestantId"]?.string
                        match.awayContestantId = matchInfo["awayContestantId"]?.string
                        match.homeContestantName = matchInfo["homeContestantName"]?.string
                        match.awayContestantName = matchInfo["awayContestantName"]?.string
                        match.homeContestantOfficialName = matchInfo["homeContestantOfficialName"]?.string
                        match.awayContestantOfficialName = matchInfo["awayContestantOfficialName"]?.string
                        match.homeContestantShortName = matchInfo["homeContestantShortName"]?.string
                        match.awayContestantShortName = matchInfo["awayContestantShortName"]?.string
                        match.homeContestantCode = matchInfo["homeContestantCode"]?.string
                        match.awayContestantCode = matchInfo["awayContestantCode"]?.string

                        matches.append(match)
                    }
                }

                matchDate.matches = matches

                matchDates.append(matchDate)
            }
        }
    }
}
