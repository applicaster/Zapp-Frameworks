//
//  EventsBusPredefinedEvents.swift
//  ZappCore
//
//  Created by Alex Zchut on 14/02/2021.
//  Copyright © 2021 Applicaster LTD. All rights reserved.
//

let eventsBusNamePrefix = "c71a8e9f-188a-4596-8b84-f5a9e51d7d9a."

public enum EventsBusTopicTypes {
    case undefined
    case reachabilityChanged
    case analytics
}

public class EventsBusTopic: CustomStringConvertible {
    var type: EventsBusTopicTypes = .undefined

    public init(type: EventsBusTopicTypes) {
        self.type = type
    }

    public var description: String {
        var result = eventsBusNamePrefix
        switch type {
        case .analytics:
            result += "analytics"
        case .reachabilityChanged:
            result += "reachabilityChanged"
        default:
            break
        }
        return result
    }
}
