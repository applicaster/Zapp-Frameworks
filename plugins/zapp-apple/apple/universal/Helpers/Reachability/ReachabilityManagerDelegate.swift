//
//  ReachabilityManagerDelegate.swift
//  ZappApple
//
//  Created by Anton Kononenko on 6/10/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import Network

protocol ReachabilityManagerDelegate {
    func reachabilityChanged(_ state: ReachabilityState)
}

public enum ReachabilityState: Equatable {
    case connected(_ interfaces: [NWInterface.InterfaceType])
    case disconnected

    public static func == (lhs: ReachabilityState, rhs: ReachabilityState) -> Bool {
        switch (lhs, rhs) {
        case let (.connected(a1), .connected(a2)):
            return a1 == a2
        case (.disconnected, .disconnected):
            return true
        default:
            return false
        }
    }

    public var description: String {
        var retValue = ""
        switch self {
        case .connected:
            retValue = "connected"
        case .disconnected:
            retValue = "disconnected"
        }
        return retValue
    }
}
