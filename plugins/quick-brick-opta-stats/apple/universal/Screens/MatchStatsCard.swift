//
//  MatchStatsCard.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/14/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import SwiftyJSON

struct MatchStatsCard {
    var matchInfo = MatchInfo()
    var liveData = LiveData()

    init(json: JSON) {
        if let value = json["matchInfo"].dictionary {
            processMatchInfo(value)
        }
        if let value = json["liveData"].dictionary {
            processLiveData(value)
        }
    }

    mutating func processMatchInfo(_ info: [String: JSON]) {
        matchInfo.id = info["id"]?.string
        matchInfo.date = Helpers.dateAndTime(info["date"]?.string, time: info["time"]?.string)
        matchInfo.lastUpdated = Helpers.longDate(from: info["lastUpdated"]?.string ?? "")
        matchInfo.description = info["description"]?.string

        if let value = info["sport"]?.dictionary {
            matchInfo.sport = Sport()
            matchInfo.sport?.id = value["id"]?.string
            matchInfo.sport?.name = value["name"]?.string
        }

        if let value = info["ruleset"]?.dictionary {
            matchInfo.ruleSet = RuleSet()
            matchInfo.ruleSet?.id = value["id"]?.string
            matchInfo.ruleSet?.name = value["name"]?.string
        }

        if let value = info["competition"]?.dictionary {
            matchInfo.competition = Competition()
            matchInfo.competition?.id = value["id"]?.string
            matchInfo.competition?.name = value["name"]?.string
            matchInfo.competition?.code = value["competitionCode"]?.string
            matchInfo.competition?.format = value["competitionFormat"]?.string
            if let country = value["country"]?.dictionary {
                matchInfo.competition?.country = Country()
                matchInfo.competition?.country?.id = country["id"]?.string
                matchInfo.competition?.country?.name = country["name"]?.string
            }
        }

        if let value = info["tournamentCalendar"]?.dictionary {
            matchInfo.tournamentCalendar = TournamentCalendar()
            matchInfo.tournamentCalendar?.id = value["id"]?.string
            matchInfo.tournamentCalendar?.startDate = Helpers.shortDate(from: value["startDate"]?.string ?? "")
            matchInfo.tournamentCalendar?.endDate = Helpers.shortDate(from: value["endDate"]?.string ?? "")
            matchInfo.tournamentCalendar?.name = value["name"]?.string
        }

        if let value = info["stage"]?.dictionary {
            matchInfo.stage = Stage()
            matchInfo.stage?.id = value["id"]?.string
            matchInfo.stage?.formatId = value["formatId"]?.string
            matchInfo.stage?.startDate = Helpers.shortDate(from: value["startDate"]?.string ?? "")
            matchInfo.stage?.endDate = Helpers.shortDate(from: value["endDate"]?.string ?? "")
            matchInfo.stage?.name = value["name"]?.string
        }

        if let value = info["series"]?.dictionary {
            matchInfo.series = Series()
            matchInfo.series?.id = value["id"]?.string
            matchInfo.series?.name = value["name"]?.string
        }

        if let value = info["contestant"]?.array {
            var contestants = [Contestant]()
            for contestantItem in value {
                guard let contestantItemInfo = contestantItem.dictionary else {
                    continue
                }

                var contestant = Contestant()

                contestant.id = contestantItemInfo["id"]?.string
                contestant.name = contestantItemInfo["name"]?.string
                contestant.shortName = contestantItemInfo["shortName"]?.string
                contestant.officialName = contestantItemInfo["officialName"]?.string
                contestant.code = contestantItemInfo["code"]?.string
                contestant.position = contestantItemInfo["position"]?.string

                if let countryInfo = contestantItemInfo["country"]?.dictionary {
                    contestant.country = Country()
                    contestant.country?.id = countryInfo["id"]?.string
                    contestant.country?.name = countryInfo["name"]?.string
                }

                contestants.append(contestant)
            }
            matchInfo.contestants = contestants
        }

        if let value = info["venue"]?.dictionary {
            matchInfo.venue = Venue()
            matchInfo.venue?.id = value["id"]?.string
            matchInfo.venue?.neutral = value["neutral"]?.string
            matchInfo.venue?.longName = value["longName"]?.string
            matchInfo.venue?.shortName = value["shortName"]?.string
        }
    }

