//
//  SessionStorageLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

public struct SessionStorageLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/local_storage"

    public static var storageInitialized = LogTemplate(message: "Local storages initialized")
}
