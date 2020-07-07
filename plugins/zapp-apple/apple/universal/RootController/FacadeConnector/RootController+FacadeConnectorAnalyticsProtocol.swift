//
//  RootController+ZAAppDelegateConnectorAnalyticsProtocol.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorAnalyticsProtocol {
    public func sendEvent(name: String, parameters: Dictionary<String, Any>) {
        pluginsManager.analytics.sendEvent(name: name,
                                           parameters: parameters)
    }

    public func sendScreenEvent(screenTitle: String, parameters: Dictionary<String, Any>) {
        pluginsManager.analytics.sendScreenEvent(screenTitle: screenTitle,
                                                 parameters: parameters)
    }

    public func startObserveTimedEvent(name: String,
                                       parameters: Dictionary<String, Any>?) {
        pluginsManager.analytics.startObserveTimedEvent(name: name,
                                                        parameters: parameters)
    }

    public func stopObserveTimedEvent(_ eventName: String,
                                      parameters: [String: Any]?) {
        pluginsManager.analytics.stopObserveTimedEvent(eventName,
                                                       parameters: parameters)
    }
}
