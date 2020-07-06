//
//  ChromecastAdapter+GCKUIMiniMediaControlsViewControllerDelegate.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import GoogleCast

extension ChromecastAdapter: GCKUIMiniMediaControlsViewControllerDelegate {

    public func miniMediaControlsViewController(_ miniMediaControlsViewController: GCKUIMiniMediaControlsViewController, shouldAppear: Bool) {

        var needUpdateAppearance = false
        if let heightConstraint = self.localContainerViewEventsDelegate?.chromecastContainerViewHeightConstraint() {
            if (heightConstraint.constant == 0 && shouldAppear) || (heightConstraint.constant > 0 && !shouldAppear) {
                needUpdateAppearance = true
            }
        }
        self.updateVisibilityOfMiniPlayerViewController(needUpdateAppearance: needUpdateAppearance)
    }
}
