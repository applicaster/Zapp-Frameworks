//
//  UrlSchemeHandler+plugin.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/02/2020.
//

import Foundation
import ZappCore

struct PluginURLSchemeKeys {
    static let pluginIdentifier = "pluginIdentifier"
}

extension UrlSchemeHandler {
    class func handlePluginURLScheme(url: URL,
                                     rootController: RootController?) -> Bool {
        let pathComponents = getPathComponents(url: url)
        let queryParams = queryStringParams(url: url)
        guard queryParams != nil || pathComponents.count > 0 else {
            return false
        }

        var pluginAdapter: PluginAdapterProtocol?
        // in case url has the following format: scheme://plugin?pluginIdentifier=xxxxx&a=1&b=2,
        // look for the plugin by identifier
        if let pluginIdentifier = queryParams?[PluginURLSchemeKeys.pluginIdentifier] as? String {
            if let instance = rootController?.pluginsManager.getProviderInstance(identifier: pluginIdentifier) as? PluginAdapterProtocol & PluginURLHandlerProtocol,
               instance.canHandlePluginURLScheme?(with: url) ?? true {
                pluginAdapter = instance
            }
        } else {
            // in case url has the following format: scheme://plugin?a=1&b=2
            // look for all plugin implementing PluginURLHandlerProtocol and call canHandlePluginURLScheme to get fist provider that can handle the url
            pluginAdapter = rootController?.pluginsManager.getProviderInstance(pluginType: ZPPluginType.General.rawValue,
                                                                                          condition: { (p) -> Any? in
                                                                                              guard let p = p as? PluginURLHandlerProtocol,
                                                                                                    p.canHandlePluginURLScheme?(with: url) ?? true else {
                                                                                                  return false
                                                                                              }
                                                                                              return true
                                                                                          })
        }

        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        if let pluginAdapter = pluginAdapter as? PluginURLHandlerProtocol {
            return pluginAdapter.handlePluginURLScheme?(with: viewController,
                                                        url: url) ?? false
        }
        return false
    }
}
