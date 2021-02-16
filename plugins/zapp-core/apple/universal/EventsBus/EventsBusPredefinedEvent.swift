//
//  EventsBusPredefinedEvents.swift
//  ZappCore
//
//  Created by Alex Zchut on 14/02/2021.
//  Copyright © 2021 Applicaster LTD. All rights reserved.
//

let eventsBusNamePrefix = "c71a8e9f-188a-4596-8b84-f5a9e51d7d9a."

public struct EventsBusPredefinedEvent {
    /// Uniquie identifier of the local notification
    public static let reachabilityChanged = eventsBusNamePrefix + "reachabilityChanged"

    public static let analytics = eventsBusNamePrefix + "analytics"
}

public enum EventsBusAnalyticsTypes: String {
    case undefined
    case sendEvent
    case startObserveTimedEvent
    case stopObserveTimedEvent
    case sendScreenEvent
    case trackURL
}
