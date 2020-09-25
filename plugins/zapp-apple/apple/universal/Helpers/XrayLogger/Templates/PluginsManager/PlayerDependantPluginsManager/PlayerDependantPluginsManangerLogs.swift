//
//  PlayerDependantPluginsManangerLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 20/08/2020.
//

import Foundation
import XrayLogger
import ZappCore

let playerDependantPluginsManagerSubsystem = "\(PluginsManagerLogs.subsystem)/player_dependant_plugins"

public struct PlayerDependantPluginsManangerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = playerDependantPluginsManagerSubsystem
    
    public static var createPlayerDependantProviders = LogTemplate(message: "Create player dependant plugins")
    public static var disableProvider = LogTemplate(message: "Disable single player dependant plugin by identifier")
    public static var createProvider = LogTemplate(message: "Create single player dependant plugin by identifier")
    public static var disableProviders = LogTemplate(message: "Disable all plugins")
    public static var createProviders = LogTemplate(message: "Create all player dependant plugins")
    public static var getProviderInstance = LogTemplate(message: "Get player dependant plugin instance by identifier")
}
