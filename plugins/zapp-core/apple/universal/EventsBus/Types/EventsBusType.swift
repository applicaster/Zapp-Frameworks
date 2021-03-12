//
//  EventsBusPredefinedTypes.swift
//  ZappCore
//
//  Created by Alex Zchut on 14/02/2021.
//  Copyright © 2021 Applicaster LTD. All rights reserved.
//

let eventsBusNamePrefix = "eventsBus."

public class EventsBusType: CustomStringConvertible {
    var type: EventsBusPredefinedType = .undefined

    public init(_ type: EventsBusPredefinedType) {
        self.type = type
    }

    public var description: String {
        var result = eventsBusNamePrefix
        switch type {
        case let .analytics(value):
            result += "analytics." + value.rawValue
        default:
            result += type.rawValue
            break
        }
        return result
    }
}
