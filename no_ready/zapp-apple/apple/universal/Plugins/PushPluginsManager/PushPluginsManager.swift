//
//  PushPluginsManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 1/24/20.
//

import Foundation
import ZappCore

public class PushPluginsManager: PluginManagerBase {
    typealias pluginTypeProtocol = PushProviderProtocol
    var _providers: [String: PushProviderProtocol] {
        return providers as? [String: PushProviderProtocol] ?? [:]
    }

    required init() {
        super.init()
        pluginType = .Push
    }

    public override func providerCreated(provider: PluginAdapterProtocol,
                                         completion: PluginManagerCompletion) {
        if let provider = provider as? PushProviderProtocol,
            let uuid = SessionStorage.sharedInstance.get(key: ZappStorageKeys.uuid,
                                                             namespace: nil) {
            provider.prepareProvider(["identity_client_device_id": uuid]) { succed in
                completion?(succed)
            }
        }
    }

    public func registerDeviceToken(data: Data) {
        _providers.forEach { providerDict in
            let provider = providerDict.value
            provider.didRegisterForRemoteNotificationsWithDeviceToken?(data)
        }
    }
}
