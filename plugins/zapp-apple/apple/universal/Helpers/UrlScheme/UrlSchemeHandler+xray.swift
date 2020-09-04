//
//  UrlSchemeHandler+plugin.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/02/2020.
//

import Foundation
import ZappCore

extension UrlSchemeHandler {
    class func handleXray(url: URL,
                          rootController: RootController?) -> Bool {
        let xrayPluginIdentifier = "xray_logging_plugin"
        guard let rootController = rootController,
            let adapter = rootController.pluginsManager.crashlogs.getProviderInstance(identifier: xrayPluginIdentifier) as? PluginURLHandlerProtocol,
            let handleURLScheme = adapter.handlePluginURLScheme else {
            return false
        }

        return handleURLScheme(nil,
                               url)
    }
}
