//
//  PlayerPluginManager.swift
//  ZappApple
//
//  Created by Alex Zchut on 20/01/2021.
//

import Foundation
import XrayLogger
import ZappCore

let playerPluginsManagerLogsSubsystem = "\(PluginsManagerLogs.subsystem)/general_plugins"

public struct PlayerPluginManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = playerPluginsManagerLogsSubsystem
}
