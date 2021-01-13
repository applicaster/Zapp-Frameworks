//
//  ZPGenericDrm.swift
//  ZappGenericDrm
//
//  Created by Alex Zchut on 12/01/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import ZappCore
import AVKit
import XrayLogger

class ZPGenericDrm: NSObject, PluginAdapterProtocol {
    lazy var logger = Logger.getLogger(for: "\(kNativeSubsystemPath)/ZappGenericDrm")

    public var configurationJSON: NSDictionary?
    public var model: ZPPluginModel?
    public var params: [String: Any]?

    /// Plugin configuration keys
    struct PluginKeys {
        static let certificateUrl = "certificate_url"
        static let licenseServerUrl = "license_url"
    }
    
    struct ItemParamsKeys {
        static let entry = "entry"
        static let extensions = "extensions"
        static let drm = "drm"
        static let fairplay = "fairplay"
        static let licenseServerUrl = "license_server_url"
        static let certificateUrl = "certificate_url"
    }

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
    }

    public var providerName: String {
        return "Generic Drm"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((_ isReady: Bool) -> Void)?) {
            params = defaultParams
            completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}
