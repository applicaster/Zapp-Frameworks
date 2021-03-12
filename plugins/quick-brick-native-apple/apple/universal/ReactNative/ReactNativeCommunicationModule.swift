//
//  ReactNativeCommunicationModule.swift
//  QuickBrickApple
//
//  Created by François Roland on 20/11/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import React
import os.log

let kQuickBrickCommunicationModule = "QuickBrickCommunicationModule"

/**
 Events Supported by the QuickBrickManager native module
 In order to add events, add a case, and add the invoke the appropriate handler in the invokeHandler method
 */
enum Events: String {
    case quickBrickReady = "quickBrickReady"
    case moveAppToBackground = "moveAppToBackground"
    case allowedOrientationsForScreen = "allowedOrientationsForScreen"
    case releaseOrientationsForScreen = "releaseOrientationsForScreen"
    case idleTimerDisabled = "idleTimerDisabled"
    /**
     invokes the event handler for a given event
     - parameter manager: instance of the native module on which the event handler should be invoked
     - parameter payload: dictionary of options to pass to the event handler
     */
    func invokeHandler(manager: QuickBrickManagerDelegate, payload: Dictionary<String, Any>) {
        switch self {
        case .quickBrickReady:
            manager.setQuickBrickReady()
        case .moveAppToBackground:
            manager.moveAppToBackground()
        case .allowedOrientationsForScreen:
            manager.allowOrientationForScreen(payload)
        case .releaseOrientationsForScreen:
            manager.releaseOrientationForScreen()
        case .idleTimerDisabled:
            manager.idleTimerDisabled(payload)
        }    
    }
}

/// Delegate Protocol for the QuickBrickManager native module
@objc public protocol QuickBrickManagerDelegate {
    /// tells the delegate that the Quick Brick app is ready to be displayed
    func setQuickBrickReady()

    /// Force move application to background
    func moveAppToBackground()
    
    /// Allow Orientation for specific screen
    ///
    /// - Parameters:
    ///   - orientation: int value representing 
    ///         JS_PORTAIT = 1
    ///         JS_LANDSCAPE = 1
    ///         JS_LANDSCAPE_REVERSED = 4
    ///         JS_PORTAIT_REVERSED = 8
    ///         JS_LANDSCAPE_SENSOR = JS_LANDSCAPE | JS_LANDSCAPE_REVERSED
    ///         JS_PORTAIT_SENSOR = JS_PORTAIT | JS_PORTAIT_REVERSED
    ///         JS_FULL_SENSOR = JS_LANDSCAPE_SENSOR | JS_PORTAIT_SENSOR
    ///         JS_SENSOR = JS_LANDSCAPE_SENSOR | JS_PORTAIT
    func allowOrientationForScreen(_ payload: Dictionary<String, Any>)
    
    /// Release Orientation for specific screen to previous state
    func releaseOrientationForScreen()

    func idleTimerDisabled(_ payload: Dictionary<String, Any>)
}

@objc(QuickBrickCommunicationModule)
class ReactNativeCommunicationModule: NSObject, RCTBridgeModule {
    var delegateManager: QuickBrickManagerDelegate? {
        return self.bridge?.delegate as? QuickBrickManagerDelegate
    }
    
    /// main React bridge
    public var bridge: RCTBridge?
    
    
    static func moduleName() -> String! {
        return kQuickBrickCommunicationModule
    }
    
    public class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    /// prefered thread on which to run this native module
    @objc public var methodQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
    @objc public func constantsToExport() -> [AnyHashable : Any]! {
        return ReactNativeManager.applicationData
    }

    /**
     bridged method exposed to the js code to allow the js code to send an event to the native code
     - parameter eventName: name of the event to be fired - should match a case of the Events enum, otherwise leads to a noop
     - parameter payload: optional dictionary of properties to pass to the event handler
     */
    @objc func quickBrickEvent(_ eventName: String, payload: [String:Any]?) {
        let event = Events(rawValue: eventName)
        
        guard event != nil, let delegateManager = delegateManager else {
            _ = OSLog(subsystem: "QUICK_BRICK:: unknown manager event called: " + eventName, category: kQuickBrickCommunicationModule)
            return
        }
        
        event?.invokeHandler(manager: delegateManager, payload: payload ?? [:])
    }
}
