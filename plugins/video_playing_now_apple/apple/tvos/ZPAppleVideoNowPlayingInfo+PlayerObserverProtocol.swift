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
    
    public override func playerDidCreate(player: PlayerProtocol) {
        //docs https://help.apple.com/itc/tvpumcstyleguide/#/itc0c92df7c9

        guard let entry = player.entry else {
            return
        }

        guard let title = entry[ItemMetadata.title] as? (NSCopying & NSObjectProtocol),
            let contentId = entry[ItemMetadata.contentId] as? (NSCopying & NSObjectProtocol) else {
                return
        }

        var metadataItems: [AVMetadataItem] = [AVMetadataItem]()
        //title
        let titleItem = self.metadataItem(identifier: AVMetadataIdentifier.commonIdentifierTitle,
                                          value: title)
        metadataItems.append(titleItem)
        
        //identifier
        let identifierItem = self.metadataItem(identifier: AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierExternalContentIdentifier),
                                               value: contentId)
        metadataItems.append(identifierItem)
        
        //image
        if let mediaGroup = entry[ItemMetadata.media_group] as? [[AnyHashable: Any]],
            let mediaItem = mediaGroup.first?[ItemMetadata.media_item] as? [[AnyHashable: Any]],
            let src = mediaItem.first?[ItemMetadata.src] as? String,
            let key = mediaItem.first?["key"] as? String, key == "image_base",
            let url = URL(string: src) {
            
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    metadataItems.append(self.metadataArtworkItem(image: image))
                }
            }
        }
        
        //description
        if let summary = entry[ItemMetadata.summary] as? (NSCopying & NSObjectProtocol) {
            metadataItems.append(self.metadataItem(identifier: AVMetadataIdentifier.commonIdentifierDescription,
                                                   value: summary))
        }
        
        avPlayer?.currentItem?.externalMetadata = metadataItems
    }
    
    override func playerDidDismiss(player: PlayerProtocol) {
        //update playback position for currently played item

        //get exising metadata of currently played item
        var metadataItems = avPlayer?.currentItem?.externalMetadata ?? [AVMetadataItem]()
        //playback position identifier
        let identifier = AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierPlaybackProgress)
        //remove old value if exists
        metadataItems.removeAll { (item) -> Bool in
            return item.identifier == identifier
        }
        //set new value of current stopped position
        let playbackProgress = player.playbackPosition() / player.playbackDuration()
        let playbackProgresItem = self.metadataItem(identifier: AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierPlaybackProgress),
                                                    value: NSNumber(value: playbackProgress))
        metadataItems.append(playbackProgresItem)
    }
}
