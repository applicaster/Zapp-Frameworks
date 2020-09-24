//
//  LocalStorageLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

public struct LocalStorageLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/session_storage"

    public static var storageInitialized = LogTemplate(message: "Session storages initialized")
}
