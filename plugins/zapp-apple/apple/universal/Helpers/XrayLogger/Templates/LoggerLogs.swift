//
//  LoggerLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

public struct LoggerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/logger"

    public static var loggerIntialized = LogTemplate(message: "Xray logger was intialized with context")
}
