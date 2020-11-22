//
//  APAnalyticsProviderCoolaData+PlayerObserverProtocol.swift
//  ZappAnalyticsPluginCoolaData
//
//  Created by Alex Zchut on 22/11/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import ZappCore
import AVFoundation

extension APAnalyticsProviderCoolaData: PlayerObserverProtocol {
    var avPlayer: AVPlayer? {
        return playerPlugin?.playerObject as? AVPlayer
    }

    public func playerDidFinishPlayItem(player: PlayerProtocol, completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    public func playerDidCreate(player: PlayerProtocol) {
        cooladataAnalytics?.playerDidCreate()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAccessLogEntry(notification:)),
                                               name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                               object: nil)
    }

    public func playerDidDismiss(player: PlayerProtocol) {
        if let playerObject = playerPlugin?.playerObject as? AVPlayer {
            playerObject.removeObserver(self,
                                        forKeyPath: "rate",
                                        context: nil)
        }
        cooladataAnalytics?.playerDidFinishPlayItem()
    }

    public func playerProgressUpdate(player: PlayerProtocol, currentTime: TimeInterval, duration: TimeInterval) {
        //
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

        cooladataAnalytics?.playerDidStartPlayItem()
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
                cooladataAnalytics?.playerDidResumePlayItem()
                playbackStalled = false
            }
            // if paused
            else if !playbackStalled, player.rate == 0 {
                cooladataAnalytics?.playerDidPausePlayItem()
                playbackStalled = true
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
