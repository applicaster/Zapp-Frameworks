//
//  QickBrickXray.swift
//  QickBrickXray
//
//  Created by Alex Zchut on 27/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import Reporter
import UIKit
import XrayLogger
import ZappCore

struct PluginConfigurationKeys {
    static let CustomSettingsEnabled = "customSettingsEnabled"
    static let FileLogLevel = "fileLogLevel"
    static let ShortcutEnabled = "shortcutEnabled"
    static let ShareLog = "shareLog"
    struct LogLevelValues {
        static let off = "off"
        static let error = "error"
        static let warning = "warning"
        static let info = "info"
        static let debug = "debug"
        static let verbose = "verbose"
    }

    static let ReportEmails = "reportEmail"
}

struct KeysHelper {
    let configurationJSON: [String: Any]

    init(configurationJSON: [String: Any]) {
        self.configurationJSON = configurationJSON
    }

    func logLevel() -> LogLevel {
        return LogLevel.logLevel(fromConfigurationKey: configurationJSON[PluginConfigurationKeys.FileLogLevel] as? String) ?? .verbose
    }

    func emailsToShare() -> [String] {
        guard let email = configurationJSON[PluginConfigurationKeys.ReportEmails] as? String else {
            return []
        }
        return [email]
    }
}
