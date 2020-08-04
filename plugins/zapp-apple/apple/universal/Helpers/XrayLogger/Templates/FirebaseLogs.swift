//
//  Firebase.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

public struct FirebaseLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/firebase"

    public static var firebaseConfigure = LogTemplate(message: "Configure Firebase")
    public static var firebaseConfigureHasValidConfiguration = LogTemplate(message: "Configure Firebase has valid configuration")
    public static var firebaseConfigureHasNoValidConfiguration = LogTemplate(message: "Configure Firebase has no valid configuration. GoogleService-Info.plist not exists or empty")
}
