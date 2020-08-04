//
//  AppCenter.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

public struct AppCenterLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/app_center"

    public static var appCenterConfigure = LogTemplate(message: "Configure AppCenter")
    public static var appCenterConfigureDiscribution = LogTemplate(message: "Configure AppCenter distribution service")
    public static var appCenterConfigureNoSecret = LogTemplate(message: "Configure AppCenter app secret was not defined")
}
