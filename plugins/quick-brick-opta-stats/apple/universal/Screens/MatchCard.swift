//
//  MatchCard.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/11/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MatchCard {
    var matches = [MatchDetail]()
    var match: MatchDetail? {
        return matches.first
    }

    init(json: JSON) {
        matches.removeAll()

        if let matchList = json["match"].array {
            for matchInfoItem in matchList {
                var matchDetail = MatchDetail()

                if let matchInfoItemInfo = matchInfoItem.dictionary?["matchInfo"] {
                    processMatchInfo(matchInfoItemInfo, matchDetail: &matchDetail)
                }

                matchDetail.liveData = createLiveData(matchInfoItem)

                matches.append(matchDetail)
            }
        }
    }

    fileprivate func processMatchInfo(_ json: JSON, matchDetail: inout MatchDetail) {
        guard let matchInfo = json.dictionary else {
            return
        }

        matchDetail.id = matchInfo["id"]?.string
        matchDetail.date = Helpers.dateAndTime(matchInfo["date"]?.string, time: matchInfo["time"]?.string)
        matchDetail.week = matchInfo["week"]?.string
        matchDetail.lastUpdated = Helpers.longDate(from: matchInfo["lastUpdated"]?.string ?? "")
        matchDetail.description = matchInfo["description"]?.string

        if let value = matchInfo["sport"]?.dictionary {
            matchDetail.sport = Sport()
            matchDetail.sport?.id = value["id"]?.string
            matchDetail.sport?.name = value["name"]?.string
        }

        if let value = matchInfo["ruleset"]?.dictionary {
            matchDetail.ruleSet = RuleSet()
            matchDetail.ruleSet?.id = value["id"]?.string
            matchDetail.ruleSet?.name = value["name"]?.string
        }

        if let value = matchInfo["competition"]?.dictionary {
            matchDetail.competition = Competition()
            matchDetail.competition?.id = value["id"]?.string
            matchDetail.competition?.name = value["name"]?.string
            matchDetail.competition?.code = value["competitionCode"]?.string
            matchDetail.competition?.format = value["competionFormat"]?.string

            if let countyInfo = value["country"]?.dictionary {
                matchDetail.competition?.country = Country()
                matchDetail.competition?.country?.id = countyInfo["id"]?.string
                matchDetail.competition?.country?.name = countyInfo["name"]?.string
            }
        }

        if let value = matchInfo["tournamentCalendar"]?.dictionary {
            matchDetail.tournamentCalendar = TournamentCalendar()
            matchDetail.tournamentCalendar?.id = value["id"]?.string
            matchDetail.tournamentCalendar?.startDate = Helpers.shortDate(from: value["startDate"]?.string ?? "")
            matchDetail.tournamentCalendar?.endDate = Helpers.shortDate(from: value["endDate"]?.string ?? "")
            matchDetail.tournamentCalendar?.name = value["name"]?.string
        }

        if let value = matchInfo["stage"]?.dictionary {
            matchDetail.stage = Stage()
            matchDetail.stage?.id = value["id"]?.string
            matchDetail.stage?.formatId = value["formatId"]?.string
            matchDetail.stage?.startDate = Helpers.shortDate(from: value["startDate"]?.string ?? "")
            matchDetail.stage?.endDate = Helpers.shortDate(from: value["endDate"]?.string ?? "")
            matchDetail.stage?.name = value["name"]?.string
        }

        if let value = matchInfo["series"]?.dictionary {
            matchDetail.series = Series()
            matchDetail.series?.id = value["id"]?.string
            matchDetail.series?.name = value["name"]?.string
        }

        matchDetail.contestants = createContestants(json)
        matchDetail.venue = createVenue(json)
    }

    fileprivate func createContestants(_ json: JSON) -> [Contestant] {
        var contestants = [Contestant]()

        if let contestantInfoList = json["contestant"].array {
            for contestantInfoItem in contestantInfoList {
                guard let contestantInfo = contestantInfoItem.dictionary else {
                    continue
                }

                var contestant = Contestant()

                contestant.id = contestantInfo["id"]?.string
                contestant.name = contestantInfo["name"]?.string
                contestant.shortName = contestantInfo["shortName"]?.string
                contestant.officialName = contestantInfo["officialName"]?.string
                contestant.code = contestantInfo["code"]?.string
                contestant.position = contestantInfo["position"]?.string

                if let countryInfo = contestantInfo["country"]?.dictionary {
                    contestant.country = Country()
                    contestant.country?.id = countryInfo["id"]?.string
                    contestant.country?.name = countryInfo["name"]?.string
                }

                contestants.append(contestant)
            }
        }

        return contestants
    }

    fileprivate func createVenue(_ json: JSON) -> Venue {
        var venue = Venue()

        if let venueInfo = json["venue"].dictionary {
            venue.id = venueInfo["id"]?.string
            venue.neutral = venueInfo["neutral"]?.string
            venue.longName = venueInfo["longName"]?.string
            venue.shortName = venueInfo["shortName"]?.string
        }

        return venue
    }

    fileprivate func createLiveData(_ json: JSON) -> LiveData {
        var tempMatchStats = MatchStatsCard(json: json) // json is not what MatchStatsCard expects, but that's OK

        if let liveDataInfo = json["liveData"].dictionary {
            tempMatchStats.processLiveData(liveDataInfo)
        }

        return tempMatchStats.liveData
    }
}
