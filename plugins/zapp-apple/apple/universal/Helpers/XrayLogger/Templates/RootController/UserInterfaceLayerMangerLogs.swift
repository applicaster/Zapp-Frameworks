//
//  UserInterfaceLayerMangerLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

public struct UserInterfaceLayerMangerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(rootControllerSubsystem)/user_interface_layer_manager"

    public static var userInterfaceLayerCreated = LogTemplate(message: "User Interface Layer: QuickBrick was created")
    public static var canNotCreateUserInterfaceLayer = LogTemplate(message: "Can not create user interface Layer")
}
