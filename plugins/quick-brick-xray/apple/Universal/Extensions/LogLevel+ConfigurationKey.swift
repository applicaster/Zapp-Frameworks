//
//  QuickBrickXray.swift
//  QuickBrickXray
//
//  Created by Anton Kononenko on 27/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import LoggerInfo
import Reporter
import UIKit
import XrayLogger
import ZappCore

extension LogLevel {
    func toConfigurationKey() -> String? {
        switch self {
        case .error:
            return PluginConfigurationKeys.LogLevelValues.error
        case .warning:
            return PluginConfigurationKeys.LogLevelValues.warning
        case .info:
            return PluginConfigurationKeys.LogLevelValues.info
        case .debug:
            return PluginConfigurationKeys.LogLevelValues.debug
        case .verbose:
            return PluginConfigurationKeys.LogLevelValues.verbose
        }
    }
    
    static func logLevel(fromConfigurationKey key: String?) -> LogLevel? {
        switch key {
        case PluginConfigurationKeys.LogLevelValues.error:
            return .error
        case PluginConfigurationKeys.LogLevelValues.warning:
            return .warning
        case PluginConfigurationKeys.LogLevelValues.info:
            return .info
        case PluginConfigurationKeys.LogLevelValues.debug:
            return .debug
        case PluginConfigurationKeys.LogLevelValues.verbose:
            return .verbose
        default:
            return nil
        }
    }
}
