//
//  MatchCardViewModel.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/8/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import RxSwift

final class MatchCardViewModel: ViewModel {
    let matchId: String

    let matchCard = Variable<MatchCard?>(nil)

    init(matchId: String) {
        self.matchId = matchId
    }

    override func fetch() {
        isLoading.on(.next(true))

        ApiManager.fetchMatchDetails(matchId: matchId) { _, json in
            self.isLoading.on(.next(false))

            if let json = json {
                self.matchCard.value = MatchCard(json: json)
            }
        }
    }
}
