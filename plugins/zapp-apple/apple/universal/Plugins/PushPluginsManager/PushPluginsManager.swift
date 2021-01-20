//
//  PushPluginsManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 1/24/20.
//

import Foundation
import XrayLogger
import ZappCore

public class PushPluginsManager: PluginManagerBase {
    typealias pluginTypeProtocol = PushProviderProtocol
    var _providers: [String: PushProviderProtocol] {
        return providers as? [String: PushProviderProtocol] ?? [:]
    }

    required init() {
        super.init()
        pluginType = .Push
        logger = Logger.getLogger(for: PushPluginsManagerLogs.subsystem)
    }

    override public func providerCreated(provider: PluginAdapterProtocol,
                                         completion: PluginManagerCompletion) {
        if let provider = provider as? PushProviderProtocol,
           let uuid = SessionStorage.sharedInstance.get(key: ZappStorageKeys.uuid,
                                                        namespace: nil) {
            provider.prepareProvider(["identity_client_device_id": uuid]) { succed in
                completion?(succed)
            }
        } else {
            completion?(false)
        }
    }

    public func registerDeviceToken(data: Data) {
        let dataAsString = String(decoding: data, as: UTF8.self)
        logger?.verboseLog(template: PushPluginsManagerLogs.registerDeviceToken,
                           data: ["token": dataAsString])

        _providers.forEach { providerDict in
            let provider = providerDict.value
            provider.didRegisterForRemoteNotificationsWithDeviceToken?(data)
        }
    }
}
