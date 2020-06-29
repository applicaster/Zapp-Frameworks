//
//  ZPChromecastProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import UIKit

public protocol ChromecastMiniPlayerViewControllerProtocol: ChromecastProtocol {
    func createMiniPlayerViewController()
    func getMiniMediaControlsViewController() -> UIViewController?
    func uninstallMiniPlayerViewController()
    func updateVisibilityOfMiniPlayerViewController()
}

