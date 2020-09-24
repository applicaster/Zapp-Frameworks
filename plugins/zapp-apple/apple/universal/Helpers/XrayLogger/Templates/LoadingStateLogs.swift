//
//  LoadingStateLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 24/09/2020.
//

import Foundation
import XrayLogger

public struct LoadingStateLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/loading_state"

    public static var loadingStateDidSet = LogTemplate(message: "Loading state didSet")
}
