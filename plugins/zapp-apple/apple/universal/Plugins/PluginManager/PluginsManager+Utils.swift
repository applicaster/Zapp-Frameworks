//
//  ZPPluginManager.swift
//  Zapp-App
//
//  Created by Anton Kononenko on 03/05/16.
//  Copyright © 2016 Applicaster LTD. All rights reserved.
//

import Foundation
import UIKit
import ZappCore

extension PluginsManager {
    /**
     Find a plugin model of a given type.
     - parameter type: The type of plugin to search. See `ZPPluginType`.
     - returns: The first plugin found with the given type.
     */
    public class func pluginModel(_ type: ZPPluginType) -> ZPPluginModel? {
        return pluginModels()?.first(where: { $0.pluginType == type })
    }

    /**
     Find a plugin model of a given type.
     - note: This version of the function is required to make it usable in Objective-C code.
     - parameter type: The type of plugin to search.
     - returns: The first plugin found with the given type.
     */
    @objc public class func pluginModel(_ type: String) -> ZPPluginModel? {
        return pluginModels()?.first(where: { $0.pluginType?.rawValue == type })
    }

    /// Find all plugin models of a given type.
    /// - parameter type: The type of plugin to search.
    /// - returns: The first plugin found with the given type.
    @objc public class func pluginModels(_ type: String) -> [ZPPluginModel]? {
        return pluginModels()?.filter({ $0.pluginType?.rawValue == type })
    }

    /// Find all plugin models of a given type.
    /// - Parameter type: The type of plugin enum to search.
    /// - Returns: The first plugin found with the given type.
    public class func pluginModels(_ type: ZPPluginType) -> [ZPPluginModel]? {
        return pluginModels()?.filter({ $0.pluginType == type })
    }

    /// Retrieve plugin by specific identifier
    ///
    /// - Parameter pluginID: Specific plugin id to search
    /// - Returns: Plugin model in case plugin exists
    @objc open class func pluginModelById(_ pluginID: String) -> ZPPluginModel? {
        return pluginModels()?.first(where: { $0.identifier == pluginID })
    }

    /// All availible plugin models
    static var allPluginModels: [ZPPluginModel]? = {
        var retVal: [ZPPluginModel]?
        guard let basePlugins = parseBasePluginsJson() else {
            return nil
        }
        guard let latestPlugins = parseLatestPluginsJson() else {
            return basePlugins
        }

        // Override configuration json from latest plugins
        var newPluginsJson = basePlugins
        for latestPlugin in latestPlugins {
            for basePlugin in newPluginsJson {
                if latestPlugin == basePlugin {
                    basePlugin.configurationJSON = latestPlugin.configurationJSON
                    break
                }
            }
        }

        return newPluginsJson
    }()

    class func parseBasePluginsJson() -> [ZPPluginModel]? {
        guard let pluginsRawArray = PluginsManager.pluginsJSONData() else {
            return nil
        }
        return parsePluginsJson(pluginsRawArray)
    }

    class func parseLatestPluginsJson() -> [ZPPluginModel]? {
        guard let pluginsRawArray = PluginsManager.latestJSONPluginData() else {
            return nil
        }
        return parsePluginsJson(pluginsRawArray)
    }

    class func parsePluginsJson(_ rawData: NSArray) -> [ZPPluginModel]? {
        var retVal: [ZPPluginModel]?

        for model in rawData {
            if let pluginRawModel = model as? NSDictionary {
                if retVal == nil {
                    retVal = [ZPPluginModel]()
                }

                if let model = ZPPluginModel(object: pluginRawModel) {
                    retVal?.append(model)
                }
            }
        }
        return retVal
    }

    public class func pluginModels() -> [ZPPluginModel]? {
        return allPluginModels
    }

    /// Plugins data that was retrieved during application launch, latest availible
    ///
    /// Note: Idea that this url will be used to retrieve configuration json only from plugins that was added in prebuild
    /// - Returns: Array of Data
    fileprivate class func latestJSONPluginData() -> NSArray? {
        guard let localURLPath = FacadeConnector.connector?.applicationData?.pluginsURLPath(),
            let pluginsData = pluginsData(from: localURLPath) else {
            return nil
        }
        return pluginsData
    }

