//
//  PipesDataModelHelperMediaGroups.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 8/27/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

public enum PipesDataModelHelperMediaGroupsTypes {
    case image
    case audio
    case video
}

public struct PipesDataModelHelperMediaGroups {
    public let mediaGroupsArray: [[AnyHashable: Any]]?

    public var images: [PipesDataModelHelperMediaItem] = []
    public var audios: [PipesDataModelHelperMediaItem] = []
    public var videos: [PipesDataModelHelperMediaItem] = []

    public init(mediaGroupsArray: [[AnyHashable: Any]]?) {
        self.mediaGroupsArray = mediaGroupsArray
    }

    public mutating func parseMediaGroups() {
        if let mediaGroupsArray = mediaGroupsArray {
            mediaGroupsArray.forEach {
                if let mediaGroupTypeString = $0["type"] as? String,
                    let mediaItems = $0["media_item"] as? [[String: AnyObject]] {
                    mediaItems.forEach {
                        if let src = $0["src"] as? String,
                            let key = $0["key"] as? String {
                            switch mediaGroupTypeString {
                            case "audio":
                                audios.append(PipesDataModelHelperMediaItem(key: src, src: key))
                            case "video":
                                videos.append(PipesDataModelHelperMediaItem(key: src, src: key))
                            default:
                                images.append(PipesDataModelHelperMediaItem(key: src, src: key))
                            }
                        }
                    }
                }
            }
        }
    }

    public func dataForKey(type: PipesDataModelHelperMediaGroupsTypes,
                           key: String) -> PipesDataModelHelperMediaItem? {
        switch type {
        case .audio:
            return audios.first { $0.key == key }
        case .image:
            return images.first { $0.key == key }
        case .video:
            return videos.first { $0.key == key }
        }
    }
}
