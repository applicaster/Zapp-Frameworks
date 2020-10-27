//
//  UrlSchemeHandler+settings.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/10/2020.
//

import Foundation
import ZappCore

struct SettingsURLSchemeKeys {
    static let type = "type"
}

extension UrlSchemeHandler {
    class func handleSettingsChanges(url: URL,
                                     rootController: RootController?) -> Bool {
        guard let rootController = rootController,
            let params = queryParams(url: url),
            let type = params[SettingsURLSchemeKeys.type] as? String else {
            return false
        }

        switch type {
        case SettingsBundleParameters.loggerAssistance.rawValue:
            handleLoggerAssistancePresentationIfNeeded(with: params,
                                                       on: rootController)
            break
        default:
            break
        }

        return true
    }

    fileprivate class func handleLoggerAssistancePresentationIfNeeded(with params: [String: Any],
                                                                      on rootController: RootController?) {
        
        rootController?.loggerAssistance.presentAuthentication(with: params,
                                                               on: rootController)
    }
}
