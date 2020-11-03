//
//  ZPAppleVideoNowPlayingInfoBase.swift
//  ZappGeneralPlugins
//
//  Created by Alex Zchut on 05/02/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import AVFoundation
import ZappCore
import XrayLogger

struct ItemMetadata {
    static let title = "title"
    static let contentId = "id"
    static let media_group = "media_group"
    static let media_item = "media_item"
    static let summary = "summary"
    static let src = "src"
    static let extensions = "extensions"
    static let serviceId = "apple_umc_service_id"
}

class ZPAppleVideoNowPlayingInfoBase: NSObject, GeneralProviderProtocol, PlayerDependantPluginProtocol {
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/AppleVideoNowPlayingInfo")

    var playerPlugin: PlayerProtocol?
    var playbackStalled: Bool = false

    var avPlayer: AVPlayer? {
        return playerPlugin?.playerObject as? AVPlayer
    }

    public var configurationJSON: NSDictionary?
    public var model: ZPPluginModel?

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }

    public var providerName: String {
        return "Apple Video Now Playing Info"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}
