//
//  RootViewController+ReachabilityManagerDelegate.swift
//  ZappApple
//
//  Created by Anton Kononenko on 6/10/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import Reachability
import ZappCore

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
        EventsBus.post(EventsBusTopics.reachabilityChanged,
                       userInfo: ["connection": connection.description])
    }

    func showInternetError() {
        showErrorMessage(message: "You are not connected to a network. Please use your device settings to connect to a network and try again.")
    }

    func forceReloadApplication() {
        makeSplashAsRootViewContoroller()
        reloadApplication()
    }
}
