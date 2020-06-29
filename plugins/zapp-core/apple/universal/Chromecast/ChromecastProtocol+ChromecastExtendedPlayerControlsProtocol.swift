//
//  ZPChromecastProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import UIKit

public protocol ChromecastExtendedPlayerControlsProtocol: ChromecastProtocol {
    func play(playableItems: [NSObject], playPosition: TimeInterval, completion: ((_ success:Bool) -> Void)?)
    func extendedPlayerControlsOrientationMask() -> UInt
    func getExpandedPlayerControlsViewController() -> UIViewController
    func getInlinePlayerControlsViewController() -> UIViewController
    func getMiniPlayerControlsViewController() -> UIViewController?
    func presentExtendedPlayerControls()
    func canShowPlayerBeforeCastSync() -> Bool
}
