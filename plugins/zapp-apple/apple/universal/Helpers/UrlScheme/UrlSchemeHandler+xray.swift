//
//  UrlSchemeHandler+plugin.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/02/2020.
//

import Foundation
import ZappCore

struct XrayURLSchemeKeys {
    static let pluginIdentifier = "pluginIdentifier"
}

extension UrlSchemeHandler {
    class func handleXray(url: URL,
                          rootController: RootController) -> Bool {
        guard let adapter = rootController.pluginsManager.crashlogs.getProviderInstance(identifier: "xray_logging_plugin") else {
            return false
        }

        return false
    }
}
