//
//  GemiusAnalytics+PlayerObserverProtocol.swift
//  GemiusAnalytics
//
//  Created by Alex Zchut on 29/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import AVFoundation
import Foundation
import ZappCore

extension GemiusAnalytics: PlayerObserverProtocol, PlayerDependantPluginProtocol {
    var avPlayer: AVPlayer? {
        return playerPlugin?.playerObject as? AVPlayer
    }

    var currentPlayerPosition: Double {
        return getCurrentPlayerInstance()?.currentItem?.currentTime().seconds ?? 0.00
    }
    
    var lastSavedPlayerPosition: Double {
        return objcHelper?.playerPlayedTime ?? 0.0
    }
    
    var lastSavedAdPosition: Double {
        return objcHelper?.adPlayedTime ?? 0.00
    }
    
    public func playerDidFinishPlayItem(player: PlayerProtocol, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    public func playerDidCreate(player: PlayerProtocol) {
        objcHelper?.playerPlayedTime = 0.00

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAccessLogEntry(notification:)),
                                               name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                               object: nil)

        if #available(tvOS 13.0, *) {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleMediaSelectionChange(notification:)),
                                                   name: AVPlayerItem.mediaSelectionDidChangeNotification,
                                                   object: nil)
        }
    }

    public func playerDidDismiss(player: PlayerProtocol) {
        if let playerObject = playerPlugin?.playerObject as? AVPlayer,
           playerRateObserverPointerString == UInt(bitPattern: ObjectIdentifier(playerObject)) {
            playerObject.removeObserver(self,
                                        forKeyPath: "rate",
                                        context: nil)
            playerRateObserverPointerString = nil
        }
        
        objcHelper?.prepareEventPlayerDidFinishPlayItem { eventName, parameters in
            let trackParameters = parameters as? [String: NSObject] ?? [:]
            self.trackEvent(eventName, parameters: trackParameters)
        }
    }

    public func playerProgressUpdate(player: PlayerProtocol, currentTime: TimeInterval, duration: TimeInterval) {
        let heartbeatDelay = 15.0
        if lastSavedPlayerPosition + heartbeatDelay < currentTime {
            objcHelper?.prepareEventPlayerPlaybackProgress(currentTime) { eventName, parameters in
                let trackParameters = parameters as? [String: NSObject] ?? [:]
                self.trackEvent(eventName, parameters: trackParameters)
            }
        }
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
        
        objcHelper?.prepareEventPlayerDidStartPlayItem { eventName, parameters in
            let trackParameters = parameters as? [String: NSObject] ?? [:]
            self.trackEvent(eventName, parameters: trackParameters)
        }
    }

    @objc func handleMediaSelectionChange(notification: NSNotification) {
        objcHelper?.prepareEventPlayerMediaSelectionChange(with: notification as Notification,
                                                           completion: { parameters in
                                                               if let parameters = parameters as? [String: NSObject] {
                                                                   // post subtitles change
                                                                   var eventName = "Subtitle Language Changed"
                                                                   self.trackEvent(eventName, parameters: parameters)

                                                                   // post audio change
                                                                   eventName = "Audio Language Selected"
                                                                   self.trackEvent(eventName, parameters: parameters)
                                                               }
                                                           })
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
                    objcHelper?.prepareEventPlayerResumePlayback { eventName, parameters in
                        let trackParameters = parameters as? [String: NSObject] ?? [:]
                        self.trackEvent(eventName, parameters: trackParameters)
                    }
                    playbackStalled = false
                }
                // if paused
                else if !playbackStalled, player.rate == 0 {
                    objcHelper?.prepareEventPlayerPausePlayback { eventName, parameters in
                        let trackParameters = parameters as? [String: NSObject] ?? [:]
                        self.trackEvent(eventName, parameters: trackParameters)
                    }
                    playbackStalled = true
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
