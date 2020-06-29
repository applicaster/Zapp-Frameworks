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
        metadataItems.append(self.metadataItem(identifier: AVMetadataIdentifier.commonIdentifierTitle,
                                               value: title))
        metadataItems.append(self.metadataItem(identifier: AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierExternalContentIdentifier),
                                               value: contentId))
        metadataItems.append(self.metadataItem(identifier: AVMetadataIdentifier(rawValue: AVKitMetadataIdentifierPlaybackProgress),
                                               value: NSNumber(integerLiteral: 0)))

        
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
}
