//
//  NetworkRequestsManager.swift
//  ZappApple
//
//  Created by Alex Zchut on 23/02/2021.
//  Copyright © 2021 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger

public class NetworkRequestsManager {
    fileprivate static var instance = NetworkRequestsManager()
    lazy var logger = Logger.getLogger(for: NetworkRequestsManagerLogs.subsystem)

    public static func startListening() {
        Sniffer.onLogger = { (logType: Sniffer.LogType, data: [String: Any]) in
            switch logType {
            case .request:
                instance.logger?.verboseLog(template: NetworkRequestsManagerLogs.request,
                                            data: data)
            case .response:
                instance.logger?.verboseLog(template: NetworkRequestsManagerLogs.response,
                                            data: data)
            }
        }
        Sniffer.start(for: URLSessionConfiguration.default)
    }
}
