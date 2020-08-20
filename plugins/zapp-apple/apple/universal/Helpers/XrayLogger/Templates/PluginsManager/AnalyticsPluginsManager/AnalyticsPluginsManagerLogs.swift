//
//  AnalyticsPluginsManagerLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 20/08/2020.
//

import Foundation
import XrayLogger

let analyticsPluginsManagerLogsSubsystem = "\(PluginsManagerLogs.subsystem)/analytics_plugins"

public struct AnalyticsPluginsManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = analyticsPluginsManagerLogsSubsystem

    public static var sendEvent = LogTemplate(message: "Send event")
    public static var startObserveTimedEvent = LogTemplate(message: "Start observing timed event")
    public static var stopObserveTimedEvent = LogTemplate(message: "Stop observing timed event")
    public static var sendScreenEvent = LogTemplate(message: "Send screen event")
    public static var trackCampaignParamsFromUrl = LogTemplate(message: "Track Campaign Params from url")

}
