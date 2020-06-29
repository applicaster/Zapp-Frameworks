//
//  APTimedEvent.swift
//  ZappCore
//
//  Created by Anton Kononenko on 12/27/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation

/// Model representation of the timed event
@objc open class APTimedEvent: NSObject {
    /// Unique event name
    public var eventName: String

    /// Parameters dictionary to send for current event
    public var parameters: [String: NSObject]?

    /// Start date of the current event
    public var startTime: Date

    /// Initialization of the APTimedEvent instance
    /// - Parameters:
    ///   - eventName: Unique event name
    ///   - parameters: Parameters dictionary to send for current event
    ///   - startTime: Start date of the current event
    public init(eventName: String, parameters: [String: NSObject]?, startTime: Date) {
        self.eventName = eventName
        self.parameters = parameters
        self.startTime = startTime
    }
}
