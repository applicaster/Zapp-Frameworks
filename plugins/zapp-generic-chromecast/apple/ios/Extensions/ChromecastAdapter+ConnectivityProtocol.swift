//
//  ChromecastAdapter+ReachabilityManagerDelegate.swift
//  ZappGeneralPluginChromecast
//
//  Created by Alex Zchut on 29/03/2020.
//  Copyright © 2020 Applicaster. All rights reserved.
//

import ZappCore

protocol ConnectivityProtocol {
    func isCastSessionConnected() -> Bool
    func isReachableViaWiFi() -> Bool
    func addConnectivityListener()
    func removeConnectivityListener()
    func updateCastButtonVisibility()
}

extension ChromecastAdapter: ConnectivityProtocol {
    
    // MARK: - Cast session connection
    func isCastSessionConnected() -> Bool {
        return isReachableViaWiFi() && self.hasConnectedCastSession() == true
    }

    func isReachableViaWiFi() -> Bool {
        self.connectivityState = FacadeConnector.connector?.connectivity?.getCurrentConnectivityState() ?? self.connectivityState
        return connectivityState == .wifi
    }
    
    func addConnectivityListener() {
        FacadeConnector.connector?.connectivity?.addConnectivityListener(self)
    }
    
    func removeConnectivityListener() {
        FacadeConnector.connector?.connectivity?.removeConnectivityListener(self)
    }
    
    func updateCastButtonVisibility() {
        switch self.connectivityState {
        case .offline, .cellular:
            if let button = self.castButton,
                button.isHidden == false {
                button.isHidden = true
            }
            //send event of no devices
            RNEventEmitter.sendEvent(for: .CAST_STATE_CHANGED, with: 0)
            break
        default:
            if let _ = self.castButton {
                //show cc button if hidden
                if let button = self.castButton,
                    button.isHidden == true {
                    button.isHidden = false
                }
                //send event of availanle devices
                RNEventEmitter.sendEvent(for: .CAST_STATE_CHANGED, with: self.getCurrentCastState())
            }
            break
        }
    }
}

extension ChromecastAdapter: ConnectivityListener {
    public func connectivityStateChanged(_ state: ConnectivityState) {
        self.connectivityState = state
    }
}
