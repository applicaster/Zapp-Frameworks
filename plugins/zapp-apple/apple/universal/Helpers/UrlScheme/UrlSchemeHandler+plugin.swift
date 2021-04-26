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
    class func handlePluginURLScheme(url: URL) -> Bool {
        guard let params = queryParams(url: url) else {
            return false
        }

        var pluginAdapter: PluginAdapterProtocol?
        if let pluginIdentifier = params[PluginURLSchemeKeys.pluginIdentifier] as? String,
           let instance = FacadeConnector.connector?.pluginManager?.getProviderInstance(identifier: pluginIdentifier) as? PluginAdapterProtocol & PluginURLHandlerProtocol,
           instance.canHandlePluginURLScheme?(with: url) ?? true {
            pluginAdapter = instance
        } else {
            pluginAdapter = FacadeConnector.connector?.pluginManager?.getProviderInstance(pluginType: ZPPluginType.General.rawValue,
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
