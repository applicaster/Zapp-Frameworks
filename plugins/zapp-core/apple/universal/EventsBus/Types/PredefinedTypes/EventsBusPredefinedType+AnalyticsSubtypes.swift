//
//  EventsBusPredefinedType+AnalyticsSubtypes.swift
//  ZappCore
//
//  Created by Alex Zchut on 16/02/2021.
//

import Foundation

public enum EventsBusTypeAnalyticsSubtype: String {
    case undefined
    case sendEvent
    case startObserveTimedEvent
    case stopObserveTimedEvent
    case sendScreenEvent
    case trackURL

    public var value: String {
        return rawValue
    }
}
