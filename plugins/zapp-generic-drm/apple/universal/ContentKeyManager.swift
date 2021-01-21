/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The `ContentKeyManager` class configures the instance of `AVContentKeySession` to use for requesting content keys
 securely for playback or offline use.
 */

//  Adopted by Alex Zchut for plugin usage on 21/01/2021.

import AVFoundation
import XrayLogger

class ContentKeyManager {
    
    // MARK: Types.
    
    /// The singleton for `ContentKeyManager`.
    static let shared: ContentKeyManager = ContentKeyManager()
    
    // MARK: Properties.
    
    /// The instance of `AVContentKeySession` that is used for managing and preloading content keys.
    let contentKeySession: AVContentKeySession
    
    /**
     The instance of `ContentKeyDelegate` which conforms to `AVContentKeySessionDelegate` and is used to respond to content key requests from
     the `AVContentKeySession`
     */
    fileprivate let contentKeyDelegate: ContentKeyDelegate
    
    /// The DispatchQueue to use for delegate callbacks.
    fileprivate let contentKeyDelegateQueue = DispatchQueue(label: "com.applicaster.drm.ContentKeyDelegateQueue")
    
    // MARK: Initialization.
    
    private init() {
        contentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)
        contentKeyDelegate = ContentKeyDelegate()
        
        contentKeySession.setDelegate(contentKeyDelegate, queue: contentKeyDelegateQueue)
    }
    
    fileprivate var currentItemSource: [String: Any]?
    var configurationJSON: NSDictionary?
    var logger: Logger? {
        didSet {
            contentKeyDelegate.logger = logger
        }
    }
    
    func setCurrentItemSource(with params:  [String: Any]?) {
        currentItemSource = params
        
        guard let entry = params?[ItemParamsKeys.entry] as? [String: Any],
          let extensions = entry[ItemParamsKeys.extensions] as? [String: Any],
          let drm = extensions[ItemParamsKeys.drm] as? [String: Any],
          let fairplay = drm[ItemParamsKeys.fairplay] as? [String: Any] else {
            return
        }
        contentKeyDelegate.contentKeyRequestParams = createParams(from: fairplay)
    }
    
    func getParam(from value: String?, defaultValue: String?) -> String? {
        return value ?? defaultValue
    }

    func createParams(from dict: [String: Any]) -> ContentKeyRequestParams {
        let licenseServerRequestContentType = getParam(from: dict[ItemParamsKeys.licenseServerRequestContentType] as? String,
                                                       defaultValue: configurationJSON?[PluginKeys.licenseServerRequestContentType] as? String)
        let licenseServerRequestJsonObjectKey = getParam(from: dict[ItemParamsKeys.licenseServerRequestJsonObjectKey] as? String,
                                                         defaultValue: configurationJSON?[PluginKeys.licenseServerRequestJsonObjectKey] as? String)

        let certificateUrlString = getParam(from: dict[ItemParamsKeys.certificateUrl] as? String,
                                            defaultValue: configurationJSON?[PluginKeys.certificateUrl] as? String)

        let licenseServerUrlString = getParam(from: dict[ItemParamsKeys.licenseServerUrl] as? String,
                                              defaultValue: configurationJSON?[PluginKeys.licenseServerUrl] as? String)

        return ContentKeyRequestParams(certificateUrlString: certificateUrlString,
                                       licenseServerUrlString: licenseServerUrlString,
                                       licenseServerRequestContentType: licenseServerRequestContentType,
                                       licenseServerRequestJsonObjectKey: licenseServerRequestJsonObjectKey)
    }
}

struct ContentKeyRequestParams {
    var certificateUrlString: String?
    var licenseServerUrlString: String?
    var licenseServerRequestContentType: String?
    var licenseServerRequestJsonObjectKey: String?
}
