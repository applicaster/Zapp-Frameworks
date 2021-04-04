//
//  GemiusAnalytics+PlayerObserverProtocol.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import AVFoundation
import Foundation
import GemiusSDK
import ZappCore

extension GemiusAnalytics: PlayerObserverProtocol, PlayerDependantPluginProtocol {
    var avPlayer: AVPlayer? {
        return playerPlugin?.playerObject as? AVPlayer
    }

    var currentPlayerPosition: TimeInterval {
        return avPlayer?.currentItem?.currentTime().seconds ?? 0.00
    }

    var entryId: String {
        return playerPlugin?.entry?["id"] as? String ?? ""
    }

    var entryTitle: String {
        return playerPlugin?.entry?["title"] as? String ?? ""
    }

    public func playerDidFinishPlayItem(player: PlayerProtocol, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    public func playerDidCreate(player: PlayerProtocol) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAccessLogEntry(notification:)),
                                               name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                               object: nil)

        gemiusPlayerObject = GSMPlayer(id: getKey(),
                                       withHost: hitCollectorHost,
                                       withGemiusID: scriptIdentifier,
                                       with: nil)

        let data = GSMProgramData()

        // set item id
        data.addCustomParameter("Video UUID", value: entryId)
        // set item title
        data.addCustomParameter("Title", value: entryTitle)
        //set program type
        data.programType = .VIDEO
        
        // set item duration
        if let duration = avPlayer?.currentItem?.duration.seconds {
            data.duration = NSNumber(value: duration)
        }

        // set program data
        gemiusPlayerObject?.newProgram(entryId, with: data)
    }

    public func playerDidDismiss(player: PlayerProtocol) {
        if let playerObject = playerPlugin?.playerObject as? AVPlayer,
           playerRateObserverPointerString == UInt(bitPattern: ObjectIdentifier(playerObject)) {
            playerObject.removeObserver(self,
                                        forKeyPath: "rate",
                                        context: nil)
            playerRateObserverPointerString = nil
        }

        gemiusPlayerObject?.program(.COMPLETE,
                                    forProgram: entryId,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
        
    }

    public func playerProgressUpdate(player: PlayerProtocol,
                                     currentTime: TimeInterval,
                                     duration: TimeInterval) {

    }
    
    public func playerVideoSeek(player: PlayerProtocol,
                                currentTime: TimeInterval,
                                seekTime: TimeInterval) {
        gemiusPlayerObject?.program(.SEEK, forProgram: entryId,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
    }

    @objc func handleAccessLogEntry(notification: NSNotification) {
        // Remove listening to the AccessLogs after first log received
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                                  object: nil)

        // Register for observer for player
        avPlayer?.addObserver(self,
                              forKeyPath: "rate",
                              options: [],
                              context: nil)
        if let avPlayer = avPlayer {
            playerRateObserverPointerString = UInt(bitPattern: ObjectIdentifier(avPlayer))
        }

        gemiusPlayerObject?.program(.PLAY,
                                    forProgram: entryId,
                                    atOffset: NSNumber(value: currentPlayerPosition),
                                    with: nil)
    }

    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if let object = object as? AVPlayer,
           let player = avPlayer,
           object == player {
            // if playing

            if currentPlayerPosition > 5 {
                if playbackStalled, player.rate > 0 {
                    gemiusPlayerObject?.program(.PLAY,
                                                forProgram: entryId,
                                                atOffset: NSNumber(value: currentPlayerPosition),
                                                with: nil)
                    playbackStalled = false
                }
                // if paused
                else if !playbackStalled, player.rate == 0 {
                    gemiusPlayerObject?.program(.PAUSE,
                                                forProgram: entryId,
                                                atOffset: NSNumber(value: currentPlayerPosition),
                                                with: nil)
                    
                    playbackStalled = true
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
