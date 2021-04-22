//
//  GroupCards.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/7/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import RxSwift

final class GroupCardsViewModel: ViewModel {
    let groupCard = Variable<GroupCard?>(nil)

    override func fetch() {
        isLoading.on(.next(true))

        ApiManager.fetchGroupCards(tournamentCalendar: OptaStats.pluginParams.calendarId) { _, json in
            self.isLoading.on(.next(false))

            if let json = json {
                self.groupCard.value = GroupCard(json: json)
            }
        }
    }
}
