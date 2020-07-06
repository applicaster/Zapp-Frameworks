//
//  ChromecastAdapter+ZPChromecastProtocol.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import GoogleCast
import ZappCore

extension ChromecastAdapter: ChromecastProtocol {
    public var isEnabled: Bool {
        return enabled
    }

    public var containerViewEventsDelegate: Any? {
        get {
            return localContainerViewEventsDelegate
        }
        set(newValue) {
            localContainerViewEventsDelegate = newValue as? ChromecastNotificationsProtocol
        }
    }

    public var triggeredChromecastButton: ChromecastButtonOrigin? {
        get {
            return localTriggeredChromecastButton
        }
        set(newValue) {
            localTriggeredChromecastButton = newValue
        }
    }

    public var lastActiveChromecastButton: ChromecastButtonOrigin? {
        get {
            return localLastActiveChromecastButton
        }
        set(newValue) {
            localLastActiveChromecastButton = newValue
        }
    }

    public func prepareChromecastForUse() -> Bool {
        guard let chromecastAppId = chromecastAppId else {
            return false
        }

        let discoveryCriteria = GCKDiscoveryCriteria(applicationID: chromecastAppId)
        let options = GCKCastOptions(discoveryCriteria: discoveryCriteria)

        if GCKCastContext.setSharedInstanceWith(options, error: nil) {
            GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = false

            // set logger
            let logFilter: GCKLoggerFilter = GCKLoggerFilter()
            let classes = ["GCKDeviceScanner",
                           "GCKDeviceProvider",
                           "GCKDiscoveryManager",
                           "GCKCastChannel",
                           "GCKMediaControlChannel",
                           "GCKUICastButton",
                           "GCKUIMediaController",
                           "NSMutableDictionary"]
            logFilter.setLoggingLevel(.error, forClasses: classes)

            GCKLogger.sharedInstance().filter = logFilter
            GCKLogger.sharedInstance().delegate = self

            addObservers()

            return true
        } else {
            return false
        }
    }

    public func hasConnectedCastSession() -> Bool {
        guard GCKCastContext.isSharedInstanceInitialized() else {
            return false
        }

        return GCKCastContext.sharedInstance().sessionManager.hasConnectedCastSession()
    }

    public func getConnectedDeviceName() -> String? {
        if !hasConnectedCastSession() {
            return nil
        }

        return GCKCastContext.sharedInstance().sessionManager.currentSession?.device.friendlyName
    }

    public func createChromecastButton(frame: CGRect,
                                       customIcons: [String: [UIImage]]?) -> UIButton {
        let castButton = GCKUICastButton(frame: frame)
//        if let customIcons = customIcons,
//            let activeIcon = customIcons[ChromecastButtonIcons.active]?.first,
//            let inactiveIcon = customIcons[ChromecastButtonIcons.inactive]?.first,
//            let animationIcons = customIcons[ChromecastButtonIcons.animation], animationIcons.count == 3 {
//
//            castButton.setInactiveIcon(inactiveIcon,
//                                       activeIcon: activeIcon,
//                                       animationIcons: animationIcons)
//        }

        // Check if the we want handle the chromecast devices dialog window
        // Otherwise, use Google's default devices dialog
        if castViewExtender != nil {
            castButton.triggersDefaultCastDialog = false
            castButton.addTarget(self, action: #selector(showCustomDevicesDialog), for: .touchUpInside)
        }

        return castButton
    }

    public func createChromecastButton(frame: CGRect) -> UIButton {
        return createChromecastButton(frame: frame,
                                      customIcons: nil)
    }

    public func presentCastInstructionsViewControllerOnce(with castButton: UIButton) {
        guard GCKCastContext.isSharedInstanceInitialized(),
            let castButton = castButton as? GCKUICastButton else {
            return
        }

        GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: castButton)
    }
    
    public func play() {
        guard GCKCastContext.isSharedInstanceInitialized(),
            let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient else {
            return
        }
        
        remoteMediaClient.play()
    }
    
    public func stop() {
        guard GCKCastContext.isSharedInstanceInitialized(),
            let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient else {
            return
        }
        
        remoteMediaClient.stop()
    }
    
    public func pause() {
        guard GCKCastContext.isSharedInstanceInitialized(),
            let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient else {
            return
        }
        
        remoteMediaClient.pause()
    }
    
    public func seek(_ playPosition: Int) {
        guard GCKCastContext.isSharedInstanceInitialized(),
            let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient else {
            return
        }
        
        let options = GCKMediaSeekOptions()
        options.interval = TimeInterval(playPosition)
        options.resumeState = .play
        remoteMediaClient.seek(with: options)
    }
    
    public func setVolume(_ volume: Float) {
        guard GCKCastContext.isSharedInstanceInitialized(),
            let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient else {
            return
        }
        remoteMediaClient.setStreamVolume(volume)
    }

    public func defaultExpandedMediaControlsViewController() -> UIViewController? {
        guard GCKCastContext.isSharedInstanceInitialized() else {
            return nil
        }

        return GCKCastContext.sharedInstance().defaultExpandedMediaControlsViewController
    }

    public func getShouldPresentIntroductionScreen() -> Bool {
        return shouldPresentIntroductionScreen
    }

    @objc func showCustomDevicesDialog(_ sender: UIButton) {
        castViewExtender?.showDialog()
    }

    @objc open func addButton(to container: UIView?,
                              key: String,
                              color: UIColor?) {
        if enabled {
            guard let container = container else {
                return
            }

            // create button with container bounds
            var frame = container.bounds
            if frame == CGRect.zero {
                frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 60, height: 47))
            }
            createButtonIfNeeded(frame: frame)

            guard let button = castButton else {
                return
            }

            // customize button color
            if let buttonColor = color {
                button.tintColor = buttonColor
            }

            // set button tag for analytics reasons
            if let tag = kChromecastButtonTag[key] {
                button.tag = tag
            }
            
            // Set button details
            button.frame = container.bounds
            button.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            // add subview
            container.addSubview(button)

            // create mini player
            createMiniPlayerViewController()
        }
    }

    fileprivate func createButtonIfNeeded(frame: CGRect) {
        guard castButton == nil else {
            return
        }

        let button = createChromecastButton(frame: frame)

        // catch tap event for analytics
        button.addTarget(self, action: #selector(chromecastButtonTapped(_:)), for: .touchUpInside)

        // assign cast button
        castButton = button
    }

    @objc private func chromecastButtonTapped(_ sender: UIButton?) {
        guard let chromecastButton = sender else {
            return
        }

        switch chromecastButton.tag {
        case 0:
            lastActiveChromecastButton = .appNavbar
        case 1:
            lastActiveChromecastButton = .playerNavbar
        default:
            print("Chromecast button was pressed without a configured tag, please be aware")
        }
    }
}
