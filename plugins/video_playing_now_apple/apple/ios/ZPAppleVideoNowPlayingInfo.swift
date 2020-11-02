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

    enum PlaybackType: String {
        case vod = "VOD"
        case live = "LIVE"
    }
    
    override func disable(completion: ((Bool) -> Void)?) {
        logger?.debugLog(message: "Disabling plugin")

        avPlayer?.removeObserver(self,
                                 forKeyPath: "rate",
                                 context: nil)

        unregisterForRemoteCommands()

        super.disable(completion: completion)
    }
    
    var playbackType: PlaybackType {
        var retValue: PlaybackType = .vod
        if let playbackType = avPlayer?.currentItem?.accessLog()?.events.last?.playbackType,
           playbackType == PlaybackType.live.rawValue {
            retValue = .live
        }
        return retValue
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

    func sendNowPlayingInitial() {
        guard let entry = playerPlugin?.entry else {
            return
        }

        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = [String: Any]()
        if let title = entry[ItemMetadata.title] as? (NSCopying & NSObjectProtocol) {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        switch self.playbackType {
        case .vod:
            if let contentIdString = entry[ItemMetadata.contentId] as? String,
               let contentIdInt = Int(contentIdString) {
                let contentId = NSNumber(value: contentIdInt)
                nowPlayingInfo[MPNowPlayingInfoPropertyExternalContentIdentifier] = contentId
            }
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerPlugin?.playbackDuration()
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerPlugin?.playbackPosition()

        case .live:
            nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = 1
            if let entensions = entry[ItemMetadata.extensions] as? [String: Any],
               let serviceId = entensions[ItemMetadata.serviceId] {
                nowPlayingInfo[MPNowPlayingInfoPropertyServiceIdentifier] = serviceId
            }
            
            if #available(iOS 11.1, *) {
                nowPlayingInfo[MPNowPlayingInfoPropertyCurrentPlaybackDate] = Date()
            }
        }

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

        //send logger event
        var data = nowPlayingInfo
        data["playbackType"] = self.playbackType.rawValue
        data["MPNowPlayingInfoPropertyCurrentPlaybackDate"] = Date().timeIntervalSince1970
        data[MPMediaItemPropertyArtwork] = nil
        logger?.debugLog(message: "Initial NPI content",
                         data: data)

        npiLogger = NowPlayingLogger()
        npiLogger?.start()
    }
}
