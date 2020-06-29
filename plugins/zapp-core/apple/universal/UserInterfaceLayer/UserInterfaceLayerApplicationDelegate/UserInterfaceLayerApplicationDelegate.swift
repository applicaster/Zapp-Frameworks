//
//  UserInterfaceLayerApplicationDelegate.swift
//  ZappCore
//
//  Created by Anton Kononenko on 12/24/19.
//

import Foundation
import UIKit

/// The protocol allows to support messaging that comes from `UIApplicationDelegate` and rest iOS API
/// This maybe relevant to inform UILayer Plugin in cases url schme comes to application
public protocol UserInterfaceLayerDelegate: AnyObject {
    /// Delegate instance that conforms implemented `UIApplicationDelegate` functions
    var applicationDelegate: UIApplicationDelegate? { get set }
    var userNotificationCenterDelegate: UNUserNotificationCenterDelegate? { get set }
}
