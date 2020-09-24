//
//  Logger Extensions.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation

public let kNativeSubsystemPath = "\(Bundle.main.bundleIdentifier!)/native_application"

public protocol XrayLoggerTemplateProtocol {
    static var subsystem: String { get }
}

public struct LogTemplate {
    public init(message: String, category: String = "") {
        self.message = message
        self.category = category
    }

    public let message: String
    public let category: String
}