    mutating func processLiveData(_ info: [String: JSON]) {
        if let value = info["matchDetails"]?.dictionary {
            liveData.matchDetails = createMatchDetails(value)
        }
        if let value = info["goal"]?.array {
            liveData.goals = createGoals(value)
        }
        if let value = info["card"]?.array {
            liveData.cards = createCards(value)
        }
        if let value = info["substitute"]?.array {
            liveData.substitutes = createSubstitudes(value)
        }
        if let value = info["lineUp"]?.array {
            liveData.lineUps = createLineUps(value)
        }
        if let value = info["matchDetailsExtra"]?.dictionary {
            liveData.matchDetailsExtra = MatchDetailsExtra()

            if let list = value["matchOfficial"]?.array {
                let matchOfficials = createMatchOfficials(list)
                liveData.matchDetailsExtra?.matchOfficials = matchOfficials
            }
        }
    }

    // MARK: -

    fileprivate func createMatchDetails(_ value: [String: JSON]) -> MatchDetails {
        var matchDetails = MatchDetails()

        matchDetails.matchTime = value["matchTime"]?.int
        matchDetails.periodId = value["periodId"]?.int
        matchDetails.matchStatus = value["matchStatus"]?.string
        matchDetails.winner = value["winner"]?.string
        matchDetails.matchLengthMin = value["matchLengthMin"]?.int
        matchDetails.matchLengthSec = value["matchLengthSec"]?.int

        if let periodItemList = value["period"]?.array {
            var periods = [Period]()

            for periodItem in periodItemList {
                guard let periodItemInfo = periodItem.dictionary else {
                    continue
                }

                var period = Period()

                period.id = periodItemInfo["id"]?.int
                period.start = Helpers.longDate(from: periodItemInfo["start"]?.string ?? "")
                period.end = Helpers.longDate(from: periodItemInfo["end"]?.string ?? "")
                period.lengthMin = periodItemInfo["lengthMin"]?.int
                period.lengthSec = periodItemInfo["lengthSec"]?.int

                periods.append(period)
            }

            matchDetails.periods = periods
        }

        if let scoresInfo = value["scores"]?.dictionary {
            matchDetails.scores = Scores()

            if let scoresDetailInfo = scoresInfo["ht"]?.dictionary {
                matchDetails.scores?.ht = ScoresDetail()
                matchDetails.scores?.ht?.home = scoresDetailInfo["home"]?.int
                matchDetails.scores?.ht?.away = scoresDetailInfo["away"]?.int
            }
            if let scoresDetailInfo = scoresInfo["ft"]?.dictionary {
                matchDetails.scores?.ft = ScoresDetail()
                matchDetails.scores?.ft?.home = scoresDetailInfo["home"]?.int
                matchDetails.scores?.ft?.away = scoresDetailInfo["away"]?.int
            }
            if let info = scoresInfo["et"]?.dictionary {
                matchDetails.scores?.et = ScoresDetail()
                matchDetails.scores?.et?.home = info["home"]?.int
                matchDetails.scores?.et?.away = info["away"]?.int
            }
            if let info = scoresInfo["pen"]?.dictionary {
                matchDetails.scores?.pen = ScoresDetail()
                matchDetails.scores?.pen?.home = info["home"]?.int
                matchDetails.scores?.pen?.away = info["away"]?.int
            }
            if let scoresDetailInfo = scoresInfo["total"]?.dictionary {
                matchDetails.scores?.total = ScoresDetail()
                matchDetails.scores?.total?.home = scoresDetailInfo["home"]?.int
                matchDetails.scores?.total?.away = scoresDetailInfo["away"]?.int
            }
        }

        return matchDetails
    }

    fileprivate func createGoals(_ value: [JSON]) -> [Goal] {
        var goals = [Goal]()

        for goalItem in value {
            guard let goalItemInfo = goalItem.dictionary else {
                continue
            }

            var goal = Goal()

            goal.contestantId = goalItemInfo["contestantId"]?.string
            goal.periodId = goalItemInfo["periodId"]?.int
            goal.timeMin = goalItemInfo["timeMin"]?.int
            goal.lastUpdated = Helpers.longDate(from: goalItemInfo["lastUpdated"]?.string ?? "")
            goal.type = goalItemInfo["type"]?.string
            goal.scorerId = goalItemInfo["scorerId"]?.string
            goal.scorerName = goalItemInfo["scorerName"]?.string
            goal.assistPlayerId = goalItemInfo["assistPlayerId"]?.string
            goal.assistPlayerName = goalItemInfo["assistPlayerName"]?.string
            goal.optaEventId = goalItemInfo["optaEventId"]?.string
            goal.homeScore = goalItemInfo["homeScore"]?.int
            goal.awayScore = goalItemInfo["awayScore"]?.int

            goals.append(goal)
        }

        return goals
    }

