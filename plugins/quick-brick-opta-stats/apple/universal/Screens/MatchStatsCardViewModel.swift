//
//  MatchStatsCardViewModel.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/14/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import RxSwift

final class MatchStatsCardViewModel: ViewModel {
    let fixtureId: String

    let matchStatsCard = Variable<MatchStatsCard?>(nil)

    init(fixtureId: String) {
        self.fixtureId = fixtureId
    }

    override func fetch() {
        isLoading.on(.next(true))

        ApiManager.fetchMatchScreenDetails(fixtureId: fixtureId) { _, json in
            self.isLoading.on(.next(false))

            if let json = json {
                self.matchStatsCard.value = MatchStatsCard(json: json)
            }
        }
    }
}
