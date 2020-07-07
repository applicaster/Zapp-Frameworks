//
//  RootViewController+ReachabilityManagerDelegate.swift
//  ZappApple
//
//  Created by Anton Kononenko on 6/10/19.
//  Copyright © 2019 Anton Kononenko. All rights reserved.
//

import Foundation
import Reachability

extension RootController: ReachabilityManagerDelegate {
    
    func reachabilityChanged(connection: Reachability.Connection) {
        switch connection {
        case .wifi, .cellular:
            if let currentConnection = currentConnection,
                currentConnection == .unavailable {
                forceReloadApplication()
            }
        case .none:
            showInternetError()
        case .unavailable:
            showInternetError()
        }
        currentConnection = connection

        updateConnectivityListeners()
    }
    
    func showInternetError() {
        showErrorMessage(message: "You are not connected to a network. Please use your device settings to connect to a network and try again.")
    }
    
    func forceReloadApplication() {
        makeSplashAsRootViewContoroller()
        reloadApplication()
    }

}
