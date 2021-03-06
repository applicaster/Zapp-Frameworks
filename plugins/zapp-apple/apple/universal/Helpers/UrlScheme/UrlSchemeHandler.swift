//
//  UrlSchemeHandler.swift
//  ZappApple
//
//  Created by Alex Zchut on 26/02/2020.
//

import Foundation

public class UrlSchemeHandler {
    enum SystemActions: String {
        case generateNewUUID
        case plugin
        case xray
        case settings
    }

    public class func handle(with rootViewController: RootController?,
                             application: UIApplication,
                             open url: URL,
                             options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var retValue = false
        // create action with string
        let action = SystemActions(rawValue: url.host ?? "")

        // check if action defined anc call its implementation or skip
        switch action {
        case .generateNewUUID:
            retValue = handleUUIDregeneration(with: rootViewController)
        case .xray:
            retValue = handleXray(url: url,
                                  rootController: rootViewController)
        case .plugin:
            // This section is experimental, not in use. If not needed in future, please remove it, with handlePluginURLScheme: func
            retValue = handlePluginURLScheme(url: url,
                                             rootController: rootViewController)
        case .settings:
            retValue = handleSettingsChanges(url: url,
                                             rootController: rootViewController)
        default:
            break
        }

        return retValue
    }

    class func queryStringParams(url: URL) -> [String: Any]? {
        guard let components = URLComponents(url: url,
                                             resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }

    class func getPathComponents(url: URL) -> [String] {
        let pathComponents = url.pathComponents.dropFirst()
        guard pathComponents.count > 0 else { return [] }
        return Array(pathComponents)
    }
}
