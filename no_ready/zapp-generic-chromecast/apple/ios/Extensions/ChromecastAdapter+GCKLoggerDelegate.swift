//
//  ChromecastAdapter+GCKLoggerDelegate.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import GoogleCast
import ZappCore

extension ChromecastAdapter: GCKLoggerDelegate {
    public func logMessage(_ message: String, fromFunction function: String) {
        let message = "GCKLogger - function: \(function), message: \(message)"
        print(message)
    }
}
