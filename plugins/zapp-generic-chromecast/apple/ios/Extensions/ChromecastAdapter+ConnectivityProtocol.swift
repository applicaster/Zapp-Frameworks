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
    func updateConnectivityState()
    func updateCastButtonVisibility()
}

extension ChromecastAdapter: ConnectivityProtocol {
    // MARK: - Cast session connection

    func isCastSessionConnected() -> Bool {
        return isReachableViaWiFi() && hasConnectedCastSession() == true
    }

    func isReachableViaWiFi() -> Bool {
        if let connectivity = FacadeConnector.connector?.connectivity {
            connectivityState = connectivity.getCurrentConnectivityState()
        }

        return connectivityState == .wifi
    }

    func updateConnectivityState() {
        guard let connectivity = FacadeConnector.connector?.connectivity else {
            return
        }
        connectivityState = connectivity.getCurrentConnectivityState()
    }

    func updateCastButtonVisibility() {
        switch connectivityState {
        case .offline, .cellular:
            if let button = castButton,
               button.isHidden == false {
                button.isHidden = true
            }
            // send event of no devices
            RNEventEmitter.sendEvent(for: .CAST_STATE_CHANGED, with: 0)
            break
        default:
            if let _ = castButton {
                // show cc button if hidden
                if let button = castButton,
                   button.isHidden == true {
                    button.isHidden = false
                }
                // send event of availanle devices
                RNEventEmitter.sendEvent(for: .CAST_STATE_CHANGED, with: getCurrentCastState())
            }
            break
        }
    }
}
