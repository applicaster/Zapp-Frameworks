//
//  PluginsManagerLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 19/08/2020.
//

import Foundation
import XrayLogger
let pluginsManagerSubsystem = "\(kNativeSubsystemPath)/plugins_manager"

public struct PluginsManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = pluginsManagerSubsystem

    public static var pluginsInitialization = LogTemplate(message: "Initializing plugins state machine")
    public static var loadingPluginsConfiguration = LogTemplate(message: "Fetching plugins")
    public static var preparingCrashlogPlugins = LogTemplate(message: "Preparing crashlog plugins")
    public static var preparingAnalyticsPlugins = LogTemplate(message: "Preparing analytics plugins")
    public static var preparingPushPlugins = LogTemplate(message: "Preparing push plugins")
    public static var preparingGeneralPlugins = LogTemplate(message: "Preparing general plugins")
    public static var preparingHookPlugins = LogTemplate(message: "Preparing hook plugins to be executed on launch")
    public static var savingPluginConfigurationToSessionStorage = LogTemplate(message: "Saving configuration of each plugin to session storage")
    public static var disableSinglePlugin = LogTemplate(message: "Disable single plugin by identifier")
    public static var enableSinglePlugin = LogTemplate(message: "Enable single plugin by identifier")
    public static var disableAllPlugins = LogTemplate(message: "Disable all plugins")
    public static var enableAllPlugins = LogTemplate(message: "Enable all plugins")
    public static var getPluginManagerRelatedToSpecificPlugin = LogTemplate(message: "Get plugin manager related to specific plugin by identifier")
    public static var getPluginInstanceByIdentifier = LogTemplate(message: "Get plugin instance by identifier")
}
