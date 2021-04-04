//
//  GemiusAnalytics+PlayerEvents.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 04/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import GemiusSDK

extension GemiusAnalytics {
    struct PlyerEvents {
        static let playing = "Player Playing"
        static let  paused = "Player Pause"
        static let  seeking = "Player Seeking"
        static let  seeked = "Player Seeked"
    }
    
    struct AdEvents {
        static let  adBreakBegin = "Ad Break Begin"
        static let  adBreakEnd = "Ad Break End"
        static let  adError = "Ad Error"
        static let  adBegin = "Ad Begin"
        static let  adEnd = "Ad End"
    }
    
    func shouldHandlePlayerEvents(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        var retValue = false
        let entryId = "11"
        
        guard let currentPlayerPosition = parameters["currentTime"] as? Int else {
            return retValue
        }
        
        switch eventName {
        case PlyerEvents.playing:
            retValue = true
            gemiusPlayerObject?.program(.PLAY, forProgram: entryId,
                                        atOffset: NSNumber(value: currentPlayerPosition),
                                        with: nil)
        case PlyerEvents.paused:
            retValue = true
            gemiusPlayerObject?.program(.PAUSE, forProgram: entryId,
                                        atOffset: NSNumber(value: currentPlayerPosition),
                                        with: nil)
        case PlyerEvents.seeked:
            retValue = true
            gemiusPlayerObject?.program(.SEEK, forProgram: entryId,
                                        atOffset: NSNumber(value: currentPlayerPosition),
                                        with: nil)
        case AdEvents.adBreakBegin:
            retValue = true
            gemiusPlayerObject?.program(.BREAK, forProgram: entryId,
                                        atOffset: NSNumber(value: currentPlayerPosition),
                                        with: nil)
        case AdEvents.adBegin:
            retValue = true
            let data = GSMAdData()
            gemiusPlayerObject?.newAd(UUID().uuidString, with: data)
        default:
            break
        }
        
        return retValue
    }
    
    
}
