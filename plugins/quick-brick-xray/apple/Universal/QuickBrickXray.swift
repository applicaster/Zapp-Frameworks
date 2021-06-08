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
    static let InMemoryNetworkRequestsSink = "InMemoryNetworkRequestsSink"
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
    let networkRequestsSubsystem = "\(kNativeSubsystemPath)/network_requests"

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
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)

        let emailsForShare = configurationHelper.emailsToShare()

        prepareConsoleSink()
        prepareFileJsonSink()
        prepareInMemorySink()
        prepareNetworkRequestSink()

        Reporter.setDefaultData(emails: emailsForShare,
                                logFileSinkDelegate: self)

        prepareSettings()
        QuickBrickXray.sharedInstance = self

        completion?(true)
    }

    @objc func appMovedToForeground() {
        if let currentSettings = currentSettings,
           currentSettings.isCustomSettingsExpired {
            applyCustomSettings(settings: currentSettings)
        }
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
    }

    func prepareConsoleSink() {
        if isDebugEnvironment {
            let consoleSink = Console(logType: .print)
            if let formatter = consoleSink.formatter as? DefaultEventFormatter {
                formatter.skipContext = true
                formatter.skipData = true
                formatter.skipException = true
            }

            Xray.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.Console,
                                        sink: consoleSink)
            addDisabledFilter(for: DefaultSinkIdentifiers.Console, subsystem: networkRequestsSubsystem)
        }
    }

    func prepareInMemorySink() {
        let inMemorySink = InMemory()
        Xray.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.InMemorySink,
                                    sink: inMemorySink)
    }

    func prepareFileJsonSink() {
        let fileJSONSink = FileJSON()
        fileJSONSink.maxLogFileSizeInMB = configurationHelper.maxLogFileSizeInMB()
        Xray.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.FileJSON,
                                    sink: fileJSONSink)
    }

    func prepareNetworkRequestSink() {
        let inMemoryNetworkRequestsSink = InMemory()
        Xray.sharedInstance.addSink(identifier: DefaultSinkIdentifiers.InMemoryNetworkRequestsSink,
                                    sink: inMemoryNetworkRequestsSink)
        let networkRequestsFilter = DefaultSinkFilter(level: .verbose)
        Xray.sharedInstance.setFilter(loggerSubsystem: networkRequestsSubsystem,
                                      sinkIdentifier: DefaultSinkIdentifiers.InMemoryNetworkRequestsSink,
                                      filter: networkRequestsFilter)
        addDisabledFilter(for: DefaultSinkIdentifiers.InMemoryNetworkRequestsSink, subsystem: "")
    }

    func addDisabledFilter(for sinkIdentifier: String, subsystem: String) {
        let disabledFilter = DisabledSinkFilter()
        Xray.sharedInstance.setFilter(loggerSubsystem: subsystem,
                                      sinkIdentifier: sinkIdentifier,
                                      filter: disabledFilter)
    }

    public func disable(completion: ((Bool) -> Void)?) {
        completion?(true)
    }
}

extension QuickBrickXray: StorableSinkDelegate {
    public func getDefaultContexts() -> [String: String]? {
        let na = "N/A"
        return [
            "App Name": FacadeConnector.connector?.storage?.sessionStorageValue(for: "app_name", namespace: nil) ?? na,
            "App Version": FacadeConnector.connector?.storage?.sessionStorageValue(for: "version_name", namespace: nil) ?? na,
            "App Version build": FacadeConnector.connector?.storage?.sessionStorageValue(for: "build_version", namespace: nil) ?? na,
            "Platform": FacadeConnector.connector?.storage?.sessionStorageValue(for: "platform", namespace: nil) ?? na,
            "OS Version": "\(UIDevice.current.systemVersion)",
            "Device Model": FacadeConnector.connector?.storage?.sessionStorageValue(for: "device_model", namespace: nil) ?? na,
            "Device Language": FacadeConnector.connector?.storage?.sessionStorageValue(for: "languageCode", namespace: nil) ?? na,
            "Device Locale": FacadeConnector.connector?.storage?.sessionStorageValue(for: "regionCode", namespace: nil) ?? na,
            "Device Country": FacadeConnector.connector?.storage?.sessionStorageValue(for: "country_code", namespace: nil) ?? na,
        ]
    }

    public func getLogFileUrl(_ completion: ((URL?) -> Void)?) {
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
        let presenter = UIApplication.shared.keyWindow?.rootViewController
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
