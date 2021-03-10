//
//  SegmentAnalytics+PlayerObserverProtocol.swift
//  SegmentAnalytics
//
//  Created by Alex Zchut on 10/03/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import ZappCore
import AVFoundation

extension SegmentAnalytics: PlayerObserverProtocol, PlayerDependantPluginProtocol {
    var avPlayer: AVPlayer? {
        return playerPlugin?.playerObject as? AVPlayer
    }

    public func playerDidFinishPlayItem(player: PlayerProtocol, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    public func playerDidCreate(player: PlayerProtocol) {
        objcHelper?.maxPosition = "0"

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
        if let playerObject = playerPlugin?.playerObject as? AVPlayer {
            playerObject.removeObserver(self,
                                        forKeyPath: "rate",
                                        context: nil)
        }
        objcHelper?.prepareEventPlayerDidFinishPlayItem { eventName, parameters in
            let trackParameters = parameters as? [String: NSObject] ?? [:]
            self.trackEvent(eventName, parameters: trackParameters)
        }
    }

    public func playerProgressUpdate(player: PlayerProtocol, currentTime: TimeInterval, duration: TimeInterval) {
        objcHelper?.prepareEventPlayerPlaybackProgress { eventName, parameters in
            let trackParameters = parameters as? [String: NSObject] ?? [:]
            self.trackEvent(eventName, parameters: trackParameters)
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

        objcHelper?.prepareEventPlayerDidStartPlayItem { eventName, parameters in
            let trackParameters = parameters as? [String: NSObject] ?? [:]
            self.trackEvent(eventName, parameters: trackParameters)
        }
    }
    
    @objc func handleMediaSelectionChange(notification: NSNotification) {
        objcHelper?.prepareEventPlayerMediaSelectionChange(with: notification as Notification,
                                                           completion: { (parameters) in
                                                            //post subtitles change
                                                            var eventName = "Subtitle Language Changed"
                                                            let trackParameters = parameters as? [String: NSObject] ?? [:]
                                                            self.trackEvent(eventName, parameters: trackParameters)
                                                            
                                                            //post audio change
                                                            eventName = "Audio Language Selected"
                                                            self.trackEvent(eventName, parameters: trackParameters)
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
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
