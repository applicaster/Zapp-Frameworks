//
//  RootController+FacadeConnectorConnectivityProtocol.swift
//  ZappApple
//
//  Created by Alex Zchut on 29/03/2020.
//

import Foundation
import ZappCore
import Reachability

extension RootController: FacadeConnectorConnnectivityProtocol {
    public func isOnline() -> Bool {
        var revValue = false
        
        switch self.currentConnection {
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
        var retValue:ConnectivityState = .cellular
        
        guard let connection = self.currentConnection else {
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
    
    public func addConnectivityListener(_ listener: ConnectivityListener) {
        self.connectivityListeners.add(listener)
    }
    
    public func removeConnectivityListener(_ listener: ConnectivityListener) {
        self.connectivityListeners.remove(listener)
    }
    
    func updateConnectivityListeners() {
        let currentConnectionState = getCurrentConnectivityState()
        for listener in self.connectivityListeners {
            if let connectivityListener = listener as? ConnectivityListener {
                connectivityListener.connectivityStateChanged(currentConnectionState)
            }
        }
    }
}
