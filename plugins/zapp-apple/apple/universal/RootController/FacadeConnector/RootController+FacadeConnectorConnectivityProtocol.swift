//
//  RootController+FacadeConnectorConnectivityProtocol.swift
//  ZappApple
//
//  Created by Alex Zchut on 29/03/2020.
//

import Foundation
import Reachability
import ZappCore

extension RootController: FacadeConnectorConnnectivityProtocol {
    public func isOnline() -> Bool {
        var revValue = false

        switch currentConnection {
        case .wifi, .cellular:
            revValue = true
        default:
            break
        }

        return revValue
    }

    public func isOffline() -> Bool {
        return !isOnline()
    }

    public func getCurrentConnectivityState() -> ConnectivityState {
        var retValue: ConnectivityState = .cellular

        guard let connection = currentConnection else {
            return retValue
        }

        switch connection {
        case .cellular:
            retValue = .cellular
        case .wifi:
            retValue = .wifi
        case .unavailable, .none:
            retValue = .offline
        }
        return retValue
    }
}