    fileprivate func createCards(_ value: [JSON]) -> [Card] {
        var cards = [Card]()

        for cardItem in value {
            guard let cardItemInfo = cardItem.dictionary else {
                continue
            }

            var card = Card()

            card.contestantId = cardItemInfo["contestantId"]?.string
            card.periodId = cardItemInfo["periodId"]?.int
            card.timeMin = cardItemInfo["timeMin"]?.int
            card.lastUpdated = Helpers.longDate(from: cardItemInfo["lastUpdated"]?.string ?? "")
            card.type = cardItemInfo["type"]?.string
            card.playerId = cardItemInfo["playerId"]?.string
            card.playerName = cardItemInfo["playerName"]?.string
            card.optaEventId = cardItemInfo["optaEventId"]?.string

            cards.append(card)
        }

        return cards
    }

    fileprivate func createSubstitudes(_ value: [JSON]) -> [Substitute] {
        var substitutes = [Substitute]()

        for substituteItem in value {
            guard let substituteItemInfo = substituteItem.dictionary else {
                continue
            }

            var substitute = Substitute()

            substitute.contestantId = substituteItemInfo["contestantId"]?.string
            substitute.periodId = substituteItemInfo["periodId"]?.int
            substitute.timeMin = substituteItemInfo["timeMin"]?.int
            substitute.lastUpdated = Helpers.longDate(from: substituteItemInfo["lastUpdated"]?.string ?? "")
            substitute.playerOnId = substituteItemInfo["playerOnId"]?.string
            substitute.playerOnName = substituteItemInfo["playerOnName"]?.string
            substitute.playerOffId = substituteItemInfo["playerOffId"]?.string
            substitute.playerOffName = substituteItemInfo["playerOffName"]?.string

            substitutes.append(substitute)
        }

        return substitutes
    }

    fileprivate func createLineUps(_ value: [JSON]) -> [LineUp] {
        var lineUps = [LineUp]()

        for lineUpItem in value {
            guard let lineUpItemInfo = lineUpItem.dictionary else {
                continue
            }

            var lineUp = LineUp()

            lineUp.contestantID = lineUpItemInfo["contestantId"]?.string

            if let playerList = lineUpItemInfo["player"]?.array {
                var players = [Player]()

                for playerItem in playerList {
                    guard let playerItemInfo = playerItem.dictionary else {
                        continue
                    }

                    var player = Player()

                    player.id = playerItemInfo["playerId"]?.string
                    player.position = playerItemInfo["position"]?.string
                    player.positionSide = playerItemInfo["positionSide"]?.string
                    if let number = playerItemInfo["shirtNumber"]?.int {
                        player.shirtNumber = "\(number)"
                    }
                    player.firstName = playerItemInfo["firstName"]?.string
                    player.lastName = playerItemInfo["lastName"]?.string
                    player.matchName = playerItemInfo["matchName"]?.string
                    player.subPosition = playerItemInfo["subPosition"]?.string

                    if let statList = playerItemInfo["stat"]?.array {
                        var stats = [Stat]()

                        for statItem in statList {
                            guard let statItemInfo = statItem.dictionary else {
                                continue
                            }

                            var stat = Stat()

                            stat.type = statItemInfo["type"]?.string
                            stat.value = statItemInfo["value"]?.double
                            stat.valueString = statItemInfo["value"]?.string

                            stats.append(stat)
                        }
                        player.stats = stats
                    }

                    players.append(player)
                }

                lineUp.players = players
            }

            if let teamOfficialInfo = lineUpItemInfo["teamOfficial"]?.dictionary {
                lineUp.teamOfficial = MatchOfficial()
                lineUp.teamOfficial?.id = teamOfficialInfo["id"]?.string
                lineUp.teamOfficial?.firstName = teamOfficialInfo["firstName"]?.string
                lineUp.teamOfficial?.lastName = teamOfficialInfo["lastName"]?.string
                lineUp.teamOfficial?.type = teamOfficialInfo["type"]?.string
            }

            if let statList = lineUpItemInfo["stat"]?.array {
                var stats = [LineUpStat]()

                for statItem in statList {
                    guard let statItemInfo = statItem.dictionary else {
                        continue
                    }

                    var stat = LineUpStat()

                    stat.fh = statItemInfo["fh"]?.string
                    stat.sh = statItemInfo["sh"]?.string
                    stat.type = statItemInfo["type"]?.string
                    stat.value = statItemInfo["value"]?.string

                    stats.append(stat)
                }

                lineUp.stats = stats
            }
            lineUps.append(lineUp)
        }

        return lineUps
    }

