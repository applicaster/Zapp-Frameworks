//
//  GemiusAnalytics+PlayerAdObserverProtocol.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappCore
import GemiusSDK

extension GemiusAnalytics: PlayerAdObserverProtocol {
    func playerAdStarted(player: PlayerProtocol) {
        let data = GSMAdData()
        gemiusPlayerObject?.newAd(UUID().uuidString, with: data)
        
        gemiusPlayerObject?.program(.BREAK,
                                    forProgram: entryId,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
    }
    
    func playerAdCompleted(player: PlayerProtocol) {
        
    }
    
    func playerAdSkiped(player: PlayerProtocol) {

    }
    
    func playerAdProgressUpdate(player: PlayerProtocol,
                                currentTime: TimeInterval,
                                duration: TimeInterval) {

    }
}