    /// Plugins data that was retrieved from ZappTool during prebuild
    ///
    /// Note: Idea that this url will be used to define plugins that was ready on prebuild phase and will not be changed
    /// - Returns: Array of Data
    fileprivate class func pluginsJSONData() -> NSArray? {
        guard let path = Bundle.main.path(forResource: "plugin_configurations",
                                          ofType: "json"),
            let pluginsData = pluginsData(from: URL(fileURLWithPath: path)) else {
            return nil
        }
        return pluginsData
    }

    fileprivate class func pluginsData(from url: URL) -> NSArray? {
        var retVal: NSArray?
        if let jsonData = try? Data(contentsOf: url) {
            do {
                retVal = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? NSArray
            } catch let error as NSError {
                #if DEBUG
                    print(error.description)
                #endif
            }
        }
        return retVal
    }

    @objc public class func adapterClass(_ pluginModel: ZPPluginModel) -> AnyClass? {
        var retVal: AnyClass?
        if let className = pluginModel.pluginClassName {
            if let aClass = NSClassFromString(className) {
                retVal = aClass
            } else if let modules = pluginModel.pluginModules {
                for module in modules {
                    if let aClass = NSClassFromString(module + "." + className) {
                        retVal = aClass
                        break
                    }
                }
            }
        }

        return retVal
    }

    @objc public class func bundleForModelClass(_ pluginModel: ZPPluginModel) -> Bundle? {
        if let modelClass = self.adapterClass(pluginModel) {
            return Bundle(for: modelClass)
        }
        return nil
    }

    /**
     Get the adapter class for the plugin.
     - parameter pluginModel: The plugin model whose class is loaded.
     - returns: The adapter class if found by checking the class name (and modules).
     */
    public class func adapter(pluginModel: ZPPluginModel) -> ZPAdapterProtocol.Type? {
        return adapterClass(pluginModel) as? ZPAdapterProtocol.Type
    }

    /** In case a plugin defines it, it returns the navigation type that we should use when navigation to a new viewController.

     - parameter screenName: The screen name provided by the model.
     - parameter model: The data model that will be used to populate the VC
     - returns:  the navigation type that we should use when navigation to a new viewController
     */
    public class func navigationType(withScreenName screenName: String?, model: NSDictionary?) -> String? {
        let navigationTypeKey = "presentation"

        if let plugin = self.plugin(withScreenName: screenName, model: model),
            let configurationJSON = plugin.configurationJSON,
            let navigationType = configurationJSON[navigationTypeKey] {
            return navigationType as? String
        } else {
            return nil
        }
    }

    public class func plugin(model: NSDictionary?) -> ZPPluginModel? {
        let modelExtensionsKey = "extensions"
        let openWithPluginIdKey = "open_with_plugin_id"

        // We try to find if we defined in our extension the plugin type
        guard let model = model as? [String: Any],
            let extensions = model[modelExtensionsKey] as? [String: Any],
            let pluginId = extensions[openWithPluginIdKey] as? String else {
            return nil
        }
        return PluginsManager.pluginModels()?.first(where: { $0.identifier == pluginId })
    }

    public class func plugin(withScreenName screenName: String?,
                             model: NSDictionary?) -> ZPPluginModel? {
        var plugin: ZPPluginModel?

        // We try to find if we defined in our extension the plugin type
        if let pluginByModel = self.plugin(model: model) {
            plugin = pluginByModel
        }

        // If we don't define any plugin id in our extension or is not valid, we try to check for the plugin type
        if plugin == nil && screenName != nil {
            plugin = PluginsManager.pluginModels()?.first(where: { $0.pluginType?.rawValue == screenName })
        }

        return plugin
    }

    /// Retrive list of all hooks plugins
    public class func getHookPlugins() -> [ZPPluginModel] {
        guard let pluginModels = PluginsManager.pluginModels() else {
            return []
        }

        return pluginModels.filter { $0.pluginRequireStartupExecution == true && (PluginsManager.adapterClass($0) as? AppLoadingHookProtocol.Type) != nil }
    }
}
