//
//  ReactNativeManager.swift
//  QuickBrickApple
//
//  Created by François Roland on 20/11/2018.
//  Copyright © 2018 Applicaster LTD. All rights reserved.
//


import UIKit
import React
import ZappCore
import XrayLogger

public let kQBModuleName = "QuickBrickApp"
public let suspendApp = "suspend"

/// React Native Manager class for Quick Brick
open class ReactNativeManager: NSObject, UserInterfaceLayerProtocol, UserInterfaceLayerDelegate  {
    lazy var logger = Logger.getLogger(for: ReactNativeManagerLogs.subsystem)

    public var applicationDelegate: UIApplicationDelegate?
    public var userNotificationCenterDelegate:UNUserNotificationCenterDelegate?
    
    static var applicationData:[String:Any] = [:]
    
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    var reactNativePackagerRoot:String?
    
    var completion:((_ viewController:UIViewController?, _ error:Error?) -> Void)?
    
    public required init(launchOptions: [UIApplication.LaunchOptionsKey : Any]?,
                         applicationData: [String : Any] = [:]) {
        super.init()
        self.launchOptions = launchOptions
        
        if let reactNativePackagerRoot = applicationData["reactNativePackagerRoot"] as? String {
            self.reactNativePackagerRoot = reactNativePackagerRoot
        }
        applicationDelegate = self
        userNotificationCenterDelegate = self
        
        ReactNativeManager.applicationData = applicationData
    }
    
    /// url of the react server
    private var jsBundleUrl: URL? {
        RCTBundleURLProvider.sharedSettings()?.jsLocation = reactNativePackagerRoot
        return RCTBundleURLProvider.sharedSettings()?.jsBundleURL(forBundleRoot: "index", fallbackResource: nil)
    }
    
    ///url of the react bundle file
    private let jsBundleFile = Bundle.main.url(forResource: "main", withExtension: "jsbundle")
    
    /// React root view
    private var reactRootView: RCTRootView?
    
    private var rootViewController:QuickBrickViewController?
    
    /**
     boolean flag used to indicate whether React should use the server url or the bundle file
     only rule currently is to use the server on Debug mode, and the bundle file otherwise
     */
    private var shouldUseReactServer: Bool {
        var retVal = false

        guard var reactNativePackagerRoot = reactNativePackagerRoot else {
            return retVal
        }
        
        if reactNativePackagerRoot.isIPv4 {
            reactNativePackagerRoot = "\(reactNativePackagerRoot):8081"
        }
        
        if reactNativePackagerRoot == "dev" ||
            reactNativePackagerRoot == "localhost" ||
            reactNativePackagerRoot == "localhost:8081" ||
            reactNativePackagerRoot.isIPv4WithPort {
            retVal = true
        }
        
        return retVal
    }
    
    public func prepareLayerForUse(completion:@escaping (_ viewController:UIViewController?, _ error:Error?) -> Void) {
        self.setRightToLeftFlag {
            self.mountReactApp(self.launchOptions)
            self.completion = completion
        }
    }
    
    /**
     Creates the react bridge and the react root view. At this point, React execution starts
     - Parameter launchOptions: launchOptions coming from AppDelegate which need to be passed to React
     */
    public func mountReactApp(_ launchOptions: [AnyHashable: Any]?) {
        logger?.debugLog(message: ReactNativeManagerLogs.mountingReactApp.message,
                         category: ReactNativeManagerLogs.mountingReactApp.category)
        
        guard let reactBridge = RCTBridge(
            delegate: self as (RCTBridgeDelegate & QuickBrickManagerDelegate),
            launchOptions: launchOptions
            ) else {
                logger?.errorLog(message: ReactNativeManagerLogs.noReactBridge.message,
                                 category: ReactNativeManagerLogs.noReactBridge.category,
                                 data: ["launchOptions": launchOptions as? [String:Any] ?? [:]])
                return
        }

        /// Check to remove warning form Dev environment
        /// https://github.com/facebook/react-native/issues/16376
        #if RCT_DEV
        reactBridge.module(for: RCTDevLoadingView.self)
        #endif
        
        DispatchQueue.main.async {
            self.reactRootView = RCTRootView(
                bridge: reactBridge,
                moduleName: kQBModuleName,
                initialProperties: nil)
        }
        
        reactRootView?.backgroundColor = UIColor.clear
    }
    
    public func reactNativeViewController() -> UIViewController {
        logger?.debugLog(message: ReactNativeManagerLogs.presentingReactViewController.message,
                         category: ReactNativeManagerLogs.presentingReactViewController.category)

        if rootViewController == nil {
            let quickBrickViewController = QuickBrickViewController()
            if let reactView = reactRootView {
                quickBrickViewController.view = reactView
                rootViewController = quickBrickViewController
            }
        }
        return rootViewController!
    }
}

extension ReactNativeManager: RCTBridgeDelegate {
    
    /**
     returns the url location of the react code
     - parameter bridge: RCTBridge instance used to launch react
     - returns: url of the react code (server or bundle file)
     */
    public func sourceURL(for bridge: RCTBridge?) -> URL? {
         // https://github.com/facebook/react-native/issues/21030#issuecomment-471344543
         if shouldUseReactServer {
             RCTBundleURLProvider.sharedSettings()?.jsLocation = jsBundleUrl?.host
             return jsBundleUrl
         }

         if let bundleFile = jsBundleFile {
             RCTBundleURLProvider.sharedSettings()?.jsLocation = jsBundleFile?.absoluteString

             return bundleFile
         }
         return nil
     }
}

extension ReactNativeManager: QuickBrickManagerDelegate {
    public func setQuickBrickReady() {
        completion?(reactNativeViewController(), nil)
        completion = nil
    }
    
    
    /// Force application to move to bakckground
    public func moveAppToBackground() {
        DispatchQueue.main.async {
            UIApplication.shared.perform(NSSelectorFromString(suspendApp))
        }
    }
    
    public func allowOrientationForScreen(_ payload: Dictionary<String, Any>) {
        if let qbViewController = self.reactNativeViewController() as? QuickBrickViewController, let orientation = payload["orientation"] as? Int {
            qbViewController.allowOrientationForScreen(orientation)
        }
    }

    /**
   invokes the event handler for a given event
   - parameter manager: instance of the native module on which the event handler should be invoked
   - parameter payload: dictionary of options to pass to the event handler
    */
    public func idleTimerDisabled(_ payload: Dictionary<String, Any>) {
        guard let disabled = payload["disabled"] as? Bool else {
            UIApplication.shared.isIdleTimerDisabled = false
            return 
        }
        UIApplication.shared.isIdleTimerDisabled = disabled
    }

    public func releaseOrientationForScreen() {
        if let qbViewController = self.reactNativeViewController() as? QuickBrickViewController {
            qbViewController.releaseOrientationForScreen()
        }
    }
    
}
