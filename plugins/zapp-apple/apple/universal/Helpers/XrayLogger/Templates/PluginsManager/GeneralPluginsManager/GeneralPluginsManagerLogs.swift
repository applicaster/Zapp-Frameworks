//
//  GeneralPluginsManagerLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 20/01/2021.
//

import Foundation
import XrayLogger
import ZappCore

let generalPluginsManagerLogsSubsystem = "\(PluginsManagerLogs.subsystem)/general_plugins"

public struct GeneralPluginsManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = generalPluginsManagerLogsSubsystem
}
