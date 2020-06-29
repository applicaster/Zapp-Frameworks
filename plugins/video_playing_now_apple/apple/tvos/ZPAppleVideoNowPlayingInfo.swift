//
//  ZPAppleVideoNowPlayingInfo.swift
//  ZappAppleVideoNowPlayingInfo for tvOS
//
//  Created by Alex Zchut on 05/02/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import ZappCore
import AVKit

class ZPAppleVideoNowPlayingInfo: ZPAppleVideoNowPlayingInfoBase {

    func metadataItem(identifier : AVMetadataIdentifier, value : (NSCopying & NSObjectProtocol)?) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.value = value
        item.identifier = identifier
        item.extendedLanguageTag = "und" // undefined (wildcard) language
        return item
    }
    
    func metadataArtworkItem(image: UIImage) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        // Choose PNG or JPEG
        item.value = image.pngData() as (NSCopying & NSObjectProtocol)?
        item.dataType = kCMMetadataBaseDataType_PNG as String
        item.identifier = AVMetadataIdentifier.commonIdentifierArtwork
        item.extendedLanguageTag = "und"
        return item
    }
}
