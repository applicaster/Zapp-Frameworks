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

        switch eventName {
        case AdEvents.adBreakBegin:
            let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
            gemiusPlayerObject?.program(.BREAK,
                                        forProgram: lastProgramID,
                                        atOffset: NSNumber(value: currentPlayerPosition),
                                        with: nil)
            retValue = proceedAdEvent(eventName)
            
        case AdEvents.adBegin:
            let data = GSMAdData()
            gemiusPlayerObject?.newAd(UUID().uuidString,
                                      with: data)
            retValue = proceedAdEvent(eventName)

        default:
            break
        }

        return retValue
    }

    fileprivate func proceedAdEvent(_ eventName: String) -> Bool {
        lastProceededAdEvent = eventName
        return true
    }
}
