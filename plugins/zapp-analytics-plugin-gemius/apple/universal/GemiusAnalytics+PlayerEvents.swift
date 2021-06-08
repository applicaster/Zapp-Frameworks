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
    struct PlayerEvents {
        static let created = "Player Created"
        static let dismissed = "Player Closed"
        static let play = "Player Playing"
        static let resume = "Player Resume"
        static let paused = "Player Pause"
        static let seeking = "Player Seek"
        static let seeked = "Player Seek End"
        static let ended = "Player Ended"
        static let buffering = "Player Buffering"
        static let entryLoaded = "Media Entry Load"
        static let videoLoaded = "Player Loaded Video"
    }
    
    struct GemiusCustomParams {
        static let sc = "_SC"
        static let sct = "_SCT"
        static let scd = "_SCD"

    }
    
    fileprivate var skipKeys: [String] {
        return [
            "video_subtype",
            "video_type",
            GemiusCustomParams.sc,
            GemiusCustomParams.scd,
            GemiusCustomParams.sct
        ]
    }

    func shouldHandlePlayerEvents(for eventName: String, parameters: [String: NSObject]) -> Bool {
        var retValue = false

        // skip same event
        guard eventName != lastProceededPlayerEvent else {
            return true
        }

        switch eventName {
        case PlayerEvents.created:
            retValue = handleCreateEvent(eventName, parameters: parameters)

        case PlayerEvents.dismissed:
            retValue = handleDismissEvent(eventName, parameters: parameters)

        case PlayerEvents.play, PlayerEvents.resume, PlayerEvents.seeked:
            retValue = handlePlayEvent(eventName, parameters: parameters)

        case PlayerEvents.paused:
            retValue = handlePauseEvent(eventName, parameters: parameters)

        case PlayerEvents.seeking:
            retValue = handleSeekingEvent(eventName, parameters: parameters)

        case PlayerEvents.ended:
            retValue = handleEndedEvent(eventName, parameters: parameters)
            
        case PlayerEvents.buffering:
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


        let data = GSMProgramData()

        // set item title
        if let title = parameters["Item Name"] as? String {
            data.name = title
        }

        // set item duration
        if let duration = parameters["Item Duration"] as? String {
            data.duration = NSNumber(value: Int(duration) ?? 0)
        }

        if let jsonString = parameters["analyticsCustomProperties"] as? String,
           let jsonData = jsonString.data(using: String.Encoding.utf8),
           let jsonDictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject] {
            for (key, value) in jsonDictionary {
                switch key {
                case GemiusCustomParams.sc:
                    //update id
                    if let value = jsonDictionary[key] as? String {
                        lastProgramID = value
                    }
                case GemiusCustomParams.sct:
                    //update name
                    if let value = jsonDictionary[key] as? String {
                        data.name = value
                    }
                case GemiusCustomParams.scd:
                    //update duration
                    if let value = jsonDictionary[key] as? Int {
                        data.duration = NSNumber(value: value)
                    }
                default:
                    break
                }
                
                if self.skipKeys.contains(key) == false {
                    data.addCustomParameter(key, value: "\(value)")
                }
            }
        }

        // set program type
        data.programType = .VIDEO

        gemiusPlayerObject = GSMPlayer(id: getKey(),
                                       withHost: hitCollectorHost,
                                       withGemiusID: scriptIdentifier,
                                       with: nil)
        
        // set program data
        gemiusPlayerObject?.newProgram(lastProgramID, with: data)

        return proceedPlayerEvent(eventName)
    }

    func handleSeekingEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        guard adIsPlaying == false else {
            return true
        }
        
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.SEEK,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handleBufferEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        guard adIsPlaying == false else {
            return true
        }
        
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.BUFFER,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handlePauseEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        guard adIsPlaying == false else {
            return true
        }
        
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.PAUSE,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handlePlayEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        guard adIsPlaying == false else {
            return true
        }
        
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.PLAY,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }
    
    func handleEndedEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        guard adIsPlaying == false else {
            return true
        }
        
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
        gemiusPlayerObject?.program(.COMPLETE,
                                    forProgram: lastProgramID,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        return proceedPlayerEvent(eventName)
    }

    func handleDismissEvent(_ eventName: String, parameters: [String: NSObject]) -> Bool {
        guard adIsPlaying == false else {
            return true
        }
        
        let currentPlayerPosition = getCurrentPlayerPosition(from: parameters)
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
