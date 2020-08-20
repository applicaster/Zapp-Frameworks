//
//  TrackingManagerLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 20/08/2020.
//

import Foundation
import XrayLogger

public struct TrackingManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/tracking_manager"

    public static var trackingInitialized = LogTemplate(message: "Tracking manager initialized")
    public static var sendEvent = LogTemplate(message: "Send event")
    public static var sendEventFailedNoEndpoint = LogTemplate(message: "Send event failed, no endpoint defined")
    public static var sendEventFailedJson = LogTemplate(message: "Send event failed, json content can not be created")
    public static var sendEventFailedResponse = LogTemplate(message: "Send event failed, error received in respomnse")
}
