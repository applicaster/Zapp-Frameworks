//
//  TeamCardViewModel.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Marcos Reyes - Applicaster on 3/8/19.
//

import Foundation
import RxSwift
import SwiftyJSON

final class TeamCardViewModel: ViewModel {
    let contestantId: String

    let teamCard = Variable<TeamCard?>(nil)
    let numberOfTrophies = Variable<Int?>(nil)
    let errorOnFetch = Variable<Bool>(false)

    init(contestantId: String) {
        self.contestantId = contestantId
    }

    override func fetch() {
        isLoading.on(.next(true))

        ApiManager.fetchTeamScreenDetails(tournamentCalendar: OptaStats.pluginParams.calendarId, contestantId: contestantId) { _, json in
            self.isLoading.on(.next(false))

            // API endpoint gives success code even though payload contains error details
            // hence, we have to check for errorCode key
            if let json = json {
                if let _ = json["errorCode"].string {
                    self.errorOnFetch.value = true
                } else {
                    self.teamCard.value = TeamCard(json: json)
                }
            }
        }
    }

    func fetchTournamentWinners(contestantId: String) {
        ApiManager.fetchTournamentWinners(competitionId: OptaStats.pluginParams.competitionId) { _, json in
            if let json = json {
                if let competitionDict = json["competition"].array, let competitionArray = competitionDict.first, let trophiesArray = competitionArray["trophy"].array {
                    var totalCount: Int = 0
                    for trophyJSON in trophiesArray {
                        if let winnerContestantId = trophyJSON["winnerContestantId"].string, winnerContestantId == contestantId {
                            totalCount += 1
                        }
                    }
                    self.numberOfTrophies.value = totalCount
                }
            }
        }
    }
}
