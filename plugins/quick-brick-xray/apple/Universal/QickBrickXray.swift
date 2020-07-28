//
//  QickBrickXray.swift
//  QickBrickXray
//
//  Created by Anton Kononenko on 27/08/2020.
//  Copyright © 2020 Applicaster Ltd. All rights reserved.
//

import LoggerInfo
import Reporter
import UIKit
import XrayLogger
import ZappCore

struct DefaultSinkIdentifiers {
    static let Console = "Console"
    static let FileJSON = "FileJSON"
    static let InMemorySink = "InMemorySink"
}

enum ActionType {
    case presentLoggerView
    case shareLogs
}

public class QickBrickXray: NSObject, CrashlogsPluginProtocol, ZPAdapterProtocol {
    public var configurationJSON: NSDictionary?
    let configurationHelper: KeysHelper

    public required init(configurationJSON: NSDictionary?) {
        self.configurationJSON = configurationJSON
        configurationHelper = KeysHelper(configurationJSON: configurationJSON as? [String: Any] ?? [:])
    }

    override public required init() {
        configurationHelper = KeysHelper(configurationJSON: [:])
    }

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON
        configurationHelper = KeysHelper(configurationJSON: configurationJSON as? [String: Any] ?? [:])
    }

    public var model: ZPPluginModel?

    public var providerName: String {
        "Qick Brick Xray Plugin"
    }

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((Bool) -> Void)?) {
        XrayLogger.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.Console,
                                          sink: Console(logType: .print))

        let inMemorySink = InMemory()
        XrayLogger.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.InMemorySink,
                                          sink: inMemorySink)

        let fileJSONSink = FileJSON()
        XrayLogger.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.FileJSON,
                                          sink: fileJSONSink)

        var filter: SinkFilterProtocol? = DisabledSinkFilter()
        if let logLevel = configurationHelper.logLevel() {
            filter = DefaultSinkFilter(level: logLevel)
        }
        XrayLogger.sharedInstance.setFilter(loggerSubsystem: "",
                                            sinkIdentifier: DefaultSinkIdentifiers.FileJSON,
                                            filter: filter)
        let emailsForShare = configurationHelper.emailsToShare()
        Reporter.setDefaultData(emails: emailsForShare,
                                url: fileJSONSink.fileURL,
                                contexts: [:])
        preparePlatform()

        completion?(true)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }

    public func handlePluginURLScheme(with rootViewController: UIViewController?, url: URL) -> Bool {
        return callActionFromURL(with: rootViewController, url: url)
    }

    private func callActionFromURL(with rootViewController: UIViewController?, url: URL) -> Bool {
        guard let params = queryParams(url: url),
            let action = params["action"] as? String else {
            return false
        }
        if action == "loggerView" {
            let loggerNavController = LoggerNavigationController.loggerNavigationController()
            let presenter = rootViewController ?? UIApplication.shared.windows.first?.rootViewController
            presenter?.present(loggerNavController,
                               animated: true,
                               completion: nil)
            return true
        } else if action == "shareLogs" {
            Reporter.requestSendEmail()
            return true
        }
        return false
    }

    private func queryParams(url: URL) -> [String: Any]? {
        guard let components = URLComponents(url: url,
                                             resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value
        }
    }
}
