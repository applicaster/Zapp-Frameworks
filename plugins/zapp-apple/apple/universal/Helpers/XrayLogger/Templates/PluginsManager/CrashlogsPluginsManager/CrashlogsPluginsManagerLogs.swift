//
//  CrashlogsPluginsManagerLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 20/01/2021.
//

import Foundation
import XrayLogger
import ZappCore

let crashlogsPluginsManagerLogsSubsystem = "\(PluginsManagerLogs.subsystem)/crashlogs_plugins"

public struct CrashlogsPluginsManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = crashlogsPluginsManagerLogsSubsystem
}
