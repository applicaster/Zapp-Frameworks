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
        static let paused = "Player Pause"
        static let seeking = "Player Seeking"
        static let seeked = "Player Seeked"
        static let dismissed = "Player Dismissed"
        static let created = "Player Created"
    }

    func shouldHandlePlayerEvents(for eventName: String, parameters: [String: NSObject]) -> Bool {
        var retValue = false
        let entryId = "11"

        guard let currentPlayerPosition = parameters["currentTime"] as? Int else {
            return retValue
        }

        switch eventName {
        case PlyerEvents.created:
            retValue = true
            gemiusPlayerObject = GSMPlayer(id: getKey(),
                                           withHost: hitCollectorHost,
                                           withGemiusID: scriptIdentifier,
                                           with: nil)

            let data = GSMProgramData()

//            // set item id
//            data.addCustomParameter("Video UUID", value: entryId)
//            // set item title
//            data.addCustomParameter("Title", value: entryTitle)
            // set program type
            data.programType = .VIDEO
            // set duration
            data.duration = 0

            // set program data
            gemiusPlayerObject?.newProgram(entryId, with: data)
            
            // buffering
            gemiusPlayerObject?.program(.BUFFER, forProgram: entryId,
                                        atOffset: NSNumber(value: currentPlayerPosition),
                                        with: nil)
            
        case PlyerEvents.dismissed:
            retValue = true
            gemiusPlayerObject?.program(.CLOSE, forProgram: entryId,
                                        atOffset: NSNumber(value: currentPlayerPosition),
                                        with: nil)
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
        default:
            break
        }

        return retValue
    }
}
