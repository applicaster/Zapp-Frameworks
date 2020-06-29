//
//  ChromecastAdapter.swift
//  ZappChromecast
//
//  Created by Alex Zchut on 4/12/2020
//  Copyright © 2020 Applicaster. All rights reserved.
//

import Foundation
import GoogleCast
import ZappCore

open class ChromecastAdapter: NSObject {
    public var configurationJSON: NSDictionary?
    public var model: ZPPluginModel?
    public var enabled: Bool = false
    public var initialized: Bool = false

    public required init(pluginModel: ZPPluginModel) {
        model = pluginModel
        configurationJSON = model?.configurationJSON        
    }

    /// Plugin configuration keys
    struct PluginKeys {
        static let applicationID = "chromecast_app_id"
        static let posterUrl = "chromecast_poster"
        static let showMiniControls = "show_mini_controls"
    }

    var chromecastAppId:String? {
        guard let value = configurationJSON?[PluginKeys.applicationID] as? String,
            value.isEmpty == false else {
                return nil
        }
        return value
    }

    var pluginPosterURL:String? {
        guard let value = configurationJSON?[PluginKeys.posterUrl] as? String,
            value.isEmpty == false else {
                return nil
        }
        return value
    }

    var shouldShowMiniControls: Bool {
        var show = false
        if let stringValue = configurationJSON?[PluginKeys.showMiniControls] as? String {
            if let boolValue = Bool(stringValue) {
                show = boolValue
            }
            else if let intValue = Int(stringValue) {
                show = Bool(truncating: intValue as NSNumber)
            }
        } else if let boolValue = configurationJSON?[PluginKeys.showMiniControls] as? Bool {
            show = boolValue
        }

        return show
    }

    lazy var castViewExtender: ChromecastCustomDialogProtocol? = {
        var retVal:ChromecastCustomDialogProtocol?

//        let pluginModels = ZPPluginManager.pluginModels()?.filter { $0.pluginType == .General}
//
//        if let pluginModels = pluginModels {
//            for pluginModel in pluginModels {
//                if let classType = ZPPluginManager.adapterClass(pluginModel) as? ChromecastCustomDialogProtocol.Type,
//                    let provider = classType.init() as? (ChromecastCustomDialogProtocol) {
//                    retVal = provider
//                }
//            }
//        }
        return retVal
    }()


    // Where the icon was tapped from that lead to the CastDialog
    var localLastActiveChromecastButton: ChromecastButtonOrigin?

    // What the "Icon Location" was that the tap which lead to the casting came from.
    var localTriggeredChromecastButton: ChromecastButtonOrigin?

    var localContainerViewEventsDelegate: ChromecastNotificationsProtocol? {
        willSet {
            if newValue == nil  {
                self.uninstallMiniPlayerViewController()
            }
        }

        didSet {
            if localContainerViewEventsDelegate != nil  {
                self.updateVisibilityOfMiniPlayerViewController()
            }
        }
    }

    //private  properties
    var castMediaClient: GCKRemoteMediaClient?
    var castSession: GCKCastSession?
    var castButton: UIButton?

    var connectivityState: ConnectivityState = .cellular {
        didSet {
            updateCastButtonVisibility()
        }
    }
    var shouldPresentIntroductionScreen: Bool = false

    // The media object to play
    var mediaInfo: GCKMediaInformation?
    // casting starting callback
    var castDidStartMediaSession: ((_ success: Bool) -> Void)?

    //public properties
    open var miniMediaControlsViewController: GCKUIMiniMediaControlsViewController?

    deinit {
        // perform the deinitialization
        self.removeObservers()
    }

    @objc open func presentIntroductionScreenIfNeeded() {
        if getShouldPresentIntroductionScreen(),
            let castButton = self.castButton {
            presentCastInstructionsViewControllerOnce(with: castButton)
        }
    }

    func updateManagerState(enabled: Bool, initialized: Bool) {
        self.initialized = initialized
        self.enabled = enabled
    }
}
