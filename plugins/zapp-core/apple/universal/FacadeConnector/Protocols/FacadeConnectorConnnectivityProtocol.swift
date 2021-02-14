//
//  FacadeConnectorConnnectivityProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 29/03/2020.
//

import Foundation

@objc public enum ConnectivityState: NSInteger {
    case offline = 0
    case cellular
    case wifi
}

@objc public protocol FacadeConnectorConnnectivityProtocol {
    /**
     Get online status
     */
    @objc func isOnline() -> Bool
    /**
     Get offline status
     */
    @objc func isOffline() -> Bool
    /**
     Get current connectivity state
     */
    @objc func getCurrentConnectivityState() -> ConnectivityState
}
