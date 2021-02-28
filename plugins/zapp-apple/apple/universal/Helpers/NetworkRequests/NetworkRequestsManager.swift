//
//  NetworkRequestsManager.swift
//  ZappApple
//
//  Created by Alex Zchut on 23/02/2021.
//  Copyright © 2021 Applicaster LTD. All rights reserved.
//

import Foundation
import XrayLogger
import ZappCore

public class NetworkRequestsManager {
    fileprivate static var instance = NetworkRequestsManager()
    lazy var logger = Logger.getLogger(for: NetworkRequestsManagerLogs.subsystem)
    var pendingRequests: [String: [String: Any]] = [:]

    struct Params {
        static let request = "request"
        static let response = "response"
        static let error = "error"
        static let statusCode = "statusCode"
        static let url = "url"
    }

    public static func startListening() {
        Sniffer.ignore(extensions: ["png", "jpeg", "jpg", "ts"])
        Sniffer.onLogger = { (url: URL, logType: Sniffer.LogType, content: [String: Any]) in
            switch logType {
            case .request:
                instance.pendingRequests[url.absoluteString] = content
            case .response:
                guard let request = instance.pendingRequests.removeValue(forKey: url.absoluteString),
                      let response = content[Params.response] as? [String: Any],
                      let statusCode = response[Params.statusCode] as? String else {
                    return
                }

                instance.logger?.verboseLog(message: "\(NetworkRequestsManagerLogs.request.message): \(url.host ?? "")",
                                            category: NetworkRequestsManagerLogs.request.category,
                                            data: [Params.request: request,
                                                   Params.response: response,
                                                   Params.statusCode: statusCode,
                                                   Params.url: url.absoluteString])
            }
        }
        Sniffer.start()
    }
}
