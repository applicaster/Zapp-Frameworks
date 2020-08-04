//
//  LocalStorageLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

public struct LocalStorageLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/session_storage"

    public static var storageInitialized = LogTemplate(message: "Session storages initialized")
}
