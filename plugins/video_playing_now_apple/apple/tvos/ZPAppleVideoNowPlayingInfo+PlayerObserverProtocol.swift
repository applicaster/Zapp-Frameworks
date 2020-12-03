//
//  ZPAppleVideoNowPlayingInfo+Observers.swift
//  ZappAppleVideoNowPlayingInfo
//
//  Created by Alex Zchut on 11/02/2020.
//

import AVKit
import Foundation
import ZappCore

extension ZPAppleVideoNowPlayingInfo {
    override public func playerDidCreate(player: PlayerProtocol) {
        // docs https://help.apple.com/itc/tvpumcstyleguide/#/itc0c92df7c9
        currentProgress = 0
        guard let entry = player.entry,
              let currentPlayer = player.playerObject as? AVPlayer,
              let currentItem = currentPlayer.currentItem else {
            return
        }

        guard let title = entry[ItemMetadata.title] as? (NSCopying & NSObjectProtocol),
              let contentId = entry[ItemMetadata.contentId] as? (NSCopying & NSObjectProtocol) else {
            return
        }

        let isLive = isEntryLive(entry: entry)

        var metadataItems: [AVMetadataItem] = [AVMetadataItem]()
        // title
        let titleItem = metadataItem(identifier: AVMetadataIdentifier.commonIdentifierTitle,
                                     value: title)
        metadataItems.append(titleItem)

        // identifier
        if isLive {
            let identifierItem = metadataItem(identifier: AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierServiceIdentifier),
                                              value: contentId)
            metadataItems.append(identifierItem)
        } else {
            let identifierItem = metadataItem(identifier: AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierExternalContentIdentifier),
                                              value: contentId)
            metadataItems.append(identifierItem)
        }

        // image
        if let mediaGroup = entry[ItemMetadata.media_group] as? [[AnyHashable: Any]],
           let mediaItem = mediaGroup.first?[ItemMetadata.media_item] as? [[AnyHashable: Any]],
           let src = mediaItem.first?[ItemMetadata.src] as? String,
           let key = mediaItem.first?["key"] as? String, key == "image_base",
           let url = URL(string: src) {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    metadataItems.append(metadataArtworkItem(image: image))
                }
            }
        }

        // description
        if let summary = entry[ItemMetadata.summary] as? (NSCopying & NSObjectProtocol) {
            metadataItems.append(metadataItem(identifier: AVMetadataIdentifier.commonIdentifierDescription,
                                              value: summary))
        }

        // progress
        if isEntryLive(entry: entry) == false {
            metadataItems.append(metadataItem(identifier: AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierPlaybackProgress),
                                              value: NSNumber(value: currentProgress)))
        }
        currentItem.externalMetadata = metadataItems
    }

    func isEntryLive(entry: [String: Any]) -> Bool {
        guard let extensions = entry[ItemMetadata.extensions] as? [String: Any],
              PipesDataModelHelperExtensions(extensionsDict: extensions).isLive == true else {
            return false
        }
        return true
    }

    override func playerProgressUpdate(player: PlayerProtocol, currentTime: TimeInterval, duration: TimeInterval) {
        super.playerProgressUpdate(player: player,
                                   currentTime: currentTime,
                                   duration: duration)

        updateProgress(player: player,
                       currentTime: currentTime,
                       duration: duration)
    }

    func updateProgress(player: PlayerProtocol,
                        currentTime: TimeInterval,
                        duration: TimeInterval) {
        guard let entry = player.entry,
              isEntryLive(entry: entry) == false,
              let currentPlayer = player.playerObject as? AVPlayer,
              let currentItem = currentPlayer.currentItem else {
            return
        }

        let roundedProgress = progress(currentTime: currentTime,
                                       duration: duration)

        if roundedProgress > currentProgress {
            currentProgress = roundedProgress

            // get exising metadata of currently played item
            var metadataItems = currentItem.externalMetadata

            // playback position identifier
            let identifier = AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierPlaybackProgress)

            // remove old value if exists
            metadataItems.removeAll { (item) -> Bool in
                item.identifier == identifier
            }

            // set new value of current stopped position
            let playbackProgresItem = metadataItem(identifier: AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierPlaybackProgress),
                                                   value: NSNumber(value: roundedProgress))
            metadataItems.append(playbackProgresItem)

            currentItem.externalMetadata = metadataItems
            print("testAnton \(currentProgress) - \(metadataItems)")
        }
    }

    func progress(currentTime: TimeInterval,
                  duration: TimeInterval) -> Double {
        let persentageDuration = currentTime / duration
        let result = Double(round(100 * persentageDuration) / 100)
        return result
    }
}
