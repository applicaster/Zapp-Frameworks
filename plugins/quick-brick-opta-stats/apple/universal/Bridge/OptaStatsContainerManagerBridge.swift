//
//  OptaStatsContainerManager.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/04/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import React

@objc(OptaStatsContainerManager)
public class OptaStatsContainerManager: RCTViewManager {

    override public static func moduleName() -> String? {
        return String(describing: Self.self)
    }
    
    override public class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override open var methodQueue: DispatchQueue {
        return bridge.uiManager.methodQueue
    }
    
    override public func view() -> UIView? {
        guard let eventDispatcher = bridge?.eventDispatcher() else {
            return nil
        }
        return OptaStatsContainer(eventDispatcher: eventDispatcher)
    }
}
