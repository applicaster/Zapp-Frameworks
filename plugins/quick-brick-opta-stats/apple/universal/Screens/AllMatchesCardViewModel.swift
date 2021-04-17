//
//  AllMatchesCardViewModel.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 4/29/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import RxSwift

final class AllMatchesCardViewModel: ViewModel {
    let matchesCard = Variable<MatchCard?>(nil)
    let matchesForDisplay = Variable<[MatchDetail]>([])
    var finishedFetchingUpcomingMatches: Bool = false

    override func fetch() {
        isLoading.on(.next(true))

        ApiManager.fetchAllMatches(tournamentCalendar: OptaStats.pluginParams.calendarId) { _, json in
            if let json = json {
                // matchesCard used in MatchesCardViewController
                let model = MatchCard(json: json)
                self.matchesCard.value = model

                self.matchesForDisplay.value = model.matches
            }

            self.isLoading.on(.next(false))
            self.finishedFetchingUpcomingMatches = true
        }
    }
}
