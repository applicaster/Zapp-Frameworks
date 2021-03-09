//
//  ReactNativeManagerLogs.swift
//  QuickBrickApple
//
//  Created by Alex Zchut on 24/09/2020.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

public struct ReactNativeManagerLogs: XrayLoggerTemplateProtocol {

    public static var subsystem: String = "\(kNativeSubsystemPath)/react_native_manager"

    public static var mountingReactApp = LogTemplate(message: "Mounting React App")
    public static var noReactBridge = LogTemplate(message: "No React Bridge")
    public static var presentingReactViewController = LogTemplate(message: "Presenting React ViewController")
    public static var setRightToLeftFlagError = LogTemplate(message: "Error setting RTL")
    public static var failedToLoadJson = LogTemplate(message: "Failed to load json")
}
