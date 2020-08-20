//
//  PluginsManagerControlFlowLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 19/08/2020.
//

import Foundation
import XrayLogger
let pluginsManagerControlFlowSubsystem = "\(PluginsManagerLogs.subsystem)/control_flow"

public struct PluginsManagerControlFlowLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = pluginsManagerControlFlowSubsystem

    public static var disablePlugin = LogTemplate(message: "Disable plugin by identifier")
    public static var enablePlugin = LogTemplate(message: "Enable plugin by identifier")
    public static var disableAllPlugins = LogTemplate(message: "Disable all plugins")
    public static var enableAllPlugins = LogTemplate(message: "Enable all plugins")
    public static var getPluginManagerRelatedToSpecificPlugin = LogTemplate(message: "Get plugin manager related to specific plugin by identifier")
    public static var getProviderInstance = LogTemplate(message: "Get plugin instance by identifier")
    
    public static var disablePluginFailed = LogTemplate(message: "Failed to disable plugin by identifier")
    public static var enablePluginFailed = LogTemplate(message: "Failed to enable plugin by identifier")
    public static var disableAllPluginsFailed = LogTemplate(message: "Failed to disable all plugins")
    public static var enableAllPluginsFailed = LogTemplate(message: "Failed to enable all plugins")
    public static var getPluginManagerRelatedToSpecificPluginFailed = LogTemplate(message: "Failed to get plugin manager related to specific plugin by identifier")
    public static var getProviderInstanceFailed = LogTemplate(message: "Failed to get plugin instance by identifier")
}
