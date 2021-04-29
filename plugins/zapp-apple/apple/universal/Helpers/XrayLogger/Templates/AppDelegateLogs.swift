//
//  AppDelegate.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

public struct AppDelegateLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/app_delegate"

    public static var didFinishLaunching = LogTemplate(message: "application:didFinishLaunchingWithOptions:")
    public static var didFinishLaunchingClearShortcuts = LogTemplate(message: "Clear shortcuts items, in case plugin was removed and not erased existing")
    public static var didFinishLaunchingFlipper = LogTemplate(message: "Configure Flipper")

    public static var handleDelayedURLScheme = LogTemplate(message: "Handle delayed URL scheme")
    public static var handleDelayedShortcut = LogTemplate(message: "Handle delayed shortcut")
    public static var handleDelayedLocalNotification = LogTemplate(message: "Handle delayed local notification")
    public static var handleDelayedRemoteUserInfo = LogTemplate(message: "Handle delayed remote user info")

    public static var handleRemoteNotificaton = LogTemplate(message: "Application did recieved remote notification")
    public static var handleRemoteNotificatonDelegate = LogTemplate(message: "Remote notification has been passed to QuickBrick")
    public static var delayRemoteNotificaton = LogTemplate(message: "Handle remote notification, app not ready. Wait until loading will finish")

    public static var handleURLScheme = LogTemplate(message: "Handle URL scheme")
    public static var handleURLSchemeDelegate = LogTemplate(message: "URL scheme has been passed to QuickBrick")
    public static var delayURLScheme = LogTemplate(message: "Handle URL scheme, app not ready. Wait until loading will finish")

    public static var handleShortcut = LogTemplate(message: "Handle shortcut, passing parametters to session storage")
    public static var delayShortcut = LogTemplate(message: "Handle shortcut, app not ready. Wait until loading will finish")

    public static var applicationBecomeActive = LogTemplate(message: "Application become active")
    public static var applicationWillResignActive = LogTemplate(message: "Application will resign active")
    public static var applicationDidRegisterRemoteNotification = LogTemplate(message: "Application did register remote notificaion")
    public static var applicationDidFailRegisterRemoteNotification = LogTemplate(message: "Application did fail register remote notificaion")
    
    public static var handleSilentRemoteNotification = LogTemplate(message: "Handle silent remote notification")
    public static var handleSilentRemoteNotificationPresentLocalPush = LogTemplate(message: "Handle silent remote notification - Present local push")
    public static var handleSilentRemoteNotificationFailedToAddAttachment = LogTemplate(message: "Handle silent remote notification - Failed to add attachment")

}
