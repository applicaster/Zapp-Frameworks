//
//  RootController+FacadeConnectorPluginManagerProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 10/15/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorPluginManagerProtocol {
    public func pluginModel(_ type: String) -> ZPPluginModel? {
        return PluginsManager.pluginModel(type)
    }

    @objc public func plugin(for identifier: String) -> ZPPluginModel? {
        return PluginsManager.pluginModelById(identifier)
    }

    @objc public func getAllPlugins() -> [ZPPluginModel]? {
        return PluginsManager.allPluginModels
    }

    @objc public func adapterClass(_ pluginModel: ZPPluginModel) -> AnyClass? {
        return PluginsManager.adapterClass(pluginModel)
    }

    @objc public func disablePlugin(identifier: String, completion: ((_ success: Bool) -> Void)?) {
        pluginsManager.disablePlugin(identifier: identifier,
                                     completion: completion)
    }

    @objc public func disableAllPlugins(pluginType: String, completion: ((_ success: Bool) -> Void)?) {
        pluginsManager.disableAllPlugins(pluginType: pluginType,
                                         completion: completion)
    }

    @objc public func enablePlugin(identifier: String, completion: ((_ success: Bool) -> Void)?) {
        pluginsManager.enablePlugin(identifier: identifier,
                                    completion: completion)
    }

    @objc public func enableAllPlugins(pluginType: String, completion: ((_ success: Bool) -> Void)?) {
        pluginsManager.enableAllPlugins(pluginType: pluginType,
                                        completion: completion)
    }
    
    @objc public func getProviderInstance(identifier: String) -> PluginAdapterProtocol? {
        return pluginsManager.getProviderInstance(identifier: identifier)
    }
    
    @objc public func getProviderInstance(pluginType: String, condition: (Any) -> Any?) -> PluginAdapterProtocol? {
        return pluginsManager.getProviderInstance(pluginType: pluginType, condition: condition)
    }
}
