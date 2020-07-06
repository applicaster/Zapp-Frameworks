//
//  ChromecastPlayableItem.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation

public class ChromecastPlayableItem: NSObject {
    struct Metadata {
        static let title = "title"
        static let summary = "subtitle"
        static let duration = "duration"
        static let mediaUrl = "mediaUrl"
        static let content_type = "content.type"
        static let analytics = "analytics"
        static let imageUrl = "imageUrl"
        static let posterUrl = "posterUrl"

    }
    
    public var entry: [String: Any]?

    init(entry: [String: Any]?) {
        super.init()
        self.entry = entry
    }
    
    lazy public var title: String? = {
        return entry?[Metadata.title] as? String
    }()
    
    lazy public var summary: String? = {
        return entry?[Metadata.summary] as? String
    }()
    
    lazy public var duration: TimeInterval = {
        return entry?[Metadata.duration] as? TimeInterval ?? 0.00
    }()
    
    lazy public var src: String? = {
        return entry?[Metadata.mediaUrl]  as? String
    }()
    
    lazy public var analytics: NSDictionary? = {
        return entry?[Metadata.analytics] as? NSDictionary
    }()

    lazy public var isLive: Bool = {
        return false
    }()
    
    lazy public var defaultImageUrl: String? = {
        return entry?[Metadata.imageUrl]  as? String
    }()
    
    lazy public var chromecastPosterImageUrl: String? = {
        return entry?[Metadata.posterUrl]  as? String
    }()
}
