//
//  ZPAppleVideoNowPlayingInfo.swift
//  ZappAppleVideoNowPlayingInfo for iOS
//
//  Created by Alex Zchut on 05/02/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import AVKit
import MediaPlayer
import ZappCore

class ZPAppleVideoNowPlayingInfo: ZPAppleVideoNowPlayingInfoBase {
    var npiLogger: NowPlayingLogger?

    override func disable(completion: ((Bool) -> Void)?) {
        logger?.debugLog(message: "Disabling plugin")

        avPlayer?.removeObserver(self,
                                 forKeyPath: "rate",
                                 context: nil)

        unregisterForRemoteCommands()

        super.disable(completion: completion)
    }

    func registerForRemoteCommands() {
        logger?.debugLog(message: "Registering for remote commands")

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            // pause player
            self.logger?.debugLog(message: "Remote Pause command received")

            self.avPlayer?.pause()
            return .success
        }
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            // play player
            self.logger?.debugLog(message: "Remote Play command received")

            self.avPlayer?.play()
            return .success
        }
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.seekForwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            // seek forward
            self.logger?.debugLog(message: "Remote Seek Forward command received")

            guard let command = event.command as? MPSkipIntervalCommand,
                  let interval = command.preferredIntervals.first else {
                return .noSuchContent
            }

            return self.seek(with: interval.doubleValue) ? .success : .commandFailed
        }
        commandCenter.seekBackwardCommand.isEnabled = true
        commandCenter.seekBackwardCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            // seek backward
            self.logger?.debugLog(message: "Remote Seek Backward command received")

            guard let command = event.command as? MPSkipIntervalCommand,
                  let interval = command.preferredIntervals.first else {
                return .noSuchContent
            }

            return self.seek(with: -interval.doubleValue) ? .success : .commandFailed
        }
    }
    
    func seek(with interval: Double) -> Bool {
        guard let player = self.avPlayer,
              let duration  = player.currentItem?.duration else {
            return false
        }
        
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = playerCurrentTime + interval

        if newTime < CMTimeGetSeconds(duration) {
            let time = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
            player.seek(to: time)
        }
        
        return true
    }

    func unregisterForRemoteCommands() {
        logger?.debugLog(message: "Unregistering from remote commands")

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.seekBackwardCommand.isEnabled = false
        commandCenter.seekBackwardCommand.removeTarget(nil)
        commandCenter.seekForwardCommand.isEnabled = false
        commandCenter.seekForwardCommand.removeTarget(nil)
    }

    func disableNowPlayingUpdates() {
        if let avPlayerViewController = playerPlugin?.pluginPlayerViewController as? AVPlayerViewController {
            avPlayerViewController.updatesNowPlayingInfoCenter = false
        }
    }

    func sendNowPlayingInitial(player: PlayerProtocol) {
        guard let entry = player.entry else {
            return
        }

        guard let title = entry[ItemMetadata.title] as? (NSCopying & NSObjectProtocol),
            let contentIdString = entry[ItemMetadata.contentId] as? String,
            let contentIdInt = Int(contentIdString) else {
            return
        }
        let contentId = NSNumber(value: contentIdInt)

        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.playbackDuration()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.playbackPosition()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        nowPlayingInfo[MPNowPlayingInfoPropertyExternalContentIdentifier] = contentId
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackProgress] = 0.0

        // image
        if let mediaGroup = entry[ItemMetadata.media_group] as? [[AnyHashable: Any]],
            let mediaItem = mediaGroup.first?[ItemMetadata.media_item] as? [[AnyHashable: Any]],
            let src = mediaItem.first?[ItemMetadata.src] as? String,
            let key = mediaItem.first?["key"] as? String, key == "image_base",
            let url = URL(string: src) {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in
                        image
                    }
                }
            }
        }

        // description
        if let summary = entry[ItemMetadata.summary] as? String {
            nowPlayingInfo[MPMediaItemPropertyComments] = summary
        }

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo

        var data = nowPlayingInfo
        data[MPMediaItemPropertyArtwork] = nil
        logger?.debugLog(message: "Initial NPI content",
                         data: data)

        npiLogger = NowPlayingLogger()
        npiLogger?.start()
    }
}
