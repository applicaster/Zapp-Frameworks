//
//  PluginsManagerControlFlowLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 19/08/2020.
//

import Foundation
import XrayLogger
let pluginsManagerControlFlowLogs = "\(PluginsManagerLogs.subsystem)/control_flow"

public struct PluginsManagerControlFlowLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = pluginsManagerControlFlowLogs

    public static var disableSinglePlugin = LogTemplate(message: "Disable single plugin by identifier")
    public static var enableSinglePlugin = LogTemplate(message: "Enable single plugin by identifier")
    public static var disableAllPlugins = LogTemplate(message: "Disable all plugins")
    public static var enableAllPlugins = LogTemplate(message: "Enable all plugins")
    public static var getPluginManagerRelatedToSpecificPlugin = LogTemplate(message: "Get plugin manager related to specific plugin by identifier")
    public static var getPluginInstanceByIdentifier = LogTemplate(message: "Get plugin instance by identifier")
}
