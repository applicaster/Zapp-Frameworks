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
              let params = queryStringParams(url: url),
              let type = params[SettingsURLSchemeKeys.type] as? String else {
            return false
        }

        switch type {
        case SettingsBundleParameters.loggerAssistanceRemoteEventsLogging.rawValue:
            rootController.loggerAssistance.presentAuthenticationForRemoteEventsLogging(with: params,
                                                                                        on: rootController)
            break
        default:
            break
        }

        return true
    }
}
