//
//  RootControllerLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger
let rootControllerSubsystem = "\(kNativeSubsystemPath)/root_controller"

public struct RootControllerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = rootControllerSubsystem

    public static var rootControllerCreated = LogTemplate(message: "Root controller was created")
}
