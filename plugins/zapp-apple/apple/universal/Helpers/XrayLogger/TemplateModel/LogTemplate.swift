//
//  Logger Extensions.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Foundation
import XrayLogger

public let kNativeSubsystemPath = "\(Bundle.main.bundleIdentifier!)/native_application"

protocol XrayLoggerTemplateProtocol {
    static var subsystem: String { get }
}

public struct LogTemplate {
    internal init(message: String, category: String = "") {
        self.message = message
        self.category = category
    }

    let message: String
    let category: String
}
