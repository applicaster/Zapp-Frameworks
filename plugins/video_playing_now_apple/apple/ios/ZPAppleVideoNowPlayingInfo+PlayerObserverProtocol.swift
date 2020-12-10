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

        // Registering for Remote Commands
        registerForRemoteCommands()

        // Disable AVKit Now Playing Updates
        disableNowPlayingUpdates()

        // Start listening to NPI after player buffered and get the AccessLogs events so we know the playback type of it.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAccessLogEntry(notification:)),
                                               name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                               object: nil)
    }

    @objc func handleAccessLogEntry(notification: NSNotification) {
        // Remove listening to the AccessLogs after first log received
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemNewAccessLogEntry,
                                                  object: nil)
        // Send Now Playing Info
        sendNowPlayingInitial()

        // Register for oobserver for player
        avPlayer?.addObserver(self,
                              forKeyPath: "rate",
                              options: [],
                              context: nil)
        

    }

    override public func playerDidDismiss(player: PlayerProtocol) {
        npiLogger?.stop()
        npiLogger = nil
        if let playerObject = playerPlugin?.playerObject as? AVPlayer {
            playerObject.removeObserver(self,
                                        forKeyPath: "rate",
                                        context: nil)
        }
        
        unregisterForRemoteCommands()
        logger?.debugLog(message: "Stop collecting NPI on playerDidDismiss")
        playerPlugin = nil
        configurationJSON = nil
        model = nil
        logger = nil
    }

    func updatePlaybackRate(_ rate: Float) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo

        switch playbackType {
        case .vod:
            if let position = playerPlugin?.playbackPosition() {
                nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Int(position)
            }

        case .live:
            // nothing to add
            break
        }

        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = rate
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo

        var data = nowPlayingInfo
        data?[MPMediaItemPropertyArtwork] = nil
        data?["playbackType"] = playbackType.rawValue
        logger?.debugLog(message: "Update NPI on playback rate change",
                         data: data)
    }
}
