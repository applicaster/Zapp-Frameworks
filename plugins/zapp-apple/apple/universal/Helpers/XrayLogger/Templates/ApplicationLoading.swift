//
//  Logger Extensions.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/20.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

public struct ApplicationLoading: XrayLoggerTemplateProtocol {
    public struct Category {
        static let appCenter = "app_center"
        static let logger = "logger"
        static let appDelegate = "app_delegate"
        static let storage = "storage"
        static let firebase = "firebase"
    }

    public static var subsystem: String = "\(Bundle.main.bundleIdentifier!)/application_initialization"

    public static var appCenterConfigure = LogTemplate(message: "Configure AppCenter", category: Category.appCenter)
    public static var appCenterConfigureDiscribution = LogTemplate(message: "Configure AppCenter distribution service", category: Category.appCenter)
    public static var appCenterConfigureNoSecret = LogTemplate(message: "Configure AppCenter app secret was not defined", category: Category.appCenter)

    public static var loggerIntialized = LogTemplate(message: "Xray logger was intialized with context", category: Category.logger)

    public static var didFinishLaunching = LogTemplate(message: "application:didFinishLaunchingWithOptions:", category: Category.appDelegate)
    public static var didFinishLaunchingClearShortcuts = LogTemplate(message: "Clear shortcuts items, in case plugin was removed and not erased existing", category: Category.appDelegate)
    public static var didFinishLaunchingFlipper = LogTemplate(message: "Configure Flipper", category: Category.appDelegate)

    public static var handleDelayedURLScheme = LogTemplate(message: "Handle delayed URL scheme", category: Category.appDelegate)
    public static var handleDelayedShortcut = LogTemplate(message: "Handle delayed shortcut", category: Category.appDelegate)
    public static var handleDelayedLocalNotification = LogTemplate(message: "Handle delayed local notification", category: Category.appDelegate)
    public static var handleDelayedRemoteUserInfo = LogTemplate(message: "Handle delayed remote user info", category: Category.appDelegate)

    public static var handleRemoteNotificaton = LogTemplate(message: "Application did recieved remote notification", category: Category.appDelegate)
    public static var handleRemoteNotificatonDelegate = LogTemplate(message: "Remote notification has been passed to QuickBrick", category: Category.appDelegate)
    public static var delayRemoteNotificaton = LogTemplate(message: "Handle remote notification, app not ready. Wait until loading will finish", category: Category.appDelegate)

    public static var handleURLScheme = LogTemplate(message: "Handle URL scheme", category: Category.appDelegate)
    public static var handleURLSchemeDelegate = LogTemplate(message: "URL scheme has been passed to QuickBrick", category: Category.appDelegate)
    public static var delayURLScheme = LogTemplate(message: "Handle URL scheme, app not ready. Wait until loading will finish", category: Category.appDelegate)

    public static var handleShortcut = LogTemplate(message: "Handle shortcut, passing parametters to session storage", category: Category.appDelegate)
    public static var delayShortcut = LogTemplate(message: "Handle shortcut, app not ready. Wait until loading will finish", category: Category.appDelegate)
    
    public static var applicationBecomeActive = LogTemplate(message: "Application become active", category: Category.appDelegate)
    public static var applicationWillResignActive = LogTemplate(message: "Application will resign active", category: Category.appDelegate)
    public static var applicationDidRegisterRemoteNotification = LogTemplate(message: "Application did register remote notificaion", category: Category.appDelegate)
    public static var applicationDidFailRegisterRemoteNotification = LogTemplate(message: "Application did fail register remote notificaion", category: Category.appDelegate)

    public static var sessionStorageInitialized = LogTemplate(message: "Session storages initialized", category: Category.storage)
    public static var localStorageInitialized = LogTemplate(message: "Local storages initialized", category: Category.storage)

    public static var firebaseConfigure = LogTemplate(message: "Configure Firebase", category: Category.firebase)
    public static var firebaseConfigureHasValidConfiguration = LogTemplate(message: "Configure Firebase has valid configuration", category: Category.firebase)
    public static var firebaseConfigureHasNoValidConfiguration = LogTemplate(message: "Configure Firebase has no valid configuration. GoogleService-Info.plist not exists or empty", category: Category.firebase)
}