    fileprivate func createMatchOfficials(_ value: [JSON]) -> [MatchOfficial] {
        var matchOfficials = [MatchOfficial]()

        for matchOfficialItem in value {
            guard let matchOfficialItemInfo = matchOfficialItem.dictionary else {
                continue
            }

            var matchOfficial = MatchOfficial()

            matchOfficial.id = matchOfficialItemInfo["id"]?.string
            matchOfficial.firstName = matchOfficialItemInfo["firstName"]?.string
            matchOfficial.lastName = matchOfficialItemInfo["lastName"]?.string
            matchOfficial.type = matchOfficialItemInfo["type"]?.string

            matchOfficials.append(matchOfficial)
        }

        return matchOfficials
    }

    // MARK: -

    func sortedPlayers(forHomeTeam: Bool) -> [Player] {
        var result = [Player]()

        if let lineup = lineUp(isHomeTeam: forHomeTeam) {
            if let players = lineup.players {
                for index in 1 ... 11 {
                    if let player = findPlayer(players: players, positionIndex: index) {
                        result.append(player)
                    }
                }
            }
        }

        return result
    }

    func allPlayers(forHomeTeam: Bool) -> [Player] {
        var result = [Player]()

        if let lineup = lineUp(isHomeTeam: forHomeTeam) {
            if let players = lineup.players {
                result.append(contentsOf: players)
            }
        }

        return result
    }

    fileprivate func findPlayer(players: [Player], positionIndex: Int) -> Player? {
        for player in players {
            guard let stats = player.stats else {
                continue
            }

            let filteredStats = stats.filter { $0.type == "formationPlace" }

            if let formationStat = filteredStats.first,
               let value = formationStat.valueString,
               let number = Int(value), number == positionIndex {
                return player
            }
        }

        return nil
    }

    func usedFormation(isHomeTeam: Bool, formatted: Bool = false) -> String {
        var result = ""

        if let lineup = lineUp(isHomeTeam: isHomeTeam) {
            if let stats = lineup.stats {
                let filteredStats = stats.filter { $0.type == "formationUsed" }
                if let s = filteredStats.first {
                    result = s.value ?? ""
                }
            }
        }

        if !result.isEmpty && formatted {
            var fomattedFormation = ""
            for c in result {
                fomattedFormation += String(c) + "-"
            }
            result = String(fomattedFormation[fomattedFormation.startIndex ..< fomattedFormation.index(fomattedFormation.endIndex, offsetBy: -1)])
        }

        return result
    }

    func goals() -> [Goal] {
        var result = [Goal]()

        if let goals = liveData.goals {
            result = goals
        }

        return result
    }

    func lineUp(isHomeTeam: Bool) -> LineUp? {
        if let lineups = liveData.lineUps, lineups.count == 2 {
            return isHomeTeam ? lineups[0] : lineups[1]
        }

        return nil
    }

    func stat(of type: String, isHomeTeam: Bool) -> LineUpStat? {
        if let lineup = lineUp(isHomeTeam: isHomeTeam) {
            if let stats = lineup.stats {
                let filteredStats = stats.filter { $0.type == type }
                return filteredStats.first
            }
        }
        return nil
    }

    func isPlayerInHomeTeam(id: String) -> Bool {
        if let lineup = lineUp(isHomeTeam: true), let players = lineup.players {
            for player in players {
                if player.id == id {
                    return true
                }
            }
        }
        return false
    }

    func calculatePercentBetweenStat(statType1: String, statType2: String, isHomeTeam: Bool) -> Float {
        if let stat = self.stat(of: statType1, isHomeTeam: isHomeTeam) {
            if let totalStat = self.stat(of: statType2, isHomeTeam: isHomeTeam) {
                if let a = Int(stat.value ?? ""), let b = Int(totalStat.value ?? "") {
                    return (Float(a) / Float(b)) * 100.0
                }
            }
        }

        return 0.0
    }

    func matchOfficialsWithType(type: String) -> [String] {
        var result = [String]()

        if let officials = liveData.matchDetailsExtra?.matchOfficials {
            let filteredOfficials = officials.filter { $0.type == type }

            for official in filteredOfficials {
                var name = ""
                if let value = official.firstName {
                    name += value
                    if let value2 = official.lastName {
                        name += " " + value2
                    }
                }

                if !name.isEmpty {
                    result.append(name)
                }
            }
        }

        return result
    }

    // MARK: -

    func isHalfTime() -> Bool {
        guard let matchDetails = liveData.matchDetails else {
            return false
        }

        if matchDetails.matchTime == nil {
            if let periods = matchDetails.periods, periods.count == 1 {
                return true
            }
        }

        return false
    }
}
