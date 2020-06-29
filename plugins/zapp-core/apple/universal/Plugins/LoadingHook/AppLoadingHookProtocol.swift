//
//  AppLoadingHookProtocol.swift
//  ZappCore
//
//  Created by Anton Kononenko on 2/12/20.
//

import Foundation

@objc public protocol AppLoadingHookProtocol: PluginAdapterProtocol {
    /*
     Hook executed after State Machine Failed to Prepare the Application
     */
    @objc optional func executeOnFailedLoading(completion: (() -> Void)?)

    /*
     Hook executed after plugins finished preparation
     */
    @objc optional func executeOnLaunch(completion: (() -> Void)?)

    /*
     Hook executed when application ready to present UI Layer Plugin
     */
    @objc optional func executeOnApplicationReady(displayViewController: UIViewController?, completion: (() -> Void)?)

    /*
     Hook executed when UI Layer plugin finished presentation.
     */
    @objc optional func executeAfterAppRootPresentation(displayViewController: UIViewController?, completion: (() -> Void)?)

    /*
     Hook executed when the application:continueUserActivity:restorationHandler is called.
     */
    @objc optional func executeOnContinuingUserActivity(_ userActivity: NSUserActivity?,
                                                        completion: (() -> Void)?)
}
