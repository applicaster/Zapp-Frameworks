//
//  OptaTeamContainerManager.swift
//  OptaStats
//
//  Created by Alex Zchut on 11/06/2021.
//  Copyright © 2021 Applicaster Ltd. All rights reserved.
//

import Foundation
import React

@objc(OptaTeamContainerManager)
public class OptaTeamContainerManager: RCTViewManager {
    static let optaStatsModuleName = "OptaTeamContainer"

    override public static func moduleName() -> String? {
        return OptaTeamContainerManager.optaStatsModuleName
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
        return OptaTeamContainer(eventDispatcher: eventDispatcher)
    }
}
