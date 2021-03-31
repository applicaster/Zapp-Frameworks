//
//  EventsBus+LogTemplates.swift
//  ZappCore
//
//  Created by Alex Zchut on 16/02/2021.
//

import Foundation

public struct EventsBusLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/events_bus"
    public static var subscribed = LogTemplate(message: "Subscribed to event")
    public static var unsubscribed = LogTemplate(message: "Unsubscribed from event")
    public static var unsubscribedFromAll = LogTemplate(message: "Unsubscribed from all events")
}
