//
//  ChromecastAdapter+Observers.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import GoogleCast
import ZappCore

extension ChromecastAdapter {

    // MARK: - Observers
    open func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(castDeviceDidChange(_:)),
            name: NSNotification.Name.gckCastStateDidChange,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(presentExpandedMediaControls(_:)),
            name: NSNotification.Name.gckExpandedMediaControlsTriggered,
            object: nil
        )

        //kGCKUICastDialogWillShowNotification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(castDialogWillShow(_:)),
            name: NSNotification.Name.gckuiCastDialogWillShow,
            object: nil
        )
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.gckCastStateDidChange,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.gckExpandedMediaControlsTriggered,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.gckuiCastDialogWillShow,
                                                  object: nil)
    }

    // MARK: - Notifications
    @objc func appDidBecomeActive() {
        self.updateVisibilityOfMiniPlayerViewController()
    }

    @objc func castDeviceDidChange(_ notification:Notification) {
        switch (GCKCastContext.sharedInstance().castState) {
        case .notConnected:
            // present the instructions on how to use Google Cast on
            // the first time the user uses you app
            self.shouldPresentIntroductionScreen = true
            break
        case .connected:
            self.updateVisibilityOfMiniPlayerViewController()
            break
        default:
            break
        }
        
        RNEventEmitter.sendEvent(for: .CAST_STATE_CHANGED, with: self.getCurrentCastState())

    }

    @objc func presentExpandedMediaControls(_ notification:Notification) {
        self.presentExtendedPlayerControls()
    }

    @objc func castDialogWillShow(_ notification:Notification) {
        if let lastActiveButton = self.lastActiveChromecastButton {
            ChromecastAnalytics.sendChromecastButtonDidTappedEvent(lastActiveChromecastButton: lastActiveButton)
        }
    }
}
