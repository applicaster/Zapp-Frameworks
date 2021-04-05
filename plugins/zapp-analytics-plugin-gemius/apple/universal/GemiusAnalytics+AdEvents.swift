//
//  GemiusAnalytics+AdEvents.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 04/04/2021.
//

import Foundation
import GemiusSDK

extension GemiusAnalytics {
    struct AdEvents {
        static let adBreakBegin = "Ad Break Begin"
        static let adBreakEnd = "Ad Break End"
        static let adError = "Ad Error"
        static let adBegin = "Ad Begin"
        static let adEnd = "Ad End"
    }

    func shouldHandleAdEvents(for eventName: String, parameters: [String: NSObject]) -> Bool {
        var retValue = false
        let entryId = "11"

        guard let currentPlayerPosition = parameters["currentTime"] as? Int else {
            return retValue
        }
        
        switch eventName {
        case AdEvents.adBreakBegin:
            retValue = proceedAdEvent(eventName)
            gemiusPlayerObject?.program(.BREAK, forProgram: entryId,
                                        atOffset: NSNumber(value: currentPlayerPosition),
                                        with: nil)
        case AdEvents.adBegin:
            retValue = proceedAdEvent(eventName)
            let data = GSMAdData()
            gemiusPlayerObject?.newAd(UUID().uuidString, with: data)
        default:
            break
        }

        return retValue
    }
    
    func proceedAdEvent(_ eventName: String) -> Bool {
        lastProceededAdEvent = eventName
        return true
    }
}
