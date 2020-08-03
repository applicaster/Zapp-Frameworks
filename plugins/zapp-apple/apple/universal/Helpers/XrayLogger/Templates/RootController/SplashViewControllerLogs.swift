//
//  SplashViewControllerLogs.swift
//  ZappApple
//
//  Created by Anton Kononenko on 08/03/20.
//  Copyright © 2020 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

public struct SplashViewControllerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(rootControllerSubsystem)/splash_view_controller"

    public static var splashViewControllerCreated = LogTemplate(message: "SplashViewController was created")
    public static var videoURL = LogTemplate(message: "Retrieve video url")

    public static var preparePlayerViewController = LogTemplate(message: "Prepare player view controller")
    public static var preparePlayerViewControllerNoURL = LogTemplate(message: "No URL availible, skipping creation PlayerViewController")
    public static var showErrorMessage = LogTemplate(message: "Application handle presentation error message")
    public static var playerVIewControllerFinished = LogTemplate(message: "PlayerViewController finish to play item")
    public static var splashViewConrollerStartAppLoadingTask = LogTemplate(message: "SplashViewController start loading app")
    public static var splashViewConrollerFinishedTask = LogTemplate(message: "SplashViewController finish task")
}

public struct SplashViewControllerDataManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(rootControllerSubsystem)/splash_view_controller/data_manager"

    public static var splashVideoPath = LogTemplate(message: "Splash video path")
    public static var stylePath = LogTemplate(message: "Zapp styles file path")
}

public struct SplashViewControllerHelperLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(rootControllerSubsystem)/splash_view_controller/local_splash_helper"

    public static var localSplashImge = LogTemplate(message: "Retrieve local splash image")
}
