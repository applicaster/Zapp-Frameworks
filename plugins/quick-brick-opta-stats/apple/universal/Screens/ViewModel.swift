//
//  ViewModel.swift
//  CopaAmericaStatsScreenPlugin
//
//  Created by Jesus De Meyer on 3/12/19.
//  Copyright © 2019 Applicaster. All rights reserved.
//

import Foundation
import RxSwift

protocol ViewModelProtocol {
    func fetch()
}

class ViewModel: NSObject, ViewModelProtocol {
    let isLoading = PublishSubject<Bool>()

    func fetch() {
        // implemented by subclass
    }
}
