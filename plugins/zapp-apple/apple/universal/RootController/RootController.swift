//
//  RootViewController.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/13/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Reachability
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
    var currentConnection: Reachability.Connection?

    var loadingStateMachine: LoadingStateMachine!
    public var userInterfaceLayer: UserInterfaceLayerProtocol?
    public var userInterfaceLayerViewController: UIViewController?

    public var pluginsManager = PluginsManager()
    public let audienceManager = TrackingManager()

    var splashViewController: SplashViewController?

    public lazy var facadeConnector: FacadeConnector = {
        FacadeConnector(connectorProvider: self)
    }()

    override public init() {
        super.init()
        reachabilityManager = ReachabilityManager(delegate: self)
    }

    public func reloadApplication() {
        appReadyForUse = false
        guard let userInterfaceLayer = UserInterfaceLayerManager.layerAdapter(launchOptions: appDelegate?.launchOptions) else {
            showErrorMessage(message: RootControllerError.canNotCreateInterfaceLayer)
            return
        }
        self.userInterfaceLayer = userInterfaceLayer
        splashViewController = UIApplication.shared.delegate?.window??.rootViewController as? SplashViewController
        pluginsManager.crashlogs.prepareManager { [weak self] success in
            guard let self = self else { return }
            if success {
                self.loadingStateMachine = LoadingStateMachine(dataSource: self,
                                                               withStates: self.preapreLoadingStates())
                self.loadingStateMachine.startStatesInvocation()
            } else {
                self.showErrorMessage(message: "Can not intialize application!")
            }
        }
    }

    func preapreLoadingStates() -> [LoadingState] {
        let splashState = LoadingState()
        splashState.stateHandler = loadApplicationLoadingGroup
        splashState.readableName = "<app-loader-state-machine> Show Splash Screen"

        let plugins = LoadingState()
        plugins.stateHandler = loadPluginsGroup
        plugins.readableName = "<app-loader-state-machine> Load plugins"

        let styles = LoadingState()
        styles.stateHandler = loadStylesGroup
        styles.readableName = "<app-loader-state-machine> Load Styles"

        // Dependant states
        let userInterfaceLayer = LoadingState()
        userInterfaceLayer.stateHandler = loadUserInterfaceLayerGroup
        userInterfaceLayer.readableName = "<app-loader-state-machine> Prepare User Interface Layer"

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
                audience,
                userInterfaceLayer,

                onApplicationReadyHook]
    }

    func makeSplashAsRootViewContoroller() {
        DispatchQueue.main.async { [weak self] in
            guard let window = UIApplication.shared.delegate?.window else {
                return
            }
            window?.rootViewController = self?.splashViewController
        }
    }

    func makeInterfaceLayerAsRootViewContoroller() {
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        window?.rootViewController = userInterfaceLayerViewController
    }

    func showErrorMessage(message: String) {
        makeSplashAsRootViewContoroller()
        // TODO: After will be added multi language support should be take from localization string
        splashViewController?.showErrorMessage(message)
    }
}
