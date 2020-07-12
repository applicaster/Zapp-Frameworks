//
//  ZPAppleVideoNowPlayingInfo+Observers.swift
//  ZappAppleVideoNowPlayingInfo
//
//  Created by Alex Zchut on 11/02/2020.
//

import Foundation
import AVKit
import ZappCore
import MediaPlayer

extension ZPAppleVideoNowPlayingInfo {

    public override func playerDidCreate(player: PlayerProtocol) {
        //docs https://help.apple.com/itc/tvpumcstyleguide/#/itc0c92df7c9

        //Registering for Remote Commands
        registerForRemoteCommands()

        //Disable AVKit Now Playing Updates
        disableNowPlayingUpdates()

        //Send Now Playing Info
        sendNowPlayingInitial(player: player)
    }

    public override func playerDidDismiss(player: PlayerProtocol) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo

        //update playback position for currently played item
        let playbackProgress = player.playbackPosition() / player.playbackDuration()

        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackProgress] = playbackProgress
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.playbackPosition()
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
        logger?.stop()
    }
}