//
//  RootViewController+ReachabilityManagerDelegate.swift
//  ZappApple
//
//  Created by Anton Kononenko on 6/10/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import ZappCore

extension RootController: ReachabilityManagerDelegate {
    func reachabilityChanged(_ state: ReachabilityState) {
        switch state {
        case .connected(_):
            if currentConnection == .disconnected {
                forceReloadApplication()
            }
        case .disconnected:
            showInternetError()
        }
        currentConnection = state

        updateConnectivityListeners()
        
        let event = EventsBus.Event(type: EventsBusType(.reachabilityChanged),
                                    source: logger?.subsystem,
                                    data: ["connection": currentConnection.description])
        EventsBus.post(event)
    }

    func showInternetError() {
        showErrorMessage(message: "You are not connected to a network. Please use your device settings to connect to a network and try again.")
    }

    func forceReloadApplication() {
        makeSplashAsRootViewContoroller()
        reloadApplication()
    }
}
