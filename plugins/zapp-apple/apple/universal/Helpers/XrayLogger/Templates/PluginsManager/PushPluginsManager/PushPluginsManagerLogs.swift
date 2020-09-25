//
//  PushPluginsManagerLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 20/08/2020.
//

import Foundation
import XrayLogger
import ZappCore

let pushPluginsManagerLogsSubsystem = "\(PluginsManagerLogs.subsystem)/push_plugins"

public struct PushPluginsManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = pushPluginsManagerLogsSubsystem

    public static var registerDeviceToken = LogTemplate(message: "Passing device token to push providers")

}
