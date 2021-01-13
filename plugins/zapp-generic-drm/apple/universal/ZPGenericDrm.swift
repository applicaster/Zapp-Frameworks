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

    /// Plugin configuration keys
    struct PluginKeys {
        static let certificateUrl = "certificate_url"
        static let licenseServerUrl = "license_url"

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

            completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}
