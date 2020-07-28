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
    static let SinkFileLogLevel = "file_sink"
    struct SinkFileLogLevelValues {
        static let off = "off"
        static let error = "error"
        static let warning = "warning"
        static let info = "info"
        static let debug = "debug"
        static let verbose = "verbose"
    }

    static let ReportEmails = "report_email"
}

struct KeysHelper {
    let configurationJSON: [String: Any]

    init(configurationJSON: [String: Any]) {
        self.configurationJSON = configurationJSON
    }

    func logLevel() -> LogLevel? {
        guard let fileSinkLevel = configurationJSON[PluginConfigurationKeys.SinkFileLogLevel] as? String else {
            return nil
        }

        switch fileSinkLevel {
        case PluginConfigurationKeys.SinkFileLogLevelValues.error:
            return .error
        case PluginConfigurationKeys.SinkFileLogLevelValues.warning:
            return .warning
        case PluginConfigurationKeys.SinkFileLogLevelValues.info:
            return .info
        case PluginConfigurationKeys.SinkFileLogLevelValues.debug:
            return .debug
        case PluginConfigurationKeys.SinkFileLogLevelValues.verbose:
            return .verbose
        default:
            return nil
        }
    }

    func emailsToShare() -> [String] {
        guard let email = configurationJSON[PluginConfigurationKeys.ReportEmails] as? String else {
            return []
        }
        return [email]
    }
}
