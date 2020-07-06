//
//  ZPPluginManager.swift
//  ZappApple
//
//  Created by Anton Kononenko on 1/24/20.
//

import Foundation
import ZappCore

public let kPluginEnabled = "enabled"
public let kPluginEnabledValue = "true"
public let kPluginDisabledValue = "false"

extension PluginsManager: FacadeConnectorPluginManagerControlFlow {
    public func disablePlugin(identifier: String, completion: ((_ success: Bool) -> Void)?) {
        guard let manager = pluginManager(identifier: identifier) else {
            completion?(false)
            return
        }

        manager.disableProvider(identifier: identifier,
                                completion: completion)
    }

    public func disableAllPlugins(pluginType: String,
                                  completion: ((_ success: Bool) -> Void)?) {
        guard let pluginType = ZPPluginType(rawValue: pluginType),
            let manager = pluginManager(type: pluginType) else {
            completion?(false)
            return
        }
        manager.disableProviders(completion: completion)
    }

    public func enablePlugin(identifier: String, completion: ((_ success: Bool) -> Void)?) {
        guard let pluginManager = pluginManager(identifier: identifier) else {
            completion?(false)
            return
        }

        pluginManager.createProvider(identifier: identifier,
                                     forceEnable: true,
                                     completion: completion)
    }

    public func enableAllPlugins(pluginType: String, completion: ((_ success: Bool) -> Void)?) {
        guard let pluginType = ZPPluginType(rawValue: pluginType),
            let manager = pluginManager(type: pluginType) else {
            completion?(false)
            return
        }
        manager.createProviders(forceEnable: true,
                                completion: completion)
    }

    func pluginManager(identifier: String) -> PluginManagerControlFlowProtocol? {
        guard let plugin = PluginsManager.pluginModelById(identifier),
            let pluginType = plugin.pluginType else {
            return nil
        }

        return pluginManager(type: pluginType)
    }

    func pluginManager(type: ZPPluginType) -> PluginManagerControlFlowProtocol? {
        // In switch defined supported control flow types plugins.
        switch type {
        case .Push:
            return push
        case .Analytics:
            return analytics
        case .Crashlogs:
            return crashlogs
        case .General:
            return general
        default:
            return nil
        }
    }
    
    public func getProviderInstance(identifier: String) -> PluginAdapterProtocol? {
        guard let pluginManager = pluginManager(identifier: identifier) else {
            return nil
        }

        return pluginManager.getProviderInstance(identifier: identifier)
    }
    
    public func getProviderInstance(pluginType: String, condition: (Any) -> Any?) -> PluginAdapterProtocol? {
        let type:ZPPluginType = ZPPluginType(rawValue: pluginType) ?? .General
        guard let pluginManager = pluginManager(type: type) else {
            return nil
        }
        
        return pluginManager.getProviderInstance(condition: condition)
    }
}
