//
//  ZPAnalyticsProvider+TimedEventsSupport.swift
//  ZappAnalyticsPluginBase
//
//  Created by Liviu Romascanu on 25/06/2018.
//  Copyright © 2018 Applicaster Ltd. All rights reserved.
//

import ZappCore
import ZappPlugins

@objc extension ZPAnalyticsProvider: ZPAnalyticsProviderTimedEventsSupportProtocol {
    public func registerTimedEvent(_ eventName: String, parameters: [String : NSObject]?) {
        if let currentEvent = self.timedEventsDictionary[eventName] {
            self.processEndTimedEvent(currentEvent.eventName, parameters: currentEvent.parameters)
        }
        
        let timedEvent = APTimedEvent(eventName: eventName, parameters: parameters, startTime: Date())
        self.timedEventsDictionary[eventName] = timedEvent
    }
    
    public func processEndTimedEvent(_ eventName: String, parameters: [String : NSObject]?) {
        if let timedEvent = self.timedEventsDictionary[eventName] {
            // Handle merging parameters with the later ones overriding the earlier ones if needed
            let parameters = parameters ?? [:] as [String:NSObject]
            let timedEventParameters = timedEvent.parameters ?? [:] as [String:NSObject]
            var mergedParameters = timedEventParameters.merge(parameters)
            mergedParameters["Event Duration"] = "\(Int(abs(timedEvent.startTime.timeIntervalSinceNow)))" as NSObject
            timedEvent.parameters = mergedParameters
            self.trackEvent(timedEvent.eventName, parameters: mergedParameters)
            self.timedEventsDictionary.removeValue(forKey: eventName)
        }
    }
    
}

@objc extension APAnalyticsProvider: ZPAnalyticsProviderTimedEventsSupportProtocol {
    public func registerTimedEvent(_ eventName: String, parameters: [String : NSObject]?) {
        if let currentEvent = self.timedEventsDictionary[eventName] as? APTimedEvent {
            self.processEndTimedEvent(currentEvent.eventName, parameters: currentEvent.parameters)
        }

        let timedEvent = APTimedEvent(eventName: eventName, parameters: parameters, startTime: Date())
        self.timedEventsDictionary[eventName] = timedEvent
    }

    public func processEndTimedEvent(_ eventName: String, parameters: [String : NSObject]?) {
        if let timedEvent = self.timedEventsDictionary[eventName]  as? APTimedEvent  {
            // Handle merging parameters with the later ones overriding the earlier ones if needed
            let parameters = parameters ?? [:] as [String:NSObject]
            let timedEventParameters = timedEvent.parameters ?? [:] as [String:NSObject]
            var mergedParameters = timedEventParameters.merge(parameters)
            mergedParameters["Event Duration"] = "\(Int(abs(timedEvent.startTime.timeIntervalSinceNow)))" as NSObject
            timedEvent.parameters = mergedParameters
            self.trackEvent(eventName, parameters: mergedParameters)
            self.timedEventsDictionary.removeObject(forKey: eventName)
        }
    }
}
