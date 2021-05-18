//
//  PlayerCardViewModel.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/12/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import RxSwift

final class SquadCardViewModel: ViewModel {
    let contestantId: String

    let squadCard = Variable<SquadCard?>(nil)

    init(contestantId: String) {
        self.contestantId = contestantId
    }

    override func fetch() {
        isLoading.on(.next(true))

        ApiManager.fetchPlayerScreenFullSquad(tournamentCalendar: OptaStats.pluginParams.calendarId, contestantId: contestantId) { _, json in
            self.isLoading.on(.next(false))

            if let json = json {
                self.squadCard.value = SquadCard(json: json)
            }
        }
    }
}
