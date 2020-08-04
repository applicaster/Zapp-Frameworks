//
//  SplashViewControllerHelperLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

public struct SplashViewControllerHelperLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(rootControllerSubsystem)/splash_view_controller/local_splash_helper"

    public static var localSplashImge = LogTemplate(message: "Retrieve local splash image")
}
