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

struct ContentKeyRequestParams {
    var certificateUrlString: String?
    var licenseServerUrlString: String?
    var licenseServerRequestContentType: String?
    var licenseServerRequestJsonObjectKey: String?
}

class ZPGenericDrm: NSObject, PluginAdapterProtocol, AVAssetResourceLoaderDelegate {
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ZappGenericDrm")
    lazy var contentKeyManager: ContentKeyManager = {
        var manager = ContentKeyManager.shared
        manager.configurationJSON = configurationJSON
        manager.logger = logger
        return manager
    }()
    
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

        if let assetUrl = defaultParams[ItemParamsKeys.avasseturl] as? AVURLAsset,
           let requestParams = contentKeyRequestParams(from: defaultParams) {
            contentKeyManager.contentKeySession.addContentKeyRecipient(assetUrl)
            contentKeyManager.setContentKeyRequestParams(requestParams)
            
            assetUrl.resourceLoader.preloadsEligibleContentKeys = true
        }
        
        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}

extension ZPGenericDrm {
    func contentKeyRequestParams(from params:  [String: Any]?) -> ContentKeyRequestParams? {
        guard let entry = params?[ItemParamsKeys.entry] as? [String: Any],
          let extensions = entry[ItemParamsKeys.extensions] as? [String: Any],
          let drm = extensions[ItemParamsKeys.drm] as? [String: Any],
          let fairplay = drm[ItemParamsKeys.fairplay] as? [String: Any] else {
            return nil
        }
        return createParams(from: fairplay)
    }
    
    func getParam(from value: String?, defaultValue: String?) -> String? {
        return value ?? defaultValue
    }

    func createParams(from dict: [String: Any]) -> ContentKeyRequestParams {
        let licenseServerRequestContentType = getParam(from: dict[ItemParamsKeys.licenseServerRequestContentType] as? String,
                                                       defaultValue: configurationJSON?[PluginKeys.licenseServerRequestContentType] as? String)
        let licenseServerRequestJsonObjectKey = getParam(from: dict[ItemParamsKeys.licenseServerRequestJsonObjectKey] as? String,
                                                         defaultValue: configurationJSON?[PluginKeys.licenseServerRequestJsonObjectKey] as? String)

        let certificateUrlString = getParam(from: dict[ItemParamsKeys.certificateUrl] as? String,
                                            defaultValue: configurationJSON?[PluginKeys.certificateUrl] as? String)

        let licenseServerUrlString = getParam(from: dict[ItemParamsKeys.licenseServerUrl] as? String,
                                              defaultValue: configurationJSON?[PluginKeys.licenseServerUrl] as? String)

        return ContentKeyRequestParams(certificateUrlString: certificateUrlString,
                                       licenseServerUrlString: licenseServerUrlString,
                                       licenseServerRequestContentType: licenseServerRequestContentType,
                                       licenseServerRequestJsonObjectKey: licenseServerRequestJsonObjectKey)
    }
}
