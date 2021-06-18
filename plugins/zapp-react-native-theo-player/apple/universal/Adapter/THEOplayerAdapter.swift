//
//  THEOplayerAdapter.swift
//  ZappTHEOplayer
//
//  Created by Anton Kononenko on 2/9/2020
//  Copyright © 2021 Applicaster. All rights reserved.
//
import Foundation
import GoogleCast
import THEOplayerSDK
import ZappCore

open class THEOplayerAdapter: NSObject, PluginAdapterProtocol {
    public var configurationJSON: NSDictionary?
    public var model: ZPPluginModel?
    public var enabled: Bool = false
    public var initialized: Bool = false

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
        THEOplayer.registerContentProtectionIntegration(integrationId: KeyOsDRMIntegration.integrationID,
                                                        keySystem: .FAIRPLAY,
                                                        integrationFactory: KeyOsDRMIntegrationFactory())
    }

    /// Plugin configuration keys
    struct PluginKeys {
        static let applicationID = "chromecast_app_id"
    }

    var chromecastAppId: String? {
        guard let value = configurationJSON?[PluginKeys.applicationID] as? String,
              value.isEmpty == false else {
            return nil
        }
        return value
    }

    open func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    open func prepareProvider(_ defaultParams: [String: Any], completion: ((Bool) -> Void)?) {
        if !initialized,
           let chromecastAppId = chromecastAppId {
            let discoveryCriteria = GCKDiscoveryCriteria(applicationID: chromecastAppId)
            let options = GCKCastOptions(discoveryCriteria: discoveryCriteria)

            GCKCastContext.setSharedInstanceWith(options)
        }

        completion?(true)
    }

    open var providerName: String {
        return "ZappTHEOplayer"
    }
}
