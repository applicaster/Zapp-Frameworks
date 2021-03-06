//
//  RootViewController.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/13/18.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import UIKit
import XrayLogger
import ZappCore

struct RootControllerError {
    static let canNotCreateInterfaceLayer = "Can not create Interface Layer"
}

public class RootController: NSObject {
    lazy var logger = Logger.getLogger(for: RootControllerLogs.subsystem)

    public var appDelegate: AppDelegateProtocol?
    public var appReadyForUse: Bool = false

    // Properties for managing connectivity listeners
    lazy var connectivityListeners: NSMutableArray = []

    var reachabilityManager: ReachabilityManager?
    var currentConnection: ReachabilityState = .connected([.wifi])

    var loadingStateMachine: LoadingStateMachine!
    public var userInterfaceLayer: UserInterfaceLayerProtocol?
    public var userInterfaceLayerViewController: UIViewController?

    public var pluginsManager = PluginsManager()
    public let audienceManager = TrackingManager()
    public let loggerAssistance = LoggerAssistanceManager()
    var splashViewController: SplashViewController?

    public lazy var facadeConnector: FacadeConnector = {
        FacadeConnector(connectorProvider: self)
    }()

    override public init() {
        super.init()
        reachabilityManager = ReachabilityManager(delegate: self)
        logger?.debugLog(template: RootControllerLogs.rootControllerCreated)
    }

    public func reloadApplication() {
        appReadyForUse = false
        guard UserInterfaceLayerManager.canCreate() else {
            showErrorMessage(message: RootControllerError.canNotCreateInterfaceLayer)
            return
        }

        DispatchQueue.main.async { [self] in
            guard let window = UIApplication.shared.delegate?.window else {
                return
            }

            window?.makeKeyAndVisible()
            splashViewController = window?.rootViewController as? SplashViewController
            #if os(iOS)
                NetworkRequestsManager.startListening()
            #endif
            self.pluginsManager.crashlogs.prepareManager { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.loadingStateMachine = LoadingStateMachine(dataSource: self,
                                                                   withStates: self.prepareLoadingStates())
                    self.loadingStateMachine.startStatesInvocation()
                } else {
                    self.showErrorMessage(message: "Can not intialize application!")
                }
            }
        }
    }

    func prepareLoadingStates() -> [LoadingState] {
        let splashState = LoadingState()
        splashState.stateHandler = loadSplashScreenGroup
        splashState.readableName = "<app-loader-state-machine> Show Splash Screen"

        let remoteConfiguration = LoadingState()
        remoteConfiguration.stateHandler = loadRemoteConfigurationGroup
        remoteConfiguration.readableName = "<app-loader-state-machine> Load RemoteConfiguration"

        let pluginsRemoteConfiguration = LoadingState()
        pluginsRemoteConfiguration.stateHandler = loadPluginsRemoteConfigurationGroup
        pluginsRemoteConfiguration.readableName = "<app-loader-state-machine> Load Plugins Remote Configuration"

        let styles = LoadingState()
        styles.stateHandler = loadStylesGroup
        styles.readableName = "<app-loader-state-machine> Load Styles"

        // Dependant states

        let plugins = LoadingState()
        plugins.stateHandler = loadPluginsGroup
        plugins.readableName = "<app-loader-state-machine> Load plugins"
        plugins.dependantStates = [splashState.name,
                                   pluginsRemoteConfiguration.name,
                                   remoteConfiguration.name]
        
        let userInterfaceLayer = LoadingState()
        userInterfaceLayer.stateHandler = loadUserInterfaceLayerGroup
        userInterfaceLayer.readableName = "<app-loader-state-machine> Prepare User Interface Layer"
        userInterfaceLayer.dependantStates = [remoteConfiguration.name]

        let audience = LoadingState()
        audience.stateHandler = trackAudience
        audience.readableName = "<app-loader-state-machine> Track Audience"

        let onApplicationReadyHook = LoadingState()
        onApplicationReadyHook.stateHandler = hookOnApplicationReady
        onApplicationReadyHook.readableName = "<app-loader-state-machine> Execute Hook Plugin Applicatoion Ready to present"
        onApplicationReadyHook.dependantStates = [splashState.name,
                                                  plugins.name,
                                                  styles.name,
                                                  userInterfaceLayer.name,
        ]

        return [splashState,
                plugins,
                styles,
                remoteConfiguration,
                pluginsRemoteConfiguration,
                audience,
                userInterfaceLayer,
                onApplicationReadyHook]
    }

    func makeSplashAsRootViewContoroller() {
        DispatchQueue.main.async { [weak self] in
            UIApplication.shared.keyWindow?.rootViewController = self?.splashViewController
        }
    }

    func makeInterfaceLayerAsRootViewContoroller() {
        DispatchQueue.main.async { [weak self] in
            UIApplication.shared.keyWindow?.rootViewController = self?.userInterfaceLayerViewController
        }
    }

    func showErrorMessage(message: String) {
        makeSplashAsRootViewContoroller()
        // TODO: After will be added multi language support should be take from localization string
        splashViewController?.showErrorMessage(message)
    }
}
