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
        Sniffer.register()

        let configuration = URLSessionConfiguration.default
        Sniffer.enable(in: configuration)

        Sniffer.onLogger = { (logType: Sniffer.LogType, log: [String: Any]) in
            instance.logger?.debugLog(template: logType == .response ?
                                        NetworkRequestsManagerLogs.response : NetworkRequestsManagerLogs.request,
                                      data: log)
        }
    }
}
