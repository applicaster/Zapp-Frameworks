//
//  QickBrickXray.swift
//  QickBrickXray
//
//  Created by Anton Kononenko on 27/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import LoggerInfo
import Reporter
import UIKit
import XrayLogger
import ZappCore

extension QickBrickXray: PluginURLHandlerProtocol {
    public func handlePluginURLScheme(with rootViewController: UIViewController?,
                                      url: URL) -> Bool {
        guard let params = queryParams(url: url) else {
            return false
        }

        var settings = Settings()

        if let shortcutEnabled = params[PluginConfigurationKeys.ShortcutEnabled] as? Bool {
            settings.customSettingsEnabled = true
            settings.shortcutEnabled = shortcutEnabled
        }

        if let fileLogLevelString = params[PluginConfigurationKeys.FileLogLevel] as? String {
            settings.customSettingsEnabled = true
            settings.fileLogLevel = LogLevel.logLevel(fromConfigurationKey: fileLogLevelString)
        }

        if settings.customSettingsEnabled == true {
            applyCustomSettings(settings: settings)
        }

        if let sendEmail = params[PluginConfigurationKeys.ShareLog] as? Bool,
            sendEmail == true {
            Reporter.requestSendEmail()
        } else {
            presentLoggerView()
        }

        return true
    }

    func queryParams(url: URL) -> [String: Any]? {
        guard let components = URLComponents(url: url,
                                             resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
}
