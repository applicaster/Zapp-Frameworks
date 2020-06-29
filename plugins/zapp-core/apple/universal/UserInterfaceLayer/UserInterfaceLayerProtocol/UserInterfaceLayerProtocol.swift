//
//  UserInterfaceLayerProtocol.swift
//  ZappPlugins
//
//  Created by Anton Kononenko on 9/24/19.
//  Copyright © 2019 Applicaster LTD. All rights reserved.
//

import Foundation
import UIKit

/// The UserInterfaceLayerProtocol protocol defines methods that allow you
/// to implement UI Layer plugin inside Zapp infrustrature .
/// The methods of this protocol are mandatory.
public protocol UserInterfaceLayerProtocol {
    /// Initialization methods for UI Layer  plugin
    /// - Parameters:
    ///   - launchOptions: A dictionary indicating the reason the app was launched (if any).
    ///   The contents of this dictionary may be empty in situations where the user launched the app directly.
    ///   For information about the possible keys in this dictionary and how to handle them, see Launch Options Keys.
    ///   - applicationData: Dictionary of general configuration of the application that
    ///   may needed to initialization or usage  UI Layer  plugin
    /// - Note: This dictionary passes from `application:didFinishLaunchingWithOptions:` when application ready for use
    init(launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
         applicationData: [String: Any])

    /// Invokation of this method must prepare UI Layer plugin for use.
    /// - Note: Plugin in this method must called logic that needs to be done before UI Layer plugin will be presented.
    /// Like load `River.json` that has information about screens to present.
    /// Do not use in this func any loaders that may be called later.
    /// - Attention: Application will wait completion of this func to present application.
    /// Completion must be called as soon as  possible
    /// - Parameter completion: Completion handler that notify app level that component  ready to  be presented or fail
    /// - Parameter viewController: ViewController instance of root view  controller of the UI Layer plugin,
    /// in case plugin failed to present must call nil
    /// - Parameter error: Error handler in case plugin can not be presented for some reason,
    /// Error must  be provided  in case fail, otherwise nil
    func prepareLayerForUse(completion: @escaping (_ viewController: UIViewController?,
                                                   _ error: Error?) -> Void)
}
