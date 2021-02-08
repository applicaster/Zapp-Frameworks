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
        guard let params = queryParams(url: url),
              let pluginIdentifier = params[PluginURLSchemeKeys.pluginIdentifier] as? String,
              let pluginModel = PluginsManager.pluginModelById(pluginIdentifier),
              let classType = PluginsManager.adapterClass(pluginModel) as? PluginAdapterProtocol.Type else {
            return false
        }
        let viewController = UIApplication.shared.delegate?.window??.rootViewController
        let pluginAdapter = classType.init(pluginModel: pluginModel)
        if let pluginAdapter = pluginAdapter as? PluginURLHandlerProtocol {
            return pluginAdapter.handlePluginURLScheme?(with: viewController,
                                                        url: url) ?? false
        }
        return false
    }
}
