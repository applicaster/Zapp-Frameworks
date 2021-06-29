//
//  RootViewController+StateMachine.swift
//  ZappApple
//
//  Created by Anton Kononenko on 11/14/18.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//

import Foundation
import os.log
import ZappCore

extension RootController: LoadingStateMachineDataSource {
    func loadSplashScreenGroup(_ successHandler: @escaping StateCallBack,
                               _ failHandler: @escaping StateCallBack) {
        splashViewController?.startAppLoading(rootViewController: self, completion: {
            successHandler()
        })
    }

    func loadPluginsGroup(_ successHandler: @escaping StateCallBack,
                          _ failHandler: @escaping StateCallBack) {
        pluginsManager.intializePlugins { success in
            if success == true {
                successHandler()
            } else {
                failHandler()
            }
        }
    }

    func loadStylesGroup(_ successHandler: @escaping StateCallBack,
                         _ failHandler: @escaping StateCallBack) {
        let loadingManager = LoadingManager()
        loadingManager.loadFile(type: .styles) { success in
            if success == true {
                successHandler()
                StylesHelper.updateZappStyles()
            } else {
                failHandler()
            }
        }
    }
    
    func loadRemoteConfigurationGroup(_ successHandler: @escaping StateCallBack,
                         _ failHandler: @escaping StateCallBack) {
        let loadingManager = LoadingManager()
        loadingManager.loadFile(type: .remoteConfiguration) { success in
            if success == true {
                RemoteConfigurationHelper.update()
                successHandler()
            } else {
                failHandler()
            }
        }
    }
    
    func loadPluginsRemoteConfigurationGroup(_ successHandler: @escaping StateCallBack,
                         _ failHandler: @escaping StateCallBack) {
        let loadingManager = LoadingManager()
        loadingManager.loadFile(type: .plugins) { success in
            if success == true {
                successHandler()
            } else {
                failHandler()
            }
        }
    }

    func loadUserInterfaceLayerGroup(_ successHandler: @escaping StateCallBack,
                                     _ failHandler: @escaping StateCallBack) {
        
        guard let userInterfaceLayer = UserInterfaceLayerManager.layerAdapter(launchOptions: appDelegate?.launchOptions) else {
            failHandler()
            return
        }
        self.userInterfaceLayer = userInterfaceLayer

        userInterfaceLayer.prepareLayerForUse { [weak self] quickBrickViewController, error in
            if let quickBrickViewController = quickBrickViewController {
                quickBrickViewController.view.backgroundColor = StylesHelper.color(forKey: CoreStylesKeys.backgroundColor)
                self?.userInterfaceLayerViewController = quickBrickViewController
                successHandler()
            } else if let error = error {
                _ = OSLog(subsystem: error.localizedDescription,
                          category: stateMachineLogCategory)
                failHandler()
            }
        }
    }

    func trackAudience(_ successHandler: @escaping StateCallBack,
                       _ failHandler: @escaping StateCallBack) {
        audienceManager.track(for: TrackingManager.EventTypes.appPresented) { _ in }
        successHandler()
    }

    func hookOnApplicationReady(_ successHandler: @escaping StateCallBack,
                                _ failHandler: @escaping StateCallBack) {
        pluginsManager.hookOnApplicationReady(displayViewController: splashViewController,
                                              hooksPlugins: nil) {
            successHandler()
        }
    }

    public func stateMachineFinishedWork(with state: LoadingStateTypes) {
        if state == .success {
            appReadyForUse = true
            makeInterfaceLayerAsRootViewContoroller()

            let event = EventsBus.Event(type: EventsBusType(.analytics(.sendEvent)),
                                        source: logger?.subsystem,
                                        data: [
                                            "name": CoreAnalyticsKeys.applicationWasLaunched
                                        ])
            EventsBus.post(event)

            EventsBus.post(EventsBus.Event(type: EventsBusType(.msAppCenterCheckUpdates)))
            
            pluginsManager.hookAfterAppRootPresentation(hooksPlugins: nil,
                                                        completion: {})
            // Delay to provide time for QB present view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.appDelegate?.handleDelayedEventsIfNeeded()
            }

        } else {
            // TODO: After will be added multi language support should be take from localization string
            showErrorMessage(message: "Loading failed. Please try again later")
            pluginsManager.hookFailedLoading(hooksPlugins: nil,
                                             completion: {})
        }
    }
}
