//
//  ZPAppleVideoNowPlayingInfo+Observers.swift
//  ZappAppleVideoNowPlayingInfo
//
//  Created by Alex Zchut on 11/02/2020.
//

import AVKit
import Foundation
import MediaPlayer
import ZappCore

extension ZPAppleVideoNowPlayingInfo {
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if let object = object as? AVPlayer,
            let player = avPlayer,
            object == player {
            // if playing
            if playbackStalled, player.rate > 0 {
                updatePlaybackRate(player.rate)
                playbackStalled = false
            }
            // if paused
            else if !playbackStalled, player.rate == 0 {
                updatePlaybackRate(player.rate)
                playbackStalled = true
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    override public func playerDidCreate(player: PlayerProtocol) {
        // docs https://help.apple.com/itc/tvpumcstyleguide/#/itc0c92df7c9

        guard let playerObject = playerPlugin?.playerObject as? AVPlayer else {
            return
        }

        // Registering for Remote Commands
        registerForRemoteCommands()

        // Disable AVKit Now Playing Updates
        disableNowPlayingUpdates()

        // Send Now Playing Info
        sendNowPlayingInitial(player: player)

        // Register for oobserver for player
        playerObject.addObserver(self,
                                 forKeyPath: "rate",
                                 options: [],
                                 context: nil)
    }

    override public func playerDidDismiss(player: PlayerProtocol) {
        if let playerObject = playerPlugin?.playerObject as? AVPlayer {
            playerObject.removeObserver(self,
                                        forKeyPath: "rate",
                                        context: nil)
        }

        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        nowPlayingInfoCenter.nowPlayingInfo = nil

        logger?.debugLog(message: "Stop collecting NPI on playerDidDismiss")
        npiLogger?.logEvent()
        npiLogger?.stop()
    }

    func updatePlaybackRate(_ rate: Float) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo
        
        if let player = playerPlugin {
            // update playback position for currently played item
            let playbackProgress = player.playbackPosition() / player.playbackDuration()
            nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackProgress] = playbackProgress
            nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.playbackPosition()
        }
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = rate
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
        logger?.debugLog(message: "Update NPI on playback rate change",
                         data: nowPlayingInfo)
        npiLogger?.logEvent()
    }
}
