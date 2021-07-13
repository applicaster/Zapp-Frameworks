//
//  RootController+FacadeConnectorConnectivityProtocol.swift
//  ZappApple
//
//  Created by Alex Zchut on 29/03/2020.
//

import Foundation
import ZappCore

extension RootController: FacadeConnectorConnnectivityProtocol {
    public func isOnline() -> Bool {
        var revValue = false

        switch currentConnection {
        case .connected:
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
        
        switch currentConnection {
        case let .connected(connections):
            if connections.contains(.cellular) {
                retValue = .cellular
            }
            
            if connections.contains(.wifi) {
                retValue = .wifi
            }
        case .disconnected:
            retValue = .offline
        }
        return retValue
    }

    public func addConnectivityListener(_ listener: ConnectivityListener) {
        connectivityListeners.add(listener)
    }

    public func removeConnectivityListener(_ listener: ConnectivityListener) {
        connectivityListeners.remove(listener)
    }

    @available(*, deprecated, message: "Deprecated from QB SDK 4.1.0, use EventsBus instead")
    func updateConnectivityListeners() {
        let currentConnectionState = getCurrentConnectivityState()
        for listener in connectivityListeners {
            if let connectivityListener = listener as? ConnectivityListener {
                connectivityListener.connectivityStateChanged(currentConnectionState)
            }
        }
    }
}
