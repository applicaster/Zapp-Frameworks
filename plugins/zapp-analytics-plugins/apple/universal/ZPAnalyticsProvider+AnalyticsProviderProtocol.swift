//
//  ZPAnalyticsProvider+AnalyticsProviderProtocol.swift
//  ZappAnalyticsPluginsSDK
//
//  Created by Anton Kononenko on 2/25/20.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import ZappCore

extension ZPAnalyticsProvider: AnalyticsProviderProtocol {
    public func sendEvent(_ eventName: String,
                           parameters: [String: Any]?) {
         var parametersToPass: [String: NSObject] = [:]
         if let parameters = parameters as? [String: NSObject] {
             parametersToPass = parameters
         }
         trackEvent(eventName,
                    parameters: parametersToPass)
     }

     public func sendScreenEvent(_ screenName: String,
                                 parameters: [String: Any]?) {
         var parametersToPass: [String: NSObject] = [:]
         if let parameters = parameters as? [String: NSObject] {
             parametersToPass = parameters
         }
         trackScreenView(screenName,
                         parameters: parametersToPass)
     }

     @objc public func startObserveTimedEvent(_ eventName: String,
                                              parameters: [String: Any]?) {
         trackEvent(eventName,
                    timed: true)
     }

     @objc public func stopObserveTimedEvent(_ eventName: String,
                                             parameters: [String: Any]?) {
         var parametersToPass: [String: NSObject] = [:]
         if let parameters = parameters as? [String: NSObject] {
             parametersToPass = parameters
         }
         endTimedEvent(eventName,
                       parameters: parametersToPass)
     }
}
