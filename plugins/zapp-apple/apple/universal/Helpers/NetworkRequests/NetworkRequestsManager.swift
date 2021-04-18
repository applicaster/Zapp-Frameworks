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
        Sniffer.ignore(extensions: ignoredExtensions)
        Sniffer.ignore(domains: ignoreDomains)
        Sniffer.onLogger = { (url: URL, logType: Sniffer.LogType, content: [String: Any]) in
            switch logType {
            case .request:
                instance.pendingRequests[url.absoluteString] = content
            case .response:
                let urlString = url.absoluteString
                guard urlString.isEmpty == false,
                      instance.pendingRequests.keys.contains(urlString),
                      let response = content[Params.response] as? [String: Any],
                      let statusCode = response[Params.statusCode] as? String else {
                    return
                }

                let request = instance.pendingRequests[urlString] ?? [:]
                instance.pendingRequests[urlString] = nil

                instance.logger?.verboseLog(message: "\(NetworkRequestsManagerLogs.request.message): \(url.host ?? "")",
                                            category: NetworkRequestsManagerLogs.request.category,
                                            data: [Params.request: request,
                                                   Params.response: response,
                                                   Params.statusCode: statusCode,
                                                   Params.url: urlString])
            }
        }
        Sniffer.start()
    }

    static var ignoredExtensions: [String] {
        let pluginNameSpace = "xray_logging_plugin"
        let key = "networkRequestsIgnoredExtensions"
        let defaultExtensions = ["png", "jpeg", "jpg", "ts"]
        guard let networkRequestsIgnoredExtensionsString = FacadeConnector.connector?.storage?.localStorageValue(for: key,
                                                                                                                 namespace: pluginNameSpace) else {
            _ = FacadeConnector.connector?.storage?.localStorageSetValue(for: key,
                                                                         value: defaultExtensions.joined(separator: ";"),
                                                                         namespace: pluginNameSpace)
            return defaultExtensions
        }
        return networkRequestsIgnoredExtensionsString.components(separatedBy: ";").filter({ !$0.isEmpty })
    }

    static var ignoreDomains: [String] {
        let pluginNameSpace = "xray_logging_plugin"
        let key = "networkRequestsIgnoredDomains"
        guard let networkRequestsIgnoredDomainsString = FacadeConnector.connector?.storage?.localStorageValue(for: key,
                                                                                                              namespace: pluginNameSpace) else {
            return []
        }
        return networkRequestsIgnoredDomainsString.components(separatedBy: ";").filter({ !$0.isEmpty })
    }
}
