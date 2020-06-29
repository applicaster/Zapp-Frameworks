//
//  ChromecastProtocol+ChromecastNotificationsProtocol.swift
//  ZappCore
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import UIKit

public protocol ChromecastNotificationsProtocol {
    func chromecastContainerView() -> UIView?
    func chromecastContainerViewHeightConstraint() -> NSLayoutConstraint?
    func chromecastContainerParentViewController() -> UIViewController?
}
