//
//  EventsBusPredefinedType.swift
//  ZappCore
//
//  Created by Alex Zchut on 04/03/2021.
//

import Foundation

public enum EventsBusPredefinedType {
    case undefined
    case testEvent
    case reachabilityChanged
    case analytics(_ subtype: EventsBusTypeAnalyticsSubtype)
    case msAppCenterCheckUpdates
    
    var rawValue: String {
        return "\(self)"
    }
}
