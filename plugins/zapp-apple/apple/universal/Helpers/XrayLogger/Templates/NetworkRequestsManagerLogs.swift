//
//  NetworkRequestsManagerLogs.swift
//  ZappApple
//
//  Created by Alex Zchut on 23/02/2021.
//

import Foundation
import XrayLogger
import ZappCore

public struct NetworkRequestsManagerLogs: XrayLoggerTemplateProtocol {
    public static var subsystem: String = "\(kNativeSubsystemPath)/network_requests"
    
    public static var request = LogTemplate(message: "Network Request")

}
