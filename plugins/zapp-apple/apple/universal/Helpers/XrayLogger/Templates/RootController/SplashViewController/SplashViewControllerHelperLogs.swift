//
//  SplashViewControllerHelperLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

public struct SplashViewControllerHelperLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(rootControllerSubsystem)/splash_view_controller/local_splash_helper"

    public static var localSplashImge = LogTemplate(message: "Retrieve local splash image")
}
