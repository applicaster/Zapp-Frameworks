//
//  SquadCareerCardViewModel.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/12/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import RxSwift

final class SquadCareerCardViewModel: ViewModel {
    let personId: String

    let squadCareerCard = Variable<SquadCareerCard?>(nil)

    init(personId: String) {
        self.personId = personId
    }

    override func fetch() {
        isLoading.on(.next(true))

        ApiManager.fetchPlayerScreenCareer(personId: personId) { _, json in
            self.isLoading.on(.next(false))

            if let json = json {
                self.squadCareerCard.value = SquadCareerCard(json: json)
            }
        }
    }
}
