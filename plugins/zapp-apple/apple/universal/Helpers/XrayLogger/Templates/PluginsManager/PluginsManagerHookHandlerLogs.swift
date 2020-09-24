//
//  PluginsManagerHookHandlerLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 19/08/2020.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

let pluginsManagerHookHandlerSubsystem = "\(PluginsManagerLogs.subsystem)/hooks_handler"

public struct PluginsManagerHookHandlerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = pluginsManagerHookHandlerSubsystem

    public static var hookOnLaunch = LogTemplate(message: "Execute OnLaunch hooks")
    public static var hookOnFailedLoading = LogTemplate(message: "Execute OnFailedLoading hooks")
    public static var hookOnApplicationReady = LogTemplate(message: "Execute OnApplicationReady hooks")
    public static var hookAfterAppRootPresentation = LogTemplate(message: "Execute AfterAppRootPresentation hooks")
    public static var hookOnContinuingUserActivity = LogTemplate(message: "Execute OnContinuingUserActivity hooks")
}
