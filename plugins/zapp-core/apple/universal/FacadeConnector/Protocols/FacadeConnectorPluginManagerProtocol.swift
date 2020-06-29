//
//  FacadeConnectorStorageProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 10/8/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

@objc public protocol FacadeConnectorPluginManagerControlFlow {
    /// Disable plugin by plugin identifier
    /// - Note: Only non ui plugins can be disabled
    /// - Parameter identifier: zapp plugin identifier of the specific plugin
    @objc func disablePlugin(identifier: String, completion: ((_ success: Bool) -> Void)?)

    /// Disable all plugins for specific type
    /// - Note: Only  non ui plugins can be disabled
    /// - Parameter pluginType: Type of the zapp Plugin
    @objc func disableAllPlugins(pluginType: String, completion: ((_ success: Bool) -> Void)?)

    /// Enable plugin by plugin identifier
    /// - Note: Only non ui plugins can be disabled
    /// - Parameter identifier: zapp plugin identifier of the specific plugin
    @objc func enablePlugin(identifier: String, completion: ((_ success: Bool) -> Void)?)

    /// Enable all plugins for specific type
    /// - Note: Only non ui plugins can be disabled
    /// - Parameter pluginType: Type of the zapp Plugin
    @objc func enableAllPlugins(pluginType: String, completion: ((_ success: Bool) -> Void)?)
    
    /// Get plugin instance  by plugin identifier
    /// - Parameter identifier: zapp plugin identifier of the specific plugin
    @objc func getProviderInstance(identifier: String) -> PluginAdapterProtocol?
    
    /// Get plugin instance  by plugin identifier
    /// - Parameter pluginType: zapp plugin type of the specific plugin
    /// - Parameter condition: specific protocol to confirms to
    @objc func getProviderInstance(pluginType: String, condition: (Any) -> Any?) -> PluginAdapterProtocol?
}

@objc public protocol FacadeConnectorPluginManagerProtocol: FacadeConnectorPluginManagerControlFlow {
    @objc func plugin(for identifier: String) -> ZPPluginModel?
    @objc func getAllPlugins() -> [ZPPluginModel]?
    @objc func adapterClass(_ pluginModel: ZPPluginModel) -> AnyClass?

    /// Get a plugin by type
    @objc func pluginModel(_ type: String) -> ZPPluginModel?
    
}
