//
//  QuickBrickViewControllerLogs.swift
//  QuickBrickApple
//
//  Created by Alex Zchut on 24/09/2020.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

public struct QuickBrickViewControllerLogs: XrayLoggerTemplateProtocol {

    public static var subsystem: String = "\(kNativeSubsystemPath)/quick_brick_view_controler"

    public static var forceOrientation = LogTemplate(message: "Force orientation")

}
