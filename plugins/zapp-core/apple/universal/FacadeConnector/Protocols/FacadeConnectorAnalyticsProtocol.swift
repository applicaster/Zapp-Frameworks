//
//  FacadeConnectorAnalyticsProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 9/23/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation

// Allows lower layer classes like plugins to send analytics using the analytics providers set for the app
@objc public protocol FacadeConnectorAnalyticsProtocol {
    // The event will be sent using all the analytics providers added as plugins
    // It might be the event is blacklisted in the provider plugin configuration, in that case it will be ignored
    @objc optional func sendEvent(name: String, parameters: [String: Any])

    // Sends an event with the parameter title indicating the selected screen was presented to the user
    // Each provider names the event itself differently (for example Page View)
    // The event will also include a Trigger parameter which indicates the title of the previous screen
    @objc optional func sendScreenEvent(screenTitle: String, parameters: [String: Any])
    @objc optional func startObserveTimedEvent(name: String,
                                               parameters: [String: Any]?)
    @objc optional func stopObserveTimedEvent(_ eventName: String,
                                              parameters: [String: Any]?)
}
