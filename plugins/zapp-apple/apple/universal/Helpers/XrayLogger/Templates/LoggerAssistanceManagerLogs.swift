//
//  File.swift
//  ZappApple
//
//  Created by Alex Zchut on 27/10/2020.
//

import Foundation
import XrayLogger
import ZappCore

public struct LoggerAssistanceManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/logger_assistance_manager"

    public static var presentAuthentication = LogTemplate(message: "Logger assistance authentication presented to user")
    public static var resetToDefaultState = LogTemplate(message: "Logger assistance state set to off")
    public static var passedAuthentication = LogTemplate(message: "Logger assistance authenticated")
    public static var cancelled = LogTemplate(message: "Logger assistance cancelled")
}
