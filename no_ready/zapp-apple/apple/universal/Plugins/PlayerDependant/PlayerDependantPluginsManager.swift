//
//  PlayerDependantPluginsManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/17/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import ZappCore

@objc public class PlayerDependantPluginsManager: NSObject, PluginManagerControlFlowProtocol {
    /// List of registered providers for player Plugins
    var providers: [String: [String: PlayerDependantPluginProtocol]] = [:]

    /// Unregister dependants plugins
    ///
    /// - Parameter playerPlugin: Player plugin that conform PlayerProtocol that uses dependant plugins
    @objc public func unRegisterProviders(playerPlugin: PlayerProtocol) {
        providers["\(playerPlugin.hash)"] = nil
    }

    /// Retrieve list provider for plugin
    ///
    /// - Parameter playerPlugin: Player plugin that conform PlayerProtocol that uses dependant plugins
    /// - Returns: Array of instances of the dependant providers that are conforming ZPPlayerDependantPluginProtocol protocol
    @objc public func providers(playerPlugin: PlayerProtocol) -> [String: PlayerDependantPluginProtocol]? {
        return providers["\(playerPlugin.hash)"]
    }

    @objc public func createPlayerDependantProviders(for player: PlayerProtocol) -> [String: PlayerDependantPluginProtocol] {
        var retVal: [String: PlayerDependantPluginProtocol] = [:]

        if let pluginModels = FacadeConnector.connector?.pluginManager?.getAllPlugins() {
            for pluginModel in pluginModels {
                if let classType = FacadeConnector.connector?.pluginManager?.adapterClass(pluginModel) as? PlayerDependantPluginProtocol.Type,
                    let provider = classType.init(pluginModel: pluginModel) as? (PlayerObserverProtocol & PlayerDependantPluginProtocol) {
                    provider.playerPlugin = player
                    provider.prepareProvider([:], completion: nil)
                    provider.playerDidCreate(player: player)
                    retVal[pluginModel.identifier] = provider
                }
            }
        }
        return retVal
    }

    func disableProvider(identifier: String, completion: PluginManagerCompletion) {
        completion?(true)
    }

    func disableProviders(completion: PluginManagerCompletion) {
        completion?(true)
    }

    func createProvider(identifier: String, forceEnable: Bool, completion: PluginManagerCompletion) {
        completion?(true)
    }

    func createProviders(forceEnable: Bool, completion: PluginManagerCompletion) {
        completion?(true)
    }
    
    func getProviderInstance(identifier: String) -> PluginAdapterProtocol? {
        return nil
    }
    
    func getProviderInstance(condition: (Any) -> Any?) -> PluginAdapterProtocol? {
        return nil
    }
}
