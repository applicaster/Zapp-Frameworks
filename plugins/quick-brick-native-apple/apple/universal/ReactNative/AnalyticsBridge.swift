//
//  AnalyticsBridge.swift
//  QuickBrickApple
//
//  Created by François Roland on 22/11/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import React
import ZappCore

@objc(AnalyticsBridge)
class AnalyticsBridge: NSObject, RCTBridgeModule {
    static func moduleName() -> String! {
        return "AnalyticsBridge"
    }

    public class func requiresMainQueueSetup() -> Bool {
        return true
    }

    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }

    @objc func postEvent(_ eventName: String, payload: [String: Any]?) {
        let event = EventsBus.Event(type: EventsBusType(.analytics(.sendEvent)),
                                    source: "\(kNativeSubsystemPath)/AnalyticsBridge",
                                    data: [
                                        "name": eventName,
                                        "parameters": payload ?? [:],
                                    ])
        EventsBus.post(event)
    }

    @objc func postScreenEvent(_ eventName: String, payload: [String: Any]?) {
        let event = EventsBus.Event(type: EventsBusType(.analytics(.sendScreenEvent)),
                                    source: "\(kNativeSubsystemPath)/AnalyticsBridge",
                                    data: [
                                        "name": eventName,
                                        "parameters": payload ?? [:],
                                    ])
        EventsBus.post(event)
    }
    
    @objc func postTimedEvent(_ eventName: String, payload: [String: Any]?) {
        let event = EventsBus.Event(type: EventsBusType(.analytics(.startObserveTimedEvent)),
                                    source: "\(kNativeSubsystemPath)/AnalyticsBridge",
                                    data: [
                                        "name": eventName,
                                        "parameters": payload ?? [:],
                                    ])
        EventsBus.post(event)
    }

    @objc func endTimedEvent(_ eventName: String, payload: [String: Any]?) {
        let event = EventsBus.Event(type: EventsBusType(.analytics(.stopObserveTimedEvent)),
                                    source: "\(kNativeSubsystemPath)/AnalyticsBridge",
                                    data: [
                                        "name": eventName,
                                        "parameters": payload ?? [:],
                                    ])
        EventsBus.post(event)
    }
}
