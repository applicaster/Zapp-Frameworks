//
//  RootViewController.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/13/18.
//  Copyright © 2018 Anton Kononenko. All rights reserved.
//

import Reachability
import UIKit
import ZappCore

public class RootController: NSObject {
    public var appDelegate: AppDelegateProtocol?
    public var appReadyForUse: Bool = false

    // Properties for managing connectivity listeners
    lazy var connectivityListeners:NSMutableArray = []
    
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

    public override init() {
        super.init()
        if let userInterfaceLayer = UserInterfaceLayerManager.layerAdapter(launchOptions: appDelegate?.launchOptions) {
            self.userInterfaceLayer = userInterfaceLayer
        }

        splashViewController = UIApplication.shared.delegate?.window??.rootViewController as? SplashViewController

        reachabilityManager = ReachabilityManager(delegate: self)

        reloadApplication()
    }

    func reloadApplication() {
        appReadyForUse = false
        loadingStateMachine = LoadingStateMachine(dataSource: self,
                                                  withStates: preapreLoadingStates())
        loadingStateMachine.startStatesInvocation()
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
        DispatchQueue.main.async { [weak self] in
            guard let window = UIApplication.shared.delegate?.window else {
                return
            }
            window?.rootViewController = self?.userInterfaceLayerViewController
        }
    }

    func showErrorMessage(message: String) {
        makeSplashAsRootViewContoroller()
        // TODO: After will be added multi language support should be take from localization string
        splashViewController?.showErrorMessage(message)
    }
}
