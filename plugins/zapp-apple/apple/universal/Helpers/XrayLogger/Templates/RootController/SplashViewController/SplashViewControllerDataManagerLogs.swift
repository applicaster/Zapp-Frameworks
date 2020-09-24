//
//  SplashViewControllerDataManagerLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

public struct SplashViewControllerDataManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(rootControllerSubsystem)/splash_view_controller/data_manager"

    public static var splashVideoPath = LogTemplate(message: "Splash video path")
    public static var stylePath = LogTemplate(message: "Zapp styles file path")
}
