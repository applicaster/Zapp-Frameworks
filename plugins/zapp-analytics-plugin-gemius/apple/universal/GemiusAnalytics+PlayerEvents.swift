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
        static let dismissed = "Play VOD Item.end"
        static let created = "Play VOD Item.start"
        static let buffering = "Player Load Start"
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

        case PlyerEvents.buffering:
            retValue = handleBufferEvent(eventName, parameters: parameters)

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
            data.name = title
        }

        // set item duration
        if let duration = parameters["Custom Propertylength"] as? String {
            data.duration = NSNumber(value: Int(duration) ?? 0)
        }

        if let jsonString = parameters["Custom PropertyanalyticsCustomProperties"] as? String,
           let jsonData = jsonString.data(using: String.Encoding.utf8),
           let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject] {
            for (key, value) in jsonDictionary {
                var updatedKey = key.lowercased()
                updatedKey = updatedKey.first == "_" ? String(updatedKey.dropFirst()) : updatedKey
                data.addCustomParameter(updatedKey, value: "\(value)")
            }
        }

        // set program type
        data.programType = .VIDEO

        // set program data
        gemiusPlayerObject?.newProgram(itemId, with: data)

        return proceedPlayerEvent(eventName)
    }

    func handleSeekEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.SEEK,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handleBufferEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.BUFFER,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handlePauseEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.PAUSE,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handlePlayEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.PLAY,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handleDismissEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.STOP,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        gemiusPlayerObject?.program(.CLOSE,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        lastProgramID = nil
        lastProceededPlayerEvent = nil
        return true
    }

    fileprivate func proceedPlayerEvent(_ eventName: String) -> Bool {
        lastProceededPlayerEvent = eventName
        return true
    }
}