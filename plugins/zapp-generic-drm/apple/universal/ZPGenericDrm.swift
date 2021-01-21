//
//  ZPGenericDrm.swift
//  ZappGenericDrm
//
//  Created by Alex Zchut on 12/01/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import AVKit
import XrayLogger
import ZappCore

/// Plugin configuration keys
struct PluginKeys {
    static let certificateUrl = "certificate_url"
    static let licenseServerUrl = "license_server_url"
    static let licenseServerRequestContentType = "license_server_request_content_type"
    static let licenseServerRequestJsonObjectKey = "license_server_request_json_object_key"
}

struct ItemParamsKeys {
    static let avasseturl = "avasseturl"
    static let entry = "entry"
    static let extensions = "extensions"
    static let drm = "drm"
    static let fairplay = "fairplay"
    static let key = "key"
    static let licenseServerUrl = "license_server_url"
    static let licenseServerRequestContentType = "license_server_request_content_type"
    static let licenseServerRequestJsonObjectKey = "license_server_request_json_object_key"
    static let certificateUrl = "certificate_url"
}

class ZPGenericDrm: NSObject, PluginAdapterProtocol, AVAssetResourceLoaderDelegate {
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ZappGenericDrm")

    public var configurationJSON: NSDictionary?
    public var model: ZPPluginModel?

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }

    public var providerName: String {
        return "Generic Drm"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {

        if let assetUrl = defaultParams[ItemParamsKeys.avasseturl] as? AVURLAsset {
            ContentKeyManager.shared.contentKeySession.addContentKeyRecipient(assetUrl)
            ContentKeyManager.shared.setCurrentItemSource(with: defaultParams)
            
            assetUrl.resourceLoader.preloadsEligibleContentKeys = true
        }
        else {
            ContentKeyManager.shared.configurationJSON = configurationJSON
            ContentKeyManager.shared.logger = logger
        }
        
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}
