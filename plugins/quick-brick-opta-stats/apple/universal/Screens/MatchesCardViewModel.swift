//
//  MatchesCardViewModel.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/8/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import RxSwift

final class MatchesCardViewModel: ViewModel {
    let matchesCard = Variable<MatchesCard?>(nil)
    let matchesForDisplay = Variable<[Match]>([])
    var finishedFetchingUpcomingMatches: Bool = false
    var allMatches = [Match]()
    var numberOfMatchesToShow: Int = OptaStats.pluginParams.numberOfMatches

    override func fetch() {
        isLoading.on(.next(true))

        ApiManager.fetchAllMatchesGrouped(tournamentCalendar: OptaStats.pluginParams.calendarId) { _, json in
            if let json = json {
                // matchesCard used in MatchesCardViewController
                let model = MatchesCard(json: json)
                self.matchesCard.value = model

                var tournamentCalendar = TournamentCalendar()
                if let value = json["tournamentCalendar"].dictionary {
                    tournamentCalendar.id = value["id"]?.string
                    tournamentCalendar.name = value["name"]?.string
                    tournamentCalendar.startDate = Helpers.shortDate(from: value["startDate"]?.string ?? "")
                    tournamentCalendar.endDate = Helpers.shortDate(from: value["endDate"]?.string ?? "")
                }

                let matches = MatchesCard(json: json)

                self.allMatches.removeAll()
                for date in matches.matchDates {
                    if let matches = date.matches {
                        self.allMatches.append(contentsOf: matches)
                    }
                }
                self.processMatchesForDisplay(matches, tournamentCalendar: tournamentCalendar)
            }

            self.isLoading.on(.next(false))
            self.finishedFetchingUpcomingMatches = true
        }
    }

    private func processMatchesForDisplay(_ matches: MatchesCard, tournamentCalendar: TournamentCalendar) {
        let matchDates = matches.matchDates
        guard matchDates.count > 0 else { return }

        // if tournament ended, set value of matchToDisplay array to only the last item in matches which was the final
        if tournamentHasEnded(tournamentCalendar) {
            var finalMatches = [Match]()

            for matchDate in matchDates.reversed() {
                if finalMatches.count == 3 { continue }

                if let matchesToAdd = matchDate.matches {
                    for match in matchesToAdd {
                        // we only retrieve UP to 3 matches per day
                        if finalMatches.count == 3 { continue }
                        finalMatches.append(match)
                    }
                }
            }

            Helpers.tournamentFinished = true
            matchesForDisplay.value = finalMatches.reversed()
            return
        }

        // if tournament hasn't started, set value of matchToDisplay array to only the first set of matches
        if tournamentHasNotStarted(tournamentCalendar) {
            if let lastMatchDate = matchDates.first, let matchesToDisplay = lastMatchDate.matches {
                matchesForDisplay.value = matchesToDisplay
            }
            return
        }

        var matches = [Match]()

        for matchDate in matchDates {
            // we only retrieve UP to 3 matches per day
            if matches.count == numberOfMatchesToShow { continue }

            let startOfToday = Calendar.current.startOfDay(for: Date())

            if let matchesToAdd = matchDate.matches {
                for match in matchesToAdd {
                    // we only retrieve UP to 3 matches per day
                    if matches.count == numberOfMatchesToShow { continue }

                    if let currentMatchDate = match.date {
                        let startOfMatchDay = Calendar.current.startOfDay(for: currentMatchDate)

                        // if the day is today or after and we havent stopped the loop because we haven't reached 3 matches or haven't reached the end, add match
                        if Calendar.current.isDateInToday(currentMatchDate) || (startOfMatchDay >= startOfToday) {
                            matches.append(match)
                        }
                    }
                }
            }
        }

        matchesForDisplay.value = matches
    }

    private func tournamentHasEnded(_ tournamentCalendar: TournamentCalendar) -> Bool {
        if let endDate = tournamentCalendar.endDate {
            if Date() >= endDate {
                return true
            } else {
                return false
            }
        }
        return false
    }

    private func tournamentHasNotStarted(_ tournamentCalendar: TournamentCalendar) -> Bool {
        if let startDate = tournamentCalendar.startDate {
            if startDate >= Date() {
                return true
            } else {
                return false
            }
        }
        return true
    }
}
