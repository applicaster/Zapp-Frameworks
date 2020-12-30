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

    public static var remoteLoggingPresentAuthentication = LogTemplate(message: "Logger assistance authentication presented to user")
    public static var remoteLoggingResetToDefaultState = LogTemplate(message: "Logger assistance state set to off")
    public static var remoteLoggingPassedAuthentication = LogTemplate(message: "Logger assistance authenticated")
    public static var remoteLoggingCancelled = LogTemplate(message: "Logger assistance cancelled")
}
