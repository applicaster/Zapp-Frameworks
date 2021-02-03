//
//  PlayerDependantPluginsManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/17/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import ZappCore
import XrayLogger

@objc public class PlayerDependantPluginsManager: NSObject, PluginManagerControlFlowProtocol {
    lazy var logger = Logger.getLogger(for: PlayerDependantPluginsManangerLogs.subsystem)

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
        logger?.debugLog(template: PlayerDependantPluginsManangerLogs.createPlayerDependantProviders)

        var retVal: [String: PlayerDependantPluginProtocol] = [:]

        if let pluginModels = FacadeConnector.connector?.pluginManager?.getAllPlugins() {
            for pluginModel in pluginModels {
                var provider: (PlayerObserverProtocol & PlayerDependantPluginProtocol)?
                //find provider in already iniaialized plugins
                if let providerInstance = FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginModel.identifier) as? (PlayerObserverProtocol & PlayerDependantPluginProtocol) {
                    provider = providerInstance
                }
                //create new plugin instance
                else if let classType = FacadeConnector.connector?.pluginManager?.adapterClass(pluginModel) as? PlayerDependantPluginProtocol.Type,
                    let providerInstance = classType.init(pluginModel: pluginModel) as? (PlayerObserverProtocol & PlayerDependantPluginProtocol) {
                    provider = providerInstance
                    provider?.prepareProvider([:], completion: nil)

                }
                
                //add provider if created or found in already created instances
                if let provider = provider {
                    provider.playerPlugin = player
                    retVal[pluginModel.identifier] = provider
                }
            }
        }
        return retVal
    }

    func disableProvider(identifier: String, completion: PluginManagerCompletion) {
        logger?.debugLog(template: PlayerDependantPluginsManangerLogs.disableProvider,
                         data: ["identifier": identifier])
        completion?(true)
    }

    func disableProviders(completion: PluginManagerCompletion) {
        logger?.debugLog(template: PlayerDependantPluginsManangerLogs.disableProviders)

        completion?(true)
    }

    func createProvider(identifier: String, forceEnable: Bool, completion: PluginManagerCompletion) {
        logger?.debugLog(template: PlayerDependantPluginsManangerLogs.createProvider,
                         data: ["identifier": identifier])
        completion?(true)
    }

    func createProviders(forceEnable: Bool, completion: PluginManagerCompletion) {
        logger?.debugLog(template: PlayerDependantPluginsManangerLogs.createProviders)

        completion?(true)
    }
    
    func getProviderInstance(identifier: String) -> PluginAdapterProtocol? {
        logger?.debugLog(template: PlayerDependantPluginsManangerLogs.getProviderInstance,
                         data: ["identifier": identifier])
        
        return nil
    }
    
    func getProviderInstance(condition: (Any) -> Any?) -> PluginAdapterProtocol? {
        return nil
    }
}
