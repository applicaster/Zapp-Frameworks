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
        static let play = "Player Playing"
        static let paused = "Player Pause"
        static let seeking = "Player Seeking"
        static let seeked = "Player Seeked"
        static let dismissed = "Player Closed"
        static let created = "VOD Item: Play Was Triggered"
    }

    func shouldHandlePlayerEvents(for eventName: String, parameters: [String: NSObject]) -> Bool {
        var retValue = false

        // skip same event
        guard eventName != lastProceededPlayerEvent else {
            return true
        }

        switch eventName {
        case PlyerEvents.created:
            retValue = handleCreateEvent(eventName, parameters: parameters)

        case PlyerEvents.dismissed:
            retValue = handleDismissEvent(eventName, parameters: parameters)
        case PlyerEvents.play:
            retValue = handlePlayEvent(eventName, parameters: parameters)

        case PlyerEvents.paused:
            retValue = handlePauseEvent(eventName, parameters: parameters)

        case PlyerEvents.seeked:
            retValue = handleSeekEvent(eventName, parameters: parameters)

        default:
            break
        }

        return retValue
    }

    func handleCreateEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        guard let itemId = parameters["Item ID"] as? String,
              lastProgramID != itemId else {
            return true
        }

        lastProgramID = itemId
        gemiusPlayerObject = GSMPlayer(id: getKey(),
                                       withHost: hitCollectorHost,
                                       withGemiusID: scriptIdentifier,
                                       with: nil)

        let data = GSMProgramData()

        // set item id
        if let uuid = parameters["uuid"] as? String {
            data.addCustomParameter("Video UUID", value: uuid)
        }

        // set item title
        if let title = parameters["Item Name"] as? String {
            data.addCustomParameter("Title", value: title)
        }

        // set item duration
        if let duration = parameters["Custom Propertylength"] as? String {
            data.addCustomParameter("Duration", value: duration)
        }

        if let jsonString = parameters["Custom PropertyanalyticsCustomProperties"] as? String,
           let jsonData = jsonString.data(using: String.Encoding.utf8),
           let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject] {
            if let cimTag = jsonDictionary["_ST"] as? String {
                data.addCustomParameter("CIM tag", value: cimTag)
            }
        }

        // set program type
        data.programType = .VIDEO

        // set program data
        gemiusPlayerObject?.newProgram(itemId, with: data)

        // buffering
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.BUFFER, forProgram: itemId,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)

        return proceedPlayerEvent(eventName)
    }

    func handleSeekEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.SEEK, forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handlePauseEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.PAUSE, forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handlePlayEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.PLAY, forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handleDismissEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.CLOSE, forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        lastProgramID = nil
        lastProceededPlayerEvent = nil
        return true
    }

    fileprivate func getCurrentPlayerPosition(from parameters: [String: NSObject]) -> Int {
        return parameters["currentTime"] as? Int ?? 0
    }

    fileprivate func proceedPlayerEvent(_ eventName: String) -> Bool {
        lastProceededPlayerEvent = eventName
        return true
    }
}
