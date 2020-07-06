//
//  ChromecastAdapter+ChromecastExtendedPlayerControlsProtocol.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import GoogleCast
import ZappCore

extension ChromecastAdapter : ChromecastExtendedPlayerControlsProtocol {
    public func extendedPlayerControlsOrientationMask() -> UInt {
        return UIInterfaceOrientationMask.all.rawValue
    }
    
    public func getMiniPlayerControlsViewController() -> UIViewController? {
        guard let castViewExtender = castViewExtender  else {
            return miniMediaControlsViewController
        }
        return castViewExtender.getMiniPlayerNavigation()
    }
    
    public func getExpandedPlayerControlsViewController() -> UIViewController {
        guard let castViewExtender = castViewExtender  else {
            return ChromecastExpandedMediaControlsViewController(adapter: self)
        }
        
        return castViewExtender.getPlayerNavigation()
    }
    
    public func getInlinePlayerControlsViewController() -> UIViewController {
        guard let castViewExtender = castViewExtender  else {
            let defaultVC = UIViewController()
            defaultVC.view.backgroundColor = UIColor.black
            return defaultVC
        }
        
        return castViewExtender.getPlayerNavigation()
    }

    public func play(playableItems: [NSObject],  playPosition: TimeInterval, completion: ((_ success:Bool) -> Void)?) {
        let playerDelegate = self as ChromecastPlayerProtocol
        playerDelegate.prepareToPlay(playableItems: playableItems,
                                     playPosition: playPosition,
                                     completion: completion)
    }

    public func presentExtendedPlayerControls() {
        let chromecastExpandedVC = ChromecastExpandedMediaControlsViewController(adapter: self)
        
        guard chromecastExpandedVC.isExpandedMediaControlsViewControllerAvailable(),
            let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }

        rootVC.present(chromecastExpandedVC, animated: true, completion: nil)
    }

    public func hasAvailableChromecastDevices() -> Bool {
        guard GCKCastContext.isSharedInstanceInitialized() else {
            return false
        }
        
        return GCKCastContext.sharedInstance().castState != .noDevicesAvailable
    }
    
    public func getCurrentCastState() -> UInt {
        guard GCKCastContext.isSharedInstanceInitialized() else {
            return 0
        }
        
        return GCKCastContext.sharedInstance().castState.rawValue
    }
    
    public func canShowPlayerBeforeCastSync() -> Bool {
        guard let _ = castViewExtender else {
            return false
        }
        return true
    }
}
