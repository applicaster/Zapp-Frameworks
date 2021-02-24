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
    var pendingRequests: [String: [String: Any]] = [:]

    struct Params {
        static let request = "request"
        static let response = "response"
        static let error = "error"
        static let statusCode = "statusCode"
    }
    
    public static func startListening() {
        Sniffer.ignore(extensions: ["png", "jpeg", "jpg", ""])
        Sniffer.onLogger = { (url: URL, logType: Sniffer.LogType, content: [String: Any]) in
            switch logType {
            case .request:
                instance.pendingRequests[url.absoluteString] = content
            case .response:
                guard let request = instance.pendingRequests[url.absoluteString],
                      let response = content[Params.response] as? [String: Any],
                      let statusCode = response[Params.statusCode] as? String else {
                    return
                }
                instance.pendingRequests.removeValue(forKey: url.absoluteString)
                if shouldSendWarning(response) {
                    instance.logger?.warningLog(message: "\(NetworkRequestsManagerLogs.request.message), status code:\(statusCode)",
                                                category: NetworkRequestsManagerLogs.request.category,
                                                data: [Params.request: request,
                                                       Params.response: response])
                } else {
                    instance.logger?.verboseLog(message: "\(NetworkRequestsManagerLogs.request.message), status code:\(statusCode)",
                                                category: NetworkRequestsManagerLogs.request.category,
                                                data: [Params.request: request,
                                                       Params.response: response])
                }
            }
        }
        Sniffer.start()
    }
    
    static func shouldSendWarning(_ response: [String: Any]) -> Bool {
        var retValue = false
        if let isError = response[Params.error] as? Bool,
           isError == true {
            retValue = true
        }
        return retValue
    }
}
