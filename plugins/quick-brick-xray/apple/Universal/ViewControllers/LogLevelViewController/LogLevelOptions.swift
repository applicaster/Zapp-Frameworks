//
//  LogLevelOptions.swift
//  QickBrickXray
//
//  Created by Anton Kononenko on 9/6/20.
//  Copyright © 2020 Applicaster. All rights reserved.

import Foundation
import XrayLogger

enum LogLevelOptions: NSInteger {
    case off
    case verbose
    case debug
    case info
    case warning
    case error

    public func toString() -> String {
        switch self {
        case .off:
            return "OFF"
        case .verbose:
            return LogLevel.verbose.toString()
        case .debug:
            return LogLevel.debug.toString()
        case .info:
            return LogLevel.info.toString()
        case .warning:
            return LogLevel.warning.toString()
        case .error:
            return LogLevel.error.toString()
        }
    }

    public func toColor() -> UIColor {
        switch self {
        case .off:
            return UIColor.lightGray
        case .verbose:
            return LogLevel.verbose.toColor()
        case .debug:
            return LogLevel.debug.toColor()
        case .info:
            return LogLevel.info.toColor()
        case .warning:
            return LogLevel.warning.toColor()
        case .error:
            return LogLevel.error.toColor()
        }
    }

    public func toLogLevel() -> LogLevel? {
        guard self != .off else {
            return nil
        }
        let logLevel = LogLevel(rawValue: self.rawValue - 1)
        return logLevel
    }

    public static let listOfAllOptions = [LogLevelOptions.off.toString(),
                                          LogLevelOptions.verbose.toString(),
                                          LogLevelOptions.debug.toString(),
                                          LogLevelOptions.info.toString(),
                                          LogLevelOptions.warning.toString(),
                                          LogLevelOptions.error.toString()]
}
