//
//  ZPAppleVideoNowPlayingInfo+Observers.swift
//  ZappAppleVideoNowPlayingInfo
//
//  Created by Alex Zchut on 11/02/2020.
//

import Foundation
import AVKit
import ZappCore

extension ZPAppleVideoNowPlayingInfo {
    public override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {

        if let object = object as? AVPlayer,
            let player = avPlayer,
            object == player {

            //if playing
            if playbackStalled, player.rate > 0 {
                playbackStalled = false
            }
            //if paused
            else if !playbackStalled, player.rate == 0 {
                self.sendNowPlayingOnPause()
                playbackStalled = true
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}

extension ZPAppleVideoNowPlayingInfo {

    public override func playerDidCreate(player: PlayerProtocol) {
        //docs https://help.apple.com/itc/tvpumcstyleguide/#/itc0c92df7c9

        //Registering for Remote Commands
        registerForRemoteCommands()

        //Disable AVKit Now Playing Updates
        disableNowPlayingUpdates()

        //Send Now Playing Info
        sendNowPlayingInitial(player: player)

        //Register for oobserver for player
        avPlayer?.addObserver(self,
                              forKeyPath: "rate",
                              options: [],
                              context: nil)
    }

    public override func playerDidDismiss(player: PlayerProtocol) {
        avPlayer?.removeObserver(self,
                                 forKeyPath: "rate",
                                 context: nil)
        logger?.stop()
    }
}
