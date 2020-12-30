//
//  QuickBrickXray.swift
//  QuickBrickXray
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

public class QuickBrickXray: NSObject, CrashlogsPluginProtocol, ZPAdapterProtocol, PluginAdapterProtocol {
    private(set) static var sharedInstance: QuickBrickXray?
    private(set) weak var loggerInstance: UITabBarController?

    let pluginNameSpace = "xray_logging_plugin"
    let sessionStorageObservationKey = "session_xray_logging_plugin"

    public var configurationJSON: NSDictionary?
    let configurationHelper: KeysHelper
    var currentSettings: Settings?

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

    lazy var isDebugEnvironment: Bool = {
        FacadeConnector.connector?.applicationData?.isDebugEnvironment() ?? true
    }()

    public func prepareProvider(_ defaultParams: [String: Any],
                                completion: ((Bool) -> Void)?) {
        addSessionStorageObserver()

        let emailsForShare = configurationHelper.emailsToShare()

        if isDebugEnvironment {
            let consoleSink = Console(logType: .print)
            if let formatter = consoleSink.formatter as? DefaultEventFormatter {
                formatter.skipContext = true
                formatter.skipData = true
                formatter.skipException = true
            }

            Xray.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.Console,
                                              sink: consoleSink)
        }

        let inMemorySink = InMemory()
        Xray.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.InMemorySink,
                                          sink: inMemorySink)

        let fileJSONSink = FileJSON()
        fileJSONSink.maxLogFileSizeInMB = configurationHelper.maxLogFileSizeInMB()
        Xray.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.FileJSON,
                                          sink: fileJSONSink)
        
        Reporter.setDefaultData(emails: emailsForShare,
                                logFileSinkDelegate: self,
                                contexts: [:])
        prepareSettings()
        QuickBrickXray.sharedInstance = self

        completion?(true)
    }

    func commitSettings() {
        var filter: SinkFilterProtocol? = DisabledSinkFilter()
        if let logLevel = currentSettings?.fileLogLevel {
            filter = DefaultSinkFilter(level: logLevel)
        }

        Xray.sharedInstance.setFilter(loggerSubsystem: "",
                                            sinkIdentifier: DefaultSinkIdentifiers.FileJSON,
                                            filter: filter)
        prepareShortcuts()
        prepareXRayFloatingButton()
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}

extension QuickBrickXray: StorableSinkDelegate {
    public func getLogFileUrl(_ completion: ((URL?) -> ())?) {
        guard let sink = Xray.sharedInstance.getSink(DefaultSinkIdentifiers.FileJSON) as? Storable else {
            completion?(nil)
            return
        }
        
        sink.generateLogsToSingleFileUrl(completion)
    }
    
    public func deleteLogFile() {
        guard let sink = Xray.sharedInstance.getSink(DefaultSinkIdentifiers.FileJSON) as? Storable else {
            return
        }
        
        sink.deleteSingleFileUrl()
    }
}

extension QuickBrickXray {
    func getTabBarViewController() -> UITabBarController? {
        let bundle = Bundle(for: Self.self)

        let storyboard = UIStoryboard(name: "QuickBrickXray", bundle: bundle)

        let viewController = storyboard.instantiateInitialViewController() as? UITabBarController

        return viewController
    }

    func presentLoggerView() {

        guard let viewController = getTabBarViewController() else {
            return
        }
        let presenter = UIApplication.shared.windows.first?.rootViewController
        if let oldLogger = loggerInstance {
            loggerInstance = viewController

            oldLogger.dismiss(animated: false) {
                presenter?.present(viewController,
                                   animated: true,
                                   completion: nil)
            }
        } else {
            loggerInstance = viewController
            presenter?.present(viewController,
                               animated: true,
                               completion: nil)
        }
    }
}
